import 'dart:async';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/queries.dart';

const connectionString = 'mysql://root@localhost:3306/sequelize_dart';
const postgresConnectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

final sequelize = Sequelize().createInstance(
  connection: SequelizeConnection.postgres(url: postgresConnectionString),
  // connection: SequelizeConnection.mysql(url: connectionString),
  normalizeJsonTypes: false,
  debug: true,
  logging: SqlFormatter.printFormatted,
);

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance

  await sequelize.initialize(models: Db.allModels());

  // await sequelize.sync(alter: true);

  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: SyncTableMode.alter,
  );

  // Run queries - all query logic is in queries.dart
  // Timer.periodic(const Duration(seconds: 1), (timer) {
  runQueries();
  // });

  // Close the connection to free up resources
  // await sequelize.close();
}
