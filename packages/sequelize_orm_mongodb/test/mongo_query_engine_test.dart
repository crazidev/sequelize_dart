import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

import 'fakes/fake_mongo_adapter.dart';

void main() {
  group('MongoQueryEngine', () {
    late FakeMongoDatabaseAdapter database;
    late MongoQueryEngine engine;

    MongoAssociationDefinition? resolver({
      required String sourceModel,
      required String associationName,
    }) {
      if (sourceModel == 'users' && associationName == 'posts') {
        return const MongoAssociationDefinition(
          sourceModel: 'users',
          associationName: 'posts',
          targetCollection: 'posts',
          associationType: MongoAssociationType.hasMany,
          localField: '_id',
          foreignField: 'userId',
        );
      }
      if (sourceModel == 'posts' && associationName == 'user') {
        return const MongoAssociationDefinition(
          sourceModel: 'posts',
          associationName: 'user',
          targetCollection: 'users',
          associationType: MongoAssociationType.belongsTo,
          localField: 'userId',
          foreignField: '_id',
        );
      }
      if (sourceModel == 'users' && associationName == 'profile') {
        return const MongoAssociationDefinition(
          sourceModel: 'users',
          associationName: 'profile',
          targetCollection: 'profiles',
          associationType: MongoAssociationType.belongsTo,
          localField: 'profileId',
          foreignField: '_id',
        );
      }
      return null;
    }

    setUp(() {
      database = FakeMongoDatabaseAdapter();
      engine = MongoQueryEngine(
        database: database,
        associationResolver: resolver,
      );
    });

    test(
        'findAll translates query operators, sorting, pagination and projection',
        () async {
      final users = database.collectionAsFake('users');
      users.findResult = [
        {'_id': 1, 'status': 'active'},
      ];

      final query = Query(
        where: ComparisonOperator(
          column: 'status',
          value: {
            r'$notIn': ['inactive', 'pending'],
          },
        ),
        order: [
          ['createdAt', 'DESC'],
        ],
        limit: 20,
        offset: 10,
        attributes: QueryAttributes.include(['_id', 'status']),
      );

      final result = await engine.findAll(
        modelName: 'users',
        query: query,
        model: {
          'options': {'paranoid': true, 'deletedAt': 'deletedAt'},
        },
      );

      expect(result, hasLength(1));
      expect(users.lastFindSort, {'createdAt': -1});
      expect(users.lastFindLimit, 20);
      expect(users.lastFindSkip, 10);
      expect(users.lastFindProjection, {
        '_id': 1,
        'status': 1,
      });
      expect(users.lastFindWhere, {
        r'$and': [
          {
            'status': {
              r'$nin': ['inactive', 'pending'],
            },
          },
          {
            'deletedAt': {r'$eq': null},
          },
        ],
      });
    });

    test('destroy performs paranoid soft delete when force is false', () async {
      final users = database.collectionAsFake('users');
      users.updateManyResult = 3;

      final destroyed = await engine.destroy(
        modelName: 'users',
        options: {
          'where': {
            'status': {r'$eq': 'inactive'},
          },
        },
        model: {
          'options': {'paranoid': true, 'deletedAt': 'deletedAt'},
        },
      );

      expect(destroyed, 3);
      expect(users.lastUpdateManyWhere, {
        r'$and': [
          {
            'status': {r'$eq': 'inactive'},
          },
          {
            'deletedAt': {r'$eq': null},
          },
        ],
      });
      expect(users.lastUpdateManyUpdate, isNotNull);
      expect(users.lastUpdateManyUpdate![r'$set'], contains('deletedAt'));
    });

    test('max builds aggregation pipeline and returns numeric result',
        () async {
      final posts = database.collectionAsFake('posts');
      posts.aggregateResult = [
        {'result': 42},
      ];

      final result = await engine.max(
        modelName: 'posts',
        column: 'views',
        query: Query(
          where: ComparisonOperator(
            column: 'published',
            value: {
              r'$eq': true,
            },
          ),
        ),
      );

      expect(result, 42);
      expect(posts.lastAggregatePipeline, [
        {
          r'$match': {
            'published': {r'$eq': true},
          },
        },
        {
          r'$group': {
            r'_id': null,
            'result': {
              r'$max': r'$views',
            },
          },
        },
      ]);
    });

    test('belongsToGet resolves and fetches associated document', () async {
      final users = database.collectionAsFake('users');
      final profiles = database.collectionAsFake('profiles');
      users.findOneResult = {
        '_id': 'u1',
        'profileId': 'p1',
      };
      profiles.findOneResult = {
        '_id': 'p1',
        'displayName': 'John',
      };

      final profile = await engine.belongsToGet(
        sourceModel: 'users',
        primaryKeyValues: {'_id': 'u1'},
        associationName: 'profile',
      );

      expect(profile, isNotNull);
      expect(profile!.data['displayName'], 'John');
      expect(profiles.lastFindOneWhere, {
        '_id': 'p1',
      });
    });

    test('create materializes nested hasMany associations as linked records',
        () async {
      final users = database.collectionAsFake('users');
      final posts = database.collectionAsFake('posts');
      users.insertOneResult = {'_id': 'u1', 'email': 'alice@example.com'};

      final result = await engine.create(
        modelName: 'users',
        data: const {
          'email': 'alice@example.com',
          'posts': [
            {'title': 'Post A'},
            {'title': 'Post B'},
          ],
        },
      );

      expect(users.lastInsertOneDocument, {'email': 'alice@example.com'});
      expect(posts.lastInsertOneDocument, isNotNull);
      expect(posts.lastInsertOneDocument!['userId'], 'u1');
      expect(result.data['posts'], isA<List<Map<String, dynamic>>>());
      expect(result.data['posts'].length, 2);
    });

    test('create materializes belongsTo association and stores foreign key',
        () async {
      final posts = database.collectionAsFake('posts');
      final users = database.collectionAsFake('users');
      posts.insertOneResult = {'_id': 'p1', 'title': 'Post with user'};
      users.insertOneResult = {'_id': 'u9', 'email': 'linked@example.com'};

      final result = await engine.create(
        modelName: 'posts',
        data: const {
          'title': 'Post with user',
          'user': {'email': 'linked@example.com'},
        },
      );

      expect(posts.lastInsertOneDocument, {'title': 'Post with user'});
      expect(users.lastInsertOneDocument, {'email': 'linked@example.com'});
      expect(posts.lastUpdateOneWhere, {'_id': 'p1'});
      expect(posts.lastUpdateOneUpdate, {
        r'$set': {'userId': 'u9'},
      });
      expect(result.data['userId'], 'u9');
      expect(result.data['user'], isA<Map<String, dynamic>>());
    });

    test('findAll logs structured mongo query payload', () async {
      final users = database.collectionAsFake('users');
      users.findResult = [
        {'_id': 1, 'status': 'active'},
      ];
      final logger = _CaptureLogger();

      await engine.findAll(
        modelName: 'users',
        query: Query(
          where: ComparisonOperator(
            column: 'status',
            value: {r'$eq': 'active'},
          ),
        ),
        sequelize: logger,
      );

      expect(logger.messages, isNotEmpty);
      final log = logger.messages.last;
      expect(log, predicate((value) => value.toString().startsWith('[mongo:findAll] ')));
      expect(log, contains('"collection":"users"'));
      expect(log, contains(r'"where":{"status":{"$eq":"active"}}'));
    });

    test('count with group logs aggregate pipeline', () async {
      final users = database.collectionAsFake('users');
      users.aggregateResult = [
        {'result': 2},
      ];
      final logger = _CaptureLogger();

      final count = await engine.count(
        modelName: 'users',
        query: Query(group: ['status']),
        sequelize: logger,
      );

      expect(count, 2);
      expect(logger.messages, isNotEmpty);
      final log = logger.messages.last;
      expect(log, predicate((value) => value.toString().startsWith('[mongo:count.aggregate] ')));
      expect(log, contains('"pipeline"'));
      expect(log, contains(r'"$group"'));
    });
  });
}

class _CaptureLogger {
  final List<String> messages = <String>[];

  void log(dynamic message) {
    messages.add(message.toString());
  }
}
