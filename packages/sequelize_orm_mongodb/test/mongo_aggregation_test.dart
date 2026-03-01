import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

void main() {
  group('MongoAggregationBuilder', () {
    test('builds accumulator pipeline with where and grouping', () {
      final pipeline = MongoAggregationBuilder.buildAccumulatorPipeline(
        accumulatorOperator: r'$max',
        column: 'views',
        where: {
          'active': {r'$eq': true},
        },
        group: 'authorId',
      );

      expect(pipeline, [
        {
          r'$match': {
            'active': {r'$eq': true},
          },
        },
        {
          r'$group': {
            r'_id': r'$authorId',
            'result': {
              r'$max': r'$views',
            },
          },
        },
      ]);
    });

    test('parses order list into sort map', () {
      final sort = MongoAggregationBuilder.parseSort([
        ['createdAt', 'DESC'],
        ['id', 'ASC'],
      ]);

      expect(sort, {
        'createdAt': -1,
        'id': 1,
      });
    });

    test('parses attribute list into projection map', () {
      final projection =
          MongoAggregationBuilder.parseProjection(['id', 'title']);
      expect(projection, {
        'id': 1,
        'title': 1,
      });
    });
  });
}
