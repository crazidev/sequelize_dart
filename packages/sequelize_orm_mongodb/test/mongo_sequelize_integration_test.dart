import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

const _mongoUrl = 'mongodb://localhost:27017';
const _mongoDatabase = 'sequelize_dart';
const _usersCollection = 'Users';
const _postsCollection = 'Post';

void main() {
  if (Platform.environment['MONGO_LOCAL_TESTS'] != '1') {
    test(
      'mongo sequelize integration tests are disabled',
      () => expect(true, isTrue),
      skip: 'Set MONGO_LOCAL_TESTS=1 to run against localhost MongoDB.',
    );
    return;
  }

  group('MongoSequelizeIntegration', () {
    late MongoConnection connection;

    setUpAll(() async {
      connection = MongoConnection(
        config: const MongoConnectionConfig(
          url: _mongoUrl,
          database: _mongoDatabase,
        ),
      );
      await connection.open();
    });

    tearDown(() async {
      await connection.collection(_usersCollection).deleteMany(where: {});
      await connection.collection(_postsCollection).deleteMany(where: {});
    });

    tearDownAll(() async {
      await connection.close();
    });

    test('attach registers mongo engine and disables bridge mode', () async {
      final sequelize = Sequelize().createInstance(
        connection: PostgresConnection(
          url: 'postgresql://postgres:postgres@localhost:5432/postgres',
        ),
      );

      MongoSequelizeIntegration.attach(
        sequelize: sequelize,
        database: connection.adapter,
      );

      expect(sequelize.resolveQueryEngine(), isA<MongoQueryEngine>());
      expect(sequelize.usesBridgeQueryEngine, isFalse);
    });

    test('uses Sequelize association metadata as default resolver', () async {
      final sequelize = Sequelize().createInstance(
        connection: PostgresConnection(
          url: 'postgresql://postgres:postgres@localhost:5432/postgres',
        ),
      );

      sequelize.registerAssociationDefinition(
        sourceModel: 'Users',
        associationName: 'posts',
        targetModel: 'Post',
        associationType: 'hasMany',
        sourceKey: '_id',
        foreignKey: 'userId',
      );

      await connection.collection(_usersCollection).insertOne({'_id': 'u1'});
      await connection.collection(_postsCollection).insertMany([
        {'_id': 'p1', 'userId': 'u1'},
      ]);

      MongoSequelizeIntegration.attach(
        sequelize: sequelize,
        database: connection.adapter,
      );

      final result = await QueryEngine().associationGet(
        sourceModel: 'Users',
        primaryKeyValues: const {'_id': 'u1'},
        associationName: 'posts',
        sequelize: sequelize,
      );

      expect(result, isA<List<ModelInstanceData>>());
      expect((result as List<ModelInstanceData>).first.data['_id'], 'p1');
    });

    test('seed extension works in mongo mode with syncTableMode', () async {
      final sequelize = Sequelize().createInstance(
        connection: PostgresConnection(
          url: 'postgresql://postgres:postgres@localhost:5432/postgres',
        ),
      );

      MongoSequelizeIntegration.attach(
        sequelize: sequelize,
        database: connection.adapter,
      );
      await connection.collection('seed_users').deleteMany(where: {});

      final seeder = _MapSeeder(
        modelName: 'seed_users',
        sequelize: sequelize,
        rows: const [
          {'email': 'seed1@example.com'},
          {'email': 'seed2@example.com'},
        ],
      );

      await sequelize.seed(
        seeders: [seeder],
        syncTableMode: SyncTableMode.alter,
      );

      final count = await connection.collection('seed_users').count({});
      expect(count, 2);
    });

    test('mongo engine emits logs through sequelize logging callback', () async {
      final logs = <String>[];
      final sequelize = Sequelize().createInstance(
        connection: PostgresConnection(
          url: 'postgresql://postgres:postgres@localhost:5432/postgres',
        ),
        logging: (message) => logs.add(message.toString()),
      );

      MongoSequelizeIntegration.attach(
        sequelize: sequelize,
        database: connection.adapter,
      );
      await connection.collection('log_users').deleteMany(where: {});

      await QueryEngine().create(
        modelName: 'log_users',
        data: const {'email': 'logged@example.com'},
        sequelize: sequelize,
      );

      expect(logs.any((line) => line.startsWith('[mongo:create] ')), isTrue);
      expect(logs.any((line) => line.contains('"collection":"log_users"')), isTrue);
    });
  });
}

class _MapSeeder extends SequelizeSeeding<Map<String, dynamic>> {
  _MapSeeder({
    required this.modelName,
    required this.sequelize,
    required this.rows,
  });

  final String modelName;
  final Sequelize sequelize;
  final List<Map<String, dynamic>> rows;

  @override
  List<Map<String, dynamic>> get seedData => rows;

  @override
  SeederCreateFn<Map<String, dynamic>> get create => (row) {
        return QueryEngine().create(
          modelName: modelName,
          data: row,
          sequelize: sequelize,
        );
      };
}
