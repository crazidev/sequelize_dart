import 'package:sequelize_orm/src/bridge/bridge_client.dart';
import 'package:sequelize_orm/src/bridge/sequelize_exceptions.dart';
import 'package:sequelize_orm/src/model/model_instance_data.dart';
import 'package:sequelize_orm/src/query/query/query.dart';
import 'package:sequelize_orm/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_orm/src/sequelize/sequelize.dart';
import 'package:sequelize_orm/src/transaction/transaction.dart';

/// Deeply converts a value from JS types (JsLinkedHashMap) to Dart types.
/// This is needed for dart2js where dartify() returns JsLinkedHashMap.
/// In Dart VM, this is essentially a no-op but ensures type safety.
dynamic _deepConvert(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.fromEntries(
      value.entries.map(
        (e) => MapEntry(e.key.toString(), _deepConvert(e.value)),
      ),
    );
  } else if (value is List) {
    return value.map((e) => _deepConvert(e)).toList();
  }
  return value;
}

/// Converts a bridge response to ModelInstanceData
ModelInstanceData _toModelInstanceData(dynamic item) {
  final converted = _deepConvert(item) as Map<String, dynamic>;
  return ModelInstanceData.fromBridgeResponse(converted);
}

/// Unified QueryEngine implementation for both Dart VM and dart2js.
/// Both platforms use the bridge pattern for database operations.
class BridgeQueryEngine extends QueryEngineInterface {
  BridgeClient getBridge(dynamic sequelize) {
    if (sequelize == null) {
      throw Exception('Sequelize instance is required');
    }

    if (sequelize is! Sequelize) {
      throw Exception('Invalid Sequelize instance type');
    }

    final bridge = sequelize.bridge;

    if (!bridge.isConnected) {
      throw Exception('Bridge is not connected');
    }

    return bridge;
  }

  Transaction? _resolveTransaction(Transaction? transaction) {
    final tx = transaction ?? Transaction.current;
    if (tx != null && tx.isFinished) {
      throw SequelizeException(
        'Transaction cannot be used because it has already been committed or rolled back.',
        context: 'QueryEngine',
      );
    }
    return tx;
  }

  @override
  Future<List<ModelInstanceData>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('findAll', {
        'model': modelName,
        'options': options,
      });

      if (result is List) {
        return result.map(_toModelInstanceData).toList();
      }

