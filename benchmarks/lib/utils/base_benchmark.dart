/// Standard interface that every ORM benchmark implementation must satisfy.
abstract class OrmBenchmark {
  /// Name of the ORM package (e.g., 'Sequelize ORM', 'Drift', 'Serverpod')
  String get name;

  /// Initialize database connection / client pool
  Future<void> init();

  /// Warmup query to prepare connection pools and execution plans
  Future<void> warmup();

  /// Benchmark 1: Fetch all posts
  Future<int> findAllPosts();

  /// Benchmark 2: Fetch posts with a limit (e.g. limit 10)
  Future<int> findAllPostsWithLimit(int limit);

  /// Benchmark 3: Fetch single post by ID
  Future<int> findOnePost(int id);

  /// Benchmark 4: Count total posts
  Future<int> countPosts();

  /// Benchmark 5: Filter posts by ID range (e.g. id < limit)
  Future<int> findPostsWhereIdLessThan(int id);

  /// Benchmark 6: Fetch posts joined with their PostDetails
  Future<int> findPostsWithDetails(int limit);

  /// Benchmark 7: Execute multiple sequential findOne queries
  Future<int> sequentialFindPosts(int count);

  /// Benchmark 8: Complex query with AND conditions and limit
  Future<int> complexWhere(int minId, int maxId, int limit);

  /// Close connection and clean up resources
  Future<void> close();
}
