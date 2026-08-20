import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sequelize_orm/src/bridge/bridge_client_interface.dart';
import 'package:sequelize_orm/src/bridge/bridge_exception.dart';
import 'package:sequelize_orm/src/bridge/bridge_latency.dart';
import 'package:sequelize_orm/src/bridge/sequelize_exceptions.dart';
import 'package:sequelize_orm/src/utils/msgpack_decoder.dart';
import 'package:sequelize_orm/src/utils/parse_helpers.dart';

/// Client for communicating with the Node.js Sequelize bridge server.
/// Uses stdio (stdin/stdout) for Dart VM environments.
class BridgeClient implements BridgeClientInterface {
  Process? _process;
  StreamController<String> _responseController =
      StreamController<String>.broadcast();
  final Map<int, Completer<dynamic>> _pendingRequests = {};
  int _requestId = 1;
  bool _isConnected = false;
  bool _isClosed = false;
  Completer<void>? _initializationCompleter;
  bool _isInitializing = false;

  /// Callback for SQL logging
  Function(String sql)? _loggingCallback;

  /// Optional callback invoked after every bridge call with latency details.
  /// Use this in tests or benchmark tools.
  ///
  /// Example:
  /// ```dart
  /// BridgeClient.instance.latencyCallback = (info) {
  ///   print(info); // BridgeLatencyInfo(findAll: 12ms total, 8ms server, 4ms overhead)
  /// };
  /// ```
  void Function(BridgeLatencyInfo info)? latencyCallback;

  BridgeClient._();

  @override
  void setLoggingCallback(Function(String sql)? callback) {
    _loggingCallback = callback;
  }

  static BridgeClient? _instance;
  static BridgeClientInterface? _customInstance;

  /// Override the active BridgeClient singleton with a custom implementation
  /// (such as QuickJsBridgeClient).
  static void overrideWith(BridgeClientInterface client) {
    _customInstance = client;
  }

  /// Reset any custom bridge override to the default stdio bridge.
  static void resetOverride() {
    _customInstance = null;
  }

  /// Get the active bridge client instance
  static BridgeClientInterface get instance {
    return _customInstance ?? (_instance ??= BridgeClient._());
  }

