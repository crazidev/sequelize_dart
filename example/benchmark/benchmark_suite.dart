// ignore_for_file: avoid_print

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';

const postgresUrl = 'postgresql://postgres:postgres@localhost:5432/postgres';
const mongoUrl = 'mongodb://localhost:27017';
const mongoDatabase = 'sequelize_dart';
const usersCollection = 'mongo_example_users';
const postsCollection = 'mongo_example_posts';

// --- PostgreSQL (Bridge) Benchmarks ---

class PostgresInitBenchmark extends AsyncBenchmarkBase {
  PostgresInitBenchmark() : super('PostgresInit');

  Sequelize? _sequelize;

  @override
  Future<void> setup() async {
    _sequelize = Sequelize().createInstance(
      connection: SequelizeConnection.postgres(url: postgresUrl),
    );
  }

  @override
  Future<void> run() async {
    await _sequelize!.initialize(
      models: [Users.model, Post.model, PostDetails.model],
    );
  }

  @override
  void teardown() {
    _sequelize?.close();
  }

  static void main() => PostgresInitBenchmark().report();
}

class PostgresFindOneBenchmark extends AsyncBenchmarkBase {
  PostgresFindOneBenchmark() : super('PostgresFindOne');

  Sequelize? _sequelize;

  @override
  Future<void> setup() async {
    _sequelize = Sequelize().createInstance(
      connection: SequelizeConnection.postgres(url: postgresUrl),
    );
    await _sequelize!.initialize(
      models: [Users.model, Post.model, PostDetails.model],
    );
  }

  @override
  Future<void> run() async {
    await Post.model.findOne(where: (p) => p.id.eq(1));
  }

  @override
  void teardown() {
    _sequelize?.close();
  }

  static void main() => PostgresFindOneBenchmark().report();
}

class PostgresFindAllBenchmark extends AsyncBenchmarkBase {
  PostgresFindAllBenchmark() : super('PostgresFindAll');

  Sequelize? _sequelize;

  @override
  Future<void> setup() async {
    _sequelize = Sequelize().createInstance(
      connection: SequelizeConnection.postgres(url: postgresUrl),
    );
    await _sequelize!.initialize(
      models: [Users.model, Post.model, PostDetails.model],
    );
  }

  @override
  Future<void> run() async {
    await Post.model.findAll(limit: 50);
  }

  @override
  void teardown() {
    _sequelize?.close();
  }

  static void main() => PostgresFindAllBenchmark().report();
}

/// Requests per second: run multiple findOne ops and report throughput.
class PostgresRpsBenchmark extends AsyncBenchmarkBase {
  PostgresRpsBenchmark({this.opsPerRun = 100}) : super('PostgresRps($opsPerRun)');

  final int opsPerRun;
  Sequelize? _sequelize;

  @override
  Future<void> setup() async {
    _sequelize = Sequelize().createInstance(
      connection: SequelizeConnection.postgres(url: postgresUrl),
    );
    await _sequelize!.initialize(
      models: [Users.model, Post.model, PostDetails.model],
    );
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < opsPerRun; i++) {
      await Post.model.findOne(where: (p) => p.id.eq(1));
    }
  }

  @override
  void teardown() {
    _sequelize?.close();
  }

  static void main() => PostgresRpsBenchmark().report();
}

// --- MongoDB (Native) Benchmarks ---

class MongoInitBenchmark extends AsyncBenchmarkBase {
  MongoInitBenchmark() : super('MongoInit');

  MongoConnection? _connection;
  MongoQueryEngine? _engine;

  @override
  Future<void> setup() async {
    _connection = MongoConnection(
      config: const MongoConnectionConfig(url: mongoUrl, database: mongoDatabase),
    );
    _engine = MongoQueryEngine(
      database: _connection!.adapter,
      associationResolver: _associationResolver,
    );
  }

  @override
  Future<void> run() async {
    await _connection!.open();
  }

  @override
  void teardown() {
    _connection?.close();
  }

