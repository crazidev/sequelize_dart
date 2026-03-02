// ignore_for_file: avoid_dynamic_calls

import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:sequelize_orm_mongodb/src/mongo_adapter.dart';
import 'package:sequelize_orm_mongodb/src/mongo_exceptions.dart';

class MongoConnectionConfig {
  final String url;
  final String database;
  final String? mongoValidationLevel;
  final String? mongoValidationAction;

  const MongoConnectionConfig({
    required this.url,
    required this.database,
    this.mongoValidationLevel,
    this.mongoValidationAction,
  });
}

class MongoConnection {
  final MongoConnectionConfig config;
  final MongoDatabaseAdapter _adapter;

  MongoConnection({
    required this.config,
    MongoDatabaseAdapter? adapter,
  }) : _adapter = adapter ?? MongoDartDatabaseAdapter(config: config);

  Future<void> open() => _adapter.connect();

  Future<void> close() => _adapter.close();

  bool get isConnected => _adapter.isConnected;

  MongoCollectionAdapter collection(String name) => _adapter.collection(name);

  MongoDatabaseAdapter get adapter => _adapter;
}

class MongoDartDatabaseAdapter implements MongoDatabaseAdapter {
  final MongoConnectionConfig config;
  mongo.Db? _db;
  bool _connected = false;

  MongoDartDatabaseAdapter({
    required this.config,
  });

  @override
  Future<void> connect() async {
    if (_connected) {
      return;
    }
    try {
      _db = mongo.Db(_connectionUri(config));
      await _db!.open();
      _connected = true;
    } catch (error, stackTrace) {
      throw MongoConnectionException(
        'Failed to connect to MongoDB: $error',
        context: 'MongoConnection.connect',
        stack: stackTrace.toString(),
      );
    }
  }

  @override
  Future<void> close() async {
    if (_db == null || !_connected) {
      return;
    }
    await _db!.close();
    _connected = false;
  }

  @override
  bool get isConnected => _connected;

  @override
  MongoCollectionAdapter collection(String name) {
    if (_db == null || !_connected) {
      throw MongoConnectionException(
        'MongoDB connection is not open.',
        context: 'MongoConnection.collection',
      );
    }
    return MongoDartCollectionAdapter(_db!.collection(name));
  }

  @override
  Future<bool> collectionExists(String name) async {
    try {
      final response = await _runDbCommand({
        'listCollections': 1,
        'filter': {'name': name},
        'nameOnly': true,
      });
      final cursor = response['cursor'];
      if (cursor is Map) {
        final firstBatch = cursor['firstBatch'];
        if (firstBatch is List) {
          return firstBatch.isNotEmpty;
        }
      }

      final dynamic names = await (_db as dynamic).getCollectionNames();
      if (names is List) {
        return names.map((entry) => entry.toString()).contains(name);
      }
      return false;
    } catch (error, stackTrace) {
      throw MongoConnectionException(
        'Failed to check collection existence for "$name": $error',
        context: 'MongoConnection.collectionExists',
        stack: stackTrace.toString(),
      );
    }
  }

  @override
  Future<void> createCollectionWithValidation({
    required String name,
    Map<String, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
  }) async {
    try {
      final command = <String, dynamic>{'create': name};
      if (validator != null && validator.isNotEmpty) {
        command['validator'] = validator;
      }
      if (validationLevel != null && validationLevel.isNotEmpty) {
        command['validationLevel'] = validationLevel;
      }
      if (validationAction != null && validationAction.isNotEmpty) {
        command['validationAction'] = validationAction;
      }
      await _runDbCommand(command);
    } catch (error, stackTrace) {
      throw MongoConnectionException(
        'Failed to create collection "$name": $error',
        context: 'MongoConnection.createCollectionWithValidation',
        stack: stackTrace.toString(),
      );
    }
  }

