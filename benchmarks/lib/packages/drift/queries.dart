import 'package:drift/drift.dart';
import 'models/database.dart';

class DriftQueries {
  /// 1. Fetch all posts
  static Future<int> findAllPosts(DriftAppDatabase db) async {
    final posts = await db.select(db.posts).get();
    return posts.length;
  }

  /// 2. Fetch posts with limit
  static Future<int> findAllPostsWithLimit(
      DriftAppDatabase db, int limit) async {
    final posts = await (db.select(db.posts)..limit(limit)).get();
    return posts.length;
  }

  /// 3. Fetch single post by ID
  static Future<int> findOnePost(DriftAppDatabase db, int id) async {
    final post = await (db.select(db.posts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return post != null ? 1 : 0;
  }

  /// 4. Count total posts
  static Future<int> countPosts(DriftAppDatabase db) async {
    final countExpr = db.posts.id.count();
    final query = db.selectOnly(db.posts)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// 5. Filter posts by ID range
  static Future<int> findPostsWhereIdLessThan(
      DriftAppDatabase db, int id) async {
    final posts = await (db.select(db.posts)
          ..where((t) => t.id.isSmallerThanValue(id)))
        .get();
    return posts.length;
  }

  /// 6. Fetch posts joined with PostDetails
  static Future<int> findPostsWithDetails(
      DriftAppDatabase db, int limit) async {
    final rows = await (db.select(db.posts).join([
      leftOuterJoin(
        db.postDetails,
        db.postDetails.postId.equalsExp(db.posts.id),
      )
    ])
          ..limit(limit))
        .get();
    return rows.length;
  }

  /// 7. 5 sequential findOne queries
  static Future<int> sequentialFindPosts(DriftAppDatabase db, int count) async {
    var found = 0;
    for (var i = 1; i <= count; i++) {
      final post = await (db.select(db.posts)..where((t) => t.id.equals(i)))
          .getSingleOrNull();
      if (post != null) found++;
    }
    return found;
  }

  /// 8. Complex query with AND conditions and limit
  static Future<int> complexWhere(
    DriftAppDatabase db,
    int minId,
    int maxId,
    int limit,
  ) async {
    final posts = await (db.select(db.posts)
          ..where((t) =>
              t.id.isBiggerThanValue(minId) & t.id.isSmallerThanValue(maxId))
          ..limit(limit))
        .get();
    return posts.length;
  }
}
