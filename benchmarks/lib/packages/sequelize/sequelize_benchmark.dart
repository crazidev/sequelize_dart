import 'package:orm_benchmarks/packages/sequelize/connection.dart';
import 'package:orm_benchmarks/packages/sequelize/models/post.model.dart';
import 'package:orm_benchmarks/packages/sequelize/queries.dart';
import 'package:orm_benchmarks/utils/base_benchmark.dart';
import 'package:sequelize_orm/sequelize_orm.dart';

export 'connection.dart';
export 'queries.dart';
export 'setup.dart';

class SequelizeOrmBenchmark implements OrmBenchmark {
  Sequelize? _sequelize;

  @override
  String get name => 'Sequelize';

  @override
  Future<void> init() async {
    _sequelize = await initSequelize();
  }

  @override
  Future<void> warmup() async {
    await Post.model.findAll(limit: 5);
  }

  @override
  Future<int> findAllPosts() => SequelizeQueries.findAllPosts();

  @override
  Future<int> findAllPostsWithLimit(int limit) =>
      SequelizeQueries.findAllPostsWithLimit(limit);

  @override
  Future<int> findOnePost(int id) => SequelizeQueries.findOnePost(id);

  @override
  Future<int> countPosts() => SequelizeQueries.countPosts();

  @override
  Future<int> findPostsWhereIdLessThan(int id) =>
      SequelizeQueries.findPostsWhereIdLessThan(id);

  @override
  Future<int> findPostsWithDetails(int limit) =>
      SequelizeQueries.findPostsWithDetails(limit);

  @override
  Future<int> sequentialFindPosts(int count) =>
      SequelizeQueries.sequentialFindPosts(count);

  @override
  Future<int> complexWhere(int minId, int maxId, int limit) =>
      SequelizeQueries.complexWhere(minId, maxId, limit);

  @override
  Future<void> close() async {
    await _sequelize?.close();
  }
}
