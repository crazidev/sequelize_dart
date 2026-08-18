import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:sequelize_orm/src/bridge/bridge_client_interface.dart';
import 'package:sequelize_orm/src/bridge/bridge_exception.dart';
import 'package:sequelize_orm/src/bridge/bridge_latency.dart';
import 'package:sequelize_orm/src/bridge/sequelize_exceptions.dart';

import 'quickjs_runtime.dart';

/// An in-process Sequelize bridge client powered by an embedded QuickJS engine.
///
/// This is a drop-in replacement for the Node.js subprocess bridge. Instead
/// of spawning a Node.js process and communicating over stdio, all Sequelize
/// JavaScript executes inside a QuickJS engine embedded directly in the Dart
/// native binary via [dart:ffi].
///
/// ## Usage
///
/// ```dart
/// import 'package:sequelize_orm_quickjs/sequelize_orm_quickjs.dart';
///
/// // Set before calling sequelize.connect()
/// BridgeClient.overrideWith(QuickJsBridgeClient.instance);
/// ```
///
/// ## How it works
///
/// 1. On [start], the QuickJS runtime is created and the bundled Sequelize
///    bridge JavaScript (`bridge_server.bundle.js`) is evaluated inside it.
/// 2. [call] invocations dispatch directly to the in-process JS
///    `_dart_handleRequest()` function — no subprocess, no IPC overhead.
/// 3. TCP connections to PostgreSQL/MySQL are routed through Dart's
///    `dart:io` [Socket] and bridged back into the QuickJS context.
class QuickJsBridgeClient implements BridgeClientInterface {
  QuickJsRuntime? _runtime;
  bool _isConnected = false;
  bool _isClosed = false;
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;
  int _requestId = 1;

  Function(String sql)? _loggingCallback;

  /// Optional latency callback for benchmarking.
  void Function(BridgeLatencyInfo info)? latencyCallback;

  QuickJsBridgeClient._();

  static QuickJsBridgeClient? _instance;

  /// The singleton [QuickJsBridgeClient] instance.
  static QuickJsBridgeClient get instance {
    _instance ??= QuickJsBridgeClient._();
    return _instance!;
  }

  // ────────────────────────────────────────────────────────────────────────
  // BridgeClientInterface
  // ────────────────────────────────────────────────────────────────────────

