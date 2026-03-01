// ignore_for_file: avoid_print

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm/src/bridge/bridge_client.dart';
import 'package:sequelize_orm/src/sequelize/sequelize_interface.dart';

/// Unified Sequelize implementation for both Dart VM and dart2js.
/// Both platforms now use the bridge pattern (stdio for VM, Worker Thread for JS).
///
/// {@category Get Started}
class Sequelize extends SequelizeInterface {
  final BridgeClient _bridge = BridgeClient.instance;
  final Map<String, Model> _models = {};
  final Map<String, Map<String, dynamic>> _associationDefinitions = {};
  Map<String, dynamic>? _connectionConfig;
  Function(String message)? _logging;
  bool _debug = false;
  QueryEngineInterface? _queryEngine;
  bool _usesBridgeQueryEngine = true;

  @override
  bool get debug => _debug;

  @override
  Future<void> authenticate() async {
    if (_bridge.isInitializing) {
      await _bridge.waitForInitialization();
    }

    if (!_bridge.isConnected) {
      throw Exception('Not connected to database. Call createInstance first.');
    }
  }

  @override
  Sequelize createInstance({
    required SequelizeCoreOptions connection,
    Function(String sql)? logging,
    SequelizePoolOptions? pool,
    bool debug = false,
    bool normalizeJsonTypes = true,
  }) {
    _debug = debug;

    final Map<String, dynamic> config = Map<String, dynamic>.from(
      connection.toJson(),
    );

    // Pass normalizeJsonTypes to the bridge so JSON/JSONB types are
    // automatically converted based on the dialect (e.g. JSON -> JSONB on
    // PostgreSQL, JSONB -> JSON on MySQL).
    config['normalizeJsonTypes'] = normalizeJsonTypes;

    // Store the logging callback in the bridge client
    if (logging != null) {
      _logging = logging;
      _bridge.setLoggingCallback(logging);
    }

    // Remove logging function (can't serialize) - just send boolean
    final hasLogging = logging != null;
    config.remove('logging');
    config.addEntries([MapEntry('logging', hasLogging)]);

    // Handle pool options
    if (pool != null) {
      config['pool'] = pool.toJson();
    }

    // If URL is provided, remove individual connection parameters
    if (connection.url != null && connection.url!.isNotEmpty) {
      final isMongoDialect = config['dialect'] == 'mongo';
      final keysToRemove = [
        'host',
        'password',
        'user',
        'port',
        'schema',
      ];
      if (!isMongoDialect) {
        keysToRemove.add('database');
      }
      config.removeWhere((key, value) => keysToRemove.contains(key));
    }

    _connectionConfig = config;
    return this;
  }

  /// Initialize Sequelize with models
  ///
  /// Start up and connect to the database, define all models, and set up all associations.
  @override
  Future<void> initialize({required List<Model> models}) async {
    if (_connectionConfig == null) {
      throw Exception(
        'Connection config not set. Call createInstance() first.',
      );
    }
    _associationDefinitions.clear();

    if (_usesBridgeQueryEngine) {
      await _bridge.start(connectionConfig: _connectionConfig!);
    }

    if (_debug) log('[Sequelize] Defining ${models.length} models...');
    for (final model in models) {
      if (_debug) log('>> Defining model: ${model.modelName}');
      model.define(model.modelName, this);
      _models[model.modelName] = model;
      model.sequelizeModel = {
        'name': model.modelName,
        'options': model.getOptionsJson(),
        'attributes': model.$getAttributesJson(),
      };

      if (_usesBridgeQueryEngine) {
        final response = await _bridge.call('defineModel', {
          'name': model.modelName,
          'attributes': model.$getAttributesJson(),
          'options': model.getOptionsJson(),
        });

        // Store primary keys from response
        final primaryKeys = response['primaryKeys'] as List?;
        if (primaryKeys != null) {
          model.primaryKeys = primaryKeys.cast<String>();
        }
      } else {
        model.primaryKeys = _derivePrimaryKeys(model);
      }
    }
    // print('[Sequelize] All models defined.');

    if (_debug) log('[Sequelize] Setting up associations...');
    for (final model in models) {
      // if (_debug) log('>> Setting up associations for model: ${model.name}');
      await model.associateModel(debug: _debug);
    }

    final engine = resolveQueryEngine();
    if (engine is QueryEngineLifecycle) {
      await (engine as QueryEngineLifecycle).onInitialize();
    }
  }

  @override
  void addModels(List<Model> models) {
    for (final model in models) {
      model.define(model.modelName, this);
      _models[model.modelName] = model;
      model.sequelizeModel = {
        'name': model.modelName,
        'options': model.getOptionsJson(),
        'attributes': model.$getAttributesJson(),
      };
      model.primaryKeys = _derivePrimaryKeys(model);

      if (_usesBridgeQueryEngine) {
        _bridge.call('defineModel', {
          'name': model.modelName,
          'attributes': model.$getAttributesJson(),
          'options': model.getOptionsJson(),
        }).catchError((error) {
          print(
            '[Sequelize] Failed to define model "${model.modelName}": $error',
          );
        });
      }
    }
  }

