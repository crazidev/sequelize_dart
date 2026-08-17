import 'package:orm_benchmarks/packages/sequelize/connection.dart';
import 'package:orm_benchmarks/packages/sequelize/models/post.model.dart';
import 'package:orm_benchmarks/utils/base_benchmark.dart';
import 'package:orm_benchmarks/utils/step_profiler.dart';
import 'package:sequelize_orm/sequelize_orm.dart';

export 'connection.dart';
export 'queries.dart';
export 'setup.dart';

/// Instrumented Sequelize benchmark that profiles internal query steps:
///   - total        : End-to-end query time (including query build + bridge + parse)
///   - bridge_call  : Total Dart→Node→Dart round-trip (from bridge latency callback)
///   - server_time  : Node.js + Sequelize.js + actual SQL (from _serverMs)
///   - ipc_overhead : IPC pipe serialization overhead (bridge_call - server_time)
class SequelizeOrmBenchmark implements OrmBenchmark {
  Sequelize? _sequelize;
  final StepProfiler _profiler = StepProfiler();

  /// Latency info from the most recent bridge call (captured via callback).
  BridgeLatencyInfo? _lastLatency;

  @override
  String get name => 'Sequelize';

  @override
  StepProfiler? get stepProfiler => _profiler;

  @override
  Future<void> init() async {
    _sequelize = await initSequelize();

    // Hook into bridge latency callback to capture per-call timing
    BridgeClient.instance.latencyCallback = (info) {
      _lastLatency = info;
    };
  }

  @override
  Future<void> warmup() async {
    await Post.model.findAll(limit: 5);
  }

  // ─── Bridge latency recording ──────────────────────────────────────

  /// Records bridge latency breakdown from the most recent call
  void _recordLatency() {
    if (_lastLatency != null) {
      _profiler.record('bridge_call', _lastLatency!.roundTrip);
      if (_lastLatency!.serverTime != null) {
        _profiler.record('server_time', _lastLatency!.serverTime!);
      }
      if (_lastLatency!.bridgeOverhead != null) {
        _profiler.record('ipc_overhead', _lastLatency!.bridgeOverhead!);
      }
    }
  }

  // ─── OrmBenchmark interface ────────────────────────────────────────

  @override
  Future<int> findAllPosts() async {
    _lastLatency = null;
    _profiler.start('total');
    final posts = await Post.model.findAll();
    _profiler.stop('total');
    _recordLatency();
    return posts.length;
  }

  @override
  Future<int> findAllPostsWithLimit(int limit) async {
    _lastLatency = null;
    _profiler.start('total');
    final posts = await Post.model.findAll(limit: limit);
    _profiler.stop('total');
    _recordLatency();
    return posts.length;
  }

  @override
  Future<int> findOnePost(int id) async {
    _lastLatency = null;
    _profiler.start('total');
    final post = await Post.model.findOne(where: (p) => p.id.eq(id));
    _profiler.stop('total');
    _recordLatency();
    return post != null ? 1 : 0;
  }

  @override
  Future<int> countPosts() async {
    _lastLatency = null;
    _profiler.start('total');
    final count = await Post.model.count();
    _profiler.stop('total');
    _recordLatency();
    return count;
  }

  @override
  Future<int> findPostsWhereIdLessThan(int id) async {
    _lastLatency = null;
    _profiler.start('total');
    final posts = await Post.model.findAll(where: (p) => p.id.lt(id));
    _profiler.stop('total');
    _recordLatency();
    return posts.length;
  }

  @override
  Future<int> findPostsWithDetails(int limit) async {
    _lastLatency = null;
    _profiler.start('total');
    final posts = await Post.model.findAll(
      limit: limit,
      include: (p) => [p.postDetails()],
    );
    _profiler.stop('total');
    _recordLatency();
    return posts.length;
  }

  @override
  Future<int> sequentialFindPosts(int count) async {
    var found = 0;
    for (var i = 1; i <= count; i++) {
      _lastLatency = null;
      _profiler.start('total');
      final post = await Post.model.findOne(where: (p) => p.id.eq(i));
      _profiler.stop('total');
      _recordLatency();
      if (post != null) found++;
    }
    return found;
  }

  @override
  Future<int> complexWhere(int minId, int maxId, int limit) async {
    _lastLatency = null;
    _profiler.start('total');
    final posts = await Post.model.findAll(
      where: (p) => and([
        p.id.gt(minId),
        p.id.lt(maxId),
      ]),
      limit: limit,
    );
    _profiler.stop('total');
    _recordLatency();
    return posts.length;
  }

  @override
  Future<void> close() async {
    BridgeClient.instance.latencyCallback = null;
    await _sequelize?.close();
  }
}
