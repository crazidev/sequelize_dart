import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

void main() {
  group('MongoOperatorTranslator', () {
    const translator = MongoOperatorTranslator();

    test('passes through basic operators and logical clauses', () {
      final translated = translator.translateWhere({
        r'$and': [
          {
            'age': {r'$gt': 18},
          },
          {
            'active': {r'$eq': true},
          },
        ],
      });

      expect(translated, {
        r'$and': [
          {
            'age': {r'$gt': 18},
          },
          {
            'active': {r'$eq': true},
          },
        ],
      });
    });

    test('renames notIn to nin', () {
      final translated = translator.translateWhere({
        'status': {
          r'$notIn': ['inactive', 'pending'],
        },
      });

      expect(translated, {
        'status': {
          r'$nin': ['inactive', 'pending'],
        },
      });
    });

    test('expands between and notBetween', () {
      final between = translator.translateWhere({
        'score': {
          r'$between': [10, 20],
        },
      });
      expect(between, {
        'score': {
          r'$gte': 10,
          r'$lte': 20,
        },
      });

      final notBetween = translator.translateWhere({
        'score': {
          r'$notBetween': [10, 20],
        },
      });
      expect(notBetween, {
        r'$or': [
          {
            'score': {r'$lt': 10},
          },
          {
            'score': {r'$gt': 20},
          },
        ],
      });
    });

    test('converts LIKE and ILIKE patterns to regex operators', () {
      final translated = translator.translateWhere({
        'name': {
          r'$like': '%john%',
          r'$iLike': 'doe%',
        },
      });

      expect(translated, {
        'name': {
          r'$regex': '^doe.*\$',
          r'$options': 'i',
        },
      });
    });

    test('converts notLike to not regex', () {
      final translated = translator.translateWhere({
        'name': {
          r'$notLike': '%bot%',
        },
      });
      expect(translated, {
        'name': {
          r'$not': {
            r'$regex': '^.*bot.*\$',
          },
        },
      });
    });

    test('converts column comparison to expr', () {
      final translated = translator.translateWhere({
        'leftField': {
          r'$col': 'rightField',
        },
      });
      expect(translated, {
        r'$expr': {
          r'$eq': [r'$leftField', r'$rightField'],
        },
      });
    });

    test('throws for unsupported match operator', () {
      expect(
        () => translator.translateWhere({
          'searchVector': {
            r'$match': 'cat & dog',
          },
        }),
        throwsA(isA<MongoUnsupportedFeatureException>()),
      );
    });
  });
}
