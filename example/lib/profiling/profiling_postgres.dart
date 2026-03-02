// ignore_for_file: avoid_print

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm/src/bridge/bridge_latency.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

const connectionString = 'postgresql://postgres:postgres@localhost:5432/postgres';

/// Phase names for comparison with MongoDB profiling
class BridgeProfilerPhases {
  static const init = 'init';
  static const connection = 'connection';
  static const defineModel = 'define_model';
  static const associateModel = 'associate_model';
  static const queryToJson = 'query_to_json';
  static const bridgeCall = 'bridge_call';
  static const resultTransform = 'result_transform';
  static const total = 'total';
}

/// Profile PostgreSQL (bridge) integration: logs every step with timing.
/// Compare output with profiling_mongo.dart (native).
Future<void> main() async {
  print('');
  print('=' * 70);
  print('POSTGRESQL (BRIDGE) INTEGRATION PROFILING');
  print('=' * 70);
  print('');

  final bridgeLatencies = <String, List<Duration>>{};

  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(url: connectionString),
  );

  // Hook into bridge latency for each RPC call (Dart VM / bridge_client_dart)
  final bridge = sequelize.bridge;
  try {
    (bridge as dynamic).latencyCallback = (BridgeLatencyInfo info) {
      print('  ${BridgeProfilerPhases.bridgeCall.padRight(25)} ${info.roundTrip.inMilliseconds.toString().padLeft(6)}ms  $info');
      bridgeLatencies.putIfAbsent(info.method, () => []).add(info.roundTrip);
    };
  } catch (_) {
    print('  (latencyCallback not available on this bridge)');
  }

  // Phase 1: Initialize
  print('[1] INITIALIZATION (start bridge + connect + define models)');
  final initSw = Stopwatch()..start();
  await sequelize.initialize(
    models: [
      Users.model,
      Post.model,
      PostDetails.model,
    ],
  );
  initSw.stop();
  print('  ${BridgeProfilerPhases.init.padRight(25)} ${initSw.elapsedMilliseconds.toString().padLeft(6)}ms  total initialize');
  print('');

  // Phase 2: Warmup
  print('[2] WARMUP');
  await Post.model.findAll();
  print('');

  // Phase 3: Queries
  print('[3] QUERY: findAll (simple)');
  final findAllSw = Stopwatch()..start();
  final posts = await Post.model.findAll();
  findAllSw.stop();
  print('  ${BridgeProfilerPhases.total.padRight(25)} ${findAllSw.elapsedMilliseconds.toString().padLeft(6)}ms  ${posts.length} rows');
  print('');

  print('[4] QUERY: findOne with where');
  final findOneSw = Stopwatch()..start();
  final one = await Post.model.findOne(where: (p) => p.id.eq(1));
  findOneSw.stop();
  print('  ${BridgeProfilerPhases.total.padRight(25)} ${findOneSw.elapsedMilliseconds.toString().padLeft(6)}ms  ${one != null ? '1 row' : '0 rows'}');
  print('');

  print('[5] QUERY: findAll with complex where');
  final complexSw = Stopwatch()..start();
  final filtered = await Post.model.findAll(
    where: (p) => and([p.id.gt(0), p.id.lt(100)]),
    limit: 20,
  );
  complexSw.stop();
  print('  ${BridgeProfilerPhases.total.padRight(25)} ${complexSw.elapsedMilliseconds.toString().padLeft(6)}ms  ${filtered.length} rows');
  print('');

  // Cleanup
  await sequelize.close();

  print('=' * 70);
  print('PostgreSQL profiling complete (bridge → Node/Sequelize.js)');
  print('=' * 70);
  print('');
}
