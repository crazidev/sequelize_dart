import 'package:serverpod/serverpod.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'generated/protocol.dart';
import 'generated/endpoints.dart';

/// Manages the Serverpod runtime instance and database session
class ServerpodConnection {
  Serverpod? _pod;
  Session? _session;

  Session get session {
    if (_session == null) {
      throw StateError(
        'Serverpod session is not initialized. Call init() first.',
      );
    }
    return _session!;
  }

  /// Initializes Serverpod in programmatic production serverless mode
  /// Works in JIT and Native AOT binaries without requiring external yaml files
  Future<void> init() async {
    final portZero = ServerConfig(
      port: 0,
      publicScheme: 'http',
      publicHost: 'localhost',
      publicPort: 0,
    );

    final dbConfig = PostgresDatabaseConfig(
      host: 'localhost',
      port: 5432,
      name: 'postgres',
      user: 'postgres',
      password: 'postgres',
      requireSsl: false,
    );

    final serverpodConfig = ServerpodConfig(
      runMode: 'production',
      role: ServerpodRole.serverless,
      loggingMode: ServerpodLoggingMode.normal,
      apiServer: portZero,
      webServer: portZero,
      insightsServer: portZero,
      database: dbConfig,
      applyMigrations: false,
      applyRepairMigration: false,
    );

    _pod = Serverpod(
      [],
      Protocol(),
      Endpoints(),
      config: serverpodConfig,
    );

    await _pod!.start(runInGuardedZone: false);
    _session = await _pod!.createSession();
  }

  /// Closes session and shuts down Serverpod cleanly
  Future<void> close() async {
    await _session?.close();
    await _pod?.shutdown(exitProcess: false);
    _session = null;
    _pod = null;
  }
}
