# Sequelize ORM SQLite

SQLite dialect support for [Sequelize Dart](https://pub.dev/packages/sequelize_orm), powered by [`package:sqlite3`](https://pub.dev/packages/sqlite3).

## Installation

```bash
dart pub add sequelize_orm sequelize_orm_sqlite
```

## Usage

Use `SequelizeSqliteConnection` in place of `SequelizeConnection.sqlite()`.
It automatically registers the SQLite handlers:

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_sqlite/sequelize_orm_sqlite.dart';

final sequelize = Sequelize().createInstance(
  connection: SequelizeSqliteConnection.fromPath('./database.sqlite'),
);

await sequelize.initialize(models: Db.allModels());
await sequelize.sync();
```

### Constructors

| Constructor                                | Storage          | Description                                 |
| ------------------------------------------ | ---------------- | ------------------------------------------- |
| `SequelizeSqliteConnection.fromPath(path)` | parsed from path | Persistent database at the given location.  |
| `SequelizeSqliteConnection.tempMemory()`   | `':memory:'`     | Temporary database in RAM.                  |
| `SequelizeSqliteConnection.tempDisk()`     | `''`             | Temporary anonymous file managed by SQLite. |

### Options

All constructors accept the following optional parameters.

| Option                | Type                | Default | Description                                            |
| --------------------- | ------------------- | ------- | ------------------------------------------------------ |
| `foreignKeys`         | `bool`              | `true`  | If set to false, SQLite will not enforce foreign keys. |
| `mode`                | `List<SqliteMode>?` | -       | Opening flags (read, write, create, mutex).            |
| `password`            | `String?`           | -       | Password for SQLCipher encryption.                     |
| `hoistIncludeOptions` | `bool?`             | -       | Hoist include options into nested queries.             |

> **Note**: Temporary storages (`tempMemory()` / `tempDisk()`) require a single
> never-closed connection to preserve data. This pool configuration is applied
> automatically — no manual setup needed.

```dart
final sequelize = Sequelize().createInstance(
  connection: SequelizeSqliteConnection.tempMemory(),
);
```

## Documentation

- [Sequelize Dart documentation](https://sequelize-orm-dart.vercel.app)
- [Database connection guide](https://sequelize-orm-dart.vercel.app/docs/databases)
