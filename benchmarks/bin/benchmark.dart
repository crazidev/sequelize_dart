import 'dart:io';

import 'package:orm_benchmarks/packages/drift/drift_benchmark.dart';
import 'package:orm_benchmarks/packages/prisma/prisma_benchmark.dart';
import 'package:orm_benchmarks/packages/sequelize/sequelize_benchmark.dart';
import 'package:orm_benchmarks/packages/sequelize/sequelize_quickjs_benchmark.dart';
import 'package:orm_benchmarks/packages/serverpod/serverpod_benchmark.dart';
import 'package:orm_benchmarks/utils/export.dart';

void main(List<String> args) async {
  final shouldSeed = args.contains('--seed') || args.contains('-s');
  final userCountArg = _parseArg(args, '--users') ?? 50;
  final postCountArg = _parseArg(args, '--posts') ?? 200;
  final warmupMillisArg = _parseArg(args, '--warmup') ?? 150;
  final exerciseMillisArg =
      _parseArg(args, '--duration') ?? _parseArg(args, '--exercise') ?? 500;

  print('============================================================');
  print('          MULTI-PACKAGE ORM BENCHMARK SUITE');
  print('============================================================');
  print('Harness: benchmark_harness (AsyncBenchmarkBase)');
  print('Packages under test:');
  print('  1. Sequelize ORM (Dart)');
  print('  2. Drift');
  print('  3. Serverpod ORM');
  print('  4. Sequelize ORM (QuickJS)');
  print('  5. Prisma (dart-orm)');
  print('Shared Database: PostgreSQL (localhost:5432/postgres)');
  print(
    'Settings: ${warmupMillisArg}ms warmup / ${exerciseMillisArg}ms sample window per query',
  );
  print('============================================================\n');

  if (shouldSeed) {
    print('[1/2] Database Setup & Data Seeding (via Sequelize ORM)...');
    await setupAndSeedDatabase(
      userCount: userCountArg,
      postCount: postCountArg,
    );
  } else {
    print('Tip: Pass --seed to re-synchronize tables & re-seed data.\n');
  }

  print('[2/2] Running Benchmark Test Suites...\n');

  final benchmarks = <OrmBenchmark>[
    SequelizeOrmBenchmark(),
    SequelizeOrmQuickjsBenchmark(),
    DriftBenchmark(),
    PrismaOrmBenchmark(),
    ServerpodOrmBenchmark(),
  ];

  final reports = <PackageBenchmarkReport>[];

  for (final benchmark in benchmarks) {
    try {
      final report = await BenchmarkRunner.runSuite(
        benchmark,
        warmupMillis: warmupMillisArg,
        exerciseMillis: exerciseMillisArg,
      );
      reports.add(report);
    } catch (e, st) {
      print('ERROR running benchmark for ${benchmark.name}: $e\n$st\n');
    }
  }

  // Display Comparative Summary Table
  BenchmarkTable.displayComparison(reports);

  // Display Step-by-Step Breakdown for instrumented ORMs
  // BenchmarkTable.displayStepBreakdown(reports);
  exit(0);
}

int? _parseArg(List<String> args, String prefix) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == prefix && i + 1 < args.length) {
      return int.tryParse(args[i + 1]);
    }
    if (args[i].startsWith('$prefix=')) {
      return int.tryParse(args[i].substring('$prefix='.length));
    }
  }
  return null;
}
