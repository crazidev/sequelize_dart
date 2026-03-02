// ignore_for_file: avoid_print

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';

const mongoUrl = 'mongodb://localhost:27017';
const mongoDatabase = 'sequelize_dart';
const usersCollection = 'mongo_example_users';
const postsCollection = 'mongo_example_posts';

/// Profile MongoDB integration: logs every step with timing.
/// Compare output with profiling_postgres.dart (bridge-based).
Future<void> main() async {
  print('');
  print('=' * 70);
  print('MONGODB INTEGRATION PROFILING');
  print('=' * 70);
  print('');

  final steps = <MongoProfilerStep>[];
  final profiler = MongoProfiler(
    onStep: (step) {
      print('  ${step.phase.padRight(25)} ${step.elapsedMs.toString().padLeft(6)}ms  ${step.detail ?? ''}');
      steps.add(step);
    },
    onOperationComplete: (ops) {
      print('  --- operation complete, ${ops.length} steps ---');
    },
  );

  // Phase 1: Connection / Initialization
  print('[1] CONNECTION (open)');
  final connection = MongoConnection(
    config: const MongoConnectionConfig(url: mongoUrl, database: mongoDatabase),
    profiler: profiler,
  );
  await connection.open();
  print('');

  // Phase 2: Engine setup
  print('[2] ENGINE SETUP');
  final engine = MongoQueryEngine(
    database: connection.adapter,
    associationResolver: ({
      required String sourceModel,
      required String associationName,
    }) {
      final key = '$sourceModel.$associationName';
      switch (key) {
        case '$usersCollection.posts':
          return const MongoAssociationDefinition(
            sourceModel: usersCollection,
            associationName: 'posts',
            targetCollection: postsCollection,
            associationType: MongoAssociationType.hasMany,
            localField: '_id',
            foreignField: 'userId',
          );
        case '$postsCollection.user':
          return const MongoAssociationDefinition(
            sourceModel: postsCollection,
            associationName: 'user',
            targetCollection: usersCollection,
            associationType: MongoAssociationType.belongsTo,
            localField: 'userId',
            foreignField: '_id',
          );
        default:
          return null;
      }
    },
    profiler: profiler,
  );
  print('  (engine setup is instant - no defineModel over wire)');
  print('');

  try {
    // Phase 3: Queries
    print('[3] QUERY: findAll (simple)');
    final users = await engine.findAll(
      modelName: usersCollection,
      query: Query(),
    );
    print('  --> ${users.length} rows');
    print('');

    print('[4] QUERY: findOne with where');
    final one = await engine.findOne(
      modelName: usersCollection,
      query: Query(
        where: ComparisonOperator(
          column: 'name',
          value: {r'$startsWith': 'A'},
        ),
      ),
    );
    print('  --> ${one != null ? '1 row' : '0 rows'}');
    print('');

    print('[5] QUERY: findAll with complex where');
    final posts = await engine.findAll(
      modelName: postsCollection,
      query: Query(
        where: ComparisonOperator(
          column: 'views',
          value: {r'$gte': 50},
        ),
        limit: 10,
      ),
    );
    print('  --> ${posts.length} rows');
    print('');
  } finally {
    await connection.close();
  }

  print('=' * 70);
  print('MongoDB profiling complete (native driver - no bridge)');
  print('=' * 70);
  print('');
}
