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

    test('findAll supports mongoWhere operator helper', () async {
      final users = database.collectionAsFake('users');
      users.findResult = [
        {'_id': 10, 'score': 99},
      ];

      final result = await engine.findAll(
        modelName: 'users',
        query: Query(where: mongoWhere('this.score >= 90')),
      );

      expect(result, hasLength(1));
      expect(users.lastFindWhere, {
        r'$where': 'this.score >= 90',
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

    test('save filters non-attribute association keys from replacement',
        () async {
      final users = database.collectionAsFake('users');

      await engine.save(
        modelName: 'users',
        currentData: const {
          'id': 1,
          'email': 'alice@example.com',
          'last_name': 'Updated Last Name',
          'post': {'id': 55, 'title': 'Should not persist in users doc'},
        },
        previousData: const {
          'id': 1,
          'email': 'alice@example.com',
          'post': {'id': 54},
        },
        primaryKeyValues: const {'id': 1},
        model: const {
          'attributes': {
            'id': {'primaryKey': true},
            'email': {'type': 'VARCHAR'},
            'last_name': {'type': 'VARCHAR'},
          },
        },
      );

      expect(users.lastReplaceOneWhere, {'id': 1});
      expect(users.lastReplaceOneReplacement, isNotNull);
      expect(users.lastReplaceOneReplacement!['id'], 1);
      expect(users.lastReplaceOneReplacement!['email'], 'alice@example.com');
      expect(
        users.lastReplaceOneReplacement!['last_name'],
        'Updated Last Name',
      );
      expect(users.lastReplaceOneReplacement, isNot(contains('post')));
    });

    test('syncModels alter updates collection validation via collMod', () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'age': {
            'type': 'INTEGER',
            'allowNull': false,
            'validate': {'min': 18},
          },
          'email': {
            'type': 'STRING',
            'allowNull': true,
            'validate': {
              'len': [3, 255],
            },
          },
          'first_name': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'min': 4},
          },
          'status': {
            'type': 'ENUM',
            'values': ['active', 'inactive', 'pending'],
          },
        },
        'options': {
          'mongoValidationLevel': 'moderate',
          'mongoValidationAction': 'warn',
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      expect(database.lastModifyCollectionCommand, isNotNull);
      final command = database.lastModifyCollectionCommand!;
      expect(command['name'], 'users');
      expect(command['validationLevel'], 'moderate');
      expect(command['validationAction'], 'warn');
      final validator = command['validator'] as Map<String, dynamic>;
      final schema = validator[r'$jsonSchema'] as Map<String, dynamic>;
      expect(schema['required'], contains('age'));
      final properties = schema['properties'] as Map<String, dynamic>;
      expect(properties['age']['minimum'], 18);
      expect(properties['email']['maxLength'], 255);
      expect(properties['first_name']['minLength'], 4);
      expect(properties['first_name'].containsKey('minimum'), isFalse);
      // status has no explicit allowNull:false so it is nullable → null appended
      expect(properties['status']['enum'],
          containsAllInOrder(['active', 'inactive', 'pending', null]));
    });

    test('_attributeSchemaFor: pattern from named validators', () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'username': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'isAlpha': true},
          },
          'email': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'isEmail': true},
          },
          'slug': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'isAlphanumeric': true},
          },
          'amount': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'isNumeric': true},
          },
          'ip': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'isIPv4': true},
          },
          'uid': {
            'type': 'UUID',
            'allowNull': false,
            'validate': {'isUUID': 4},
          },
          'explicit': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {'is': r'^[a-z]+$'},
          },
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      final command = database.lastModifyCollectionCommand!;
      final schema =
          (command['validator'] as Map)[r'$jsonSchema'] as Map<String, dynamic>;
      final props = schema['properties'] as Map<String, dynamic>;

      expect(props['username']['pattern'], r'^[a-zA-Z]+$');
      expect(props['email']['pattern'],
          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
      expect(props['slug']['pattern'], r'^[a-zA-Z0-9]+$');
      expect(props['amount']['pattern'], r'^[0-9]+(\.[0-9]+)?$');
      expect(
          (props['ip']['pattern'] as String).startsWith(r'^((25[0-5]'), isTrue);
      // UUID v4 pattern contains '4' in the version nibble slot
      expect(props['uid']['pattern'], contains('-4'));
      expect(props['explicit']['pattern'], r'^[a-z]+$');
    });

    test('_attributeSchemaFor: notEmpty maps to minLength 1', () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'bio': {
            'type': 'TEXT',
            'allowNull': false,
            'validate': {'notEmpty': true},
          },
          'name': {
            'type': 'STRING',
            'allowNull': false,
            'validate': {
              'notEmpty': true,
              'len': [3, 100],
            },
          },
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      final command = database.lastModifyCollectionCommand!;
      final schema =
          (command['validator'] as Map)[r'$jsonSchema'] as Map<String, dynamic>;
      final props = schema['properties'] as Map<String, dynamic>;

      expect(props['bio']['minLength'], 1);
      // len already sets minLength to 3 which is ≥ 1; notEmpty must not shrink it
      expect(props['name']['minLength'], 3);
      expect(props['name']['maxLength'], 100);
    });

    test('_attributeSchemaFor: typed JSON array uses bsonType array + items',
        () async {
      database.existingCollections.add('posts');
      final model = {
        'name': 'posts',
        'attributes': {
          'tags': {
            'type': 'JSON',
            'dartType': 'List<String>',
            'allowNull': false,
          },
          'scores': {
            'type': 'JSONB',
            'dartType': 'List<int>',
            'allowNull': false,
          },
          'meta': {
            'type': 'JSON',
            'dartType': 'Map<String, dynamic>',
            'allowNull': false,
          },
          'counts': {
            'type': 'JSON',
            'dartType': 'List<String>',
            'allowNull': false,
            'validate': {
              'len': [1, 10],
            },
          },
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      final command = database.lastModifyCollectionCommand!;
      final schema =
          (command['validator'] as Map)[r'$jsonSchema'] as Map<String, dynamic>;
      final props = schema['properties'] as Map<String, dynamic>;

      // tags → bsonType: 'array', items: {bsonType: 'string'}
      expect(props['tags']['bsonType'], 'array');
      expect(props['tags']['items']['bsonType'], 'string');

      // scores → bsonType: 'array', items: {bsonType: ['int','long']}
      expect(props['scores']['bsonType'], 'array');
      expect(props['scores']['items']['bsonType'], containsAll(['int', 'long']));

      // meta → bsonType: 'object' (Map dartType)
      expect(props['meta']['bsonType'], 'object');
      expect(props['meta'].containsKey('items'), isFalse);

      // counts → minItems/maxItems from len
      expect(props['counts']['minItems'], 1);
      expect(props['counts']['maxItems'], 10);
    });

    test(
        '_attributeSchemaFor: BIGINT maps to string bsonType (SequelizeBigInt serialises as string)',
        () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'phone_number': {'type': 'BIGINT', 'allowNull': true},
          'id': {'type': 'BIGINT', 'allowNull': false},
          'age': {'type': 'INTEGER', 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      final command = database.lastModifyCollectionCommand!;
      final schema =
          (command['validator'] as Map)[r'$jsonSchema'] as Map<String, dynamic>;
      final props = schema['properties'] as Map<String, dynamic>;

      // Nullable BIGINT → ['string', 'null']
      expect(props['phone_number']['bsonType'],
          containsAll(['string', 'null']));
      // Non-null BIGINT → 'string'
      expect(props['id']['bsonType'], 'string');
      // Regular INTEGER still maps to int/long
      expect(props['age']['bsonType'], containsAll(['int', 'long']));
    });

    test('_attributeSchemaFor: enum non-null field omits null from enum list',
        () async {
      database.existingCollections.add('orders');
      final model = {
        'name': 'orders',
        'attributes': {
          'state': {
            'type': 'ENUM',
            'values': ['pending', 'shipped'],
            'allowNull': false,
          },
          'optState': {
            'type': 'ENUM',
            'values': ['pending', 'shipped'],
            'allowNull': true,
          },
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      final command = database.lastModifyCollectionCommand!;
      final schema =
          (command['validator'] as Map)[r'$jsonSchema'] as Map<String, dynamic>;
      final props = schema['properties'] as Map<String, dynamic>;

      // NOT NULL → exact values, no null appended
      expect(props['state']['enum'], equals(['pending', 'shipped']));
      // nullable → null appended
      expect(
          props['optState']['enum'], containsAllInOrder(['pending', 'shipped', null]));
    });

    test('syncModels force drops and recreates collection with validation',
        () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'name': {'type': 'STRING', 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: true,
        alter: false,
        sequelize: null,
        models: [model],
      );

      expect(database.lastDropCollectionName, 'users');
      expect(database.lastCreateCollectionCommand, isNotNull);
      expect(database.lastCreateCollectionCommand!['name'], 'users');
    });

    test('findDocumentsNotMatchingSchema uses \$nor + \$jsonSchema', () async {
      final users = database.collectionAsFake('users');
      users.findResult = [
        {'_id': 1, 'status': 'invalid'},
      ];

      final rows = await engine.findDocumentsNotMatchingSchema(
        modelName: 'users',
        where: {
          'status': {r'$eq': 'invalid'},
        },
        model: {
          'attributes': {
            'status': {'type': 'STRING', 'allowNull': false},
          },
        },
      );

      expect(rows, hasLength(1));
      expect(users.lastFindWhere, isNotNull);
      expect(users.lastFindWhere![r'$and'], isA<List>());
      final andClauses = users.lastFindWhere![r'$and'] as List;
      expect(andClauses.first, {
        'status': {r'$eq': 'invalid'},
      });
      expect(andClauses.last, contains(r'$nor'));
    });

    test('deleteDocumentsNotMatchingSchema uses \$nor + \$jsonSchema', () async {
      final users = database.collectionAsFake('users');
      users.deleteManyResult = 4;

      final deleted = await engine.deleteDocumentsNotMatchingSchema(
        modelName: 'users',
        model: {
          'attributes': {
            'status': {'type': 'STRING', 'allowNull': false},
          },
        },
      );

      expect(deleted, 4);
      expect(users.lastDeleteManyWhere, isNotNull);
      expect(users.lastDeleteManyWhere, contains(r'$nor'));
    });

    test('syncModels creates unique index on primary key when creating new collection',
        () async {
      final model = {
        'name': 'users',
        'attributes': {
          'id': {'type': 'INTEGER', 'primaryKey': true, 'allowNull': false},
          'name': {'type': 'STRING', 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: false,
        alter: false,
        sequelize: null,
        models: [model],
      );

      expect(database.lastCreateCollectionCommand, isNotNull);
      expect(database.ensureUniqueIndexCalls, hasLength(1));
      expect(database.ensureUniqueIndexCalls.first['collectionName'], 'users');
      expect(database.ensureUniqueIndexCalls.first['fields'], equals(['id']));
    });

    test('syncModels creates unique index on primary key when force-recreating collection',
        () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'id': {'type': 'INTEGER', 'primaryKey': true, 'allowNull': false},
          'name': {'type': 'STRING', 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: true,
        alter: false,
        sequelize: null,
        models: [model],
      );

      expect(database.lastDropCollectionName, 'users');
      expect(database.lastCreateCollectionCommand, isNotNull);
      expect(database.ensureUniqueIndexCalls, hasLength(1));
      expect(database.ensureUniqueIndexCalls.first['collectionName'], 'users');
      expect(database.ensureUniqueIndexCalls.first['fields'], equals(['id']));
    });

    test('syncModels ensures unique index on primary key when altering existing collection',
        () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'id': {'type': 'UUID', 'primaryKey': true, 'allowNull': false},
          'email': {'type': 'STRING', 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: false,
        alter: true,
        sequelize: null,
        models: [model],
      );

      expect(database.lastModifyCollectionCommand, isNotNull);
      expect(database.ensureUniqueIndexCalls, hasLength(1));
      expect(database.ensureUniqueIndexCalls.first['collectionName'], 'users');
      expect(database.ensureUniqueIndexCalls.first['fields'], equals(['id']));
    });

    test('syncModels skips unique index when no primary key field is defined',
        () async {
      final model = {
        'name': 'users',
        'attributes': {
          'name': {'type': 'STRING', 'allowNull': false},
          'email': {'type': 'STRING', 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: false,
        alter: false,
        sequelize: null,
        models: [model],
      );

      expect(database.ensureUniqueIndexCalls, isEmpty);
    });

    test('syncModels does not create unique index when collection exists and no alter/force',
        () async {
      database.existingCollections.add('users');
      final model = {
        'name': 'users',
        'attributes': {
          'id': {'type': 'INTEGER', 'primaryKey': true, 'allowNull': false},
        },
      };

      await engine.syncModels(
        force: false,
        alter: false,
        sequelize: null,
        models: [model],
      );

      expect(database.ensureUniqueIndexCalls, isEmpty);
    });
  });
}

class _CaptureLogger {
  final List<String> messages = <String>[];

  void log(dynamic message) {
    messages.add(message.toString());
  }
}
