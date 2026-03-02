class MongoAggregationBuilder {
  const MongoAggregationBuilder._();

  static List<Map<String, dynamic>> buildAccumulatorPipeline({
    required String accumulatorOperator,
    required String column,
    Map<String, dynamic>? where,
    String resultField = 'result',
    dynamic group,
  }) {
    final pipeline = <Map<String, dynamic>>[];
    if (where != null && where.isNotEmpty) {
      pipeline.add({r'$match': where});
    }

    final groupId = _groupIdFrom(group);
    pipeline.add({
      r'$group': {
        r'_id': groupId,
        resultField: {
          accumulatorOperator:
              column == '*' ? 1 : '\$${column.replaceFirst(r'$', '')}',
        },
      },
    });
    return pipeline;
  }

  static List<Map<String, dynamic>> buildCountPipeline({
    Map<String, dynamic>? where,
    dynamic group,
    String resultField = 'result',
  }) {
    return buildAccumulatorPipeline(
      accumulatorOperator: r'$sum',
      column: '*',
      where: where,
      group: group,
      resultField: resultField,
    );
  }

  static List<Map<String, dynamic>> buildFindPipeline({
    Map<String, dynamic>? where,
    List<Map<String, dynamic>>? includeStages,
    Map<String, int>? sort,
    int? skip,
    int? limit,
    Map<String, dynamic>? projection,
  }) {
    final pipeline = <Map<String, dynamic>>[];
    if (where != null && where.isNotEmpty) {
      pipeline.add({r'$match': where});
    }
    if (includeStages != null && includeStages.isNotEmpty) {
      pipeline.addAll(includeStages);
    }
    if (sort != null && sort.isNotEmpty) {
      pipeline.add({r'$sort': sort});
    }
    if (skip != null && skip > 0) {
      pipeline.add({r'$skip': skip});
    }
    if (limit != null && limit >= 0) {
      pipeline.add({r'$limit': limit});
    }
    if (projection != null && projection.isNotEmpty) {
      pipeline.add({r'$project': projection});
    }
    return pipeline;
  }

  static Map<String, int>? parseSort(dynamic order) {
    if (order == null) {
      return null;
    }

    final sort = <String, int>{};
    if (order is String) {
      sort[order] = 1;
      return sort;
    }

    if (order is List) {
      for (final item in order) {
        if (item is String) {
          sort[item] = 1;
        } else if (item is List && item.length >= 2 && item.first is String) {
          final direction = item[1].toString().toUpperCase();
          sort[item.first as String] = direction == 'DESC' ? -1 : 1;
        } else if (item is Map && item.length == 1) {
          final field = item.keys.first.toString();
          final direction = item.values.first.toString().toUpperCase();
          sort[field] = direction == 'DESC' ? -1 : 1;
        }
      }
      return sort.isEmpty ? null : sort;
    }

    if (order is Map) {
      for (final entry in order.entries) {
        final field = entry.key.toString();
        final value = entry.value;
        if (value is num) {
          sort[field] = value < 0 ? -1 : 1;
        } else {
          final direction = value.toString().toUpperCase();
          sort[field] = direction == 'DESC' ? -1 : 1;
        }
      }
      return sort.isEmpty ? null : sort;
    }

    return null;
  }

  static Map<String, dynamic>? parseProjection(dynamic attributes) {
    if (attributes == null) {
      return null;
    }

    if (attributes is List) {
      final projection = <String, dynamic>{};
      for (final attr in attributes) {
        projection[attr.toString()] = 1;
      }
      return projection.isEmpty ? null : projection;
    }

    if (attributes is Map) {
      final map = Map<String, dynamic>.from(attributes);
      if (map.containsKey('exclude') && map['exclude'] is List) {
        final projection = <String, dynamic>{};
        for (final attr in map['exclude'] as List<dynamic>) {
          projection[attr.toString()] = 0;
        }
        return projection.isEmpty ? null : projection;
      }

      return map;
    }

    return null;
  }

  static dynamic _groupIdFrom(dynamic group) {
    if (group == null) {
      return null;
    }
    if (group is String) {
      return '\$${group.replaceFirst(r'$', '')}';
    }
    if (group is List) {
      final map = <String, dynamic>{};
      for (final field in group) {
        final fieldName = field.toString();
        map[fieldName] = '\$${fieldName.replaceFirst(r'$', '')}';
      }
      return map;
    }
    return group;
  }
}
