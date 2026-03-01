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
  });
}
