/// Sequelize Dart - SQLite Dialect Package
///
/// Provides cross-platform SQLite database execution powered by `package:sqlite3`.
library;

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_sqlite/src/sqlite_host_dispatcher.dart';

export 'src/sqlite_host_dispatcher.dart';

/// SQLite connection configuration for Sequelize ORM.
///
/// Automatically initializes and registers SQLite host handlers on creation.
/// If [storage] is omitted or null, defaults to `':memory:'`.
class SequelizeSqliteConnection extends SqliteConnection {
  SequelizeSqliteConnection({
    super.storage,
    super.mode,
    String? password,
    super.foreignKeys,
    super.hoistIncludeOptions,
  }) : super(
         sqlitePassword: password,
       ) {
    SequelizeSqlite.initialize();
  }
}

/// Entry point to initialize and configure SQLite for Sequelize ORM.
class SequelizeSqlite {
  SequelizeSqlite._();

  static bool _initialized = false;

  /// Initialize and register SQLite dialect with the bridge dispatcher.
  static void initialize() {
    if (_initialized) return;
    _initialized = true;
    SqliteHostDispatcher.register();
  }

  /// Creates an auto-initializing SQLite connection configuration.
  ///
  /// If [storage] is omitted, defaults to `':memory:'`.
  static SequelizeSqliteConnection connection({
    String storage = ':memory:',
    List<SqliteMode>? mode,
    String? password,
    bool foreignKeys = true,
    bool hoistIncludeOptions = false,
  }) {
    return SequelizeSqliteConnection(
      storage: storage,
      mode: mode,
      password: password,
      foreignKeys: foreignKeys,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }
}
