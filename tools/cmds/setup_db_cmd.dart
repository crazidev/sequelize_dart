part of '../run.dart';

/// Container names for each dialect
const _containers = {
  'postgres': 'sequelize_postgres',
  'mysql': 'sequelize_mysql',
  'mariadb': 'sequelize_mariadb',
};

/// Docker run args for each dialect (matches test_helper.dart connection strings)
List<String> _dockerRunArgs(String dialect, String container) {
  switch (dialect) {
    case 'mysql':
      return [
        'run',
        '-d',
        '--name',
        container,
        '-e',
        'MYSQL_ALLOW_EMPTY_PASSWORD=yes',
        '-e',
        'MYSQL_DATABASE=sequelize_orm',
        '-p',
        '3306:3306',
        'mysql:8',
      ];
    case 'mariadb':
      return [
        'run',
        '-d',
        '--name',
        container,
        '-e',
        'MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes',
        '-e',
        'MARIADB_DATABASE=sequelize_orm',
        '-p',
        '3307:3306',
        'mariadb:10',
        '--query_cache_type=0',
        '--query_cache_size=0',
      ];
    case 'postgres':
    default:
      return [
        'run',
        '-d',
        '--name',
        container,
        '-e',
        'POSTGRES_USER=postgres',
        '-e',
        'POSTGRES_PASSWORD=postgres',
        '-e',
        'POSTGRES_DB=postgres',
        '-p',
        '5432:5432',
        'postgres:15',
      ];
  }
}

/// Setup database and support selecting dialect for dev mode or testing
Future<void> cmdSetupDb(Directory root, List<String> args) async {
  String dialect = 'postgres';
  if (args.contains('--mysql')) dialect = 'mysql';
  if (args.contains('--mariadb')) dialect = 'mariadb';
  if (args.contains('--postgres')) dialect = 'postgres';

  bool isTest = args.contains('--test');
  bool isReset = args.contains('--reset');

  String mode = isTest ? 'testing' : 'dev mode';
  final container = _containers[dialect]!;

  cmdlog('Checking Docker...');
  final dockerCheck = await _docker(['info']);
  if (dockerCheck.exitCode != 0) {
    stderr.writeln('Docker is not running. Start Docker and try again.');
    exit(1);
  }

  // Stop and remove any existing container so we can re-create it cleanly
  cmdlog('Stopping existing $dialect container (if any)...');
  await _docker(['stop', container]);
  if (isReset) {
    cmdlog('Resetting $dialect container (removing volumes)...');
    await _docker(['rm', '-f', '-v', container]);
  } else {
    await _docker(['rm', container]);
  }

  cmdlog('Setting up $dialect database for $mode...');

  final runResult = await _docker(_dockerRunArgs(dialect, container));

  if (runResult.exitCode != 0) {
    stderr.write(runResult.stderr);
    exit(runResult.exitCode);
  }

  cmdlog('Waiting for $dialect to be ready...');
  await _waitForDialect(dialect, container);

  cmdlog('Database $dialect started. Container: $container');
}

Future<void> _waitForDialect(String dialect, String container) async {
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(seconds: 2));
    ProcessResult ready;
    if (dialect == 'postgres') {
      ready = await _docker(
        ['exec', container, 'pg_isready', '-U', 'postgres', '-d', 'postgres'],
      );
    } else {
      // For mysql/mariadb just check the container is reachable
      ready = await _docker(['exec', container, 'sh', '-c', 'exit 0']);
      // Give mysql/mariadb extra time to initialise even after socket is ready
      if (ready.exitCode == 0 && i < 5) continue;
    }
    if (ready.exitCode == 0) return;
    if (i == 29) {
      stderr.writeln('$dialect did not become ready in time.');
      exit(1);
    }
  }
}
