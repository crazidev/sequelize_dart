# Sequelize ORM QuickJS

An in-process [QuickJS](https://bellard.org/quickjs/) JavaScript engine for
[Sequelize Dart](https://pub.dev/packages/sequelize_orm). Embeds a full Sequelize
ORM runtime inside your Dart native binary via `dart:ffi` and vendored QuickJS C
sources — **no Node.js subprocess required**.

## Why

The default Sequelize Dart runtime executes queries in a Node.js child process
(or a Node worker thread on the web). That's not always available or desirable:

|                     | Node.js bridge            | QuickJS runtime                     |
| ------------------- | ------------------------- | ----------------------------------- |
| External dependency | Node.js 18+               | None                                |
| Execution           | Separate OS process       | In-process (FFI)                    |
| Platforms           | Desktop servers           | iOS, Android, macOS, Linux, Windows |
| Startup             | Process spawn per connect | Instant engine creation             |

## Features

- **Drop-in replacement** for the Node.js bridge — same `BridgeClientInterface`.
- **Embedded SQLite** — the SQLite amalgamation is compiled directly into the
  engine library (FTS5 + RTree enabled), so `SequelizeSqliteConnection` works
  without any external driver.
- **C-accelerated crypto** — SHA-256, HMAC-SHA256, and PBKDF2 implemented in C
  (used by PostgreSQL SCRAM-SHA-256 authentication).
- **Single bundle** — runs the exact same Sequelize bridge bundle as the
  Node.js runtime.

## Installation

```bash
dart pub add sequelize_orm sequelize_orm_quickjs
```

The native engine library is built automatically by the Dart native-assets
build hook when you build your application. A prebuilt development library is
bundled as a fallback.

## Usage

Override the bridge client before creating your Sequelize instance:

```dart
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_quickjs/sequelize_orm_quickjs.dart';
import 'package:sequelize_orm_sqlite/sequelize_orm_sqlite.dart';

Future<void> main() async {
  // Route all bridge traffic through the embedded QuickJS engine.
  BridgeClient.overrideWith(QuickJsBridgeClient.instance);

  final sequelize = Sequelize().createInstance(
    connection: SequelizeSqliteConnection.fromPath('./database.sqlite'),
  );

  await sequelize.initialize(models: Db.allModels());
  await sequelize.sync();

  // Use the ORM as usual...
  await sequelize.close();
}
```

Everything else — models, code generation, querying, associations,
transactions — works exactly as documented for
[`sequelize_orm`](https://pub.dev/packages/sequelize_orm).

## Notes

- Requires Dart SDK ^3.8.0 with native-assets support.
- The engine runs the Sequelize JavaScript bundle in-process; long-running
  queries do not block other isolates, but keep heavy work off the UI isolate
  on mobile.
- For benchmark comparisons against the Node.js bridge and other Dart ORMs,
  see the repository's `benchmarks/` suite (`Sequelize(QT)` entries).

## Documentation

- [Sequelize Dart documentation](https://sequelize-orm-dart.vercel.app)
- [Get started guide](https://sequelize-orm-dart.vercel.app/docs/get-started)
