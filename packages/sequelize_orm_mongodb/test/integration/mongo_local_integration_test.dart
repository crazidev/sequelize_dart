@Tags(['mongo_integration'])
library;

import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

const _mongoUrl = 'mongodb://localhost:27017';
const _mongoDatabase = 'sequelize_dart';
const _mongoHost = '127.0.0.1';
const _mongoPort = 27017;

const _usersCollection = 'mongo_it_users';
const _postsCollection = 'mongo_it_posts';

bool get _isEnabled => Platform.environment['MONGO_LOCAL_TESTS'] == '1';

void main() {
  if (!_isEnabled) {
    test(
      'mongo local integration tests are disabled',
      () {
        expect(true, isTrue);
      },
      skip: 'Set MONGO_LOCAL_TESTS=1 to run MongoDB integration tests against '
          'localhost:27017/sequelize_dart.',
    );
    return;
  }

  group('MongoDB local integration', () {
    late MongoConnection connection;
    late MongoQueryEngine engine;
    Process? spawnedMongod;
    Directory? spawnedDbPath;

    MongoAssociationDefinition? associationResolver({
      required String sourceModel,
      required String associationName,
    }) {
      final key = '$sourceModel.$associationName';
      switch (key) {
        case '$_usersCollection.posts':
          return const MongoAssociationDefinition(
            sourceModel: _usersCollection,
            associationName: 'posts',
            targetCollection: _postsCollection,
            associationType: MongoAssociationType.hasMany,
            localField: '_id',
            foreignField: 'userId',
          );
        case '$_postsCollection.user':
          return const MongoAssociationDefinition(
            sourceModel: _postsCollection,
            associationName: 'user',
            targetCollection: _usersCollection,
            associationType: MongoAssociationType.belongsTo,
            localField: 'userId',
            foreignField: '_id',
          );
        default:
          return null;
      }
    }

    Future<void> clearCollections() async {
      await connection.collection(_usersCollection).deleteMany(where: {});
      await connection.collection(_postsCollection).deleteMany(where: {});
    }

    setUpAll(() async {
      final started = await _startMongodIfNeeded();
      spawnedMongod = started?.process;
      spawnedDbPath = started?.dbPath;

      connection = MongoConnection(
        config: const MongoConnectionConfig(
          url: _mongoUrl,
          database: _mongoDatabase,
        ),
      );
      await connection.open();
      engine = MongoQueryEngine(
        database: connection.adapter,
        associationResolver: associationResolver,
      );
    });

    setUp(() async {
      await clearCollections();
    });

    tearDownAll(() async {
      await clearCollections();
      await connection.close();
      await _stopMongodIfStarted(
        process: spawnedMongod,
        dbPath: spawnedDbPath,
      );
    });

    test('connection lifecycle works with local mongodb', () async {
      final localConnection = MongoConnection(
        config: const MongoConnectionConfig(
          url: _mongoUrl,
          database: _mongoDatabase,
        ),
      );

      expect(localConnection.isConnected, isFalse);
      await localConnection.open();
      expect(localConnection.isConnected, isTrue);
      await localConnection.close();
      expect(localConnection.isConnected, isFalse);
    });

    test('throws typed exception when connection fails', () async {
      final failing = MongoConnection(
        config: const MongoConnectionConfig(
          url: 'mongodb://localhost:1',
          database: _mongoDatabase,
        ),
      );

      await expectLater(
        failing.open(),
        throwsA(isA<MongoConnectionException>()),
      );
    });

    test('operator translation works against real mongodb queries', () async {
      await engine.bulkCreate(
        modelName: _usersCollection,
        data: const [
          {
            '_id': 'u1',
            'name': 'Alice',
            'status': 'active',
            'age': 30,
            'leftField': 10,
            'rightField': 10,
          },
          {
            '_id': 'u2',
            'name': 'Bob',
            'status': 'inactive',
            'age': 42,
            'leftField': 5,
            'rightField': 8,
          },
          {
            '_id': 'u3',
            'name': 'Alina',
            'status': 'active',
            'age': 25,
            'leftField': 7,
            'rightField': 7,
          },
        ],
      );

      final notIn = await engine.findAll(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: 'status',
            value: {
              r'$notIn': ['inactive'],
            },
          ),
        ),
      );
      expect(notIn.map((doc) => doc.data['_id']), containsAll(['u1', 'u3']));
      expect(notIn, hasLength(2));

      final startsWith = await engine.findAll(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: 'name',
            value: {
              r'$startsWith': 'Ali',
            },
          ),
        ),
      );
      expect(
        startsWith.map((doc) => doc.data['_id']),
        containsAll(['u1', 'u3']),
      );

      final between = await engine.findAll(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: 'age',
            value: {
              r'$between': [20, 35],
            },
          ),
        ),
      );
      expect(between, hasLength(2));

      final colComparison = await engine.findAll(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: 'leftField',
            value: {
              r'$col': 'rightField',
            },
          ),
        ),
      );
      expect(
        colComparison.map((doc) => doc.data['_id']),
        containsAll(['u1', 'u3']),
      );
      expect(colComparison, hasLength(2));
    });

    test('query lifecycle create/update/aggregate/paranoid restore works',
        () async {
      final created = await engine.create(
        modelName: _usersCollection,
        data: const {
          '_id': 'q1',
          'name': 'Query User',
          'status': 'active',
          'score': 5,
        },
      );
      expect(created.data['_id'], 'q1');

      await engine.bulkCreate(
        modelName: _usersCollection,
        data: const [
          {
            '_id': 'q2',
            'name': 'Second User',
            'status': 'active',
            'score': 15,
          },
          {
            '_id': 'q3',
            'name': 'Third User',
            'status': 'inactive',
            'score': 25,
          },
        ],
      );

      final activeCount = await engine.count(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: 'status',
            value: {
              r'$eq': 'active',
            },
          ),
        ),
      );
      expect(activeCount, 2);

      final updatedRows = await engine.update(
        modelName: _usersCollection,
        data: const {'status': 'active'},
        query: Query(
          where: ComparisonOperator(
            column: '_id',
            value: {
              r'$eq': 'q3',
            },
          ),
        ),
      );
      expect(updatedRows, 1);

      final sum = await engine.sum(
        modelName: _usersCollection,
        column: 'score',
      );
      expect(sum, 45);

      final max = await engine.max(
        modelName: _usersCollection,
        column: 'score',
      );
      expect(max, 25);

      final destroyedSoft = await engine.destroy(
        modelName: _usersCollection,
        options: const {
          'where': {
            '_id': {
              r'$eq': 'q2',
            },
          },
        },
        model: const {
          'options': {'paranoid': true, 'deletedAt': 'deletedAt'},
        },
      );
      expect(destroyedSoft, 1);

      final hiddenAfterSoftDelete = await engine.findOne(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: '_id',
            value: {
              r'$eq': 'q2',
            },
          ),
        ),
        model: const {
          'options': {'paranoid': true, 'deletedAt': 'deletedAt'},
        },
      );
      expect(hiddenAfterSoftDelete, isNull);

      await engine.restore(
        modelName: _usersCollection,
        options: const {
          'where': {
            '_id': {
              r'$eq': 'q2',
            },
          },
        },
        model: const {
          'options': {'paranoid': true, 'deletedAt': 'deletedAt'},
        },
      );

      final restored = await engine.findOne(
        modelName: _usersCollection,
        query: Query(
          where: ComparisonOperator(
            column: '_id',
            value: {
              r'$eq': 'q2',
            },
          ),
        ),
        model: const {
          'options': {'paranoid': true, 'deletedAt': 'deletedAt'},
        },
      );
      expect(restored, isNotNull);
      expect(restored!.data['_id'], 'q2');
    });

    test('associations work with real mongodb data', () async {
      await engine.create(
        modelName: _usersCollection,
        data: const {
          '_id': 'au1',
          'name': 'Association User A',
        },
      );
      await engine.create(
        modelName: _usersCollection,
        data: const {
          '_id': 'au2',
          'name': 'Association User B',
        },
      );

      final createdPost = await engine.associationCreate(
        sourceModel: _usersCollection,
        primaryKeyValues: const {'_id': 'au1'},
        associationName: 'posts',
        data: const {
          '_id': 'ap1',
          'title': 'First Post',
        },
      );
      expect(createdPost.data['userId'], 'au1');

      final postsForUserA = await engine.associationGet(
        sourceModel: _usersCollection,
        primaryKeyValues: const {'_id': 'au1'},
        associationName: 'posts',
      );
      expect(postsForUserA, isA<List<ModelInstanceData>>());
      expect((postsForUserA as List<ModelInstanceData>).length, 1);
      expect(postsForUserA.first.data['_id'], 'ap1');

      final userBeforeSet = await engine.belongsToGet(
        sourceModel: _postsCollection,
        primaryKeyValues: const {'_id': 'ap1'},
        associationName: 'user',
      );
      expect(userBeforeSet, isNotNull);
      expect(userBeforeSet!.data['_id'], 'au1');

      await engine.belongsToSet(
        sourceModel: _postsCollection,
        primaryKeyValues: const {'_id': 'ap1'},
        associationName: 'user',
        targetOrKey: 'au2',
      );

      final userAfterSet = await engine.belongsToGet(
        sourceModel: _postsCollection,
        primaryKeyValues: const {'_id': 'ap1'},
        associationName: 'user',
      );
      expect(userAfterSet, isNotNull);
      expect(userAfterSet!.data['_id'], 'au2');
    });
  });
}

