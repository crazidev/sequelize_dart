import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

part 'cmds/benchmark_bridge_cmd.dart';
part 'cmds/benchmark_cmd.dart';
part 'cmds/build_all_cmd.dart';
part 'cmds/build_cmd.dart';
part 'cmds/format_cmd.dart';
part 'cmds/release_cmd.dart';
part 'cmds/setup_bridge_cmd.dart';
part 'cmds/setup_db_cmd.dart';
part 'cmds/setup_git_hook_cmd.dart';
part 'cmds/test_cmd.dart';
part 'cmds/watch_bridge_cmd.dart';
part 'cmds/watch_dart_cmd.dart';
part 'cmds/watch_js_cmd.dart';
part 'cmds/watch_models_cmd.dart';

void cmdlog(String msg) => stdout.writeln('[tools] $msg');

/// Resolved path to the docker binary.
String get _dockerBin {
  for (final candidate in [
    '/usr/local/bin/docker',
    '/usr/bin/docker',
    '/opt/homebrew/bin/docker',
  ]) {
    if (File(candidate).existsSync()) return candidate;
  }
  return 'docker'; // fallback – rely on PATH
}

/// Environment overrides for docker subprocesses.
/// Injects DOCKER_HOST so the daemon socket is always found regardless of
/// which shell profile is (or isn't) loaded in the subprocess.
Map<String, String> get _dockerEnv {
  final env = Map<String, String>.from(Platform.environment);
  // Prefer an explicit DOCKER_HOST already set in the environment
  if (env.containsKey('DOCKER_HOST')) return env;
  // Auto-detect common socket paths (Colima default, then Docker Desktop)
  for (final sock in [
    '${Platform.environment['HOME']}/.colima/default/docker.sock',
    '${Platform.environment['HOME']}/.colima/docker.sock',
    '/var/run/docker.sock',
  ]) {
    if (File(sock).existsSync()) {
      env['DOCKER_HOST'] = 'unix://$sock';
      return env;
    }
  }
  return env;
}

/// Run a docker command, returning the [ProcessResult].
Future<ProcessResult> _docker(List<String> args) =>
    Process.run(_dockerBin, args, environment: _dockerEnv);

/// Start a docker process (streaming I/O), returning the [Process].
Future<Process> _dockerStart(List<String> args) =>
    Process.start(_dockerBin, args, environment: _dockerEnv);

void main(List<String> args) async {
  final root = _projectRoot;
  Directory.current = root;

  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printHelp();
    exit(0);
  }

  final command = args.first.toLowerCase();
  final rest = args.skip(1).toList();

  try {
    switch (command) {
      case 'benchmark':
        await cmdBenchmark(root, rest);
        break;
      case 'build-benchmark':
      case 'compile-benchmark':
        await cmdBuildBenchmark(root, rest);
        break;
      case 'benchmark-bridge':
        await cmdBenchmarkBridge(root, rest);
        break;
      case 'build':
        await cmdBuild(root, rest);
        break;
      case 'setup-bridge':
        await cmdSetupBridge(root, rest);
        break;
      case 'format':
        await cmdFormat(root);
        break;
      case 'watch-models':
        await cmdWatchModels(root);
        break;
      case 'watch-dart':
        await cmdWatchDart(root);
        break;
      case 'watch-js':
        await cmdWatchJs(root);
        break;
      case 'watch-bridge':
        await cmdWatchBridge(root);
        break;
      case 'setup-db':
        await cmdSetupDb(root, rest);
        break;
      case 'setup-git-hooks':
        await cmdSetupGitHooks(root);
        break;
      case 'test':
        await cmdTest(root, rest);
        break;
      case 'release':
        await cmdRelease(root, rest);
        break;
      case 'all-build':
        await cmdAllBuild(root, rest);
        break;
      default:
        stderr.writeln('Unknown command: $command');
        _printHelp();
        exit(1);
    }
  } catch (e, st) {
    stderr.writeln('Error: $e');
    stderr.writeln(st);
    exit(1);
  }
}

Directory get _projectRoot {
  final uri = Platform.script;
  String? path;
  if (uri.scheme == 'file') {
    path = uri.toFilePath();
  }
  if (path != null) {
    final script = File(path);
    if (script.existsSync()) {
      final root = script.parent.parent;
      if (File('${root.path}/tools/run.dart').existsSync() ||
          File('${root.path}\\tools\\run.dart').existsSync()) {
        return root;
      }
    }
  }
  return Directory.current;
}

(String?, List<String>) _findPrettier(Directory root) {
  final local = File('${root.path}/node_modules/.bin/prettier$_binExt');
  if (local.existsSync()) return (local.path, <String>[]);
  return ('npx', ['prettier']);
}

String get _binExt => Platform.isWindows ? '.cmd' : '';

int _fileHash(Directory root, List<String> relPaths, String extension) {
  int h = 0;
  for (final rel in relPaths) {
    final dir = Directory('${root.path}/$rel');
    if (!dir.existsSync()) continue;
    for (final e in dir.listSync(recursive: true)) {
      if (e is File && e.path.endsWith(extension)) {
        h = 0x1fffffff & (h * 31 + e.path.hashCode);
        try {
          h =
              0x1fffffff &
              (h * 31 + e.lastModifiedSync().millisecondsSinceEpoch.hashCode);
        } catch (_) {}
      }
    }
  }
  return h;
}

int _singleFileHash(File f) {
  if (!f.existsSync()) return 0;
  try {
    return 0x1fffffff &
        (f.path.hashCode * 31 +
            f.lastModifiedSync().millisecondsSinceEpoch.hashCode);
  } catch (_) {
    return 0;
  }
}

void _printHelp() {
  print('''
Sequelize ORM – cross-platform tools (Windows, macOS, Linux)

Usage: dart run tools/run.dart <command> [options]

Commands:
  benchmark        Run multi-ORM benchmark suite (Sequelize ORM, Drift, Serverpod)
                    Options: --seed (re-sync and seed DB), --posts=N, --users=N
  benchmark-bridge  Measure round-trip latency between Dart and the bridge
                    Options: --postgres (default), --mysql, --mariadb, --sqlite
                             --iterations=N (default: 100), --verbose
  build            Compile Dart to JS (default: example/lib/main.dart → index.js)
                    Options: --input=FILE, --output=NAME
  setup-bridge     Install and build bridge server (bun | pnpm | npm)
                    Options: [bun|pnpm|npm], --skip-install, --skip-cleanup
  format           Format Dart + JS/JSON/MD (dart format + Prettier)
  watch-models     Watch model files, run build_runner (example/)
  watch-dart       Watch Dart files, restart VM server on change
  watch-js         Watch Dart files, recompile to JS on change
  watch-bridge     Watch TypeScript, rebuild bridge on change
  setup-db         Start database in Docker
                    Dialect: --postgres (default), --mysql, --mariadb
                    Mode: --dev, --test, --reset
  setup-git-hooks  Install git hooks from .github/hooks
  test             Run tests (pass flags to tools/test.dart)
  release          Release/publish (pass flags to tools/release_publish.dart)
  all-build        Full build: setup-bridge → models → dart2js
''');
}
