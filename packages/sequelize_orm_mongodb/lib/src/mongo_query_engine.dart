// ignore_for_file: avoid_dynamic_calls, implementation_imports

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_orm_mongodb/src/mongo_adapter.dart';
import 'package:sequelize_orm_mongodb/src/mongo_aggregation.dart';
import 'package:sequelize_orm_mongodb/src/mongo_association.dart';
import 'package:sequelize_orm_mongodb/src/mongo_exceptions.dart';
import 'package:sequelize_orm_mongodb/src/mongo_lookup_builder.dart';
import 'package:sequelize_orm_mongodb/src/mongo_operator_translator.dart';

class MongoQueryEngine extends QueryEngineInterface {
  MongoQueryEngine({
    required MongoDatabaseAdapter database,
    MongoOperatorTranslator? operatorTranslator,
    MongoLookupBuilder? lookupBuilder,
    MongoAssociationResolver? associationResolver,
    this.defaultParanoidField = 'deletedAt',
  })  : _database = database,
        _operatorTranslator =
            operatorTranslator ?? const MongoOperatorTranslator(),
        _associationResolver = associationResolver,
        _lookupBuilder = lookupBuilder ??
            (associationResolver == null
                ? null
                : MongoLookupBuilder(
                    associationResolver: associationResolver,
                    operatorTranslator: operatorTranslator,
                  ));

  final MongoDatabaseAdapter _database;
  final MongoOperatorTranslator _operatorTranslator;
  final MongoAssociationResolver? _associationResolver;
  final MongoLookupBuilder? _lookupBuilder;
  final String defaultParanoidField;

  MongoCollectionAdapter _collection(String modelName) {
    return _database.collection(modelName);
  }

  @override
  Future<List<ModelInstanceData>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final plan = _buildQueryPlan(
        query: query,
        model: model,
      );
      final collection = _collection(modelName);

      final docs = plan.includes.isNotEmpty
          ? await _runAggregationQuery(
              modelName: modelName,
              collection: collection,
              plan: plan,
            )
          : await collection.find(
              where: plan.where,
              sort: plan.sort,
              limit: plan.limit,
              skip: plan.offset,
              projection: plan.projection,
            );

