import '../../utils/base_benchmark.dart';
import 'connection.dart';
import 'models/database.dart';
import 'queries.dart';

export 'connection.dart';
export 'queries.dart';
export 'models/database.dart';

class DriftBenchmark implements OrmBenchmark {
  DriftAppDatabase? _db;

  @override
  String get name => 'Drift';

  @override
  Future<void> init() async {
    _db = createDriftDatabase();
  }

  @override
  Future<void> warmup() async {
    if (_db != null) {
      await DriftQueries.findAllPostsWithLimit(_db!, 5);
    }
  }

  @override
  Future<int> findAllPosts() => DriftQueries.findAllPosts(_db!);

  @override
  Future<int> findAllPostsWithLimit(int limit) =>
      DriftQueries.findAllPostsWithLimit(_db!, limit);

  @override
  Future<int> findOnePost(int id) => DriftQueries.findOnePost(_db!, id);

  @override
  Future<int> countPosts() => DriftQueries.countPosts(_db!);

  @override
  Future<int> findPostsWhereIdLessThan(int id) =>
      DriftQueries.findPostsWhereIdLessThan(_db!, id);

  @override
  Future<int> findPostsWithDetails(int limit) =>
      DriftQueries.findPostsWithDetails(_db!, limit);

  @override
  Future<int> sequentialFindPosts(int count) =>
      DriftQueries.sequentialFindPosts(_db!, count);

  @override
  Future<int> complexWhere(int minId, int maxId, int limit) =>
      DriftQueries.complexWhere(_db!, minId, maxId, limit);

  @override
  Future<void> close() async {
    await _db?.close();
  }
}
