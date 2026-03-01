import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

void main() {
  group('MongoLikePatternConverter', () {
    test('converts contains pattern', () {
      final regex = MongoLikePatternConverter.convertLikeToRegex('%text%');
      expect(regex, '^.*text.*\$');
    });

    test('converts starts and ends patterns', () {
      expect(
        MongoLikePatternConverter.convertLikeToRegex('text%'),
        '^text.*\$',
      );
      expect(
        MongoLikePatternConverter.convertLikeToRegex('%text'),
        '^.*text\$',
      );
    });

    test('converts underscore wildcard to single-character match', () {
      final regex = MongoLikePatternConverter.convertLikeToRegex('ab_cd');
      expect(regex, '^ab.cd\$');
    });

    test('escapes regex special characters in literals', () {
      final regex = MongoLikePatternConverter.convertLikeToRegex('a.c+d?');
      expect(regex, r'^a\.c\+d\?$');
    });

    test('handles escaped SQL wildcard characters', () {
      final regex =
          MongoLikePatternConverter.convertLikeToRegex(r'value\%x\_y');
      expect(regex, r'^value%x_y$');
    });
  });
}
