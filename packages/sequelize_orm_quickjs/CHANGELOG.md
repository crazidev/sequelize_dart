# Changelog

All notable changes to `sequelize_orm_quickjs` are documented in this file.

## 0.1.0

- Initial release: embeds a full Sequelize ORM runtime inside the Dart process
  via QuickJS C (vendored) and `dart:ffi` — no Node.js subprocess required.
  Supports iOS, Android, Linux, macOS, and Windows.
- **FEAT**: Native in-process SQLite — the vendored SQLite amalgamation (`sqlite3.c`) is compiled directly into `libquickjs_dart` by the native-assets build hook (FTS5 + RTree enabled) and exposed to the JS bridge via the `_native_sqlite` global, with per-runtime handle tables and LRU prepared-statement caching implemented in C.
- **FEAT**: The embedded Sequelize bridge uses a single unified bundle shared with the Node.js runtime; SQLite resolves natively inside QuickJS instead of falling back to Dart host calls.
- **IMPROVEMENT**: Runtime polyfills and FFI transport for the unified bridge (binary MessagePack responses, socket/timer/crypto shims).
