import 'dart:async';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/queries.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';

const connectionString = 'mysql://root@localhost:3306/sequelize_dart';
const postgresConnectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

const mongoUrl = 'mongodb://localhost:27017';
const mongoDatabase = 'sequelize_dart';

final sequelize = Sequelize().createInstance(
  // connection: SequelizeConnection.postgres(url: postgresConnectionString),
  connection: MongoConnectionOptions(
    url: mongoUrl,
    database: mongoDatabase,
  ),
  logging: (message) {
    if (message.startsWith('[mongo:')) {
      MongoDbFormatter.printFormatted(message);
      return;
    }
    SqlFormatter.printFormatted(message);
  },
  normalizeJsonTypes: false,
);

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  sequelize.useMongoQueryEngine();

  await sequelize.initialize(
    models: Db.allModels(),
  );

  await sequelize.sync();

  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: SyncTableMode.alter,
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  await sequelize.close();
}
