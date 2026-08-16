# Sequelize ORM – Tools

Cross-platform tooling and developer CLI for **Windows, macOS, and Linux**. All commands run via Dart so they work everywhere without Bash.

## Global Installation (Dart Global Package)

You can activate the tools package globally on your system:

```bash
dart pub global activate --source path ./tools
```

Once activated, run commands directly using `sqtools`, `sequelize_orm_tools`, or `tools`:

```bash
sqtools benchmark
sqtools benchmark --seed
sqtools build
sqtools format
```

_(Make sure `$HOME/.pub-cache/bin` is in your `PATH`)_.

---

## Workspace Runner (Local)

Run directly from the repository root without global activation:

```bash
dart run tools/run.dart <command> [options]
dart run tools/run.dart --help
```

---

## Commands

| Command            | Description                                                                                                                    |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| `benchmark`        | Run multi-ORM comparative benchmark suite (`Sequelize ORM`, `Drift`, `Serverpod`). Options: `--seed`, `--posts=N`, `--users=N` |
| `benchmark-bridge` | Measure round-trip latency between Dart and the bridge                                                                         |
| `build`            | Compile Dart to JS (default: `example/lib/main.dart` → `index.js`). Options: `--input=FILE`, `--output=NAME`                   |
| `setup-bridge`     | Install and build bridge server (`bun`, `pnpm`, or `npm`). Options: `--skip-install`, `--skip-cleanup`                         |
| `format`           | Format Dart and JS/JSON/MD (dart format + Prettier)                                                                            |
| `watch-models`     | Watch model files and run build_runner                                                                                         |
| `watch-dart`       | Watch Dart files and restart VM server on change                                                                               |
| `watch-js`         | Watch Dart files and recompile to JS on change                                                                                 |
| `watch-bridge`     | Watch TypeScript and rebuild bridge on change                                                                                  |
| `setup-db`         | Start database in Docker (postgres, mysql, mariadb) for dev or testing (`--dev`, `--test`, `--reset`)                          |
| `setup-dev`        | Start PostgreSQL in Docker for development                                                                                     |
| `setup-git-hooks`  | Install git hooks from `.github/hooks`                                                                                         |
| `test`             | Run tests (forwards to `tools/test.dart`)                                                                                      |
| `release`          | Release/publish (forwards to `tools/release_publish.dart`)                                                                     |
| `all-build`        | Full build: setup-bridge → models → dart2js                                                                                    |

---

## VS Code

- **Tasks**: Use **Terminal → Run Task**. All build and watch tasks call `dart run tools/run.dart` so they work on every OS.
- **Launch**: **Debug Node.js (dart2js)** uses the **Build: dart2js** task. **Run Tests (tools)** runs `dart run tools/run.dart test`.
