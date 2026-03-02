import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

void main() {
  group('Mongo auto bootstrap', () {
    test('auto-attaches mongo query engine from dialect', () {
      final sequelize = Sequelize().createInstance(
        connection: MongoConnectionOptions(
          url: 'mongodb://localhost:27017',
          database: 'sequelize_dart',
        ),
      );

      expect(sequelize.usesBridgeQueryEngine, isFalse);
      expect(sequelize.resolveQueryEngine(), isA<MongoQueryEngine>());
    });

    test('reads defaultParanoidField from MongoConnectionOptions', () {
      final sequelize = Sequelize().createInstance(
        connection: MongoConnectionOptions(
          url: 'mongodb://localhost:27017',
          database: 'sequelize_dart',
          defaultParanoidField: 'removedAt',
        ),
      );

      final engine = sequelize.resolveQueryEngine() as MongoQueryEngine;
      expect(engine.defaultParanoidField, 'removedAt');
    });
  });
}
