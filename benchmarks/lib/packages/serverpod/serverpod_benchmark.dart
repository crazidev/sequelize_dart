import '../../utils/base_benchmark.dart';
import '../../utils/step_profiler.dart';
import 'connection.dart';
import 'queries.dart';

export 'connection.dart';
export 'queries.dart';

class ServerpodOrmBenchmark implements OrmBenchmark {
  final ServerpodConnection _connection = ServerpodConnection();
  int _lastCreatedId = 10;

  @override
  String get name => 'Serverpod';

  /// Serverpod uses a direct Postgres pool — no intermediate serialization
  /// layer to profile, so stepProfiler is null.
  @override
  StepProfiler? get stepProfiler => null;

  @override
  Future<void> init() async {
    await _connection.init();
  }

  @override
  Future<void> warmup() async {
    await ServerpodQueries.findAllPostsWithLimit(_connection.session, 5);
  }

  @override
  Future<int> findAllPosts() =>
      ServerpodQueries.findAllPosts(_connection.session);

  @override
  Future<int> findAllPostsWithLimit(int limit) =>
      ServerpodQueries.findAllPostsWithLimit(_connection.session, limit);

  @override
  Future<int> findOnePost(int id) =>
      ServerpodQueries.findOnePost(_connection.session, id);

  @override
  Future<int> countPosts() => ServerpodQueries.countPosts(_connection.session);

  @override
  Future<int> findPostsWhereIdLessThan(int id) =>
      ServerpodQueries.findPostsWhereIdLessThan(_connection.session, id);

  @override
  Future<int> findPostsWithDetails(int limit) =>
      ServerpodQueries.findPostsWithDetails(_connection.session, limit);

  @override
  Future<int> sequentialFindPosts(int count) =>
      ServerpodQueries.sequentialFindPosts(_connection.session, count);

  @override
  Future<int> complexWhere(int minId, int maxId, int limit) =>
      ServerpodQueries.complexWhere(_connection.session, minId, maxId, limit);

  @override
  Future<int> createPost() async {
    final id = await ServerpodQueries.createPost(_connection.session);
    if (id > 0) _lastCreatedId = id;
    return id;
  }

  @override
  Future<int> updatePost() =>
      ServerpodQueries.updatePost(_connection.session, _lastCreatedId);

  @override
  Future<int> bulkCreatePosts(int count) =>
      ServerpodQueries.bulkCreatePosts(_connection.session, count);

  @override
  Future<int> deletePost() =>
      ServerpodQueries.deletePost(_connection.session, _lastCreatedId);

  @override
  Future<void> close() async {
    await _connection.close();
  }
}