      throw Exception('Invalid response format from bridge');
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute findAll()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute findAll()',
        stack: StackTrace.current.toString(),
      );
    }
  }

  @override
  Future<ModelInstanceData?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('findOne', {
        'model': modelName,
        'options': options,
      });

      if (result == null) return null;
      return _toModelInstanceData(result);
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute findOne()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute findOne()',
      );
    }
  }

  @override
  Future<ModelInstanceData> create({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('create', {
        'model': modelName,
        'data': data,
        'options': options,
      });

      // Handle both single result and array result
      if (result is List && result.isNotEmpty) {
        return _toModelInstanceData(result.first);
      }

      return _toModelInstanceData(result);
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute create()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute create()',
      );
    }
  }

  @override
  Future<List<ModelInstanceData>> bulkCreate({
    required String modelName,
    required List<Map<String, dynamic>> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('create', {
        'model': modelName,
        'data': data,
        'options': options,
      });

      if (result is List) {
        return result.map(_toModelInstanceData).toList();
      }

      throw Exception('Invalid response format from bridge');
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute bulkCreate()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute bulkCreate()',
      );
    }
  }

  @override
  Future<int> update({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('update', {
        'model': modelName,
        'data': data,
        'query': options,
      });

      if (result is int) return result;
      if (result is num) return result.toInt();

      throw Exception(
        'Invalid response format: expected int, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute update()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute update()',
      );
    }
  }

  @override
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('count', {
        'model': modelName,
        'options': options,
      });

      if (result is int) return result;
      if (result is num) return result.toInt();

      throw Exception(
        'Invalid response format: expected int, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute count()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute count()',
      );
    }
  }

  @override
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('max', {
        'model': modelName,
        'column': column,
        'options': options,
      });

      if (result == null) return null;
      if (result is num) return result;

      throw Exception(
        'Invalid response format: expected num, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute max()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute max()',
      );
    }
  }

  @override
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('min', {
        'model': modelName,
        'column': column,
        'options': options,
      });

      if (result == null) return null;
      if (result is num) return result;

      throw Exception(
        'Invalid response format: expected num, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute min()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute min()',
      );
    }
  }

  @override
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call('sum', {
        'model': modelName,
        'column': column,
        'options': options,
      });

      if (result == null) return null;
      if (result is num) return result;

      throw Exception(
        'Invalid response format: expected num, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute sum()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute sum()',
      );
    }
  }

  @override
  Future<List<ModelInstanceData>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    return _executeNumericOperation(
      modelName: modelName,
      fields: fields,
      query: query,
      sequelize: sequelize,
      operation: 'increment',
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
  }) async {
    return _executeNumericOperation(
      modelName: modelName,
      fields: fields,
      query: query,
      sequelize: sequelize,
      operation: 'decrement',
      transaction: transaction,
    );
  }

  Future<List<ModelInstanceData>> _executeNumericOperation({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    required String operation,
    Transaction? transaction,
  }) async {
    try {
      final options = query?.toJson() ?? {};
      final tx = _resolveTransaction(transaction);
      if (tx != null) {
        options['transactionId'] = tx.transactionId;
      }

      final result = await getBridge(sequelize).call(operation, {
        'model': modelName,
        'fields': fields,
        'query': options,
      });

      if (result is List) {
        return result.map(_toModelInstanceData).toList();
      }
      return [];
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute $operation()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute $operation()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      final result = await getBridge(sequelize).call('save', {
        'model': modelName,
        'currentData': currentData,
        'previousData': previousData,
        'primaryKeyValues': primaryKeyValues,
        'options': {'transactionId': tx?.transactionId},
      });

      if (result is Map) {
        final converted = _deepConvert(result) as Map<String, dynamic>;
        final data = converted['data'] as Map<String, dynamic>?;
        if (data != null) {
          return ModelInstanceData.fromBridgeResponse({'data': data});
        }
      }

      throw Exception(
        'Invalid response format: expected Map with data, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute save()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute save()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      final result = await getBridge(sequelize).call('belongsToGet', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
      if (result == null) return null;
      return _toModelInstanceData(result);
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute belongsToGet()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute belongsToGet()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('belongsToSet', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'targetOrKey': targetOrKey,
        'save': save,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute belongsToSet()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute belongsToSet()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      final result = await getBridge(sequelize).call('belongsToCreate', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'data': data,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
      return _toModelInstanceData(result);
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext(
          'Exception: failed to execute belongsToCreate()',
        );
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute belongsToCreate()',
      );
    }
  }

  @override
  Future<int> destroy({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      final result = await getBridge(sequelize).call('destroy', {
        'model': modelName,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });

      if (result is int) return result;
      if (result is num) return result.toInt();

      throw Exception(
        'Invalid response format: expected int, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute destroy()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute destroy()',
      );
    }
  }

  @override
  Future<void> truncate({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('truncate', {
        'model': modelName,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute truncate()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute truncate()',
      );
    }
  }

  @override
  Future<void> restore({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('restore', {
        'model': modelName,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext('Exception: failed to execute restore()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute restore()',
      );
    }
  }

  @override
  Future<void> instanceDestroy({
    required String modelName,
    required Map<String, dynamic> primaryKeyValues,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('instanceDestroy', {
        'model': modelName,
        'primaryKeyValues': primaryKeyValues,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext(
          'Exception: failed to execute instanceDestroy()',
        );
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute instanceDestroy()',
      );
    }
  }

  @override
  Future<void> instanceRestore({
    required String modelName,
    required Map<String, dynamic> primaryKeyValues,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('instanceRestore', {
        'model': modelName,
        'primaryKeyValues': primaryKeyValues,
        'options': {
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext(
          'Exception: failed to execute instanceRestore()',
        );
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute instanceRestore()',
      );
    }
  }

  @override
  Future<dynamic> associationGet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      final result = await getBridge(sequelize).call('associationGet', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
      if (result == null) return null;
      if (result is List) return result.map(_toModelInstanceData).toList();
      return _toModelInstanceData(result);
    } catch (e) {
      if (e is SequelizeException) {
        throw e
            .copyWithContext('Exception: failed to execute associationGet()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute associationGet()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('associationSet', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'targetOrKey': targetOrKey,
        'save': save,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e
            .copyWithContext('Exception: failed to execute associationSet()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute associationSet()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('associationAdd', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'targetOrKey': targetOrKey,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e
            .copyWithContext('Exception: failed to execute associationAdd()');
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute associationAdd()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      await getBridge(sequelize).call('associationRemove', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'targetOrKey': targetOrKey,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext(
          'Exception: failed to execute associationRemove()',
        );
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute associationRemove()',
      );
    }
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
  }) async {
    try {
      final tx = _resolveTransaction(transaction);
      final result = await getBridge(sequelize).call('associationCreate', {
        'sourceModel': sourceModel,
        'primaryKeyValues': primaryKeyValues,
        'associationName': associationName,
        'data': data,
        'options': {
          if (options != null) ...options,
          if (tx != null) 'transactionId': tx.transactionId,
        },
      });
      return _toModelInstanceData(result);
    } catch (e) {
      if (e is SequelizeException) {
        throw e.copyWithContext(
          'Exception: failed to execute associationCreate()',
        );
      }
      throw SequelizeException(
        e.toString(),
        context: 'Exception: failed to execute associationCreate()',
      );
    }
  }
}
