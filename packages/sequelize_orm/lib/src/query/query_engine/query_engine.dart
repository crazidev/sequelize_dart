import 'package:sequelize_orm/src/model/model_instance_data.dart';
import 'package:sequelize_orm/src/query/query/query.dart';
import 'package:sequelize_orm/src/query/query_engine/query_engine_impl.dart';
import 'package:sequelize_orm/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_orm/src/transaction/transaction.dart';

export 'query_engine_impl.dart' show BridgeQueryEngine;
export 'query_engine_interface.dart';

/// Registry for resolving query engines per sequelize instance.
class QueryEngineRegistry {
  QueryEngineRegistry._();

  static final Expando<QueryEngineInterface> _instanceEngines =
      Expando<QueryEngineInterface>('queryEngineBySequelize');

  static QueryEngineInterface _defaultEngine = BridgeQueryEngine();

  static QueryEngineInterface get defaultEngine => _defaultEngine;

  static set defaultEngine(QueryEngineInterface engine) {
    _defaultEngine = engine;
  }

  static void registerForSequelize(
    Object sequelize,
    QueryEngineInterface engine,
  ) {
    _instanceEngines[sequelize] = engine;
  }

  static void unregisterForSequelize(Object sequelize) {
    _instanceEngines[sequelize] = null;
  }

  static QueryEngineInterface resolve(dynamic sequelize) {
    if (sequelize is Object) {
      final bound = _instanceEngines[sequelize];
      if (bound != null) {
        return bound;
      }
    }
    return _defaultEngine;
  }
}

/// QueryEngine facade that dispatches to an engine registered for the active
/// sequelize instance, falling back to the bridge SQL engine by default.
class QueryEngine extends QueryEngineInterface {
  QueryEngineInterface _engineFor(dynamic sequelize) {
    return QueryEngineRegistry.resolve(sequelize);
  }

  @override
  Future<List<ModelInstanceData>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).findAll(
      modelName: modelName,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<ModelInstanceData?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).findOne(
      modelName: modelName,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<ModelInstanceData> create({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).create(
      modelName: modelName,
      data: data,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<List<ModelInstanceData>> bulkCreate({
    required String modelName,
    required List<Map<String, dynamic>> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).bulkCreate(
      modelName: modelName,
      data: data,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<int> update({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).update(
      modelName: modelName,
      data: data,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).count(
      modelName: modelName,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).max(
      modelName: modelName,
      column: column,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).min(
      modelName: modelName,
      column: column,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).sum(
      modelName: modelName,
      column: column,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<List<ModelInstanceData>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).increment(
      modelName: modelName,
      fields: fields,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<List<ModelInstanceData>> decrement({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).decrement(
      modelName: modelName,
      fields: fields,
      query: query,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<ModelInstanceData> save({
    required String modelName,
    required Map<String, dynamic> currentData,
    Map<String, dynamic>? previousData,
    required Map<String, dynamic> primaryKeyValues,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).save(
      modelName: modelName,
      currentData: currentData,
      previousData: previousData,
      primaryKeyValues: primaryKeyValues,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<ModelInstanceData?> belongsToGet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).belongsToGet(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> belongsToSet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required dynamic targetOrKey,
    bool? save,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).belongsToSet(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      targetOrKey: targetOrKey,
      save: save,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<ModelInstanceData> belongsToCreate({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required Map<String, dynamic> data,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).belongsToCreate(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      data: data,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<int> destroy({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).destroy(
      modelName: modelName,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> truncate({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).truncate(
      modelName: modelName,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> restore({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).restore(
      modelName: modelName,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> instanceDestroy({
    required String modelName,
    required Map<String, dynamic> primaryKeyValues,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).instanceDestroy(
      modelName: modelName,
      primaryKeyValues: primaryKeyValues,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> instanceRestore({
    required String modelName,
    required Map<String, dynamic> primaryKeyValues,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).instanceRestore(
      modelName: modelName,
      primaryKeyValues: primaryKeyValues,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future associationGet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).associationGet(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> associationSet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required dynamic targetOrKey,
    bool? save,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).associationSet(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      targetOrKey: targetOrKey,
      save: save,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> associationAdd({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required dynamic targetOrKey,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).associationAdd(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      targetOrKey: targetOrKey,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<void> associationRemove({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required dynamic targetOrKey,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).associationRemove(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      targetOrKey: targetOrKey,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }

  @override
  Future<ModelInstanceData> associationCreate({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required Map<String, dynamic> data,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) {
    return _engineFor(sequelize).associationCreate(
      sourceModel: sourceModel,
      primaryKeyValues: primaryKeyValues,
      associationName: associationName,
      data: data,
      options: options,
      sequelize: sequelize,
      model: model,
      transaction: transaction,
    );
  }
}