  static MongoAssociationDefinition? _associationResolver({
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
  }

  static void main() => MongoInitBenchmark().report();
}

class MongoFindOneBenchmark extends AsyncBenchmarkBase {
  MongoFindOneBenchmark() : super('MongoFindOne');

  MongoConnection? _connection;
  MongoQueryEngine? _engine;

  @override
  Future<void> setup() async {
    _connection = MongoConnection(
      config: const MongoConnectionConfig(url: mongoUrl, database: mongoDatabase),
    );
    await _connection!.open();
    _engine = MongoQueryEngine(
      database: _connection!.adapter,
      associationResolver: _associationResolver,
    );
  }

  @override
  Future<void> run() async {
    await _engine!.findOne(
      modelName: postsCollection,
      query: Query(
        where: ComparisonOperator(column: '_id', value: {r'$eq': 'p1'}),
      ),
    );
  }

  @override
  void teardown() {
    _connection?.close();
  }

  static MongoAssociationDefinition? _associationResolver({
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
  }

  static void main() => MongoFindOneBenchmark().report();
}

class MongoFindAllBenchmark extends AsyncBenchmarkBase {
  MongoFindAllBenchmark() : super('MongoFindAll');

  MongoConnection? _connection;
  MongoQueryEngine? _engine;

  @override
  Future<void> setup() async {
    _connection = MongoConnection(
      config: const MongoConnectionConfig(url: mongoUrl, database: mongoDatabase),
    );
    await _connection!.open();
    _engine = MongoQueryEngine(
      database: _connection!.adapter,
      associationResolver: _associationResolver,
    );
  }

  @override
  Future<void> run() async {
    await _engine!.findAll(
      modelName: postsCollection,
      query: Query(limit: 50),
    );
  }

  @override
  void teardown() {
    _connection?.close();
  }

  static MongoAssociationDefinition? _associationResolver({
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
  }

  static void main() => MongoFindAllBenchmark().report();
}

class MongoRpsBenchmark extends AsyncBenchmarkBase {
  MongoRpsBenchmark({this.opsPerRun = 100}) : super('MongoRps($opsPerRun)');

  final int opsPerRun;
  MongoConnection? _connection;
  MongoQueryEngine? _engine;

  @override
  Future<void> setup() async {
    _connection = MongoConnection(
      config: const MongoConnectionConfig(url: mongoUrl, database: mongoDatabase),
    );
    await _connection!.open();
    _engine = MongoQueryEngine(
      database: _connection!.adapter,
      associationResolver: _associationResolver,
    );
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < opsPerRun; i++) {
      await _engine!.findOne(
        modelName: postsCollection,
        query: Query(
          where: ComparisonOperator(column: '_id', value: {r'$eq': 'p1'}),
        ),
      );
    }
  }

  @override
  void teardown() {
    _connection?.close();
  }

  static MongoAssociationDefinition? _associationResolver({
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
  }

  static void main() => MongoRpsBenchmark().report();
}

// --- Runner ---

Future<void> runBench(AsyncBenchmarkBase b) async {
  // report() orchestrates setup -> exercise -> teardown internally
  b.report();
}

void main() async {
  print('');
  print('=' * 60);
  print('SEQUELIZE DART BENCHMARK SUITE');
  print('MongoDB (native) vs PostgreSQL (bridge)');
  print('=' * 60);
  print('');

  print('--- Initialization ---');
  await runBench(PostgresInitBenchmark());
  await runBench(MongoInitBenchmark());

  print('');
  print('--- Model / Single Query ---');
  await runBench(PostgresFindOneBenchmark());
  await runBench(MongoFindOneBenchmark());

  print('');
  print('--- Batch Query ---');
  await runBench(PostgresFindAllBenchmark());
  await runBench(MongoFindAllBenchmark());

  print('');
  print('--- Throughput (requests/sec) ---');
  await runBench(PostgresRpsBenchmark());
  await runBench(MongoRpsBenchmark());

  print('');
  print('=' * 60);
  print('Done.');
  print('=' * 60);
  print('');
}
