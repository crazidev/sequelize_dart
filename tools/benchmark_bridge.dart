// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

String _arg(List<String> args, String key, String fallback) {
  final hit = args.firstWhere((a) => a.startsWith('--$key='), orElse: () => '');
  final val = hit.replaceFirst('--$key=', '');
  return val.isNotEmpty ? val : fallback;
}

class _Stats {
  final String name;
  final List<int> roundTrips = [];
  final List<int?> serverTimes = [];
  final List<int?> overheads = [];

  _Stats(this.name);

  void record(BridgeLatencyInfo info) {
    roundTrips.add(info.roundTrip.inMicroseconds);
    serverTimes.add(info.serverTime?.inMicroseconds);
    overheads.add(info.bridgeOverhead?.inMicroseconds);
  }

  double _avgMs(List<int> us) =>
      us.isEmpty ? 0 : (us.reduce((a, b) => a + b) / us.length) / 1000;

  double _minMs(List<int> us) =>
      us.isEmpty ? 0 : us.reduce(min).toDouble() / 1000;

  double _maxMs(List<int> us) =>
      us.isEmpty ? 0 : us.reduce(max).toDouble() / 1000;

  double _p95Ms(List<int> us) {
    if (us.isEmpty) return 0;
    final sorted = List<int>.from(us)..sort();
    return sorted[(sorted.length * 0.95).floor().clamp(0, sorted.length - 1)] /
        1000;
  }

  void print() {
    final n = roundTrips.length;
    stdout.writeln('  $name ($n calls)');

    final rt = roundTrips;
    stdout.writeln(
      '    Round-trip   min=${_minMs(rt).toStringAsFixed(2)}ms avg=${_avgMs(rt).toStringAsFixed(2)}ms p95=${_p95Ms(rt).toStringAsFixed(2)}ms max=${_maxMs(rt).toStringAsFixed(2)}ms',
    );

    final st = serverTimes.whereType<int>().toList();
    if (st.isNotEmpty) {
      stdout.writeln(
        '    Server time  min=${_minMs(st).toStringAsFixed(2)}ms avg=${_avgMs(st).toStringAsFixed(2)}ms p95=${_p95Ms(st).toStringAsFixed(2)}ms max=${_maxMs(st).toStringAsFixed(2)}ms',
      );

      final oh = overheads.whereType<int>().toList();
      stdout.writeln(
        '    IPC overhead min=${_minMs(oh).toStringAsFixed(2)}ms avg=${_avgMs(oh).toStringAsFixed(2)}ms p95=${_p95Ms(oh).toStringAsFixed(2)}ms max=${_maxMs(oh).toStringAsFixed(2)}ms',
      );
    }
    stdout.writeln();
  }
}

final buckets = <String, List<BridgeLatencyInfo>>{};
String currentOp = '';

Future<void> main(List<String> args) async {
  try {
    final dbType = _arg(args, 'db', 'postgres');
    final iterations = int.tryParse(_arg(args, 'iterations', '100')) ?? 100;

    SequelizeCoreOptions connection;
    if (dbType == 'mysql') {
      connection =
          MysqlConnection(url: 'mysql://root@localhost:3306/sequelize_orm');
    } else if (dbType == 'sqlite') {
      connection = SqliteConnection(storage: 'bench.db');
    } else {
      connection = PostgresConnection(
        url: 'postgresql://postgres:postgres@localhost:5432/postgres',
      );
    }

    final bridgeClient = BridgeClient.instance;
    bridgeClient.latencyCallback = (info) {
      final key = currentOp.isNotEmpty ? currentOp : info.method;
      buckets.putIfAbsent(key, () => []).add(info);
    };

    final sequelize = Sequelize().createInstance(connection: connection);
    await sequelize
        .initialize(models: [Users.model, Post.model, PostDetails.model]);

    int suffix = 0;
    String uid() => '${DateTime.now().millisecondsSinceEpoch}${suffix++}';

    Map<String, dynamic> generateMap(int depth, int width) {
      if (depth <= 0) return {'v': uid()};
      return {
        for (var i = 0; i < width; i++) 'k$i': generateMap(depth - 1, width),
      };
    }

    final largeMap = generateMap(3, 8); // Large recursion

    Future<_Stats> bench(String label, Future<void> Function() op) async {
      currentOp = label;
      buckets[label] = [];
      final stats = _Stats(label);
      await op();
      await op(); // Warmup
      buckets[label]!.clear();
      for (var i = 0; i < iterations; i++) await op();
      for (final info in buckets[label]!) stats.record(info);
      currentOp = '';
      return stats;
    }

    stdout.writeln();
    stdout
        .writeln('┌─────────────────────────────────────────────────────────┐');
    stdout
        .writeln('│        Sequelize ORM – Bridge Latency Benchmark         │');
    stdout
        .writeln('└─────────────────────────────────────────────────────────┘');
    stdout.writeln();

    final s1 =
        await bench('findAll (limit 10)', () => Users.model.findAll(limit: 10));
    final s2 = await bench(
      'findOne (by id)',
      () => Users.model.findOne(where: (u) => u.id.gt(0)),
    );
    final s3 = await bench(
      'create (insert)',
      () => Users.model.create(
        CreateUsers(
          email: 'b${uid()}@e.com',
          firstName: 'Bench',
          lastName: 'User',
        ),
      ),
    );

    final s4 = await bench(
      'update (static)',
      () => Users.model.update(lastName: 'Updated', where: (u) => u.id.gt(0)),
    );

    final s5 = await bench(
      'count',
      () => Users.model.count(),
    );

    final s6 = await bench(
      'create (large JSON)',
      () => Users.model.create(
        CreateUsers(
          email: 'large${uid()}@e.com',
          firstName: 'Large',
          lastName: 'User',
          metadata: largeMap,
        ),
      ),
    );

    stdout.writeln('Seeding 100 users for bulk fetch benchmark...');
    for (var i = 0; i < 100; i++) {
      await Users.model.create(
        CreateUsers(
          email: 'bulk${uid()}@e.com',
          firstName: 'B',
          lastName: 'U',
        ),
      );
    }
    final s7 = await bench(
      'findAll (100 records)',
      () => Users.model.findAll(limit: 100),
    );

    stdout.writeln();
    stdout.writeln(
        '── Results ───────────────────────────────────────────────────');
    s1.print();
    s2.print();
    s3.print();
    s4.print();
    s5.print();
    s6.print();
    s7.print();

    stdout.writeln(
        '── Column legend ─────────────────────────────────────────────');
    stdout.writeln(
        '  Round-trip   = full Dart → stdin → Node.js → stdout → Dart');
    stdout
        .writeln('  Server time  = Node.js handler wall-clock (JS + DB query)');
    stdout.writeln(
        '  IPC overhead = Round-trip − Server time (pipe + JSON codec)');
    stdout.writeln();

    await sequelize.close();
  } catch (e, st) {
    stderr.writeln('ERROR: $e');
    stderr.writeln(st);
  }
}
