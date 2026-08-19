import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  setUp(() {
    clearCapturedSql();
  });

  // ──────────────────────────────────────────────
  // UNMANAGED TRANSACTIONS
  // ──────────────────────────────────────────────
  group('Unmanaged Transactions', () {
    test('rollback prevents data from being persisted', () async {
      final tx = await sequelize.startUnmanagedTransaction();
      final email =
          'rollback_${DateTime.now().millisecondsSinceEpoch}@example.com';

      try {
        await Users.model.create(
          CreateUsers(email: email, firstName: 'Rollback', lastName: 'User'),
          transaction: tx,
        );

        // Visible inside the transaction
        final inTx = await Users.model.findOne(
          where: (u) => u.email.eq(email),
          transaction: tx,
        );
        expect(
          inTx,
          isNotNull,
          reason: 'Should be visible within the transaction',
        );

        // Not visible outside
        final outside = await Users.model.findOne(
          where: (u) => u.email.eq(email),
        );
        expect(
          outside,
          isNull,
          reason: 'Should not be visible outside transaction before commit',
        );

        await tx.rollback();
      } catch (e) {
        if (!tx.isFinished) await tx.rollback();
        rethrow;
      }

      // Still not visible after rollback
      final afterRollback = await Users.model.findOne(
        where: (u) => u.email.eq(email),
      );
      expect(afterRollback, isNull, reason: 'Should not exist after rollback');
    });

    test('commit persists data', () async {
      final tx = await sequelize.startUnmanagedTransaction();
      final email =
          'commit_${DateTime.now().millisecondsSinceEpoch}@example.com';

      try {
        await Users.model.create(
          CreateUsers(email: email, firstName: 'Commit', lastName: 'User'),
          transaction: tx,
        );
        await tx.commit();
      } catch (e) {
        if (!tx.isFinished) await tx.rollback();
        rethrow;
      }

      final afterCommit = await Users.model.findOne(
        where: (u) => u.email.eq(email),
      );
      expect(afterCommit, isNotNull);
      expect(afterCommit?.email, equals(email));
    });

    test('instance methods (update) support explicit transaction', () async {
      final user = await Users.model.create(
        CreateUsers(
          email:
              'instance_tx_${DateTime.now().millisecondsSinceEpoch}@example.com',
          firstName: 'Before',
          lastName: 'TX',
        ),
      );

      final tx = await sequelize.startUnmanagedTransaction();
      try {
        await user.update({'first_name': 'UpdatedInTX'}, transaction: tx);

        // Updated on local instance
        expect(user.firstName, equals('UpdatedInTX'));

        // Visible within tx
        final inTx = await Users.model.findOne(
          where: (u) => u.id.eq(user.id),
          transaction: tx,
        );
        expect(inTx?.firstName, equals('UpdatedInTX'));

        // Not yet visible outside
        final outside = await Users.model.findOne(
          where: (u) => u.id.eq(user.id),
        );
        expect(outside?.firstName, isNot(equals('UpdatedInTX')));

        await tx.commit();
      } catch (e) {
        if (!tx.isFinished) await tx.rollback();
        rethrow;
      }

      await user.reload();
      expect(user.firstName, equals('UpdatedInTX'));
    });

    test('reusing a finished transaction throws StateError', () async {
      final tx = await sequelize.startUnmanagedTransaction();
      await tx.commit();

      expect(tx.isFinished, isTrue);
      expect(() => tx.commit(), throwsStateError);
      expect(() => tx.rollback(), throwsStateError);
    });
  });

  // ──────────────────────────────────────────────
  // MANAGED TRANSACTIONS
  // ──────────────────────────────────────────────
  group('Managed Transactions', () {
    test('automatically commits when callback succeeds', () async {
      final email =
          'managed_${DateTime.now().millisecondsSinceEpoch}@example.com';

      await sequelize.transaction((_) async {
        await Users.model.create(
          CreateUsers(email: email, firstName: 'Managed', lastName: 'User'),
        );
      });

      // Committed — should be findable outside
      final found = await Users.model.findOne(where: (u) => u.email.eq(email));
      expect(found, isNotNull);
      expect(found?.email, equals(email));
    });

    test('automatically rolls back when callback throws', () async {
      final email =
          'managed_rb_${DateTime.now().millisecondsSinceEpoch}@example.com';

      await expectLater(
        () => sequelize.transaction((_) async {
          await Users.model.create(
            CreateUsers(
              email: email,
              firstName: 'ShouldRollback',
              lastName: 'User',
            ),
          );
          // Force rollback via error in unknown column
          await Users.model.findOne(
            where: (u) => const Column('emails').eq('trigger@error.com'),
          );
        }),
        throwsA(isA<SequelizeException>()),
      );

      // Rolled back — should not exist
      final found = await Users.model.findOne(where: (u) => u.email.eq(email));
      expect(found, isNull, reason: 'User should have been rolled back');
    });

    test(
      'operations automatically inherit the transaction (zone-based)',
      () async {
        final email =
            'inherit_${DateTime.now().millisecondsSinceEpoch}@example.com';

        await sequelize.transaction((_) async {
          // No 'transaction:' argument — inherited from Zone
          await Users.model.create(
            CreateUsers(email: email, firstName: 'Inherited', lastName: 'TX'),
          );

          // Also inherited
          final found = await Users.model.findOne(
            where: (u) => u.email.eq(email),
          );
          expect(
            found,
            isNotNull,
            reason: 'Should be visible via inherited transaction',
          );
        });

        // Confirmed committed
        final afterCommit = await Users.model.findOne(
          where: (u) => u.email.eq(email),
        );
        expect(afterCommit, isNotNull);
      },
    );

    test(
      'manually rolled back managed transaction is not re-rolled-back',
      () async {
        final email =
            'manual_rb_${DateTime.now().millisecondsSinceEpoch}@example.com';

        try {
          await sequelize.transaction((t) async {
            await Users.model.create(
              CreateUsers(
                email: email,
                firstName: 'Manual',
                lastName: 'Rollback',
              ),
            );
            // Manually roll back inside the callback
            await t.rollback();
            // The managed cleanup should detect isFinished=true and not try again
          });
        } catch (_) {
          // We may or may not get an error depending on implementation — just ensure no crash
        }

        final found = await Users.model.findOne(
          where: (u) => u.email.eq(email),
        );
        expect(found, isNull, reason: 'User should have been rolled back');
      },
    );
  });

  // ──────────────────────────────────────────────
  // NESTED TRANSACTIONS
  // ──────────────────────────────────────────────
  group('Nested Managed Transactions', () {
    test(
      'nested transaction commits independently of outer',
      () async {
        final emailOuter =
            'outer_${DateTime.now().millisecondsSinceEpoch}@example.com';
        final emailNested =
            'nested_${DateTime.now().millisecondsSinceEpoch}@example.com';

        await expectLater(
          sequelize.transaction((_) async {
            // Outer transaction writes
            await Users.model.create(
              CreateUsers(
                email: emailOuter,
                firstName: 'Outer',
                lastName: 'User',
              ),
            );

            // Nested transaction — commits before outer fails
            await sequelize.transaction((_) async {
              await Users.model.create(
                CreateUsers(
                  email: emailNested,
                  firstName: 'Nested',
                  lastName: 'User',
                ),
              );
            });

            // Force outer to fail
            throw Exception('Outer transaction fails intentionally');
          }),
          throwsException,
        );

        // Outer was rolled back
        final foundOuter = await Users.model.findOne(
          where: (u) => u.email.eq(emailOuter),
        );
        expect(
          foundOuter,
          isNull,
          reason: 'Outer transaction should be rolled back',
        );

        // Nested was its own committed transaction
        final foundNested = await Users.model.findOne(
          where: (u) => u.email.eq(emailNested),
        );
        expect(
          foundNested,
          isNotNull,
          reason: 'Nested transaction should have committed',
        );
      },
      skip: isSqlite
          ? 'SQLite locks the entire database and does not support concurrent write transactions easily'
          : null,
    );
  });

  // ──────────────────────────────────────────────
  // UNMANAGED INSIDE MANAGED
  // ──────────────────────────────────────────────
  group('Unmanaged Transaction inside Managed Transaction', () {
    test(
      'unmanaged tx is independent of managed tx rollback',
      () async {
        final emailManaged =
            'mix_m_${DateTime.now().millisecondsSinceEpoch}@example.com';
        final emailUnmanaged =
            'mix_u_${DateTime.now().millisecondsSinceEpoch}@example.com';

        final txUn = await sequelize.startUnmanagedTransaction();

        try {
          await sequelize.transaction((_) async {
            // Created in managed (inherited)
            await Users.model.create(
              CreateUsers(
                email: emailManaged,
                firstName: 'Managed',
                lastName: 'Mix',
              ),
            );

            // Created in unmanaged (explicit passing)
            await Users.model.create(
              CreateUsers(
                email: emailUnmanaged,
                firstName: 'Unmanaged',
                lastName: 'Mix',
              ),
              transaction: txUn,
            );

            // Force managed to fail — rolling back only emailManaged
            throw Exception(
              'Managed fails — should only affect managed records',
            );
          });
        } catch (_) {
          // Expected
        }

        // Managed was rolled back
        final foundManaged = await Users.model.findOne(
          where: (u) => u.email.eq(emailManaged),
        );
        expect(
          foundManaged,
          isNull,
          reason: 'Managed record should be rolled back',
        );

        // Unmanaged: not yet committed — not visible outside it
        final foundUnBeforeCommit = await Users.model.findOne(
          where: (u) => u.email.eq(emailUnmanaged),
        );
        expect(
          foundUnBeforeCommit,
          isNull,
          reason: 'Unmanaged record not yet committed',
        );

        // Commit unmanaged tx
        await txUn.commit();

        // Now it should be visible
        final foundUnAfterCommit = await Users.model.findOne(
          where: (u) => u.email.eq(emailUnmanaged),
        );
        expect(
          foundUnAfterCommit,
          isNotNull,
          reason: 'Unmanaged record should exist after commit',
        );
      },
      skip: isSqlite
          ? 'SQLite locks the entire database and does not support concurrent write transactions easily'
          : null,
    );
  });
}
