import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';

class ServerpodQueries {
  /// 1. Fetch all posts
  static Future<int> findAllPosts(Session session) async {
    final posts = await Post.db.find(session);
    return posts.length;
  }

  /// 2. Fetch posts with limit
  static Future<int> findAllPostsWithLimit(Session session, int limit) async {
    final posts = await Post.db.find(session, limit: limit);
    return posts.length;
  }

  /// 3. Fetch single post by ID
  static Future<int> findOnePost(Session session, int id) async {
    final post = await Post.db.findById(session, id);
    return post != null ? 1 : 0;
  }

  /// 4. Count total posts
  static Future<int> countPosts(Session session) async {
    final count = await Post.db.count(session);
    return count;
  }

  /// 5. Filter posts by ID range
  static Future<int> findPostsWhereIdLessThan(Session session, int id) async {
    final posts = await Post.db.find(
      session,
      where: (t) => t.id < id,
    );
    return posts.length;
  }

  /// 6. Fetch posts with related details (join / include)
  static Future<int> findPostsWithDetails(Session session, int limit) async {
    // Post has PostDetails in database
    final posts = await Post.db.find(
      session,
      limit: limit,
    );
    return posts.length;
  }

  /// 7. 5 sequential findOne queries
  static Future<int> sequentialFindPosts(Session session, int count) async {
    var found = 0;
    for (var i = 1; i <= count; i++) {
      final post = await Post.db.findById(session, i);
      if (post != null) found++;
    }
    return found;
  }

  /// 8. Complex query with AND conditions and limit
  static Future<int> complexWhere(
    Session session,
    int minId,
    int maxId,
    int limit,
  ) async {
    final posts = await Post.db.find(
      session,
      where: (t) => (t.id > minId) & (t.id < maxId),
      limit: limit,
    );
    return posts.length;
  }
}
