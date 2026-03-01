import 'package:sequelize_orm_mongodb/src/mongo_aggregation.dart';
import 'package:sequelize_orm_mongodb/src/mongo_association.dart';
import 'package:sequelize_orm_mongodb/src/mongo_exceptions.dart';
import 'package:sequelize_orm_mongodb/src/mongo_operator_translator.dart';

class MongoLookupBuilder {
  const MongoLookupBuilder({
    required MongoAssociationResolver associationResolver,
    MongoOperatorTranslator? operatorTranslator,
  })  : _associationResolver = associationResolver,
        _operatorTranslator =
            operatorTranslator ?? const MongoOperatorTranslator();

  final MongoAssociationResolver _associationResolver;
  final MongoOperatorTranslator _operatorTranslator;

  List<Map<String, dynamic>> buildLookupStages({
    required String sourceModel,
    required List<Map<String, dynamic>> includes,
  }) {
    final stages = <Map<String, dynamic>>[];
    for (final include in includes) {
      stages.addAll(
        _buildSingleInclude(
          sourceModel: sourceModel,
          include: include,
        ),
      );
    }
    return stages;
  }

  List<Map<String, dynamic>> _buildSingleInclude({
    required String sourceModel,
    required Map<String, dynamic> include,
  }) {
    final associationName = include['association']?.toString();
    if (associationName == null || associationName.isEmpty) {
      throw MongoAssociationResolutionException(
        'Include entry is missing a valid association name.',
        context: 'MongoLookupBuilder',
      );
    }

    final definition = _associationResolver(
      sourceModel: sourceModel,
      associationName: associationName,
    );

    if (definition == null) {
      throw MongoAssociationResolutionException(
        'Association "$associationName" for model "$sourceModel" is not registered.',
        context: 'MongoLookupBuilder',
      );
    }

    final subPipeline = <Map<String, dynamic>>[];

    final where = include['where'];
    if (where is Map && where.isNotEmpty) {
      subPipeline.add({
        r'$match': _operatorTranslator.translateWhere(
          Map<String, dynamic>.from(where),
        ),
      });
    }

    final nestedIncludeRaw = include['include'];
    if (nestedIncludeRaw is List && nestedIncludeRaw.isNotEmpty) {
      final nestedIncludes = nestedIncludeRaw
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
      subPipeline.addAll(
        buildLookupStages(
          sourceModel: definition.targetCollection,
          includes: nestedIncludes,
        ),
      );
    }

    final includeOrder = include['order'];
    final sort = MongoAggregationBuilder.parseSort(includeOrder);
    if (sort != null && sort.isNotEmpty) {
      subPipeline.add({r'$sort': sort});
    }

    final includeOffset = include['offset'];
    if (includeOffset is int && includeOffset > 0) {
      subPipeline.add({r'$skip': includeOffset});
    }

    final includeLimit = include['limit'];
    if (includeLimit is int && includeLimit >= 0) {
      subPipeline.add({r'$limit': includeLimit});
    }

    final projection = MongoAggregationBuilder.parseProjection(
      include['attributes'],
    );
    if (projection != null && projection.isNotEmpty) {
      subPipeline.add({r'$project': projection});
    }

    final lookupStage = <String, dynamic>{
      r'$lookup': {
        'from': definition.targetCollection,
        'localField': definition.localField,
        'foreignField': definition.foreignField,
        'as': definition.as,
        if (subPipeline.isNotEmpty) 'pipeline': subPipeline,
      },
    };

    final stages = <Map<String, dynamic>>[lookupStage];
    if (include['required'] == true) {
      stages.add({
        r'$match': {
          '${definition.as}.0': {r'$exists': true},
        },
      });
    }
    return stages;
  }
}
