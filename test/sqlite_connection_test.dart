import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:sequelize_orm_sqlite/sequelize_orm_sqlite.dart';
import 'package:test/test.dart';

/// Tests for SQLite connection behavior:
///
/// 1. Persistent databases — the database file is created automatically if it
///    doesn't exist.
/// 2. Temporary connections — `tempMemory()` / `tempDisk()` connect without
///    manual pool configuration and persist data for the session lifetime.
void main() {
  const dbPath = 'test_sqlite_auto.db';

  Future<Sequelize> createSequelize(
    SequelizeSqliteConnection connection,
  ) async {
    final sequelize = Sequelize().createInstance(connection: connection);
    await sequelize.initialize(
      models: [
        Users.model,
        Post.model,
        PostDetails.model,
      ],
    );
    return sequelize;
  }

  group('persistent database', () {
    late Sequelize sequelize;

    setUp(() {
      final file = File(dbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      expect(
        file.existsSync(),
        isFalse,
        reason: 'precondition: database file removed before connecting',
      );
    });

    tearDown(() async {
      await sequelize.close();
      final file = File(dbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test(
      'database file is created automatically if it does not exist',
      () async {
        sequelize = await createSequelize(
          SequelizeSqliteConnection.fromPath(dbPath),
        );
        await sequelize.sync(force: true);

        // Verify the newly created database is fully usable.
        final user = await Users.model.create(
          CreateUsers(
            email: 'auto@example.com',
            firstName: 'Auto',
            lastName: 'Create',
          ),
        );
        final found = await Users.model.findOne(
          where: (u) => u.id.eq(user.id),
        );
        expect(found, isNotNull);
        expect(found!.email, 'auto@example.com');

        expect(
          File(dbPath).existsSync(),
          isTrue,
          reason: 'database file should be created automatically on connect',
        );
      },
    );
  });

  group('temporary connections', () {
    test('tempMemory connects without pool configuration and persists data '
        'during the session', () async {
      final sequelize = await createSequelize(
        SequelizeSqliteConnection.tempMemory(),
      );
      await sequelize.sync(force: true);

      expect(await Users.model.count(), 0);

      final user = await Users.model.create(
        CreateUsers(
          email: 'mem@example.com',
          firstName: 'Memory',
          lastName: 'Temp',
        ),
      );
      final found = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(found, isNotNull);
      expect(found!.email, 'mem@example.com');

      await sequelize.close();
    });

    test('tempDisk connects without pool configuration and persists data '
        'during the session', () async {
      final sequelize = await createSequelize(
        SequelizeSqliteConnection.tempDisk(),
      );
      await sequelize.sync(force: true);

      expect(await Users.model.count(), 0);

      final user = await Users.model.create(
        CreateUsers(
          email: 'disk@example.com',
          firstName: 'Disk',
          lastName: 'Temp',
        ),
      );
      final found = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(found, isNotNull);
      expect(found!.email, 'disk@example.com');

      await sequelize.close();
    });
  });
}
