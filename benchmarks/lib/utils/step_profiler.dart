/// Lightweight step-level profiler for benchmark instrumentation.
///
/// Accumulates timing data across multiple iterations of a benchmark and
/// reports per-step averages. Each ORM benchmark can own an instance, start/stop
/// named steps within a query call, and the harness collects the results after
/// all iterations complete.
///
/// Usage:
/// ```dart
/// final profiler = StepProfiler();
/// profiler.start('query_build');
/// // ... build query ...
/// profiler.stop('query_build');
/// profiler.start('bridge_call');
/// // ... call bridge ...
/// profiler.stop('bridge_call');
/// profiler.markIteration(); // increment iteration count
/// ```
class StepProfiler {
  /// Accumulated microseconds per step name.
  final Map<String, int> _accumulated = {};

  /// Preserves insertion order for display.
  final List<String> _orderedSteps = [];

  /// Number of completed iterations (calls to [markIteration]).
  int _iterations = 0;

  /// Currently running step start times (step name → µs from shared clock).
  final Map<String, int> _running = {};

  /// Shared monotonic stopwatch — started once and never reset.
  static final Stopwatch _clock = Stopwatch()..start();

  /// Start timing a named step.
  void start(String step) {
    _running[step] = _clock.elapsedMicroseconds;
  }

  /// Stop timing a named step and accumulate the elapsed time.
  void stop(String step) {
    final startTime = _running.remove(step);
    if (startTime == null) return;
    final elapsed = _clock.elapsedMicroseconds - startTime;
    _addToStep(step, elapsed);
  }

  /// Record a duration directly (e.g. from bridge latency callback).
  void record(String step, Duration duration) {
    _addToStep(step, duration.inMicroseconds);
  }

  /// Record raw microseconds directly.
  void recordMicros(String step, int micros) {
    _addToStep(step, micros);
  }

  void _addToStep(String step, int micros) {
    if (!_accumulated.containsKey(step)) {
      _orderedSteps.add(step);
    }
    _accumulated[step] = (_accumulated[step] ?? 0) + micros;
  }

  /// Mark the end of one benchmark iteration.
  void markIteration() {
    _iterations++;
  }

  /// Reset all accumulated data.
  void reset() {
    _accumulated.clear();
    _orderedSteps.clear();
    _running.clear();
    _iterations = 0;
  }

  /// Number of completed iterations.
  int get iterations => _iterations;

  /// All tracked step names, in insertion order.
  List<String> get stepNames => List.unmodifiable(_orderedSteps);

  /// Average microseconds per iteration for each step.
  Map<String, double> get averageMicros {
    if (_iterations == 0) return {};
    final result = <String, double>{};
    for (final step in _orderedSteps) {
      result[step] = (_accumulated[step] ?? 0).toDouble() / _iterations;
    }
    return result;
  }

  /// Average milliseconds per iteration for each step.
  Map<String, double> get averageMs {
    return averageMicros.map(
      (step, us) => MapEntry(step, us / 1000.0),
    );
  }

  /// Whether any data has been collected.
  bool get hasData => _iterations > 0 && _accumulated.isNotEmpty;
}