  @override
  Future<void> modifyCollectionValidation({
    required String name,
    Map<String, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
  }) async {
    try {
      final command = <String, dynamic>{'collMod': name};
      if (validator != null && validator.isNotEmpty) {
        command['validator'] = validator;
      }
      if (validationLevel != null && validationLevel.isNotEmpty) {
        command['validationLevel'] = validationLevel;
      }
      if (validationAction != null && validationAction.isNotEmpty) {
        command['validationAction'] = validationAction;
      }
      await _runDbCommand(command);
    } catch (error, stackTrace) {
      throw MongoConnectionException(
        'Failed to modify schema validation for "$name": $error',
        context: 'MongoConnection.modifyCollectionValidation',
        stack: stackTrace.toString(),
      );
    }
  }

  @override
  Future<void> dropCollectionIfExists(String name) async {
    try {
      if (!await collectionExists(name)) {
        return;
      }
      await _runDbCommand({'drop': name});
    } catch (error, stackTrace) {
      throw MongoConnectionException(
        'Failed to drop collection "$name": $error',
        context: 'MongoConnection.dropCollectionIfExists',
        stack: stackTrace.toString(),
      );
    }
  }

  @override
  Future<void> ensureUniqueIndex({
    required String collectionName,
    required List<String> fields,
  }) async {
    if (fields.isEmpty) return;
    try {
      final indexKey = {for (final f in fields) f: 1};
      final indexName = '${fields.join('_')}_unique';
      await _runDbCommand({
        'createIndexes': collectionName,
        'indexes': [
          {
            'key': indexKey,
            'name': indexName,
            'unique': true,
          },
        ],
      });
    } catch (error, stackTrace) {
      throw MongoConnectionException(
        'Failed to create unique index on "$collectionName" for fields $fields: $error',
        context: 'MongoConnection.ensureUniqueIndex',
        stack: stackTrace.toString(),
      );
    }
  }

  @override
  Future<int> nextSequenceValue({
    required String sequenceName,
  }) async {
    try {
      final response = await _runDbCommand({
        'findAndModify': '_sequelize_orm_counters',
        'query': {'_id': sequenceName},
        'update': {
          r'$inc': {'seq': 1},
        },
        'upsert': true,
        'new': true,
      });
      final value = response['value'];
      if (value is Map) {
        final seq = value['seq'];
        if (seq is int) {
          return seq;
        }
        if (seq is num) {
          return seq.toInt();
        }
      }
      throw MongoConnectionException(
        'Failed to resolve sequence value for "$sequenceName": $response',
        context: 'MongoConnection.nextSequenceValue',
      );
    } catch (error, stackTrace) {
      if (error is MongoConnectionException) {
        rethrow;
      }
      throw MongoConnectionException(
        'Failed to increment sequence "$sequenceName": $error',
        context: 'MongoConnection.nextSequenceValue',
        stack: stackTrace.toString(),
      );
    }
  }

  String _connectionUri(MongoConnectionConfig cfg) {
    try {
      final uri = Uri.parse(cfg.url);
      final hasDatabasePath = uri.pathSegments
          .where((segment) => segment.trim().isNotEmpty)
          .isNotEmpty;
      if (hasDatabasePath) {
        return cfg.url;
      }
      return uri.replace(path: '/${cfg.database}').toString();
    } catch (_) {
      if (cfg.url.endsWith('/')) {
        return '${cfg.url}${cfg.database}';
      }
      return '${cfg.url}/${cfg.database}';
    }
  }

