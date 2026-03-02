import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group(
    'Mongo Save Semantics',
    skip: isMongo ? null : 'Mongo-only save semantics test',
    () {
      setUpAll(() async {
        await initTestEnvironment();
        await sequelize.sync(force: true);
      });

      tearDownAll(() async {
        await cleanupTestEnvironment();
      });

      setUp(() {
        clearCapturedSql();
      });

      test(
        'parent save excludes association payload, child save updates child',
        () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final created = await Users.model.create(
          CreateUsers(
            email: 'mongo_save_$timestamp@example.com',
            firstName: 'Mongo',
            lastName: 'Parent',
            post: CreatePost(
              title: 'mongo_post_$timestamp',
              content: 'Initial content',
              views: 10,
            ),
          ),
        );

        final userWithPost = await Users.model.findOne(
          where: (u) => u.id.eq(created.id),
          include: (includeUsers) => [includeUsers.post()],
        );
        expect(userWithPost, isNotNull);
        expect(userWithPost!.post, isNotNull);

        userWithPost.lastName = 'Updated Last Name';
        userWithPost.post!.title = 'Updated Title Should Not Persist Via UserSave';
        await userWithPost.save();

        final saveLog = capturedSql.lastWhere(
          (entry) => entry.startsWith('[mongo:save] '),
        );
        expect(saveLog, contains('"collection":"Users"'));
        expect(saveLog, isNot(contains('"post"')));
        expect(saveLog, isNot(contains('"posts"')));

        final userWithoutInclude = await Users.model.findOne(
          where: (u) => u.id.eq(created.id),
        );
        expect(userWithoutInclude, isNotNull);
        expect(userWithoutInclude!.post, isNull);
        expect(userWithoutInclude.lastName, 'Updated Last Name');

        userWithPost.post!.views = 100;
        await userWithPost.post!.save();

        final updatedPost = await Post.model.findOne(
          where: (p) => p.id.eq(userWithPost.post!.id),
        );
        expect(updatedPost, isNotNull);
        expect(updatedPost!.views, 100);
        },
        skip:
            'Mongo parent save full-instance update parity is not fully supported yet.',
      );
    },
  );
}
