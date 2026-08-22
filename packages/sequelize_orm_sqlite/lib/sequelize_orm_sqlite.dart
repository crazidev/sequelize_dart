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

  /// Creates a temporary in-memory database (`:memory:`).
  ///
  /// Temporary storages are destroyed when the connection is closed; configure
  /// the connection pool to keep exactly one connection alive.
  factory SequelizeSqliteConnection.tempMemory({
    List<SqliteMode>? mode,
    String? password,
    bool foreignKeys = true,
    bool hoistIncludeOptions = false,
  }) {
    return SequelizeSqliteConnection(
      // ignore: avoid_redundant_argument_values
      storage: ':memory:',
      mode: mode,
      password: password,
      foreignKeys: foreignKeys,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a temporary disk-based database managed by SQLite.
  ///
  /// The database lives in an anonymous file on disk and is destroyed when the
  /// connection is closed; configure the connection pool to keep exactly one
  /// connection alive.
  factory SequelizeSqliteConnection.tempDisk({
    List<SqliteMode>? mode,
    String? password,
    bool foreignKeys = true,
    bool hoistIncludeOptions = false,
  }) {
    return SequelizeSqliteConnection(
      storage: '',
      mode: mode,
      password: password,
      foreignKeys: foreignKeys,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a persistent database at [path].
  ///
  /// The database file is created by SQLite if it doesn't exist.
  factory SequelizeSqliteConnection.fromPath(
    String path, {
    List<SqliteMode>? mode,
    String? password,
    bool foreignKeys = true,
    bool hoistIncludeOptions = false,
  }) {
    return SequelizeSqliteConnection(
      storage: path,
      mode: mode,
      password: password,
      foreignKeys: foreignKeys,
      hoistIncludeOptions: hoistIncludeOptions,
    );
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
