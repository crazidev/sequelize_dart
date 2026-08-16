import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart';
import 'models/database.dart';

/// Creates a configured Drift database instance connected to the shared PostgreSQL database
DriftAppDatabase createDriftDatabase() {
  final pgDatabase = PgDatabase(
    endpoint: Endpoint(
      host: 'localhost',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
  return DriftAppDatabase(pgDatabase);
}
