part of '../run.dart';

/// Builds the native AOT benchmark binary using Dart's native assets build system
Future<File> cmdBuildBenchmark(
  Directory root, [
  List<String> args = const [],
]) async {
  cmdlog('Building native AOT benchmark executable with dart build cli...');
  final benchmarksDir = Directory('${root.path}/benchmarks');
  if (!benchmarksDir.existsSync()) {
    stderr.writeln(
      'Error: benchmarks directory not found at ${benchmarksDir.path}',
    );
    exit(1);
  }

  final buildProcess = await Process.start(
    'dart',
    ['build', 'cli'],
    workingDirectory: benchmarksDir.path,
    mode: ProcessStartMode.inheritStdio,
  );

  final buildCode = await buildProcess.exitCode;
  if (buildCode != 0) {
    stderr.writeln(
      'Failed to build native benchmark binary (exit code $buildCode)',
    );
    exit(buildCode);
  }

  final executable = _findNativeBenchmarkExecutable(benchmarksDir);
  if (executable == null || !executable.existsSync()) {
    stderr.writeln(
      'Error: Could not locate compiled native benchmark binary in ${benchmarksDir.path}/build',
    );
    exit(1);
  }

  cmdlog('Native benchmark built successfully at: ${executable.path}');
  return executable;
}

File? _findNativeBenchmarkExecutable(Directory benchmarksDir) {
  final buildDir = Directory('${benchmarksDir.path}/build/cli');
  if (!buildDir.existsSync()) return null;

  for (final entity in buildDir.listSync(recursive: true)) {
    if (entity is File) {
      final name = p.basename(entity.path);
      if ((name == 'benchmark' || name == 'benchmark.exe') &&
          entity.path.contains('bundle/bin')) {
        return entity;
      }
    }
  }
  return null;
}

/// Runs the multi-ORM comparative benchmark suite (supports JIT and Native AOT modes)
Future<void> cmdBenchmark(Directory root, List<String> args) async {
  final isNative = args.contains('--native') || args.contains('--aot');
  final passArgs = args.where((a) => a != '--native' && a != '--aot').toList();

  final benchmarksDir = Directory('${root.path}/benchmarks');
  if (!benchmarksDir.existsSync()) {
    stderr.writeln(
      'Error: benchmarks directory not found at ${benchmarksDir.path}',
    );
    exit(1);
  }

  Process process;
  if (isNative) {
    cmdlog('Running in Native AOT mode...');

    // Automatically skip sqlite build hook if downloaded
    _patchSqliteHookToSupportLock();

    // Always build when --native is passed
    var executable = await cmdBuildBenchmark(root);

    process = await Process.start(
      executable.path,
      passArgs,
      workingDirectory: benchmarksDir.path,
    );
  } else {
    cmdlog(
      'Running multi-ORM benchmark suite in benchmarks/... (pass --native for AOT mode)',
    );
    process = await Process.start(
      'dart',
      ['run', 'bin/benchmark.dart', ...passArgs],
      workingDirectory: benchmarksDir.path,
    );
  }

  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      // Filter Serverpod lifecycle banners and DB integrity check noise
      final trimmed = line.trim();
      if (trimmed.startsWith('SERVERPOD') ||
          trimmed.startsWith('runMode:') ||
          trimmed.startsWith('serverId:') ||
          trimmed.startsWith('role:') ||
          trimmed.startsWith('loggingMode:') ||
          trimmed.startsWith('applyMigrations:') ||
          trimmed.startsWith('applyRepairMigration:') ||
          trimmed.contains('Insights server disabled') ||
          trimmed.contains('WARNING: The database does not match') ||
          trimmed.contains('Table "') ||
          trimmed.contains('Column "') ||
          trimmed.contains('expected type') ||
          trimmed.contains('expected default') ||
          trimmed.contains('expected isNullable') ||
          trimmed.contains('Missing Foreign key') ||
          trimmed.startsWith('Hint: Did you forget')) {
        return;
      }

      stdout.writeln(line);
    },
  );

  process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      final trimmed = line.trim();
      if (trimmed.contains('WARNING') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('Hint:')) {
        return;
      }
      stderr.writeln(line);
    },
  );

  final code = await process.exitCode;
  if (code != 0) {
    exit(code);
  }
}

void _patchSqliteHookToSupportLock() {
  try {
    final pubCache =
        Platform.environment['PUB_CACHE'] ??
        '${Platform.environment['HOME']}/.pub-cache';

    final sqliteDir = Directory('$pubCache/hosted/pub.dev')
        .listSync()
        .firstWhere(
          (e) => e is Directory && p.basename(e.path).startsWith('sqlite3-'),
          orElse: () => Directory(''),
        );

    if (sqliteDir.existsSync()) {
      final hookFile = File('${sqliteDir.path}/hook/build.dart');
      if (hookFile.existsSync()) {
        final content = hookFile.readAsStringSync();
        if (!content.contains('sqlite_build_hook.lock')) {
          final patched = content.replaceFirst(
            'void main(List<String> args) async {',
            'void main(List<String> args) async {\n  if (File(".dart_tool/sqlite_build_hook.lock").existsSync()) return;\n',
          );
          hookFile.writeAsStringSync(patched);
        }
      }
    }
  } catch (e) {
    // Ignore
  }
}
