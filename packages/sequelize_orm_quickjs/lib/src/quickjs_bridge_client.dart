import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// ignore_for_file: implementation_imports
import 'package:path/path.dart' as p;
import 'package:sequelize_orm/src/bridge/bridge_client_interface.dart';
import 'package:sequelize_orm/src/bridge/bridge_exception.dart';
import 'package:sequelize_orm/src/bridge/bridge_latency.dart';
import 'package:sequelize_orm/src/bridge/sequelize_exceptions.dart';
import 'package:sequelize_orm_quickjs/src/quickjs_runtime.dart';

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
class QuickJsBridgeClient implements BridgeClientInterface {
  QuickJsRuntime? _runtime;
  bool _isConnected = false;
  bool _isClosed = false;
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;
  int _requestId = 1;

  Function(String sql)? _loggingCallback;

  /// Optional latency callback for benchmarking.
  @override
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
    _initializationCompleter!.future.catchError((_) {});

    try {
      // 1. Create the in-process QuickJS runtime with polyfills.
      _runtime = await QuickJsRuntime.create();

      // 2. Load the Sequelize bridge bundle JS into the QuickJS context.
      final bundleJs = await _loadBundleJs(bridgePath);
      _runtime!.loadBundle(bundleJs);

      // 3. Install the direct async dispatch shim.
      _runtime!.eval(r"""
        globalThis._dart_handleRequest = async function(promiseId, params) {
          try {
            const req = params.requestJson ? JSON.parse(params.requestJson) : params;
            let response;
            if (typeof globalThis.handleRequest === 'function') {
              response = await globalThis.handleRequest(req.method, req.params);
            } else if (typeof processRequest === 'function') {
              response = await new Promise((resolve) => {
                processRequest(req, (res) => resolve(res));
              });
            } else {
              throw new Error('No request handler found in QuickJS bundle');
            }
            _ffiNotify('_dart_promise_resolve', JSON.stringify({id: promiseId, value: response}));
          } catch (err) {
            console.error('[QuickJS handleRequest Error]:', err, err ? err.stack : '');
            _ffiNotify('_dart_promise_reject', JSON.stringify({id: promiseId, error: String(err?.message || err)}));
          }
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
    final stopwatch = Stopwatch()..start();

    // Dispatch directly into the QuickJS context without JS eval or double JSON stringification
    final response = await _runtime!.callAsync(
      '_dart_handleRequest',
      {
        'id': id,
        'method': method,
        'params': params,
      },
    );

    // response is the decoded JS object (Map).
    Map<String, dynamic> responseMap;
    if (response is Map) {
      responseMap = Map<String, dynamic>.from(response);
    } else {
      responseMap = jsonDecode(response.toString()) as Map<String, dynamic>;
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
      } catch (_) {}
    }

    _isClosed = true;
    _isConnected = false;
    _runtime?.dispose();
    _runtime = null;
  }

  Future<void> _connectToDatabase(Map<String, dynamic> config) async {
    final response = await call('connect', {'config': config});
    if (response != null &&
        response is Map &&
        (response['connected'] == true || response['authenticated'] == true)) {
      _isConnected = true;
    } else {
      _isConnected = false;
      throw BridgeException('Failed to authenticate with database via QuickJS');
    }
  }

  Future<String> _loadBundleJs(String? explicitPath) async {
    if (explicitPath != null && explicitPath.isNotEmpty) {
      final file = File(explicitPath);
      if (await file.exists()) {
        return file.readAsString();
      }
    }

    final candidatePaths = <String>[];

    try {
      final exeDir = File(Platform.resolvedExecutable).parent;
      final bundleDir = exeDir.parent;
      candidatePaths.add(
        p.join(bundleDir.path, 'lib', 'src', 'bridge',
            'bridge_server_quickjs.bundle.js'),
      );
      candidatePaths.add(
        p.join(bundleDir.path, 'assets', 'bridge_server_quickjs.bundle.js'),
      );
    } catch (_) {}

    try {
      final pkgUri = Uri.parse(
          'package:sequelize_orm/src/bridge/bridge_server_quickjs.bundle.js');
      final resolved = await Isolate.resolvePackageUri(pkgUri);
      if (resolved != null && resolved.scheme == 'file') {
        candidatePaths.add(resolved.toFilePath());
      }
    } catch (_) {}

    final cwd = Directory.current.path;
    candidatePaths.addAll([
      p.join(cwd, 'packages', 'sequelize_orm', 'lib', 'src', 'bridge',
          'bridge_server_quickjs.bundle.js'),
      p.join(cwd, '..', 'sequelize_orm', 'lib', 'src', 'bridge',
          'bridge_server_quickjs.bundle.js'),
      p.join(cwd, 'lib', 'src', 'bridge', 'bridge_server_quickjs.bundle.js'),
    ]);

    for (final path in candidatePaths) {
      final file = File(path);
      if (await file.exists()) {
        return file.readAsString();
      }
    }

    throw StateError(
      'Could not find bridge_server_quickjs.bundle.js. Tried:\n'
      '${candidatePaths.map((e) => ' - $e').join('\n')}',
    );
  }
}