  @override
  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  ) {
    if (!_usesBridgeQueryEngine) {
      return;
    }

    if (!_bridge.isConnected) {
      throw Exception(
        'Bridge not connected. Ensure createInstance() has completed.',
      );
    }

    _bridge.call('defineModel', {
      'name': name,
      'attributes': attributes,
      'options': options,
    }).catchError((error) {
      print('[Sequelize] Failed to define model "$name": $error');
    });
  }

  /// Get the bridge client (for QueryEngine and Model)
  BridgeClient get bridge => _bridge;

  /// Get a registered model by name
  Model? getModel(String name) => _models[name];

  List<String> _derivePrimaryKeys(Model model) {
    final keys = model.$getAttributes()
        .where((attr) => attr.primaryKey == true)
        .map((attr) => attr.name)
        .toList(growable: false);
    return keys;
  }

  @override
  Future<void> sync({bool force = false, bool alter = false}) async {
    if (!_usesBridgeQueryEngine) {
      return;
    }
    await _bridge.call('sync', {
      'force': force,
      'alter': alter,
    });
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction transaction) callback,
  ) async {
    final response = await _bridge.call('startTransaction', {});
    final transactionId = response['transactionId'] as String;
    final transaction = Transaction(transactionId, _bridge);

    try {
      final result = await transaction.scope(() => callback(transaction));
      if (!transaction.isFinished) {
        await transaction.commit();
      }
      return result;
    } catch (e) {
      if (!transaction.isFinished) {
        try {
          await transaction.rollback();
        } catch (rollbackError) {
          // Ignore rollback errors if we're already failing
          if (_debug) log('[Sequelize] Rollback failed: $rollbackError');
        }
      }
      rethrow;
    }
  }

  @override
  Future<Transaction> startUnmanagedTransaction() async {
    final response = await _bridge.call('startTransaction', {});
    final transactionId = response['transactionId'] as String;
    return Transaction(transactionId, _bridge);
  }

  @override
  Future<void> close() async {
    final engine = resolveQueryEngine();
    if (engine is QueryEngineLifecycle) {
      await (engine as QueryEngineLifecycle).onClose();
    }
    QueryEngineRegistry.unregisterForSequelize(this);
    if (_usesBridgeQueryEngine && _bridge.isConnected) {
      await _bridge.close();
    }
  }

  @override
  void setQueryEngine(
    QueryEngineInterface engine, {
    bool useBridge = true,
  }) {
    _queryEngine = engine;
    _usesBridgeQueryEngine = useBridge;
    QueryEngineRegistry.registerForSequelize(this, engine);
  }

  @override
  QueryEngineInterface resolveQueryEngine() {
    return _queryEngine ?? QueryEngineRegistry.defaultEngine;
  }

  @override
  bool get usesBridgeQueryEngine => _usesBridgeQueryEngine;

  @override
  void registerAssociationDefinition({
    required String sourceModel,
    required String associationName,
    required String targetModel,
    required String associationType,
    String? foreignKey,
    String? sourceKey,
    String? targetKey,
  }) {
    _associationDefinitions['$sourceModel.$associationName'] = {
      'sourceModel': sourceModel,
      'associationName': associationName,
      'targetModel': targetModel,
      'associationType': associationType,
      if (foreignKey != null) 'foreignKey': foreignKey,
      if (sourceKey != null) 'sourceKey': sourceKey,
      if (targetKey != null) 'targetKey': targetKey,
    };
  }

  @override
  Map<String, dynamic>? getAssociationDefinition({
    required String sourceModel,
    required String associationName,
  }) {
    final map = _associationDefinitions['$sourceModel.$associationName'];
    if (map == null) {
      return null;
    }
    return Map<String, dynamic>.from(map);
  }

  @override
  List<String> getModelPrimaryKeys(String modelName) {
    return List<String>.from(_models[modelName]?.primaryKeys ?? const []);
  }

  @override
  Map<String, dynamic>? get connectionConfig => _connectionConfig == null
      ? null
      : Map<String, dynamic>.from(_connectionConfig!);

  /// Truncate all models registered in this instance.
  /// This is done by calling Model.truncate on each model.
  ///
  /// __Danger__: This will completely empty all your tables!
  Future<void> truncate({
    bool? cascade,
    bool? restartIdentity,
    bool? withoutForeignKeyChecks,
  }) async {
    final options = <String, dynamic>{
      if (cascade != null) 'cascade': cascade,
      if (restartIdentity != null) 'restartIdentity': restartIdentity,
      if (withoutForeignKeyChecks != null)
        'withoutForeignKeyChecks': withoutForeignKeyChecks,
    };
    await _bridge.call('sequelizeTruncate', {'options': options});
  }

  /// A slower alternative to truncate that uses DELETE FROM instead of TRUNCATE,
  /// but which works with foreign key constraints in dialects that don't support
  /// TRUNCATE CASCADE (postgres), or temporarily disabling foreign key constraints
  /// (mysql, mariadb, sqlite).
  Future<void> destroyAll({
    bool? force,
    bool? individualHooks,
  }) async {
    final options = <String, dynamic>{
      if (force != null) 'force': force,
      if (individualHooks != null) 'individualHooks': individualHooks,
    };
    await _bridge.call('sequelizeDestroyAll', {'options': options});
  }

  // --- SQL Expression Builders ---

  static SqlFn fn(String fn, [dynamic args]) {
    if (args == null) return SqlFn(fn);
    if (args is List) return SqlFn(fn, args);
    return SqlFn(fn, [args]);
  }

  static SqlCol col(String col) => SqlCol(col);
  static SqlLiteral literal(String val) => SqlLiteral(val);
  static SqlAttribute attribute(String attr) => SqlAttribute(attr);
  static SqlIdentifier identifier(String id) => SqlIdentifier(id);
  static SqlCast cast(dynamic expr, String type) => SqlCast(expr, type);
  static SqlRandom random() => SqlRandom();

  @override
  void log(String message) {
    if (_logging != null) {
      _logging!(message);
    }
  }
}
