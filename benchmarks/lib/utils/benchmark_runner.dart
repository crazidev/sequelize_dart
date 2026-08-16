import 'package:benchmark_harness/benchmark_harness.dart';
import 'base_benchmark.dart';

/// Holds the benchmark result for a single query test measured via [AsyncBenchmarkBase]
class QueryBenchmarkResult {
  final String testName;
  final double durationMs;
  final int rowCount;
  final int iterations;
  final double opsPerSecond;

  const QueryBenchmarkResult({
    required this.testName,
    required this.durationMs,
    required this.rowCount,
    required this.iterations,
    required this.opsPerSecond,
  });
}

/// An [AsyncBenchmarkBase] implementation for measuring an ORM query
class OrmQueryAsyncBenchmark extends AsyncBenchmarkBase {
  final Future<int> Function() queryFn;
  final int warmupMillis;
  final int exerciseMillis;
  int lastRowCount = 0;
  int exerciseRuns = 0;

  OrmQueryAsyncBenchmark(
    super.name,
    this.queryFn, {
    this.warmupMillis = 200,
    this.exerciseMillis = 1000,
  });

  @override
  Future<void> run() async {
    lastRowCount = await queryFn();
  }

  @override
  Future<void> warmup() async {
    await run();
  }

  @override
  Future<void> exercise() async {
    await run();
    exerciseRuns++;
  }

  @override
  Future<double> measure() async {
    await setup();
    try {
      // Warmup phase (primes VM JIT, connection buffers, DB plan cache)
      if (warmupMillis > 0) {
        await AsyncBenchmarkBase.measureFor(warmup, warmupMillis);
      }
      // Measure phase (executes continuously over exerciseMillis window)
      exerciseRuns = 0;
      final avgMicros =
          await AsyncBenchmarkBase.measureFor(exercise, exerciseMillis);
      return avgMicros;
    } finally {
      await teardown();
    }
  }
}

/// Holds all benchmark results for a particular ORM package
class PackageBenchmarkReport {
  final String packageName;
  final List<QueryBenchmarkResult> results;
  final double totalDurationMs;
  final double averageDurationMs;

  PackageBenchmarkReport({
    required this.packageName,
    required this.results,
    required this.totalDurationMs,
    required this.averageDurationMs,
  });
}

/// Utility for running and measuring benchmark queries using benchmark_harness
class BenchmarkRunner {
  /// Measures a single query function using benchmark_harness's AsyncBenchmarkBase
  static Future<QueryBenchmarkResult> measure(
    String testName,
    Future<int> Function() queryFn, {
    int warmupMillis = 200,
    int exerciseMillis = 800,
  }) async {
    final bench = OrmQueryAsyncBenchmark(
      testName,
      queryFn,
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    );

    final avgMicros = await bench.measure();
    final durationMs = avgMicros / 1000.0;
    final opsPerSec = avgMicros > 0 ? (1000000.0 / avgMicros) : 0.0;

    return QueryBenchmarkResult(
      testName: testName,
      durationMs: durationMs,
      rowCount: bench.lastRowCount,
      iterations: bench.exerciseRuns,
      opsPerSecond: opsPerSec,
    );
  }

  /// Runs the entire benchmark test suite against an [OrmBenchmark] instance
  static Future<PackageBenchmarkReport> runSuite(
    OrmBenchmark benchmark, {
    int warmupMillis = 200,
    int exerciseMillis = 800,
  }) async {
    print('------------------------------------------------------------');
    print(
        'Running benchmark for: ${benchmark.name} (using benchmark_harness)...');
    print('------------------------------------------------------------');

    print('Initializing...');
    await benchmark.init();

    print('Warming up connection pool...');
    await benchmark.warmup();

    final results = <QueryBenchmarkResult>[];

    // 1. findAll (all posts)
    print('Measuring findAll (all posts)...');
    results.add(await measure(
      'findAll (all posts)',
      () => benchmark.findAllPosts(),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 2. findAll (limit 10)
    print('Measuring findAll (limit 10)...');
    results.add(await measure(
      'findAll (limit 10)',
      () => benchmark.findAllPostsWithLimit(10),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 3. findOne
    print('Measuring findOne (id = 1)...');
    results.add(await measure(
      'findOne (id = 1)',
      () => benchmark.findOnePost(1),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 4. count
    print('Measuring count...');
    results.add(await measure(
      'count',
      () => benchmark.countPosts(),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 5. findAll (where id < 50)
    print('Measuring findAll (where id < 50)...');
    results.add(await measure(
      'findAll (where id < 50)',
      () => benchmark.findPostsWhereIdLessThan(50),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 6. findAll with include (join)
    print('Measuring findAll with include (join)...');
    results.add(await measure(
      'findAll with include (join)',
      () => benchmark.findPostsWithDetails(10),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 7. 5 sequential findOnes
    print('Measuring 5 sequential findOnes...');
    results.add(await measure(
      '5 sequential findOnes',
      () => benchmark.sequentialFindPosts(5),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    // 8. findAll (complex where)
    print('Measuring findAll (complex where)...');
    results.add(await measure(
      'findAll (complex where)',
      () => benchmark.complexWhere(10, 50, 20),
      warmupMillis: warmupMillis,
      exerciseMillis: exerciseMillis,
    ));

    await benchmark.close();

    final totalDuration = results.fold<double>(
      0.0,
      (sum, r) => sum + r.durationMs,
    );
    final avgDuration =
        results.isNotEmpty ? totalDuration / results.length : 0.0;

    print(
        'Completed ${benchmark.name} in ${totalDuration.toStringAsFixed(2)}ms (avg ${avgDuration.toStringAsFixed(2)}ms/op)\n');

    return PackageBenchmarkReport(
      packageName: benchmark.name,
      results: results,
      totalDurationMs: totalDuration,
      averageDurationMs: avgDuration,
    );
  }
}
