part of '../run.dart';

/// Run the bridge benchmark.
///
/// Usage:
///   dart run tools/run.dart benchmark-bridge [--postgres|--mysql|--mariadb|--sqlite]
///   dart run tools/run.dart benchmark-bridge --iterations=200 --mysql
Future<void> cmdBenchmarkBridge(Directory root, List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    print('Usage: dart run tools/run.dart benchmark-bridge [options]');
    print('');
    print('Options:');
    print('  --postgres        Use PostgreSQL (default)');
    print('  --mysql           Use MySQL');
    print('  --mariadb         Use MariaDB');
    print('  --sqlite          Use SQLite (fastest, in-memory)');
    print('  --iterations=N    Number of calls per operation (default: 100)');
    print('  --verbose         Print every call latency instead of summary');
    return;
  }

  final dbType = args.contains('--mysql')
      ? 'mysql'
      : args.contains('--mariadb')
          ? 'mariadb'
          : args.contains('--sqlite')
              ? 'sqlite'
              : 'postgres';

  final iterationsArg = args
      .firstWhere((a) => a.startsWith('--iterations='), orElse: () => '')
      .replaceFirst('--iterations=', '');
  final iterations =
      iterationsArg.isNotEmpty ? (int.tryParse(iterationsArg) ?? 100) : 100;

  final verbose = args.contains('--verbose');

  cmdlog('Launching benchmark script...');
  cmdlog('  DB      : $dbType');
  cmdlog('  Iters   : $iterations per operation');

  // Delegate to the Dart benchmark script so it can use the sequelize_orm package.
  final process = await Process.start(
    'dart',
    [
      'run',
      'tools/benchmark_bridge.dart',
      '--db=$dbType',
      '--iterations=$iterations',
      if (verbose) '--verbose',
    ],
    workingDirectory: root.path,
  );

  // Pipe stdout and stderr to the current process
  final stdoutFuture = stdout.addStream(process.stdout);
  final stderrFuture = stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;
  await Future.wait([stdoutFuture, stderrFuture]);

  if (exitCode != 0) {
    stderr.writeln('[ERROR] Benchmark exited with code $exitCode');
    exit(exitCode);
  }
}
