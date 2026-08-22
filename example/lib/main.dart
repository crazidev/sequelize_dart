import 'dart:async';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/queries.dart';
import 'package:sequelize_orm_sqlite/sequelize_orm_sqlite.dart';

const connectionString = 'mysql://root@localhost:3306/sequelize_dart';
const postgresConnectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

final sequelize = Sequelize().createInstance(
  // connection: SequelizeConnection.postgres(url: postgresConnectionString),
  // connection: SequelizeConnection.mysql(url: connectionString),
  connection: SequelizeSqliteConnection.tempMemory(),
  normalizeJsonTypes: false,
  debug: true,
  logging: SqlFormatter.printFormatted,
);

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance

  await sequelize.initialize(models: Db.allModels());

  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: SyncTableMode.force,
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  await sequelize.close();
}
