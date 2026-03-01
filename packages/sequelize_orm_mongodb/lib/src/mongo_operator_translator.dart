import 'package:sequelize_orm_mongodb/src/mongo_exceptions.dart';
import 'package:sequelize_orm_mongodb/src/mongo_like_pattern_converter.dart';

class MongoOperatorTranslator {
  const MongoOperatorTranslator();

  Map<String, dynamic> translateWhere(Map<String, dynamic>? where) {
    if (where == null || where.isEmpty) {
      return <String, dynamic>{};
    }

    final clauses = <Map<String, dynamic>>[];
    for (final entry in where.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key == r'$and' || key == r'$or' || key == r'$not') {
        clauses.add(_translateLogicalClause(key: key, value: value));
      } else {
        clauses.add(_translateFieldClause(field: key, value: value));
      }
    }

    return _combineWithAnd(clauses);
  }

  Map<String, dynamic> _translateLogicalClause({
    required String key,
    required dynamic value,
  }) {
    final list = value is List ? value : [value];
    final translated = list
        .whereType<Map>()
        .map((item) => translateWhere(Map<String, dynamic>.from(item)))
        .where((item) => item.isNotEmpty)
        .toList();

    if (translated.isEmpty) return {};

    if (key == r'$not') {
      return {r'$nor': translated};
    }
    return {key: translated};
  }

  Map<String, dynamic> _translateFieldClause({
    required String field,
    required dynamic value,
  }) {
    if (value is! Map) {
      return {field: value};
    }

    final mapValue = Map<String, dynamic>.from(value);
    if (!_containsOperatorKey(mapValue)) {
      return {field: _translateNestedDocument(mapValue)};
    }

    final translatedOperators = <String, dynamic>{};
    final additionalClauses = <Map<String, dynamic>>[];

    for (final entry in mapValue.entries) {
      final opKey = entry.key;
      final opValue = entry.value;

      switch (opKey) {
        case r'$eq':
        case r'$ne':
        case r'$gt':
        case r'$gte':
        case r'$lt':
        case r'$lte':
        case r'$in':
          translatedOperators[opKey] = _translateValue(opValue);
          break;
        case r'$notIn':
          translatedOperators[r'$nin'] = _translateValue(opValue);
          break;
        case r'$between':
          final pair = _expectTwoValues(opValue, opKey);
          translatedOperators[r'$gte'] = _translateValue(pair[0]);
          translatedOperators[r'$lte'] = _translateValue(pair[1]);
          break;
        case r'$notBetween':
          final pair = _expectTwoValues(opValue, opKey);
          additionalClauses.add({
            r'$or': [
              {
                field: {r'$lt': _translateValue(pair[0])},
              },
              {
                field: {r'$gt': _translateValue(pair[1])},
              },
            ],
          });
          break;
        case r'$like':
          translatedOperators.addAll(
            MongoLikePatternConverter.likeOperator(opValue.toString()),
          );
          break;
        case r'$notLike':
          translatedOperators.addAll(
            MongoLikePatternConverter.notLikeOperator(opValue.toString()),
          );
          break;
        case r'$iLike':
        case r'$ilike':
          translatedOperators.addAll(
            MongoLikePatternConverter.likeOperator(
              opValue.toString(),
              caseInsensitive: true,
            ),
          );
          break;
        case r'$notILike':
        case r'$notIlike':
          translatedOperators.addAll(
            MongoLikePatternConverter.notLikeOperator(
              opValue.toString(),
              caseInsensitive: true,
            ),
          );
          break;
        case r'$startsWith':
          translatedOperators[r'$regex'] =
              '^${RegExp.escape(opValue.toString())}';
          break;
        case r'$endsWith':
          translatedOperators[r'$regex'] =
              '${RegExp.escape(opValue.toString())}\$';
          break;
        case r'$substring':
          translatedOperators[r'$regex'] = RegExp.escape(opValue.toString());
          break;
        case r'$regexp':
          translatedOperators[r'$regex'] = opValue.toString();
          break;
        case r'$notRegexp':
          translatedOperators[r'$not'] = {r'$regex': opValue.toString()};
          break;
        case r'$iRegexp':
          translatedOperators[r'$regex'] = opValue.toString();
          translatedOperators[r'$options'] = 'i';
          break;
        case r'$notIRegexp':
          translatedOperators[r'$not'] = {
            r'$regex': opValue.toString(),
            r'$options': 'i',
          };
          break;
        case r'$is':
          translatedOperators[r'$eq'] = _translateValue(opValue);
          break;
        case r'$not':
          translatedOperators[r'$not'] = _translateNotValue(opValue);
          break;
        case r'$col':
          return {
            r'$expr': {
              r'$eq': ['\$$field', '\$${opValue.toString()}'],
            },
          };
        case r'$match':
          throw MongoUnsupportedFeatureException(
            'The \$match text-search operator is not supported for MongoDB translation.',
            context: 'MongoOperatorTranslator',
          );
        default:
          if (opKey.startsWith(r'$')) {
            translatedOperators[opKey] = _translateValue(opValue);
          } else {
            translatedOperators[opKey] = opValue;
          }
      }
    }

    final clauses = <Map<String, dynamic>>[];
    if (translatedOperators.isNotEmpty) {
      clauses.add({field: translatedOperators});
    }
    clauses.addAll(additionalClauses);

    return _combineWithAnd(clauses);
  }

  bool _containsOperatorKey(Map<String, dynamic> map) {
    return map.keys.any((key) => key.startsWith(r'$'));
  }

  Map<String, dynamic> _translateNestedDocument(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final value = entry.value;
      if (value is Map) {
        final nested = Map<String, dynamic>.from(value);
        if (_containsOperatorKey(nested)) {
          final translated =
              _translateFieldClause(field: entry.key, value: nested);
          result[entry.key] = translated.containsKey(entry.key)
              ? translated[entry.key]
              : translated;
        } else {
          result[entry.key] = _translateNestedDocument(nested);
        }
      } else if (value is List) {
        result[entry.key] = value.map(_translateValue).toList();
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  dynamic _translateNotValue(dynamic value) {
    if (value is Map) {
      final translated = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key;
        final nestedValue = entry.value;
        if (key == r'$notIn') {
          translated[r'$nin'] = _translateValue(nestedValue);
        } else {
          translated[key] = _translateValue(nestedValue);
        }
      }
      return translated;
    }
    return _translateValue(value);
  }

  dynamic _translateValue(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (key, nestedValue) =>
            MapEntry(key.toString(), _translateValue(nestedValue)),
      );
    }
    if (value is List) {
      return value.map(_translateValue).toList();
    }
    return value;
  }

  List<dynamic> _expectTwoValues(dynamic value, String operator) {
    if (value is List && value.length == 2) {
      return value;
    }
    throw MongoQueryException(
      '$operator expects exactly two values.',
      context: 'MongoOperatorTranslator',
    );
  }

  Map<String, dynamic> _combineWithAnd(List<Map<String, dynamic>> clauses) {
    final nonEmpty = clauses.where((c) => c.isNotEmpty).toList();
    if (nonEmpty.isEmpty) {
      return <String, dynamic>{};
    }
    if (nonEmpty.length == 1) {
      return nonEmpty.first;
    }
    return {r'$and': nonEmpty};
  }
}
