/// Profiler for MongoDB integration operations.
///
/// Records step-by-step timing for initialization, query planning,
/// operator translation, and DB execution. Use to compare MongoDB (native)
/// vs PostgreSQL (bridge) performance.
///
/// Example:
/// ```dart
/// final profiler = MongoProfiler(
///   onStep: (step) => print(step),
/// );
/// final engine = MongoQueryEngine(
///   database: connection.adapter,
///   profiler: profiler,
/// );
/// ```
class MongoProfiler {
  MongoProfiler({
    void Function(MongoProfilerStep step)? onStep,
    void Function(List<MongoProfilerStep> steps)? onOperationComplete,
  })  : _onStep = onStep,
        _onOperationComplete = onOperationComplete;

  final void Function(MongoProfilerStep step)? _onStep;
  final void Function(List<MongoProfilerStep> steps)? _onOperationComplete;

  final List<MongoProfilerStep> _currentSteps = [];
  DateTime? _operationStart;

  /// Phase labels for consistent comparison with Postgres (bridge)
  static const String phaseInit = 'init';
  static const String phaseConnection = 'connection';
  static const String phaseDefine = 'define';
  static const String phaseQueryJson = 'query_to_json';
  static const String phaseBuildPlan = 'build_query_plan';
  static const String phaseTranslateWhere = 'translate_where';
  static const String phaseTranslateOptions = 'translate_options';
  static const String phaseDbFind = 'db_find';
  static const String phaseDbFindOne = 'db_find_one';
  static const String phaseDbAggregate = 'db_aggregate';
  static const String phaseDbInsert = 'db_insert';
  static const String phaseDbUpdate = 'db_update';
  static const String phaseDbDelete = 'db_delete';
  static const String phaseDbCount = 'db_count';
  static const String phaseResultTransform = 'result_transform';
  static const String phaseResolveAssociation = 'resolve_association';
  static const String phaseBuildLookup = 'build_lookup';
  static const String phaseParanoidMerge = 'paranoid_merge';
  static const String phaseIncludeExtract = 'include_extract';
  static const String phaseTotal = 'total';

  void _record(String phase, Duration elapsed, {String? detail}) {
    final step = MongoProfilerStep(
      phase: phase,
      elapsed: elapsed,
      detail: detail,
      timestamp: DateTime.now(),
    );
    _currentSteps.add(step);
    _onStep?.call(step);
  }

  /// Start timing an operation (e.g. findAll, findOne).
  void startOperation(String operation) {
    _currentSteps.clear();
    _operationStart = DateTime.now();
  }

  /// Record a step and optionally invoke completion callback.
  void record(String phase, Duration elapsed, {String? detail}) {
    _record(phase, elapsed, detail: detail);
  }

  /// Record elapsed time from a stopwatch started at operation start.
  void recordFromStart(String phase, {String? detail}) {
    if (_operationStart != null) {
      _record(phase, DateTime.now().difference(_operationStart!), detail: detail);
    }
  }

  /// Finish the current operation and optionally invoke onOperationComplete.
  void endOperation({String? operation}) {
    if (_operationStart != null) {
      final total = DateTime.now().difference(_operationStart!);
      _record(phaseTotal, total, detail: operation);
      _onOperationComplete?.call(List.from(_currentSteps));
    }
    _operationStart = null;
  }

  /// Run [fn] and record its duration under [phase].
  Future<T> measure<T>(
    String phase,
    Future<T> Function() fn, {
    String? detail,
  }) async {
    final sw = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      sw.stop();
      record(phase, sw.elapsed, detail: detail);
    }
  }

  /// Synchronous version of [measure].
  T measureSync<T>(
    String phase,
    T Function() fn, {
    String? detail,
  }) {
    final sw = Stopwatch()..start();
    try {
      return fn();
    } finally {
      sw.stop();
      record(phase, sw.elapsed, detail: detail);
    }
  }

  /// Whether any callbacks are registered (avoids unnecessary work).
  bool get isEnabled => _onStep != null || _onOperationComplete != null;

  /// Get steps from the last completed operation.
  List<MongoProfilerStep> get lastSteps => List.unmodifiable(_currentSteps);
}

/// A single profiled step with phase name, duration, and optional detail.
class MongoProfilerStep {
  const MongoProfilerStep({
    required this.phase,
    required this.elapsed,
    this.detail,
    required this.timestamp,
  });

  final String phase;
  final Duration elapsed;
  final String? detail;
  final DateTime timestamp;

  int get elapsedMs => elapsed.inMicroseconds ~/ 1000;

  @override
  String toString() {
    final detailStr = detail != null ? ' [$detail]' : '';
    return '[$phase] ${elapsedMs}ms$detailStr';
  }
}
