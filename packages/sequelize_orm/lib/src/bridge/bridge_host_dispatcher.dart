import 'dart:async';

/// Callback type for host calls from the JavaScript bridge.
typedef HostCallHandler =
    FutureOr<dynamic> Function(Map<String, dynamic> params);

/// Central dispatcher for host calls made from the JS bridge back to Dart.
///
/// This enables dialects like SQLite to execute database operations via
/// Dart's native packages (e.g. `package:sqlite3`) without requiring
/// native C++ Node.js addons (`node_modules`) or OS libraries.
class BridgeHostDispatcher {
  BridgeHostDispatcher._();

  static final Map<String, HostCallHandler> _handlers = {};

  /// Register a host call handler for [method].
  static void register(String method, HostCallHandler handler) {
    _handlers[method] = handler;
  }

  /// Remove a registered handler for [method].
  static void unregister(String method) {
    _handlers.remove(method);
  }

  /// Check if a handler is registered for [method].
  static bool hasHandler(String method) => _handlers.containsKey(method);

  static Never _throwUnregisteredError(String method) {
    if (method.startsWith('sqlite_')) {
      throw StateError(
        'No host call handler registered for "$method".\n'
        'To use SQLite with Sequelize ORM, please add `sequelize_orm_sqlite` to your pubspec.yaml:\n'
        '  dependencies:\n'
        '    sequelize_orm_sqlite: ^latest\n'
        'and call `SequelizeSqlite.initialize()` before connecting.',
      );
    }
    throw StateError('No host call handler registered for "$method"');
  }

  /// Asynchronously dispatch a host call to the registered handler.
  static Future<dynamic> dispatch(
    String method,
    Map<String, dynamic> params,
  ) async {
    final handler = _handlers[method];
    if (handler == null) {
      _throwUnregisteredError(method);
    }
    return await handler(params);
  }

  /// Synchronously dispatch a host call (used by QuickJS in-process FFI).
  static dynamic dispatchSync(String method, Map<String, dynamic> params) {
    final handler = _handlers[method];
    if (handler == null) {
      _throwUnregisteredError(method);
    }
    final result = handler(params);
    if (result is Future) {
      throw StateError(
        'Handler for "$method" returned a Future during synchronous dispatch',
      );
    }
    return result;
  }
}