  @override
  void setLoggingCallback(Function(String sql)? callback) {
    _loggingCallback = callback;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isClosed => _isClosed;

  @override
  bool get isInitializing => _isInitializing;

  @override
  Future<void> waitForInitialization() async {
    if (_isInitializing && _initializationCompleter != null) {
      return _initializationCompleter!.future;
    }
  }

  @override
  Future<void> start({
    required Map<String, dynamic> connectionConfig,
    String? nodePath, // Ignored — no Node.js used.
    String? bridgePath,
  }) async {
    // Already running — no-op.
    if (_runtime != null && !_isClosed && _isConnected) return;

    // Already initialising — wait for it.
    if (_isInitializing && _initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    _isInitializing = true;
    _initializationCompleter = Completer<void>();
    // Prevent unhandled zone error if completeError is called without external listeners
    _initializationCompleter!.future.catchError((_) {});

    try {
      // 1. Create the in-process QuickJS runtime with polyfills.
      _runtime = await QuickJsRuntime.create();

      // 2. Load the Sequelize bridge bundle JS into the QuickJS context.
      final bundleJs = await _loadBundleJs(bridgePath);
      _runtime!.loadBundle(bundleJs);

      // 3. Install the async dispatch shim so Dart can call handleRequest / processRequest.
      _runtime!.eval(r"""
        globalThis._dart_handleRequest = async function(params) {
          const req = JSON.parse(params.requestJson);
          if (typeof globalThis.handleRequest === 'function') {
            return await globalThis.handleRequest(req.method, req.params);
          }
          if (typeof processRequest === 'function') {
            return new Promise((resolve) => {
              processRequest(req, (response) => resolve(response));
            });
          }
          throw new Error('No request handler found in QuickJS bundle');
        };
      """);

      _runtime!.onNotification = (notification) {
        if (notification['notification'] == 'sql_log') {
          final sql = notification['sql'] as String?;
          if (sql != null) _loggingCallback?.call(sql);
        }
      };

      // 4. Connect to database.
      _isClosed = false;
      await _connectToDatabase(connectionConfig);

      _isInitializing = false;
      if (!_initializationCompleter!.isCompleted) {
        _initializationCompleter!.complete();
      }
      _initializationCompleter = null;
    } catch (e) {
      _isInitializing = false;
      _isClosed = true;
      _isConnected = false;
      if (_initializationCompleter != null &&
          !_initializationCompleter!.isCompleted) {
        _initializationCompleter!.completeError(e);
      }
      _initializationCompleter = null;
      _runtime?.dispose();
      _runtime = null;
      rethrow;
    }
  }

  @override
  Future<dynamic> call(String method, Map<String, dynamic> params) async {
    if (_isClosed) throw BridgeException('QuickJS bridge is closed');
    if (_runtime == null) {
      throw BridgeException('QuickJS runtime not started — call start() first');
    }

    final id = _requestId++;
    final request = {'id': id, 'method': method, 'params': params};
    final requestJson = jsonEncode(request);

    final stopwatch = Stopwatch()..start();

    // Dispatch into the QuickJS context — runs Sequelize in-process.
    final response = await _runtime!.callAsync(
      '_dart_handleRequest',
      {'requestJson': requestJson},
    );

    final callTime = stopwatch.elapsedMilliseconds;
    // ignore: avoid_print
    print(
        '[QuickJsBridgeClient] _runtime.callAsync("$method") took $callTime ms');
    stopwatch.reset();

    // response is the decoded JS object (Map).
    Map<String, dynamic> responseMap;
    if (response is Map) {
      responseMap = Map<String, dynamic>.from(response);
    } else {
      responseMap = jsonDecode(response.toString()) as Map<String, dynamic>;
    }
    final decodeTime = stopwatch.elapsedMilliseconds;
    if (decodeTime > 2) {
      // ignore: avoid_print
      print('[QuickJsBridgeClient] response decode took $decodeTime ms');
    }

    // Handle SQL logging notifications.
    if (responseMap['notification'] == 'sql_log') {
      final sql = responseMap['sql'] as String?;
      if (sql != null) _loggingCallback?.call(sql);
      return null;
    }

    // Report latency.
    final serverMs = responseMap['_serverMs'] as int?;
    final cb = latencyCallback;
    if (cb != null) {
      cb(BridgeLatencyInfo(
        method: method,
        roundTrip: stopwatch.elapsed,
        serverTime: serverMs != null ? Duration(milliseconds: serverMs) : null,
      ));
    }

    if (responseMap.containsKey('error')) {
      final error = responseMap['error'];
      if (error is Map) {
        if (error['stack'] != null && error['stack'].toString().isNotEmpty) {
          // ignore: avoid_print
          print('[QuickJS Error Stack]\n${error['stack']}');
        }
        throw SequelizeException.fromBridge(Map<String, dynamic>.from(error));
      }
      throw BridgeException(
          error?.toString() ?? 'Unknown QuickJS bridge error');
    }

    return responseMap['result'];
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;

    if (_runtime != null) {
      try {
        await call('close', {}).timeout(const Duration(milliseconds: 500));
      } catch (_) {
        // Ignore errors during shutdown.
      }
    }

    _isClosed = true;
    _isConnected = false;
    _runtime?.dispose();
    _runtime = null;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Internal helpers
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _connectToDatabase(Map<String, dynamic> config) async {
    final result = await call('connect', {'config': config});
    if (result is Map && result['connected'] == true) {
      _isConnected = true;
    } else {
      throw BridgeException('QuickJS bridge: failed to connect to database');
    }
  }

  Future<String> _loadBundleJs(String? customPath) async {
    final bundlePath = customPath ?? await _findBundlePath();
    if (!File(bundlePath).existsSync()) {
      throw BridgeException(
        'Bridge bundle not found at: $bundlePath\n'
        'Run: dart run tools/build_js.dart to rebuild it.',
      );
    }
    return File(bundlePath).readAsStringSync();
  }

  Future<String> _findBundlePath() async {
    const bundleNames = [
      'bridge_server_quickjs.bundle.js',
      'bridge_server.bundle.js',
    ];

    for (final name in bundleNames) {
      // Try package URI resolution first (works in JIT / dev).
      try {
        final uri = Uri.parse('package:sequelize_orm/src/bridge/$name');
        final resolved = await Isolate.resolvePackageUri(uri);
        if (resolved != null && resolved.scheme == 'file') {
          final filePath = resolved.toFilePath();
          if (File(filePath).existsSync()) return p.absolute(filePath);
        }
      } catch (_) {}

      // Fallback: search relative paths.
      final candidates = [
        'packages/sequelize_orm/lib/src/bridge/$name',
        '../packages/sequelize_orm/lib/src/bridge/$name',
        '../../packages/sequelize_orm/lib/src/bridge/$name',
        p.join(
          p.dirname(Platform.resolvedExecutable),
          'packages/sequelize_orm/lib/src/bridge/$name',
        ),
      ];

      for (final c in candidates) {
        if (File(c).existsSync()) return p.absolute(c);
      }

      // Walk up from current dir.
      var dir = Directory.current;
      for (var i = 0; i < 5; i++) {
        final probe = File(
            p.join(dir.path, 'packages/sequelize_orm/lib/src/bridge/$name'));
        if (probe.existsSync()) return probe.absolute.path;
        if (dir.parent.path == dir.path) break;
        dir = dir.parent;
      }
    }

    return 'packages/sequelize_orm/lib/src/bridge/bridge_server_quickjs.bundle.js';
  }
}
