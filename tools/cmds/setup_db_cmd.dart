part of '../run.dart';

/// Setup database and support selecting dialect for dev mode or testing
Future<void> cmdSetupDb(Directory root, List<String> args) async {
  String dialect = 'postgres';
  if (args.contains('--mysql')) dialect = 'mysql';
  if (args.contains('--mariadb')) dialect = 'mariadb';
  if (args.contains('--postgres')) dialect = 'postgres';

  bool isTest = args.contains('--test');
  bool isReset = args.contains('--reset');

  String mode = isTest ? 'testing' : 'dev mode';

  cmdlog('Checking Docker...');
  final dockerCheck = await Process.run('docker', ['info'], runInShell: true);
  if (dockerCheck.exitCode != 0) {
    stderr.writeln('Docker is not running. Start Docker and try again.');
    exit(1);
  }

  if (isReset) {
    cmdlog('Resetting $dialect database (stopping and removing volumes)...');
    await Process.run(
      'docker',
      ['compose', 'rm', '-s', '-f', '-v', dialect],
      runInShell: true,
    );
  }

  cmdlog('Setting up $dialect database for $mode...');

  final runResult = await Process.run(
    'docker',
    ['compose', 'up', '-d', dialect],
    runInShell: true,
  );

  if (runResult.exitCode != 0) {
    stderr.write(runResult.stderr);
    exit(runResult.exitCode);
  }

  cmdlog('Database $dialect started successfully.');
}