  Future<Map<String, dynamic>> _runDbCommand(
      Map<String, dynamic> command) async {
    if (_db == null || !_connected) {
      throw MongoConnectionException(
        'MongoDB connection is not open.',
        context: 'MongoConnection._runDbCommand',
      );
    }
    final normalizedCommand = _normalizeCommand(command);
    final dynamic response =
        await (_db as dynamic).runCommand(normalizedCommand);
    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final ok = map['ok'];
      if ((ok is num && ok == 1) || ok == true || ok == '1') {
        return map;
      }
      throw MongoConnectionException(
        'Mongo command failed: $command, response: $map',
        context: 'MongoConnection._runDbCommand',
      );
    }
    return <String, dynamic>{};
  }

  Map<String, Object> _normalizeCommand(Map<String, dynamic> command) {
    final normalized = <String, Object>{};
    command.forEach((key, value) {
      final normalizedValue = _normalizeCommandValue(value);
      if (normalizedValue != null) {
        normalized[key] = normalizedValue;
      }
    });
    return normalized;
  }

  Object? _normalizeCommandValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final map = <String, Object>{};
      value.forEach((k, v) {
        final normalizedValue = _normalizeCommandValue(v);
        if (normalizedValue != null) {
          map[k.toString()] = normalizedValue;
        }
      });
      return map;
    }
    if (value is List) {
      return value
          .map(_normalizeCommandValue)
          .where((item) => item != null)
          .cast<Object>()
          .toList(growable: false);
    }
    return value as Object;
  }
}

class MongoDartCollectionAdapter implements MongoCollectionAdapter {
  final dynamic _collection;

  MongoDartCollectionAdapter(mongo.DbCollection collection)
      : _collection = collection;

  @override
  Future<List<Map<String, dynamic>>> aggregate(
    List<Map<String, dynamic>> pipeline,
  ) async {
    final List<Map<String, Object>> mongoPipeline = pipeline
        .map(
          (stage) => stage.map<String, Object>(
            (key, value) => MapEntry(key, value as Object),
          ),
        )
        .toList(growable: false);
    final dynamic stream = _collection.aggregateToStream(mongoPipeline);
    final dynamic docs = await stream.toList();
    return _asDocList(docs);
  }

  @override
  Future<int> count(Map<String, dynamic> where) async {
    final docs = await aggregate([
      {r'$match': where},
      {r'$count': 'count'},
    ]);
    if (docs.isEmpty) {
      return 0;
    }
    return _asInt(docs.first['count']);
  }

  @override
  Future<int> deleteMany({
    required Map<String, dynamic> where,
  }) async {
    final dynamic response = await _collection.deleteMany(where);
    return _extractCount(response, ['nRemoved', 'deletedCount', 'n']);
  }

  @override
  Future<int> deleteOne({
    required Map<String, dynamic> where,
  }) async {
    final dynamic response = await _collection.deleteOne(where);
    return _extractCount(response, ['nRemoved', 'deletedCount', 'n']);
  }

  @override
  Future<List<Map<String, dynamic>>> find({
    Map<String, dynamic>? where,
    Map<String, int>? sort,
    int? limit,
    int? skip,
    Map<String, dynamic>? projection,
  }) async {
    final shouldUsePipeline = (sort != null && sort.isNotEmpty) ||
        (limit != null) ||
        (skip != null) ||
        (projection != null && projection.isNotEmpty);
    if (shouldUsePipeline) {
      return aggregate([
        if (where != null && where.isNotEmpty) {r'$match': where},
        if (sort != null && sort.isNotEmpty) {r'$sort': sort},
        if (skip != null && skip > 0) {r'$skip': skip},
        if (limit != null && limit >= 0) {r'$limit': limit},
        if (projection != null && projection.isNotEmpty)
          {r'$project': projection},
      ]);
    }

    final dynamic cursor = _collection.find(where ?? <String, dynamic>{});
    final dynamic docs = await cursor.toList();
    return _asDocList(docs);
  }

  @override
  Future<Map<String, dynamic>?> findOne({
    Map<String, dynamic>? where,
    Map<String, int>? sort,
    Map<String, dynamic>? projection,
  }) async {
    if ((sort != null && sort.isNotEmpty) ||
        (projection != null && projection.isNotEmpty)) {
      final docs = await aggregate([
        if (where != null && where.isNotEmpty) {r'$match': where},
        if (sort != null && sort.isNotEmpty) {r'$sort': sort},
        {r'$limit': 1},
        if (projection != null && projection.isNotEmpty)
          {r'$project': projection},
      ]);
      return docs.isEmpty ? null : docs.first;
    }

    final dynamic doc = await _collection.findOne(where ?? <String, dynamic>{});
    if (doc == null) {
      return null;
    }
    return Map<String, dynamic>.from(doc as Map);
  }

