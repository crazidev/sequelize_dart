import 'package:sequelize_orm/src/bridge/bridge_client_interface.dart';
import 'package:sequelize_orm/src/bridge/bridge_latency.dart';

/// Stub implementation of BridgeClient for unsupported platforms
class BridgeClient implements BridgeClientInterface {
  @override
  void Function(BridgeLatencyInfo info)? latencyCallback;

  BridgeClient._();

  static BridgeClient? _instance;
  static BridgeClientInterface? _customInstance;

  /// Override the active BridgeClient singleton with a custom implementation.
  static void overrideWith(BridgeClientInterface client) {
    print('Overriding bridge with a new bridge');
    _customInstance = client;
  }

  /// Reset any custom bridge override.
  static void resetOverride() {
    _customInstance = null;
  }

  /// Get the singleton instance
  static BridgeClientInterface get instance {
    return _customInstance ?? (_instance ??= BridgeClient._());
  }

  @override
  Future<void> start({
    required Map<String, dynamic> connectionConfig,
    String? nodePath,
    String? bridgePath,
  }) {
    throw UnimplementedError(
      'BridgeClient is not available in this environment',
    );
  }

  @override
  Future<dynamic> call(String method, Map<String, dynamic> params) {
    throw UnimplementedError(
      'BridgeClient is not available in this environment',
    );
  }

  @override
  void setLoggingCallback(Function(String sql)? callback) {
    throw UnimplementedError(
      'BridgeClient is not available in this environment',
    );
  }

  @override
  bool get isConnected => false;

  @override
  bool get isClosed => true;

  @override
  bool get isInitializing => false;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<void> close() async {}
}
