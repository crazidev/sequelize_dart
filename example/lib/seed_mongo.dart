import 'dart:io';

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
  final engine = MongoQueryEngine(database: connection.adapter);

  try {
    await connection.collection(usersCollection).deleteMany(where: {});
    await connection.collection(postsCollection).deleteMany(where: {});

    final now = DateTime.now().toUtc().toIso8601String();
    await engine.bulkCreate(
      modelName: usersCollection,
      data: [
        {
          '_id': 'seed-u1',
          'email': 'dev@example.com',
          'firstName': 'Crazibeat',
          'lastName': 'Dev',
          'role': 'developer',
          'isActive': true,
          'createdAt': now,
        },
        {
          '_id': 'seed-u2',
          'email': 'admin@example.com',
          'firstName': 'Ada',
          'lastName': 'Lovelace',
          'role': 'admin',
          'isActive': true,
          'createdAt': now,
        },
      ],
    );

    await engine.bulkCreate(
      modelName: postsCollection,
      data: [
        {
          '_id': 'seed-p1',
          'userId': 'seed-u1',
          'title': 'Mongo seed post',
          'views': 10,
          'createdAt': now,
        },
      ],
    );

    final userCount = await engine.count(modelName: usersCollection);
    final postCount = await engine.count(modelName: postsCollection);
    stdout.writeln(
      'Mongo seed complete: $userCount users, $postCount posts in '
      '$mongoDatabase',
    );
  } finally {
    await connection.close();
  }
}
