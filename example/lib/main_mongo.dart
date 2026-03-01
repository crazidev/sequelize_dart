import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';

const mongoUrl = 'mongodb://localhost:27017';
const mongoDatabase = 'sequelize_dart';
const usersCollection = 'mongo_example_users';
const postsCollection = 'mongo_example_posts';

Future<void> main() async {
  final connection = MongoConnection(
    config: const MongoConnectionConfig(
      url: mongoUrl,
      database: mongoDatabase,
    ),
  );
  await connection.open();

  final engine = MongoQueryEngine(
    database: connection.adapter,
    associationResolver: ({
      required String sourceModel,
      required String associationName,
    }) {
      final key = '$sourceModel.$associationName';
      switch (key) {
        case '$usersCollection.posts':
          return const MongoAssociationDefinition(
            sourceModel: usersCollection,
            associationName: 'posts',
            targetCollection: postsCollection,
            associationType: MongoAssociationType.hasMany,
            localField: '_id',
            foreignField: 'userId',
          );
        case '$postsCollection.user':
          return const MongoAssociationDefinition(
            sourceModel: postsCollection,
            associationName: 'user',
            targetCollection: usersCollection,
            associationType: MongoAssociationType.belongsTo,
            localField: 'userId',
            foreignField: '_id',
          );
        default:
          return null;
      }
    },
  );

  try {
    await connection.collection(usersCollection).deleteMany(where: {});
    await connection.collection(postsCollection).deleteMany(where: {});

    await engine.bulkCreate(
      modelName: usersCollection,
      data: const [
        {
          '_id': 'u1',
          'name': 'Alice',
          'role': 'developer',
          'isActive': true,
        },
        {
          '_id': 'u2',
          'name': 'Bob',
          'role': 'admin',
          'isActive': true,
        },
      ],
    );

    await engine.associationCreate(
      sourceModel: usersCollection,
      primaryKeyValues: const {'_id': 'u1'},
      associationName: 'posts',
      data: const {
        '_id': 'p1',
        'title': 'Hello MongoDB',
        'views': 100,
      },
    );

    final usersStartingWithA = await engine.findAll(
      modelName: usersCollection,
      query: Query(
        where: ComparisonOperator(
          column: 'name',
          value: {
            r'$startsWith': 'A',
          },
        ),
      ),
    );
    stdout.writeln('Users starting with A: ${usersStartingWithA.length}');

    final postsForAlice = await engine.associationGet(
      sourceModel: usersCollection,
      primaryKeyValues: const {'_id': 'u1'},
      associationName: 'posts',
    );
    stdout.writeln(
      'Posts for user u1: ${(postsForAlice as List<ModelInstanceData>).length}',
    );

    final relatedUser = await engine.belongsToGet(
      sourceModel: postsCollection,
      primaryKeyValues: const {'_id': 'p1'},
      associationName: 'user',
    );
    stdout.writeln('Post p1 belongs to user: ${relatedUser?.data['_id']}');
  } finally {
    await connection.close();
  }
}