  @override
  Future<List<Map<String, dynamic>>> insertMany(
    List<Map<String, dynamic>> documents,
  ) async {
    await _collection.insertMany(documents);
    return documents
        .map((doc) => Map<String, dynamic>.from(doc))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> insertOne(Map<String, dynamic> document) async {
    final doc = Map<String, dynamic>.from(document);
    // Generate Mongo ObjectId on client side when absent.
    // This allows immediate key availability for association linking.
    doc.putIfAbsent('_id', () => mongo.ObjectId());
    final dynamic response = await _collection.insertOne(doc);
    final dynamic id = _extractValue(response, ['id', 'insertedId', 'oid']) ??
        _extractValue(doc, ['_id', 'id']);
    if (id != null && !doc.containsKey('_id')) {
      doc['_id'] = id;
    }
    return doc;
  }

  @override
  Future<Map<String, dynamic>> replaceOne({
    required Map<String, dynamic> where,
    required Map<String, dynamic> replacement,
    bool upsert = false,
  }) async {
    await _collection.replaceOne(where, replacement, upsert: upsert);
    final reloaded = await findOne(where: where);
    return reloaded ?? Map<String, dynamic>.from(replacement);
  }

  @override
  Future<int> updateMany({
    required Map<String, dynamic> where,
    required Map<String, dynamic> update,
  }) async {
    final dynamic response = await _collection.updateMany(where, update);
    return _extractCount(response, ['nModified', 'modifiedCount', 'n']);
  }

  @override
  Future<int> updateOne({
    required Map<String, dynamic> where,
    required Map<String, dynamic> update,
  }) async {
    final dynamic response = await _collection.updateOne(where, update);
    return _extractCount(response, ['nModified', 'modifiedCount', 'n']);
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  List<Map<String, dynamic>> _asDocList(dynamic docs) {
    if (docs is! List) {
      return const <Map<String, dynamic>>[];
    }
    return docs
        .whereType<Map>()
        .map((doc) => Map<String, dynamic>.from(doc))
        .toList(growable: false);
  }

  int _extractCount(dynamic response, List<String> keys) {
    for (final key in keys) {
      final value = _extractValue(response, [key]);
      if (value != null) {
        return _asInt(value);
      }
    }

    final directValue = _extractValue(response, const ['ok', 'isSuccess']);
    if (directValue is bool && directValue) {
      return 1;
    }

    return 0;
  }

  dynamic _extractValue(dynamic source, List<String> keys) {
    if (source == null) {
      return null;
    }

    if (source is Map) {
      for (final key in keys) {
        if (source.containsKey(key)) {
          return source[key];
        }
      }
    }

    for (final key in keys) {
      switch (key) {
        case 'id':
          try {
            return source.id;
          } catch (_) {}
          break;
        case 'insertedId':
          try {
            return source.insertedId;
          } catch (_) {}
          break;
        case 'oid':
          try {
            return source.oid;
          } catch (_) {}
          break;
        case 'n':
          try {
            return source.n;
          } catch (_) {}
          break;
        case 'nRemoved':
          try {
            return source.nRemoved;
          } catch (_) {}
          break;
        case 'nModified':
          try {
            return source.nModified;
          } catch (_) {}
          break;
        case 'deletedCount':
          try {
            return source.deletedCount;
          } catch (_) {}
          break;
        case 'modifiedCount':
          try {
            return source.modifiedCount;
          } catch (_) {}
          break;
        case 'ok':
          try {
            return source.ok;
          } catch (_) {}
          break;
        case 'isSuccess':
          try {
            return source.isSuccess;
          } catch (_) {}
          break;
      }
    }

    return null;
  }
}
