import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:sequelize_orm/sequelize_orm.dart';
import 'connection.dart';
import 'models/users.model.dart';
import 'models/post.model.dart';
import 'models/post_details.model.dart';

/// Synchronizes the database schema and seeds identical data for all benchmarks
Future<void> setupAndSeedDatabase({
  int userCount = 50,
  int postCount = 200,
}) async {
  print('Setting up database tables using Sequelize ORM...');
  final sequelize = await initSequelize();

  // Re-create tables with clean schema
  await sequelize.sync(force: true);

  print('Seeding database with $userCount users and $postCount posts...');

  // Create Users
  for (var i = 1; i <= userCount; i++) {
    await Users.model.create(
      CreateUsers(
        email: 'user$i@benchmark.com',
        firstName: 'User$i',
        lastName: 'Benchmark',
        status: i.isEven ? UsersStatus.active : UsersStatus.inactive,
        phoneNumber: SequelizeBigInt('${1000000000 + i}'),
        tags: ['benchmark', 'orm', 'dart'],
        scores: [i * 5, i * 10, i * 15],
        metadata: {
          'role': 'user',
          'isAdmin': i % 5 == 0,
          'age': 20 + (i % 50),
          'address': {'city': 'San Francisco', 'country': 'USA'},
        },
      ),
    );
  }

  // Create Posts and PostDetails
  for (var i = 1; i <= postCount; i++) {
    final userId = (i % userCount) + 1;
    final createdPost = await Post.model.create(
      CreatePost(
        title: 'Benchmark Post $i',
        content: 'This is the benchmark content for post number $i.',
        views: i * 10,
        userId: userId,
      ),
    );

    await PostDetails.model.create(
      CreatePostDetails(
        likes: i * 3,
        metadata: {
          'category': 'tech',
          'rating': 4.5,
          'postIndex': i,
        },
        postId: createdPost.id,
        userId: userId,
      ),
    );
  }

  // Ensure Serverpod metadata tables exist for Serverpod ORM compatibility
  await _initServerpodMetadataTables();

  print('Database setup & seeding completed successfully.\n');
  await sequelize.close();
}

Future<void> _initServerpodMetadataTables() async {
  final migrationFile = File('migrations/20260816191505752/migration.sql');
  if (!migrationFile.existsSync()) return;

  final sql = migrationFile.readAsStringSync();
  final statements = sql
      .replaceAll('CREATE TABLE "', 'CREATE TABLE IF NOT EXISTS "')
      .replaceAll(
          'CREATE UNIQUE INDEX "', 'CREATE UNIQUE INDEX IF NOT EXISTS "')
      .replaceAll('CREATE INDEX "', 'CREATE INDEX IF NOT EXISTS "')
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && s != 'BEGIN' && s != 'COMMIT');

  Connection? conn;
  try {
    conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'postgres',
        username: 'postgres',
        password: 'postgres',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    for (final stmt in statements) {
      if (stmt.contains('CREATE TABLE IF NOT EXISTS "post_details"') ||
          stmt.contains('CREATE TABLE IF NOT EXISTS "posts"') ||
          stmt.contains('CREATE TABLE IF NOT EXISTS "users"')) {
        continue;
      }
      try {
        await conn.execute(stmt);
      } catch (_) {
        // Ignore existing relation or index conflicts
      }
    }
  } catch (_) {
    // Ignore connection issues
  } finally {
    await conn?.close();
  }
}
