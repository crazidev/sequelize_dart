import 'dart:io';

import 'package:orm/orm.dart';
import 'package:orm_benchmarks/prisma_client/client.dart';
import 'package:orm_benchmarks/prisma_client/prisma.dart';
import 'package:orm_benchmarks/utils/base_benchmark.dart';
import 'package:orm_benchmarks/utils/step_profiler.dart';

class PrismaOrmBenchmark implements OrmBenchmark {
  late PrismaClient _prisma;
  int _lastCreatedId = 10;

  @override
  String get name => 'Prisma';

  @override
  StepProfiler? get stepProfiler => null;

  @override
  Future<void> init() async {
    final candidatePaths = [
      'prisma/prisma-query-engine',
      'benchmarks/prisma/prisma-query-engine',
      '../benchmarks/prisma/prisma-query-engine',
    ];
    for (final p in candidatePaths) {
      final f = File(p);
      if (f.existsSync()) {
        Platform.environment['PRISMA_QUERY_ENGINE_BINARY'] = f.absolute.path;
        break;
      }
    }
    _prisma = PrismaClient();
    await _prisma.$connect();
  }

  @override
  Future<void> warmup() async {
    await _prisma.posts.findMany(take: 5);
  }

  @override
  Future<int> findAllPosts() async {
    final posts = await _prisma.posts.findMany();
    return posts.toList().length;
  }

  @override
  Future<int> findAllPostsWithLimit(int limit) async {
    final posts = await _prisma.posts.findMany(take: limit);
    return posts.toList().length;
  }

  @override
  Future<int> findOnePost(int id) async {
    final post = await _prisma.posts.findFirst(
      where: PostsWhereInput(
        id: PrismaUnion.$1(IntFilter(equals: PrismaUnion.$1(id))),
      ),
    );
    return post != null ? 1 : 0;
  }

  @override
  Future<int> countPosts() async {
    final result = await _prisma.posts.aggregate(
      select: const AggregatePostsSelect($count: PrismaUnion.$1(true)),
    );
    return result.$count?.$all ?? 0;
  }

  @override
  Future<int> findPostsWhereIdLessThan(int id) async {
    final posts = await _prisma.posts.findMany(
      where: PostsWhereInput(
        id: PrismaUnion.$1(IntFilter(lt: PrismaUnion.$1(id))),
      ),
    );
    return posts.toList().length;
  }

  @override
  Future<int> findPostsWithDetails(int limit) async {
    final posts = await _prisma.posts.findMany(
      take: limit,
      include: const PostsInclude(postDetails: PrismaUnion.$1(true)),
    );
    return posts.toList().length;
  }

  @override
  Future<int> sequentialFindPosts(int count) async {
    var found = 0;
    for (var i = 1; i <= count; i++) {
      final post = await _prisma.posts.findFirst(
        where: PostsWhereInput(
          id: PrismaUnion.$1(IntFilter(equals: PrismaUnion.$1(i))),
        ),
      );
      if (post != null) found++;
    }
    return found;
  }

  @override
  Future<int> complexWhere(int minId, int maxId, int limit) async {
    final posts = await _prisma.posts.findMany(
      where: PostsWhereInput(
        AND: PrismaUnion.$2([
          PostsWhereInput(
            id: PrismaUnion.$1(IntFilter(gt: PrismaUnion.$1(minId))),
          ),
          PostsWhereInput(
            id: PrismaUnion.$1(IntFilter(lt: PrismaUnion.$1(maxId))),
          ),
        ]),
      ),
      take: limit,
    );
    return posts.toList().length;
  }

  @override
  Future<int> createPost() async {
    final post = await _prisma.posts.create(
      data: const PrismaUnion.$2(
        PostsUncheckedCreateInput(
          title: PrismaUnion.$1('Test Post'),
          content: PrismaUnion.$1('Test Content'),
          userId: PrismaUnion.$1(1),
        ),
      ),
    );
    _lastCreatedId = post.id ?? 10;
    return _lastCreatedId;
  }

  @override
  Future<int> updatePost() async {
    final post = await _prisma.posts.update(
      where: PostsWhereUniqueInput(id: _lastCreatedId),
      data: const PrismaUnion.$1(
        PostsUpdateInput(
          title: PrismaUnion.$1('Updated Title'),
        ),
      ),
    );
    return post != null ? 1 : 0;
  }

  @override
  Future<int> bulkCreatePosts(int count) async {
    final posts = List.generate(
      count,
      (i) => PostsCreateManyInput(
        title: PrismaUnion.$1('Bulk Post $i'),
        content: PrismaUnion.$1('Content $i'),
        userId: const PrismaUnion.$1(1),
      ),
    );
    final result = await _prisma.posts.createMany(
      data: PrismaUnion.$2(posts),
    );
    return result.count ?? 0;
  }

  @override
  Future<int> deletePost() async {
    try {
      final deleted = await _prisma.posts.delete(
        where: PostsWhereUniqueInput(id: _lastCreatedId),
      );
      return deleted != null ? 1 : 0;
    } catch (_) {
      // Prisma throws P2025 if the record does not exist.
      // In a benchmark loop, subsequent iterations will fail.
      return 0;
    }
  }

  @override
  Future<void> close() async {
    await _prisma.$disconnect();
  }
}