class _SpawnedMongo {
  final Process process;
  final Directory dbPath;

  const _SpawnedMongo({
    required this.process,
    required this.dbPath,
  });
}

Future<_SpawnedMongo?> _startMongodIfNeeded() async {
  final alreadyRunning = await _isPortOpen(_mongoHost, _mongoPort);
  if (alreadyRunning) {
    return null;
  }

  final which = await Process.run('which', ['mongod']);
  if (which.exitCode != 0) {
    throw StateError(
      'mongod binary not found, and no MongoDB service is running on '
      '$_mongoHost:$_mongoPort.',
    );
  }

  final dbPath = await Directory.systemTemp.createTemp('mongo-it-');
  final process = await Process.start(
    'mongod',
    [
      '--bind_ip',
      _mongoHost,
      '--port',
      '$_mongoPort',
      '--dbpath',
      dbPath.path,
      '--quiet',
    ],
  );

  const maxAttempts = 30;
  for (var i = 0; i < maxAttempts; i++) {
    if (await _isPortOpen(_mongoHost, _mongoPort)) {
      return _SpawnedMongo(process: process, dbPath: dbPath);
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  process.kill(ProcessSignal.sigkill);
  await process.exitCode;
  throw StateError(
    'mongod failed to start on $_mongoHost:$_mongoPort for integration tests.',
  );
}

Future<void> _stopMongodIfStarted({
  required Process? process,
  required Directory? dbPath,
}) async {
  if (process == null) {
    return;
  }

  process.kill();
  try {
    await process.exitCode.timeout(const Duration(seconds: 5));
  } catch (_) {
    process.kill(ProcessSignal.sigkill);
    await process.exitCode;
  }

  if (dbPath != null && dbPath.existsSync()) {
    dbPath.deleteSync(recursive: true);
  }
}

Future<bool> _isPortOpen(String host, int port) async {
  Socket? socket;
  try {
    socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(milliseconds: 400),
    );
    return true;
  } catch (_) {
    return false;
  } finally {
    await socket?.close();
  }
}
