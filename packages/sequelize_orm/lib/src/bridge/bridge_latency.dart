/// Timing snapshot for a single Dart → Bridge → Dart round-trip.
///
/// Exposed via [BridgeClient.latencyCallback]. Register a callback to receive
/// one [BridgeLatencyInfo] per bridge call:
///
/// ```dart
/// BridgeClient.instance.latencyCallback = (info) {
///   print(info);
///   // BridgeLatencyInfo(findAll: 12ms total, 8ms server, 4ms overhead)
/// };
/// ```
class BridgeLatencyInfo {
  /// The JSON-RPC method name (e.g. `'findAll'`, `'create'`).
  final String method;

  /// Total elapsed time from Dart writing to stdin to receiving the response.
  final Duration roundTrip;

  /// Time the Node.js handler spent (JavaScript execution + DB query).
  ///
  /// Derived from the `_serverMs` field injected by the bridge server.
  /// `null` only when communicating with an older bridge that does not
  /// emit that field.
  final Duration? serverTime;

  /// Detailed sub-timing breakdown of server operations in milliseconds.
  /// Keys: 'convertMs', 'dbMs', 'serializeMs', 'compactMs', 'totalServerMs'.
  final Map<String, double>? serverBreakdown;

  /// Pure Dart↔Node IPC overhead: serialisation, pipe write, pipe read,
  /// and deserialisation. Available only when [serverTime] is non-null.
  Duration? get bridgeOverhead {
    final s = serverTime;
    if (s == null) return null;
    final overhead = roundTrip - s;
    // Guard against tiny negative values caused by OS clock jitter.
    return overhead.isNegative ? Duration.zero : overhead;
  }

  const BridgeLatencyInfo({
    required this.method,
    required this.roundTrip,
    this.serverTime,
    this.serverBreakdown,
  });

  @override
  String toString() {
    final rt = roundTrip.inMilliseconds;
    final st = serverTime?.inMilliseconds;
    final oh = bridgeOverhead?.inMilliseconds;
    if (st != null && oh != null) {
      return 'BridgeLatencyInfo($method: ${rt}ms total, ${st}ms server, ${oh}ms overhead, breakdown: $serverBreakdown)';
    }
    return 'BridgeLatencyInfo($method: ${rt}ms total)';
  }
}
