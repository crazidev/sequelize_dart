import 'package:sequelize_orm/sequelize_orm.dart';
import 'models/post.model.dart';

class SequelizeQueries {
  /// 1. Fetch all posts
  static Future<int> findAllPosts() async {
    final posts = await Post.model.findAll();
    return posts.length;
  }

  /// 2. Fetch posts with limit
  static Future<int> findAllPostsWithLimit(int limit) async {
    final posts = await Post.model.findAll(limit: limit);
    return posts.length;
  }

  /// 3. Fetch single post by ID
  static Future<int> findOnePost(int id) async {
    final post = await Post.model.findOne(where: (p) => p.id.eq(id));
    return post != null ? 1 : 0;
  }

  /// 4. Count total posts
  static Future<int> countPosts() async {
    final count = await Post.model.count();
    return count;
  }

  /// 5. Filter posts by ID range
  static Future<int> findPostsWhereIdLessThan(int id) async {
    final posts = await Post.model.findAll(where: (p) => p.id.lt(id));
    return posts.length;
  }

  /// 6. Fetch posts with included PostDetails (JOIN)
  static Future<int> findPostsWithDetails(int limit) async {
    final posts = await Post.model.findAll(
      limit: limit,
      include: (p) => [p.postDetails()],
    );
    return posts.length;
  }

  /// 7. 5 sequential findOne queries
  static Future<int> sequentialFindPosts(int count) async {
    var found = 0;
    for (var i = 1; i <= count; i++) {
      final post = await Post.model.findOne(where: (p) => p.id.eq(i));
      if (post != null) found++;
    }
    return found;
  }

  /// 8. Complex query with AND conditions and limit
  static Future<int> complexWhere(int minId, int maxId, int limit) async {
    final posts = await Post.model.findAll(
      where: (p) => and([
        p.id.gt(minId),
        p.id.lt(maxId),
      ]),
      limit: limit,
    );
    return posts.length;
  }
}
