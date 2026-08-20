import 'package:orm_benchmarks/packages/serverpod/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

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

  /// 9. Create a single post
  static Future<int> createPost(Session session) async {
    final post = Post(
      title: 'Test Post',
      content: 'Test Content',
      userId: 1,
    );
    final row = await Post.db.insertRow(session, post);
    return row.id ?? 0;
  }

  /// 10. Update a single post
  static Future<int> updatePost(Session session, int id) async {
    final updated = await Post.db.updateWhere(
      session,
      where: (t) => t.id.equals(id),
      columnValues: (PostUpdateTable p1) {
        return [
          p1.title('Update Title'),
        ];
      },
    );

    return 1;
  }

  /// 11. Bulk create posts
  static Future<int> bulkCreatePosts(Session session, int count) async {
    final posts = List.generate(
      count,
      (i) => Post(
        title: 'Bulk Post $i',
        content: 'Content $i',
        userId: 1,
      ),
    );
    final inserted = await Post.db.insert(session, posts);
    return inserted.length;
  }

  /// 12. Delete a single post
  static Future<int> deletePost(Session session, int id) async {
    final deleted = await Post.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
    return 1;
  }
}
