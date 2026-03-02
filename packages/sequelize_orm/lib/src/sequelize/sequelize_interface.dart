import 'package:sequelize_orm/sequelize_orm.dart';

abstract class SequelizeInterface {
  /// Creates a Sequelize instance with the given connection configuration.
  ///
  /// The [connection] parameter specifies the database connection options.
  /// The [logging] parameter is an optional callback for SQL query logging.
  ///
  /// Example:
  /// ```dart
  /// final sequelize = Sequelize().createInstance(
  ///   connection: SequelizeConnection.postgres(url: 'postgresql://...'),
  ///   logging: (sql) => print(sql),
  /// );
  /// ```
  SequelizeInterface createInstance({
    required SequelizeCoreOptions connection,
    Function(String sql)? logging,
    SequelizePoolOptions? pool,
    bool debug = false,
    bool normalizeJsonTypes = true,
  });

  Future<void> authenticate();

  /// Initialize Sequelize with models
  ///
  /// This method properly sequences the initialization:
  /// 1. Waits for bridge connection
  /// 2. Defines all models in the bridge (awaited)
  /// 3. Sets up all associations (awaited)
  Future<void> initialize({required List<Model> models});

  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  );

  void addModels(List<Model> models);

  /// Synchronize all models in the database.
  ///
  /// If [force] is true, tables will be dropped and recreated.
  /// If [alter] is true, tables will be altered to match the model definition.
  Future<void> sync({bool force = false, bool alter = false});

  /// Starts a managed transaction.
  ///
  /// The transaction will be automatically committed if the callback completes successfully,
  /// or rolled back if an error occurs.
  ///
  /// The transaction is automatically accessible via [Transaction.current] within the callback
  /// and its descendants, enabling automatic transaction inheritance.
  ///
  /// Example:
  /// ```dart
  /// final user = await sequelize.transaction((t) async {
  ///   // Transaction t is automatically used here
  ///   return await User.create({'name': 'John'});
  /// });
  /// ```
  Future<T> transaction<T>(
    Future<T> Function(Transaction transaction) callback,
  );

  /// Starts an unmanaged transaction.
  ///
  /// You must manually call `commit()` or `rollback()` on the returned [Transaction] object.
  ///
  /// Unmanaged transactions do **not** support automatic inheritance via [Transaction.current].
  /// You must pass the transaction explicitly to all model methods.
  ///
  /// Example:
  /// ```dart
  /// final transaction = await sequelize.startUnmanagedTransaction();
  /// try {
  ///   await User.create({'name': 'John'}, transaction: transaction);
  ///   await transaction.commit();
  /// } catch (e) {
  ///   await transaction.rollback();
  ///   rethrow;
  /// }
  /// ```
  Future<Transaction> startUnmanagedTransaction();

  Future<void> close();

  /// Registers a query engine for this sequelize instance.
  ///
  /// When [useBridge] is false, initialization and associations run in
  /// bridge-less mode and all query calls route to the registered engine.
  void setQueryEngine(
    QueryEngineInterface engine, {
    bool useBridge = true,
  });

  /// Resolves the active query engine for this sequelize instance.
  QueryEngineInterface resolveQueryEngine();

  /// Whether this sequelize instance currently uses the JS bridge.
  bool get usesBridgeQueryEngine;

  /// Registers association metadata for runtime consumers (e.g. Mongo lookup translation).
  void registerAssociationDefinition({
    required String sourceModel,
    required String associationName,
    required String targetModel,
    required String associationType,
    String? foreignKey,
    String? sourceKey,
    String? targetKey,
  });

  /// Looks up association metadata by source model and association name.
  Map<String, dynamic>? getAssociationDefinition({
    required String sourceModel,
    required String associationName,
  });

  /// Returns known primary keys for a model.
  List<String> getModelPrimaryKeys(String modelName);

  /// Returns a read-only snapshot of the configured connection options.
  Map<String, dynamic>? get connectionConfig;

  /// Whether debug logging is enabled.
  bool get debug;

  /// Log a message using the configured logging function.
  void log(String message);
}
