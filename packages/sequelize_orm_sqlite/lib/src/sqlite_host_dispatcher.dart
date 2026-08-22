import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sqlite3/sqlite3.dart';

/// Manages SQLite database instances and registers host call handlers
/// for the Sequelize JS bridge.
class SqliteHostDispatcher {
  static final Map<int, Database> _databases = {};
  static int _nextHandleId = 1;
  static bool _initialized = false;

  /// Initialize and register SQLite handlers with [BridgeHostDispatcher].
  static void register() {
    if (_initialized) return;
    _initialized = true;

    BridgeHostDispatcher.register('sqlite_open', _handleOpen);
    BridgeHostDispatcher.register('sqlite_query', _handleQuery);
    BridgeHostDispatcher.register('sqlite_run', _handleRun);
    BridgeHostDispatcher.register('sqlite_exec', _handleExec);
    BridgeHostDispatcher.register('sqlite_close', _handleClose);
  }

  static dynamic _handleOpen(Map<String, dynamic> params) {
    final storage = params['storage'] as String? ?? ':memory:';
    final Database db;
    if (storage == ':memory:' || storage.isEmpty) {
      db = sqlite3.openInMemory();
    } else {
      db = sqlite3.open(storage);
    }

    final handleId = _nextHandleId++;
    _databases[handleId] = db;
    return {'handle': handleId};
  }

  static StatementParameters _buildParams(dynamic rawParams) {
    if (rawParams is Map) {
      final named = <String, Object?>{};
      for (final entry in rawParams.entries) {
        final key = entry.key.toString();
        final cleanKey =
            key.startsWith(r'$') || key.startsWith(':') || key.startsWith('@')
            ? key
            : ':$key';
        named[cleanKey] = entry.value;
      }
      return StatementParameters.named(named);
    } else if (rawParams is List) {
      return StatementParameters(rawParams.cast<Object?>());
    }
    return const StatementParameters([]);
  }

  static dynamic _handleQuery(Map<String, dynamic> params) {
    final handleId = (params['handle'] as num).toInt();
    final sql = params['sql'] as String;
    final rawParams = params['params'];
    final db = _databases[handleId];
    if (db == null) {
      throw StateError('SQLite database handle $handleId is not open');
    }

    final stmt = db.prepare(sql);
    try {
      final result = stmt.selectWith(_buildParams(rawParams));
      final rows = <Map<String, dynamic>>[];
      for (final row in result) {
        rows.add(Map<String, dynamic>.from(row));
      }
      return rows;
    } finally {
      stmt.dispose();
    }
  }

  static dynamic _handleRun(Map<String, dynamic> params) {
    final handleId = (params['handle'] as num).toInt();
    final sql = params['sql'] as String;
    final rawParams = params['params'];
    final db = _databases[handleId];
    if (db == null) {
      throw StateError('SQLite database handle $handleId is not open');
    }

    final stmt = db.prepare(sql);
    try {
      stmt.executeWith(_buildParams(rawParams));
      return {
        'lastID': db.lastInsertRowId,
        'changes': db.updatedRows,
      };
    } finally {
      stmt.dispose();
    }
  }

  static dynamic _handleExec(Map<String, dynamic> params) {
    final handleId = (params['handle'] as num).toInt();
    final sql = params['sql'] as String;
    final db = _databases[handleId];
    if (db == null) {
      throw StateError('SQLite database handle $handleId is not open');
    }

    db.execute(sql);
    return null;
  }

  static dynamic _handleClose(Map<String, dynamic> params) {
    final handleId = (params['handle'] as num).toInt();
    final db = _databases.remove(handleId);
    db?.dispose();
    return null;
  }
}