  @override
  Future<void> start({
    required Map<String, dynamic> connectionConfig,
    String? nodePath,
    String? bridgePath,
  }) async {
    // If already initializing, wait for it to complete
    if (_isInitializing && _initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    // If already started and connected, return immediately
    if (_process != null && !_isClosed && _isConnected) {
      return;
    }

    // If already started but not connected, just connect
    if (_process != null && !_isClosed) {
      await _connect(connectionConfig);
      return;
    }

    // Recreate response controller if closed
    if (_isClosed) {
      _responseController = StreamController<String>.broadcast();
    }

    // Start initialization
    _isInitializing = true;
    _initializationCompleter = Completer<void>();

    // Find the bridge server path
    final serverPath = bridgePath ?? await _findBridgeServerPath();

    if (!File(serverPath).existsSync()) {
      _isInitializing = false;
      _initializationCompleter?.completeError(
        Exception(
          'Bridge server not found at: $serverPath\n'
          'Make sure to run: ./tools/setup_bridge.sh to build the bundle',
        ),
      );
      _initializationCompleter = null;
      throw Exception(
        'Bridge server not found at: $serverPath\n'
        'Make sure to run: ./tools/setup_bridge.sh to build the bundle',
      );
    }

    // Collect stderr for error reporting
    final stderrBuffer = StringBuffer();
    final stderrCompleter = Completer<void>();

    // Start Node.js process
    _process = await Process.start(
      nodePath ?? _findNodePath(),
      [serverPath],
      workingDirectory: p.dirname(serverPath),
    );

    _isClosed = false;

    // Listen to stdout for MessagePack binary responses
    final builder = BytesBuilder(copy: false);

    _process!.stdout.listen(
      (chunk) {
        builder.add(chunk);
        var bytes = builder.takeBytes();
        var offset = 0;

        while (bytes.length - offset >= 4) {
          final bd = ByteData.sublistView(bytes, offset, offset + 4);
          final frameLen = bd.getUint32(0, Endian.big);

          if (bytes.length - offset < 4 + frameLen) {
            break;
          }

          final frameBytes = Uint8List.sublistView(
            bytes,
            offset + 4,
            offset + 4 + frameLen,
          );
          offset += 4 + frameLen;

          try {
            final decoded = FastMsgPackDecoder.decode(frameBytes);
            if (decoded is Map) {
              if (_isInitializing) {
                _responseController.add(jsonEncode(decoded));
              }
              _handleDecodedResponse(decoded);
            }
          } catch (e) {
            // ignore: avoid_print
            print('[BridgeClient] Failed to decode MsgPack frame: $e');
          }
        }

        if (offset < bytes.length) {
          builder.add(Uint8List.sublistView(bytes, offset));
        }
      },
      onError: (error) {
        // ignore: avoid_print
        print('[BridgeClient] stdout error: $error');
      },
    );

    // Listen to stderr for errors
    _process!.stderr
        .transform(utf8.decoder)
        .listen(
          (data) {
            stderrBuffer.writeln(data);
          },
          onDone: () {
            stderrCompleter.complete();
          },
          onError: (error) {
            stderrCompleter.completeError(error);
          },
        );

    // Handle process exit
    final bridgeProcess = _process;
    _process!.exitCode.then((code) {
      if (_process != bridgeProcess) return;
      if (!_isClosed && code != 0) {
        final stderr = stderrBuffer.toString();
        final errorMsg = stderr.isNotEmpty
            ? 'Bridge server exited with code $code.\nError: $stderr'
            : 'Bridge server exited with code $code';
        // ignore: avoid_print
        print('[BridgeClient] Process exited with code: $code');
        _cleanup();
        throw BridgeException(errorMsg);
      } else if (!_isClosed) {
        // ignore: avoid_print
        print('[BridgeClient] Process exited with code: $code');
        _cleanup();
      }
    });

    // Wait for ready signal with timeout
    try {
      await _waitForReady();
    } catch (e) {
      _isInitializing = false;
      _initializationCompleter?.completeError(e);
      _initializationCompleter = null;
      final stderr = stderrBuffer.toString();
      final errorMsg = stderr.isNotEmpty
          ? 'Failed to start bridge server: $e\nError output: $stderr'
          : 'Failed to start bridge server: $e';
      throw BridgeException(errorMsg);
    }

    // Connect to database
    try {
      await _connect(connectionConfig);
      _isInitializing = false;
      _initializationCompleter?.complete();
      _initializationCompleter = null;
    } catch (e) {
      _isInitializing = false;
      _initializationCompleter?.completeError(e);
      _initializationCompleter = null;
      final stderr = stderrBuffer.toString();
      if (stderr.isNotEmpty && e is BridgeException && e.message.isEmpty) {
        throw BridgeException(
          'Failed to connect to database.\nError output: $stderr',
        );
      }
      rethrow;
    }
  }

  /// Find Node.js path
  String _findNodePath() {
    // Try common Node.js paths
    final possiblePaths = [
      '/usr/local/bin/node',
      '/usr/bin/node',
      // NVM paths
      '${Platform.environment['HOME']}/.nvm/versions/node/v22.9.0/bin/node',
      '${Platform.environment['HOME']}/.nvm/versions/node/v20.0.0/bin/node',
      '${Platform.environment['HOME']}/.nvm/versions/node/v18.0.0/bin/node',
    ];

    for (final path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }

    // Fallback to just 'node' and hope it's in PATH
    return 'node';
  }

  /// Find the bridge server path relative to the package
  Future<String> _findBridgeServerPath() async {
    try {
      final packageUri = Uri.parse(
        'package:sequelize_orm/src/bridge/bridge_server.bundle.js',
      );
      final resolvedUri = await Isolate.resolvePackageUri(packageUri);
      if (resolvedUri != null && resolvedUri.scheme == 'file') {
        final filePath = resolvedUri.toFilePath();
        if (File(filePath).existsSync()) {
          return p.absolute(filePath);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[BridgeClient] Failed to resolve package URI for bundle: $e');
    }

    // In AOT binaries, Isolate.resolvePackageUri returns null.
    // Search current directory, parent directories, and executable path.
    final candidatePaths = [
      'packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
      '../packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
      '../../packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
      p.join(
        p.dirname(Platform.resolvedExecutable),
        'packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
      ),
      p.join(
        p.dirname(Platform.resolvedExecutable),
        '../packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
      ),
    ];

    for (final candidate in candidatePaths) {
      if (File(candidate).existsSync()) {
        return p.absolute(candidate);
      }
    }

    // Traverse upward from Directory.current to find repo root
    var dir = Directory.current;
    for (var i = 0; i < 5; i++) {
      final probe = File(
        p.join(
          dir.path,
          'packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
        ),
      );
      if (probe.existsSync()) {
        return probe.absolute.path;
      }
      if (dir.parent.path == dir.path) break;
      dir = dir.parent;
    }

    return 'packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js';
  }

  /// Wait for the ready signal from the bridge server
  Future<void> _waitForReady() async {
    final completer = Completer<void>();

    late StreamSubscription<String> subscription;
    subscription = _responseController.stream.listen((line) {
      try {
        final response = jsonDecode(line);
        if (response['id'] == 0 && response['result']?['ready'] == true) {
          subscription.cancel();
          completer.complete();
        }
      } catch (e) {
        // Ignore parse errors during initial wait
      }
    });

    // Timeout after 10 seconds
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
        throw Exception('Timeout waiting for bridge server to be ready');
      },
    );
  }

  /// Connect to the database
  Future<void> _connect(Map<String, dynamic> connectionConfig) async {
    final result = await call('connect', {'config': connectionConfig});
    if (result['connected'] == true) {
      _isConnected = true;
    } else {
      throw Exception('Failed to connect to database');
    }
  }

  /// Handle a decoded MessagePack response map from the bridge server
  void _handleDecodedResponse(Map response) {
    try {
      // Handle SQL log notifications
      if (response['notification'] == 'sql_log') {
        final sql = response['sql'] as String?;
        if (sql != null && _loggingCallback != null) {
          _loggingCallback!(sql);
        }
        return;
      }

      // Handle general log notifications
      if (response['notification'] == 'log') {
        final message = response['message'] as String?;
        if (message != null) {
          // ignore: avoid_print
          print(message);
        }
        return;
      }

      final id = response['id'];

      if (id is int && _pendingRequests.containsKey(id)) {
        final completer = _pendingRequests.remove(id)!;

        // Stash the server-side elapsed time and breakdown so call() can pick it up.
        _serverMsById[id] = response['_serverMs'] as int?;
        if (response['_serverBreakdown'] is Map) {
          final rawMap = response['_serverBreakdown'] as Map;
          _serverBreakdownById[id] = rawMap.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          );
        }

        if (response.containsKey('error')) {
          final error = response['error'];
          if (error is Map) {
            completer.completeError(
              SequelizeException.fromBridge(Map<String, dynamic>.from(error)),
            );
          } else {
            completer.completeError(
              BridgeException(error?.toString() ?? 'Unknown error'),
            );
          }
        } else {
          completer.complete(unpackTabularResult(response['result']));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[BridgeClient] Failed to parse response: $e');
    }
  }

  // Per-pending-request server-time storage (populated by _handleResponse).
  final Map<int, int?> _serverMsById = {};
  final Map<int, Map<String, double>?> _serverBreakdownById = {};

  @override
  Future<dynamic> call(String method, Map<String, dynamic> params) async {
    if (_isClosed) {
      throw Exception('Bridge is closed');
    }

    if (_process == null) {
      throw Exception('Bridge is not started. Call start() first.');
    }

    final id = _requestId++;
    final request = jsonEncode({'id': id, 'method': method, 'params': params});

    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    final stopwatch = Stopwatch()..start();
    _process!.stdin.writeln(request);

    final result = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(id);
        _serverMsById.remove(id);
        _serverBreakdownById.remove(id);
        throw Exception('Request timeout: $method');
      },
    );
    stopwatch.stop();

    // Report latency to the registered callback (if any).
    final cb = latencyCallback;
    if (cb != null) {
      final serverMs = _serverMsById.remove(id);
      final serverBreakdown = _serverBreakdownById.remove(id);
      cb(
        BridgeLatencyInfo(
          method: method,
          roundTrip: stopwatch.elapsed,
          serverTime: serverMs != null
              ? Duration(milliseconds: serverMs)
              : null,
          serverBreakdown: serverBreakdown,
        ),
      );
    } else {
      _serverMsById.remove(id);
      _serverBreakdownById.remove(id);
    }

    return result;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isClosed => _isClosed;

  @override
  bool get isInitializing => _isInitializing;

  @override
  Future<void> waitForInitialization() async {
    if (!_isInitializing) {
      return;
    }
    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }
  }

  /// Clean up resources
  void _cleanup() {
    _isClosed = true;
    _isConnected = false;

    for (final completer in _pendingRequests.values) {
      completer.completeError(Exception('Bridge closed'));
    }
    _pendingRequests.clear();

    _responseController.close();
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;

    try {
      await call('close', {});
    } catch (e) {
      // Ignore errors during close
    }

    _cleanup();
    _process?.kill();
    _process = null;
  }
}
