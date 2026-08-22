# Changelog

All notable changes to `sequelize_orm_sqlite` are documented in this file.

## 0.2.0

- Initial release: SQLite execution for Sequelize Dart, powered by [`package:sqlite3`](https://pub.dev/packages/sqlite3).
- **FEAT**: `SequelizeSqliteConnection` — auto-initializing drop-in replacement for `SequelizeConnection.sqlite()` with `storage`, `mode`, `password` (SQLCipher), `foreignKeys`, and `hoistIncludeOptions` options.
- **FEAT**: Typed constructors — `SequelizeSqliteConnection.tempMemory()` and `.tempDisk()` for temporary databases, and `SequelizeSqliteConnection.fromPath(String)` for persistent databases (no `dart:io` dependency).
- **FEAT**: Temporary storages automatically configure the connection pool for data safety — no manual pool setup required.
- **FEAT**: `SequelizeSqlite.initialize()` / `SequelizeSqlite.connection()` entry points.
- **FEAT**: `SqliteHostDispatcher.register()` — installs the SQLite host handlers used by the bridge (`sqlite_open`, `sqlite_query`, `sqlite_run`, `sqlite_exec`, `sqlite_close`).