      return docs.map((doc) => ModelInstanceData(data: doc)).toList();
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute findAll()',
      );
    }
  }

  @override
  Future<ModelInstanceData?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final plan = _buildQueryPlan(
        query: query,
        model: model,
      );
      final collection = _collection(modelName);

      Map<String, dynamic>? doc;
      if (plan.includes.isNotEmpty) {
        final docs = await _runAggregationQuery(
          modelName: modelName,
          collection: collection,
          plan: plan.copyWith(limit: 1),
        );
        if (docs.isNotEmpty) {
          doc = docs.first;
        }
      } else {
        doc = await collection.findOne(
          where: plan.where,
          sort: plan.sort,
          projection: plan.projection,
        );
      }

      if (doc == null) {
        return null;
      }
      return ModelInstanceData(data: doc);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute findOne()',
      );
    }
  }

  @override
  Future<ModelInstanceData> create({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final inserted = await _collection(modelName).insertOne(
        Map<String, dynamic>.from(data),
      );
      return ModelInstanceData(data: inserted);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute create()',
      );
    }
  }

  @override
  Future<List<ModelInstanceData>> bulkCreate({
    required String modelName,
    required List<Map<String, dynamic>> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final inserted = await _collection(modelName).insertMany(
        data.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
      return inserted.map((doc) => ModelInstanceData(data: doc)).toList();
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute bulkCreate()',
      );
    }
  }

  @override
  Future<int> update({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final plan = _buildQueryPlan(
        query: query,
        model: model,
      );
      return _collection(modelName).updateMany(
        where: plan.where,
        update: {
          r'$set': data,
        },
      );
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute update()',
      );
    }
  }

  @override
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final plan = _buildQueryPlan(
        query: query,
        model: model,
      );
      final collection = _collection(modelName);
      if (plan.group != null) {
        final pipeline = MongoAggregationBuilder.buildCountPipeline(
          where: plan.where,
          group: plan.group,
        );
        final docs = await collection.aggregate(pipeline);
        if (docs.isEmpty) {
          return 0;
        }
        return _numValue(docs.first['result']).toInt();
      }
      return collection.count(plan.where);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute count()',
      );
    }
  }

  @override
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    return _aggregateNumeric(
      modelName: modelName,
      column: column,
      query: query,
      model: model,
      accumulator: r'$max',
      context: 'Exception: failed to execute max()',
    );
  }

  @override
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    return _aggregateNumeric(
      modelName: modelName,
      column: column,
      query: query,
      model: model,
      accumulator: r'$min',
      context: 'Exception: failed to execute min()',
    );
  }

  @override
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    return _aggregateNumeric(
      modelName: modelName,
      column: column,
      query: query,
      model: model,
      accumulator: r'$sum',
      context: 'Exception: failed to execute sum()',
    );
  }

  @override
  Future<List<ModelInstanceData>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    return _applyIncrement(
      modelName: modelName,
      fields: fields,
      query: query,
      model: model,
      sign: 1,
      context: 'Exception: failed to execute increment()',
    );
  }

  @override
  Future<List<ModelInstanceData>> decrement({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    return _applyIncrement(
      modelName: modelName,
      fields: fields,
      query: query,
      model: model,
      sign: -1,
      context: 'Exception: failed to execute decrement()',
    );
  }

  @override
  Future<ModelInstanceData> save({
    required String modelName,
    required Map<String, dynamic> currentData,
    Map<String, dynamic>? previousData,
    required Map<String, dynamic> primaryKeyValues,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final replacement = Map<String, dynamic>.from(currentData);
      final saved = await _collection(modelName).replaceOne(
        where: Map<String, dynamic>.from(primaryKeyValues),
        replacement: replacement,
        upsert: true,
      );
      return ModelInstanceData(data: saved);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute save()',
      );
    }
  }

  @override
  Future<ModelInstanceData?> belongsToGet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      if (association.associationType != MongoAssociationType.belongsTo) {
        throw MongoUnsupportedFeatureException(
          'belongsToGet only supports belongsTo associations.',
          context: 'MongoQueryEngine.belongsToGet',
        );
      }

      final source = await _collection(sourceModel).findOne(
        where: Map<String, dynamic>.from(primaryKeyValues),
      );
      if (source == null) {
        return null;
      }

      final foreignKeyValue = source[association.localField];
      if (foreignKeyValue == null) {
        return null;
      }

      final target = await _collection(
        association.targetCollection,
      ).findOne(
        where: {
          association.foreignField: foreignKeyValue,
        },
      );
      if (target == null) {
        return null;
      }

      return ModelInstanceData(data: target);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute belongsToGet()',
      );
    }
  }

  @override
  Future<void> belongsToSet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required targetOrKey,
    bool? save,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      final targetKey = _extractTargetKey(
        targetOrKey,
        preferredField: association.foreignField,
      );

      await _collection(sourceModel).updateOne(
        where: Map<String, dynamic>.from(primaryKeyValues),
        update: {
          r'$set': {
            association.localField: targetKey,
          },
        },
      );
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute belongsToSet()',
      );
    }
  }

  @override
  Future<ModelInstanceData> belongsToCreate({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required Map<String, dynamic> data,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      final created = await _collection(association.targetCollection).insertOne(
        Map<String, dynamic>.from(data),
      );

      final targetKey = _extractTargetKey(
        created,
        preferredField: association.foreignField,
      );
      await _collection(sourceModel).updateOne(
        where: Map<String, dynamic>.from(primaryKeyValues),
        update: {
          r'$set': {
            association.localField: targetKey,
          },
        },
      );

      return ModelInstanceData(data: created);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute belongsToCreate()',
      );
    }
  }

  @override
  Future<int> destroy({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final where = _translateOptionsWhere(options);
      final collection = _collection(modelName);
      final force = options?['force'] == true;
      final paranoid = _isParanoidModel(model);

      if (paranoid && !force) {
        final deletedField = _paranoidField(model);
        final scopedWhere = _mergeAnd(
          where,
          {
            deletedField: {r'$eq': null},
          },
        );
        return collection.updateMany(
          where: scopedWhere,
          update: {
            r'$set': {
              deletedField: DateTime.now().toUtc().toIso8601String(),
            },
          },
        );
      }
      return collection.deleteMany(where: where);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute destroy()',
      );
    }
  }

  @override
  Future<void> truncate({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      await _collection(modelName).deleteMany(where: <String, dynamic>{});
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute truncate()',
      );
    }
  }

  @override
  Future<void> restore({
    required String modelName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final deletedField = _paranoidField(model);
      final where = _mergeAnd(
        _translateOptionsWhere(options),
        {
          deletedField: {r'$ne': null},
        },
      );

      await _collection(modelName).updateMany(
        where: where,
        update: {
          r'$unset': {
            deletedField: '',
          },
        },
      );
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute restore()',
      );
    }
  }

  @override
  Future<void> instanceDestroy({
    required String modelName,
    required Map<String, dynamic> primaryKeyValues,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final force = options?['force'] == true;
      final paranoid = _isParanoidModel(model);
      if (paranoid && !force) {
        final deletedField = _paranoidField(model);
        await _collection(modelName).updateOne(
          where: Map<String, dynamic>.from(primaryKeyValues),
          update: {
            r'$set': {
              deletedField: DateTime.now().toUtc().toIso8601String(),
            },
          },
        );
      } else {
        await _collection(modelName).deleteOne(
          where: Map<String, dynamic>.from(primaryKeyValues),
        );
      }
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute instanceDestroy()',
      );
    }
  }

  @override
  Future<void> instanceRestore({
    required String modelName,
    required Map<String, dynamic> primaryKeyValues,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final deletedField = _paranoidField(model);
      await _collection(modelName).updateOne(
        where: Map<String, dynamic>.from(primaryKeyValues),
        update: {
          r'$unset': {
            deletedField: '',
          },
        },
      );
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute instanceRestore()',
      );
    }
  }

  @override
  Future associationGet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      switch (association.associationType) {
        case MongoAssociationType.belongsTo:
          return belongsToGet(
            sourceModel: sourceModel,
            primaryKeyValues: primaryKeyValues,
            associationName: associationName,
            options: options,
            sequelize: sequelize,
            model: model,
            transaction: transaction,
          );
        case MongoAssociationType.hasOne:
          final sourceKey = _sourceAssociationKey(
            association: association,
            primaryKeyValues: primaryKeyValues,
          );
          final result =
              await _collection(association.targetCollection).findOne(
            where: {
              association.foreignField: sourceKey,
            },
          );
          return result == null ? null : ModelInstanceData(data: result);
        case MongoAssociationType.hasMany:
          final sourceKey = _sourceAssociationKey(
            association: association,
            primaryKeyValues: primaryKeyValues,
          );
          final result = await _collection(association.targetCollection).find(
            where: {
              association.foreignField: sourceKey,
            },
          );
          return result.map((doc) => ModelInstanceData(data: doc)).toList();
      }
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute associationGet()',
      );
    }
  }

  @override
  Future<void> associationSet({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required targetOrKey,
    bool? save,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      if (association.associationType == MongoAssociationType.belongsTo) {
        await belongsToSet(
          sourceModel: sourceModel,
          primaryKeyValues: primaryKeyValues,
          associationName: associationName,
          targetOrKey: targetOrKey,
          save: save,
          options: options,
          sequelize: sequelize,
          model: model,
          transaction: transaction,
        );
        return;
      }

      await associationAdd(
        sourceModel: sourceModel,
        primaryKeyValues: primaryKeyValues,
        associationName: associationName,
        targetOrKey: targetOrKey,
        options: options,
        sequelize: sequelize,
        model: model,
        transaction: transaction,
      );
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute associationSet()',
      );
    }
  }

  @override
  Future<void> associationAdd({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required targetOrKey,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      if (association.associationType == MongoAssociationType.belongsTo) {
        throw MongoUnsupportedFeatureException(
          'associationAdd is not valid for belongsTo associations.',
          context: 'MongoQueryEngine.associationAdd',
        );
      }

      final targetKeys = _extractTargetKeys(
        targetOrKey,
        preferredField: '_id',
      );
      final sourceKey = _sourceAssociationKey(
        association: association,
        primaryKeyValues: primaryKeyValues,
      );
      final targetCollection = _collection(association.targetCollection);

      for (final targetKey in targetKeys) {
        await targetCollection.updateOne(
          where: {
            '_id': targetKey,
          },
          update: {
            r'$set': {
              association.foreignField: sourceKey,
            },
          },
        );
      }
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute associationAdd()',
      );
    }
  }

  @override
  Future<void> associationRemove({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required targetOrKey,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      if (association.associationType == MongoAssociationType.belongsTo) {
        await _collection(sourceModel).updateOne(
          where: Map<String, dynamic>.from(primaryKeyValues),
          update: {
            r'$unset': {
              association.localField: '',
            },
          },
        );
        return;
      }

      final targetKeys = _extractTargetKeys(
        targetOrKey,
        preferredField: '_id',
      );
      final targetCollection = _collection(association.targetCollection);
      for (final targetKey in targetKeys) {
        await targetCollection.updateOne(
          where: {
            '_id': targetKey,
          },
          update: {
            r'$unset': {
              association.foreignField: '',
            },
          },
        );
      }
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute associationRemove()',
      );
    }
  }

  @override
  Future<ModelInstanceData> associationCreate({
    required String sourceModel,
    required Map<String, dynamic> primaryKeyValues,
    required String associationName,
    required Map<String, dynamic> data,
    Map<String, dynamic>? options,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final association = _resolveAssociation(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      if (association.associationType == MongoAssociationType.belongsTo) {
        return belongsToCreate(
          sourceModel: sourceModel,
          primaryKeyValues: primaryKeyValues,
          associationName: associationName,
          data: data,
          options: options,
          sequelize: sequelize,
          model: model,
          transaction: transaction,
        );
      }

      final sourceKey = _sourceAssociationKey(
        association: association,
        primaryKeyValues: primaryKeyValues,
      );
      final payload = Map<String, dynamic>.from(data)
        ..[association.foreignField] = sourceKey;
      final created = await _collection(association.targetCollection).insertOne(
        payload,
      );
      return ModelInstanceData(data: created);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute associationCreate()',
      );
    }
  }

  Future<num?> _aggregateNumeric({
    required String modelName,
    required String column,
    required Query? query,
    required dynamic model,
    required String accumulator,
    required String context,
  }) async {
    try {
      final plan = _buildQueryPlan(
        query: query,
        model: model,
      );
      final pipeline = MongoAggregationBuilder.buildAccumulatorPipeline(
        accumulatorOperator: accumulator,
        column: column,
        where: plan.where,
        group: plan.group,
      );
      final docs = await _collection(modelName).aggregate(pipeline);
      if (docs.isEmpty) {
        return null;
      }
      final value = docs.first['result'];
      if (value == null) {
        return null;
      }
      return _numValue(value);
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
  }

  Future<List<ModelInstanceData>> _applyIncrement({
    required String modelName,
    required Map<String, dynamic> fields,
    required Query? query,
    required dynamic model,
    required int sign,
    required String context,
  }) async {
    try {
      final plan = _buildQueryPlan(
        query: query,
        model: model,
      );
      final inc = <String, dynamic>{};
      for (final entry in fields.entries) {
        inc[entry.key] = _numValue(entry.value) * sign;
      }
      await _collection(modelName).updateMany(
        where: plan.where,
        update: {
          r'$inc': inc,
        },
      );
      return findAll(
        modelName: modelName,
        query: query,
        model: model,
      );
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _runAggregationQuery({
    required String modelName,
    required MongoCollectionAdapter collection,
    required _MongoQueryPlan plan,
  }) async {
    if (_lookupBuilder == null) {
      throw MongoUnsupportedFeatureException(
        'Include translation requires a MongoLookupBuilder with association resolver.',
        context: 'MongoQueryEngine',
      );
    }
    final includeStages = _lookupBuilder.buildLookupStages(
      sourceModel: modelName,
      includes: plan.includes,
    );
    final pipeline = MongoAggregationBuilder.buildFindPipeline(
      where: plan.where,
      includeStages: includeStages,
      sort: plan.sort,
      skip: plan.offset,
      limit: plan.limit,
      projection: plan.projection,
    );
    return collection.aggregate(pipeline);
  }

  _MongoQueryPlan _buildQueryPlan({
    required Query? query,
    required dynamic model,
  }) {
    final json = query?.toJson() ?? <String, dynamic>{};
    final rawWhere = json['where'];
    Map<String, dynamic> where = rawWhere is Map
        ? Map<String, dynamic>.from(rawWhere)
        : <String, dynamic>{};

    if (_isParanoidModel(model) && json['paranoid'] != false) {
      where = _mergeAnd(
        where,
        {
          _paranoidField(model): {r'$eq': null},
        },
      );
    }

    final translatedWhere = _operatorTranslator.translateWhere(where);
    final includes = _extractIncludes(json['include']);

    return _MongoQueryPlan(
      where: translatedWhere,
      includes: includes,
      sort: MongoAggregationBuilder.parseSort(json['order']),
      projection: MongoAggregationBuilder.parseProjection(json['attributes']),
      limit: json['limit'] is int ? json['limit'] as int : null,
      offset: json['offset'] is int ? json['offset'] as int : null,
      group: json['group'],
    );
  }

  List<Map<String, dynamic>> _extractIncludes(dynamic includeRaw) {
    if (includeRaw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return includeRaw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _translateOptionsWhere(Map<String, dynamic>? options) {
    if (options == null) {
      return <String, dynamic>{};
    }
    final rawWhere = options['where'];
    if (rawWhere is! Map) {
      return <String, dynamic>{};
    }
    return _operatorTranslator
        .translateWhere(Map<String, dynamic>.from(rawWhere));
  }

  MongoAssociationDefinition _resolveAssociation({
    required String sourceModel,
    required String associationName,
  }) {
    if (_associationResolver == null) {
      throw MongoAssociationResolutionException(
        'No association resolver was configured for MongoQueryEngine.',
        context: 'MongoQueryEngine',
      );
    }

    final definition = _associationResolver(
      sourceModel: sourceModel,
      associationName: associationName,
    );
    if (definition == null) {
      throw MongoAssociationResolutionException(
        'Association "$associationName" for "$sourceModel" was not found.',
        context: 'MongoQueryEngine',
      );
    }
    return definition;
  }

  dynamic _extractTargetKey(
    dynamic targetOrKey, {
    required String preferredField,
  }) {
    if (targetOrKey is ModelInstanceData) {
      return _extractTargetKey(
        targetOrKey.data,
        preferredField: preferredField,
      );
    }
    if (targetOrKey is Map) {
      final map = Map<String, dynamic>.from(targetOrKey);
      if (map.containsKey(preferredField)) {
        return map[preferredField];
      }
      if (map.containsKey('_id')) {
        return map['_id'];
      }
      if (map.containsKey('id')) {
        return map['id'];
      }
    }
    return targetOrKey;
  }

  List<dynamic> _extractTargetKeys(
    dynamic targetOrKey, {
    required String preferredField,
  }) {
    if (targetOrKey is List) {
      return targetOrKey
          .map(
            (item) => _extractTargetKey(item, preferredField: preferredField),
          )
          .toList();
    }
    return <dynamic>[
      _extractTargetKey(targetOrKey, preferredField: preferredField),
    ];
  }

  dynamic _sourceAssociationKey({
    required MongoAssociationDefinition association,
    required Map<String, dynamic> primaryKeyValues,
  }) {
    if (primaryKeyValues.containsKey(association.localField)) {
      return primaryKeyValues[association.localField];
    }
    if (primaryKeyValues.containsKey('_id')) {
      return primaryKeyValues['_id'];
    }
    if (primaryKeyValues.isNotEmpty) {
      return primaryKeyValues.values.first;
    }
    return null;
  }

  Map<String, dynamic> _mergeAnd(
    Map<String, dynamic> left,
    Map<String, dynamic> right,
  ) {
    if (left.isEmpty) {
      return right;
    }
    if (right.isEmpty) {
      return left;
    }
    return {
      r'$and': [left, right],
    };
  }

  bool _isParanoidModel(dynamic model) {
    if (model is Map) {
      final options = model['options'];
      if (options is Map && options['paranoid'] == true) {
        return true;
      }
      if (model['paranoid'] == true) {
        return true;
      }
    }

    if (model != null) {
      try {
        final dynamic options = model.getOptionsJson();
        if (options is Map && options['paranoid'] == true) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  String _paranoidField(dynamic model) {
    if (model is Map) {
      final options = model['options'];
      if (options is Map && options['deletedAt'] is String) {
        return options['deletedAt'] as String;
      }
      if (model['deletedAt'] is String) {
        return model['deletedAt'] as String;
      }
    }

    if (model != null) {
      try {
        final dynamic options = model.getOptionsJson();
        if (options is Map && options['deletedAt'] is String) {
          return options['deletedAt'] as String;
        }
      } catch (_) {}
    }

    return defaultParanoidField;
  }

  num _numValue(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  MongoOrmException _wrapError({
    required Object error,
    required StackTrace stackTrace,
    required String context,
  }) {
    if (error is MongoOrmException) {
      return MongoQueryException(
        error.message,
        code: error.code,
        original: error.original,
        stack: error.stack ?? stackTrace.toString(),
        context: context,
      );
    }
    if (error is SequelizeException) {
      return MongoQueryException(
        error.message,
        code: error.code,
        original: error.original,
        stack: error.stack ?? stackTrace.toString(),
        context: context,
      );
    }
    return MongoQueryException(
      error.toString(),
      context: context,
      stack: stackTrace.toString(),
    );
  }
}

class _MongoQueryPlan {
  final Map<String, dynamic> where;
  final List<Map<String, dynamic>> includes;
  final Map<String, int>? sort;
  final Map<String, dynamic>? projection;
  final int? limit;
  final int? offset;
  final dynamic group;

  const _MongoQueryPlan({
    required this.where,
    required this.includes,
    required this.sort,
    required this.projection,
    required this.limit,
    required this.offset,
    required this.group,
  });

  _MongoQueryPlan copyWith({
    Map<String, dynamic>? where,
    List<Map<String, dynamic>>? includes,
    Map<String, int>? sort,
    Map<String, dynamic>? projection,
    int? limit,
    int? offset,
    dynamic group,
  }) {
    return _MongoQueryPlan(
      where: where ?? this.where,
      includes: includes ?? this.includes,
      sort: sort ?? this.sort,
      projection: projection ?? this.projection,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      group: group ?? this.group,
    );
  }
}
