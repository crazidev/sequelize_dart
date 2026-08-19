import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_quickjs/sequelize_orm_quickjs.dart';
import 'package:test/test.dart';

void main() {
  group('QuickJsBridgeClient', () {
    test('singleton instance access', () {
      final client1 = QuickJsBridgeClient.instance;
      final client2 = QuickJsBridgeClient.instance;
      expect(identical(client1, client2), isTrue);
    });

    test(
      'initializes and executes in-process bridge with typed SequelizeException',
      () async {
        final client = QuickJsBridgeClient.instance;

        // SQLite3 triggers our custom SequelizeConnectionError explaining the driver requirement
        await expectLater(
          client.start(
            connectionConfig: {
              'dialect': 'sqlite',
              'storage': ':memory:',
              'logging': false,
            },
          ),
          throwsA(
            isA<SequelizeConnectionError>().having(
              (e) => e.message,
              'message',
              contains('SQLite3 is currently not supported'),
            ),
          ),
        );

        expect(client.isClosed, isTrue);
        expect(client.isConnected, isFalse);
      },
    );

    test('re-initialization after close works cleanly', () async {
      final client = QuickJsBridgeClient.instance;

      await expectLater(
        client.start(
          connectionConfig: {
            'dialect': 'sqlite',
            'storage': ':memory:',
            'logging': false,
          },
        ),
        throwsA(isA<SequelizeConnectionError>()),
      );

      await client.close();
      expect(client.isClosed, isTrue);
    });
  });
}
