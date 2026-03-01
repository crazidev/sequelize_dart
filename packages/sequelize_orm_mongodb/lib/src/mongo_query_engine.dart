// ignore_for_file: avoid_dynamic_calls, implementation_imports

import 'dart:convert';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_orm_mongodb/src/mongo_adapter.dart';
import 'package:sequelize_orm_mongodb/src/mongo_aggregation.dart';
import 'package:sequelize_orm_mongodb/src/mongo_association.dart';
import 'package:sequelize_orm_mongodb/src/mongo_exceptions.dart';
import 'package:sequelize_orm_mongodb/src/mongo_lookup_builder.dart';
import 'package:sequelize_orm_mongodb/src/mongo_operator_translator.dart';

class MongoQueryEngine extends QueryEngineInterface
    implements QueryEngineLifecycle, QueryEngineSyncLifecycle {
  MongoQueryEngine({
    required MongoDatabaseAdapter database,
    MongoOperatorTranslator? operatorTranslator,
    MongoLookupBuilder? lookupBuilder,
    MongoAssociationResolver? associationResolver,
    this.defaultParanoidField = 'deletedAt',
    this.defaultValidationLevel,
    this.defaultValidationAction,
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
  final String? defaultValidationLevel;
  final String? defaultValidationAction;

  @override
  Future<void> onInitialize() async {
    if (!_database.isConnected) {
      await _database.connect();
    }
  }

  @override
  Future<void> onClose() async {
    if (_database.isConnected) {
      await _database.close();
    }
  }

  @override
  Future<void> syncModels({
    required bool force,
    required bool alter,
    required dynamic sequelize,
    required List<dynamic> models,
  }) async {
    if (!_database.isConnected) {
      await _database.connect();
    }

    for (final model in models) {
      final modelName = _modelNameForSync(model);
      if (modelName == null || modelName.isEmpty) {
        continue;
      }
      final metadata = _modelMetadataFor(
        modelName: modelName,
        sequelize: sequelize,
        model: model,
      );
      final validator = _buildMongoValidatorFromMetadata(metadata);
      final options = _modelOptionsFromMetadata(metadata);
      final validationLevel = _resolveValidationLevel(options);
      final validationAction = _resolveValidationAction(options);
      final primaryKeyFields = _extractPrimaryKeyFields(metadata);

      if (force) {
        await _database.dropCollectionIfExists(modelName);
        await _database.createCollectionWithValidation(
          name: modelName,
          validator: validator,
          validationLevel: validationLevel,
          validationAction: validationAction,
        );
        await _ensurePrimaryKeyIndex(modelName, primaryKeyFields);
        continue;
      }

      final exists = await _database.collectionExists(modelName);
      if (exists && alter) {
        await _database.modifyCollectionValidation(
          name: modelName,
          validator: validator,
          validationLevel: validationLevel,
          validationAction: validationAction,
        );
        await _ensurePrimaryKeyIndex(modelName, primaryKeyFields);
        continue;
      }

      if (!exists) {
        await _database.createCollectionWithValidation(
          name: modelName,
          validator: validator,
          validationLevel: validationLevel,
          validationAction: validationAction,
        );
        await _ensurePrimaryKeyIndex(modelName, primaryKeyFields);
      }
    }
  }

  List<String> _extractPrimaryKeyFields(Map<String, dynamic>? metadata) {
    if (metadata == null) return [];
    final attributesRaw = metadata['attributes'];
    if (attributesRaw is! Map) return [];
    final fields = <String>[];
    for (final entry in attributesRaw.entries) {
      final attrDef = entry.value;
      if (attrDef is Map && attrDef['primaryKey'] == true) {
        fields.add(entry.key.toString());
      }
    }
    return fields;
  }

  Future<void> _ensurePrimaryKeyIndex(
    String modelName,
    List<String> primaryKeyFields,
  ) async {
    if (primaryKeyFields.isEmpty) return;
    await _database.ensureUniqueIndex(
      collectionName: modelName,
      fields: primaryKeyFields,
    );
  }

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
              sequelize: sequelize,
            )
          : await collection.find(
              where: plan.where,
              sort: plan.sort,
              limit: plan.limit,
              skip: plan.offset,
              projection: plan.projection,
            );
      if (plan.includes.isEmpty) {
        _logMongoQuery(
          operation: 'findAll',
          sequelize: sequelize,
          payload: {
            'collection': modelName,
            'where': plan.where,
            'sort': plan.sort,
            'limit': plan.limit,
            'skip': plan.offset,
            'projection': plan.projection,
          },
        );
      }

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
          sequelize: sequelize,
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
        _logMongoQuery(
          operation: 'findOne',
          sequelize: sequelize,
          payload: {
            'collection': modelName,
            'where': plan.where,
            'sort': plan.sort,
            'projection': plan.projection,
          },
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
      final includes = _extractIncludes(query?.toJson()['include']);
      final effectiveIncludes = includes.isNotEmpty
          ? includes
          : _inferIncludesFromData(
              modelName: modelName,
              data: data,
            );
      final inserted = await _createWithAssociations(
        modelName: modelName,
        data: data,
        includes: effectiveIncludes,
        sequelize: sequelize,
        model: model,
      );
      _logMongoQuery(
        operation: 'create',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'data': data,
          'includes': effectiveIncludes,
        },
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

  Future<Map<String, dynamic>> _createWithAssociations({
    required String modelName,
    required Map<String, dynamic> data,
    required List<Map<String, dynamic>> includes,
    required dynamic sequelize,
    required dynamic model,
  }) async {
    final sourcePayload = Map<String, dynamic>.from(data);
    await _assignAutoIncrementPrimaryKeyIfNeeded(
      modelName: modelName,
      payload: sourcePayload,
      sequelize: sequelize,
      model: model,
    );
    final associationPayloads = <String, dynamic>{};

    for (final include in includes) {
      final associationName = include['association']?.toString();
      if (associationName == null || associationName.isEmpty) {
        continue;
      }
      if (sourcePayload.containsKey(associationName)) {
        associationPayloads[associationName] = sourcePayload.remove(
          associationName,
        );
      }
    }

    final inserted = await _collection(modelName).insertOne(sourcePayload);
    if (associationPayloads.isEmpty) {
      return inserted;
    }

    final hydrated = Map<String, dynamic>.from(inserted);
    for (final include in includes) {
      final associationName = include['association']?.toString();
      if (associationName == null || associationName.isEmpty) {
        continue;
      }
      if (!associationPayloads.containsKey(associationName)) {
        continue;
      }

      final associationValue = associationPayloads[associationName];
      if (associationValue == null) {
        continue;
      }

      final association = _resolveAssociation(
        sourceModel: modelName,
        associationName: associationName,
      );
      final nestedIncludes = _extractIncludes(include['include']);
      final targetModel = _resolveModelFor(modelName: association.targetCollection, sequelize: sequelize);

      switch (association.associationType) {
        case MongoAssociationType.hasMany:
          final listPayload = associationValue is List
              ? associationValue
              : [associationValue];
          final createdChildren = <Map<String, dynamic>>[];
          final sourceKey = _sourceAssociationKey(
            association: association,
            primaryKeyValues: hydrated,
          );
          for (final item in listPayload) {
            if (item is! Map) {
              continue;
            }
            final childPayload = Map<String, dynamic>.from(item)
              ..[association.foreignField] = sourceKey;
            final created = await _createWithAssociations(
              modelName: association.targetCollection,
              data: childPayload,
              includes: nestedIncludes,
              sequelize: sequelize,
              model: targetModel,
            );
            createdChildren.add(created);
          }
          hydrated[associationName] = createdChildren;
          break;
        case MongoAssociationType.hasOne:
          if (associationValue is! Map) {
            break;
          }
          final sourceKey = _sourceAssociationKey(
            association: association,
            primaryKeyValues: hydrated,
          );
          final childPayload = Map<String, dynamic>.from(associationValue)
            ..[association.foreignField] = sourceKey;
          final created = await _createWithAssociations(
            modelName: association.targetCollection,
            data: childPayload,
            includes: nestedIncludes,
            sequelize: sequelize,
            model: targetModel,
          );
          hydrated[associationName] = created;
          break;
        case MongoAssociationType.belongsTo:
          if (associationValue is! Map) {
            final targetKey = _extractTargetKey(
              associationValue,
              preferredField: association.foreignField,
            );
            await _collection(modelName).updateOne(
              where: _primaryWhereFromDocument(hydrated),
              update: {
                r'$set': {association.localField: targetKey},
              },
            );
            hydrated[association.localField] = targetKey;
            break;
          }
          final created = await _createWithAssociations(
            modelName: association.targetCollection,
            data: Map<String, dynamic>.from(associationValue),
            includes: nestedIncludes,
            sequelize: sequelize,
            model: targetModel,
          );
          final targetKey = _extractTargetKey(
            created,
            preferredField: association.foreignField,
          );
          await _collection(modelName).updateOne(
            where: _primaryWhereFromDocument(hydrated),
            update: {
              r'$set': {association.localField: targetKey},
            },
          );
          hydrated[association.localField] = targetKey;
          hydrated[associationName] = created;
          break;
      }
    }

    return hydrated;
  }

  dynamic _resolveModelFor({
    required String modelName,
    required dynamic sequelize,
  }) {
    if (sequelize == null) {
      return null;
    }
    try {
      final dynamic modelInstance = sequelize.getModel(modelName);
      if (modelInstance == null) {
        return null;
      }
      return {
        'name': modelName,
        'attributes': modelInstance.$getAttributesJson(),
        'options': modelInstance.getOptionsJson(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _assignAutoIncrementPrimaryKeyIfNeeded({
    required String modelName,
    required Map<String, dynamic> payload,
    required dynamic sequelize,
    required dynamic model,
  }) async {
    final metadata = _modelMetadataFor(
      modelName: modelName,
      sequelize: sequelize,
      model: model,
    );
    if (metadata == null) {
      return;
    }
    final attributesRaw = metadata['attributes'];
    if (attributesRaw is! Map) {
      return;
    }
    final attributes = Map<String, dynamic>.from(attributesRaw);

    MapEntry<String, dynamic>? pkEntry;
    for (final entry in attributes.entries) {
      final attrDefRaw = entry.value;
      if (attrDefRaw is! Map) {
        continue;
      }
      final attrDef = Map<String, dynamic>.from(attrDefRaw);
      if (attrDef['primaryKey'] == true) {
        pkEntry = MapEntry(entry.key.toString(), attrDef);
        break;
      }
    }
    if (pkEntry == null) {
      return;
    }

    final pkName = pkEntry.key;
    final pkDefinition = Map<String, dynamic>.from(pkEntry.value as Map);
    if (payload.containsKey(pkName) && payload[pkName] != null) {
      return;
    }

    final isAutoIncrement = pkDefinition['autoIncrement'] == true;
    final typeName = pkDefinition['type']?.toString().toUpperCase() ?? '';
    final isIntegerLike = typeName.contains('INT');
    if (!isAutoIncrement || !isIntegerLike) {
      return;
    }

    final latest = await _collection(modelName).findOne(
      sort: {pkName: -1},
      projection: {pkName: 1},
    );
    final latestValue = latest?[pkName];
    var nextValue = 1;
    if (latestValue is int) {
      nextValue = latestValue + 1;
    } else if (latestValue is num) {
      nextValue = latestValue.toInt() + 1;
    } else if (latestValue is String) {
      final parsed = int.tryParse(latestValue);
      if (parsed != null) {
        nextValue = parsed + 1;
      }
    }
    payload[pkName] = nextValue;
  }

  Map<String, dynamic>? _modelMetadataFor({
    required String modelName,
    required dynamic sequelize,
    required dynamic model,
  }) {
    if (model is Map && model['attributes'] is Map) {
      return Map<String, dynamic>.from(model);
    }
    final resolved = _resolveModelFor(modelName: modelName, sequelize: sequelize);
    if (resolved is Map) {
      return Map<String, dynamic>.from(resolved);
    }
    return null;
  }

  String? _modelNameForSync(dynamic model) {
    if (model is Map && model['name'] != null) {
      return model['name']?.toString();
    }
    if (model != null) {
      try {
        return model.modelName?.toString();
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic> _modelOptionsFromMetadata(
    Map<String, dynamic>? metadata,
  ) {
    if (metadata == null) {
      return <String, dynamic>{};
    }
    final options = metadata['options'];
    if (options is Map) {
      return Map<String, dynamic>.from(options);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _buildMongoValidatorFromMetadata(
    Map<String, dynamic>? metadata,
  ) {
    if (metadata == null) {
      return <String, dynamic>{};
    }
    final attributesRaw = metadata['attributes'];
    if (attributesRaw is! Map) {
      return <String, dynamic>{};
    }
    final attributes = Map<String, dynamic>.from(attributesRaw);
    if (attributes.isEmpty) {
      return <String, dynamic>{};
    }
    return {
      r'$jsonSchema': _buildMongoJsonSchemaFromAttributes(attributes),
    };
  }

  Map<String, dynamic> _jsonSchemaFromMetadata(
    Map<String, dynamic>? metadata,
  ) {
    if (metadata == null) {
      return <String, dynamic>{};
    }
    final attributesRaw = metadata['attributes'];
    if (attributesRaw is! Map) {
      return <String, dynamic>{};
    }
    final attributes = Map<String, dynamic>.from(attributesRaw);
    if (attributes.isEmpty) {
      return <String, dynamic>{};
    }
    return _buildMongoJsonSchemaFromAttributes(attributes);
  }

  Map<String, dynamic> _buildSchemaMismatchWhere(Map<String, dynamic> schema) {
    return {
      r'$nor': [
        {r'$jsonSchema': schema},
      ],
    };
  }

  Map<String, dynamic> _buildMongoJsonSchemaFromAttributes(
    Map<String, dynamic> attributes,
  ) {
    final required = <String>[];
    final properties = <String, dynamic>{};
    for (final entry in attributes.entries) {
      final name = entry.key.toString();
      final rawAttr = entry.value;
      if (rawAttr is! Map) {
        continue;
      }
      final attr = Map<String, dynamic>.from(rawAttr);
      final allowNull = attr['allowNull'] != false;
      if (!allowNull) {
        required.add(name);
      }
      properties[name] = _attributeSchemaFor(attr);
    }

    return {
      'bsonType': 'object',
      if (required.isNotEmpty) 'required': required,
      'properties': properties,
    };
  }

  Map<String, dynamic> _attributeSchemaFor(Map<String, dynamic> attribute) {
    final schema = <String, dynamic>{};
    final allowNull = attribute['allowNull'] != false;
    final typeName = attribute['type']?.toString().toUpperCase() ?? '';
    final dartType = attribute['dartType']?.toString();

    final isStringLikeType = typeName.contains('CHAR') ||
        typeName.contains('STRING') ||
        typeName.contains('TEXT') ||
        typeName == 'UUID' ||
        typeName == 'ENUM';

    final isJsonType = typeName == 'JSON' || typeName == 'JSONB';
    // A JSON/JSONB field with a List dartType hint maps to a true array.
    final isTypedArrayType =
        isJsonType && dartType != null && dartType.startsWith('List<');

    final bsonType = _mapTypeToBsonType(
      typeName,
      allowNull: allowNull,
      dartType: dartType,
    );
    schema['bsonType'] = bsonType;

    // §5.3 items — typed JSON arrays carry a per-element bsonType (e.g. List<String>)
    if (isTypedArrayType) {
      final itemsBsonType = _itemsBsonTypeFromListDartType(dartType);
      if (itemsBsonType != null) {
        schema['items'] = <String, dynamic>{'bsonType': itemsBsonType};
      }
    }

    // §5.5.1 enum — ENUM type values; include null when the field is nullable
    final values = attribute['values'];
    if (values is List && values.isNotEmpty) {
      schema['enum'] = allowNull
          ? <dynamic>[...values, null]
          : values.toList(growable: false);
    }

    final validate = attribute['validate'];
    if (validate is Map) {
      // §5.2.1-2 / §5.3.2-3 len → minLength/maxLength (strings) or
      // minItems/maxItems (typed arrays)
      final lenRule = validate['len'];
      final lenArgs = _extractValidateArgs(lenRule);
      if (lenArgs.length == 2) {
        final minLen = _toInt(lenArgs[0]);
        final maxLen = _toInt(lenArgs[1]);
        if (isTypedArrayType) {
          if (minLen != null) schema['minItems'] = minLen;
          if (maxLen != null) schema['maxItems'] = maxLen;
        } else {
          if (minLen != null) schema['minLength'] = minLen;
          if (maxLen != null) schema['maxLength'] = maxLen;
        }
      }

      // §5.1.2-3 / §5.2.1-2  min/max → minimum/maximum (numbers) or
      // minLength/maxLength (strings)
      final minRule = validate['min'];
      final minArgs = _extractValidateArgs(minRule);
      final minValue =
          minArgs.isNotEmpty ? _toNum(minArgs.first) : _toNum(minRule);
      if (minValue != null) {
        if (isStringLikeType) {
          schema['minLength'] = minValue.toInt();
        } else {
          schema['minimum'] = minValue;
        }
      }

      final maxRule = validate['max'];
      final maxArgs = _extractValidateArgs(maxRule);
      final maxValue =
          maxArgs.isNotEmpty ? _toNum(maxArgs.first) : _toNum(maxRule);
      if (maxValue != null) {
        if (isStringLikeType) {
          schema['maxLength'] = maxValue.toInt();
        } else {
          schema['maximum'] = maxValue;
        }
      }

      // §5.5.1 isIn → enum (nullable fields include null in the list)
      final isInRule = validate['isIn'];
      final isInArgs = _extractValidateArgs(isInRule);
      if (isInArgs.isNotEmpty && isInArgs.first is List) {
        final enumValues = List<dynamic>.from(isInArgs.first as List);
        if (allowNull && !enumValues.contains(null)) enumValues.add(null);
        schema['enum'] = enumValues;
      }

      // §5.2.2 notEmpty → minLength: 1 (only tighten, never loosen)
      final notEmptyRule = validate['notEmpty'];
      if (notEmptyRule != null && notEmptyRule != false) {
        final existing = schema['minLength'];
        if (existing == null || (existing is int && existing < 1)) {
          schema['minLength'] = 1;
        }
      }

      // §5.2.3 pattern — explicit `is` regex takes highest priority, then
      // named format validators (isAlpha, isEmail, isUUID, …)
      final pattern = _extractPatternFromRule(validate['is']) ??
          _namedValidatorPattern(validate);
      if (pattern != null && isStringLikeType) {
        schema['pattern'] = pattern;
      }
    }

    return schema;
  }

  dynamic _mapTypeToBsonType(
    String typeName, {
    required bool allowNull,
    String? dartType,
  }) {
    dynamic baseType;
    if (typeName == 'BIGINT') {
      // SequelizeBigInt.toJson() always serialises to a String to avoid
      // JS/MongoDB precision loss for values beyond Number.MAX_SAFE_INTEGER.
      baseType = 'string';
    } else if (typeName.contains('INT')) {
      baseType = <String>['int', 'long'];
    } else if (typeName.contains('FLOAT') ||
        typeName.contains('DOUBLE') ||
        typeName.contains('DECIMAL')) {
      baseType = <String>['double', 'int', 'long', 'decimal'];
    } else if (typeName == 'BOOLEAN') {
      baseType = 'bool';
    } else if (typeName == 'DATE' || typeName == 'DATEONLY') {
      baseType = 'date';
    } else if (typeName == 'JSON' || typeName == 'JSONB') {
      // Refine to 'array' or 'object' when a dartType hint is available
      if (dartType != null && dartType.startsWith('List<')) {
        baseType = 'array';
      } else if (dartType != null && dartType.startsWith('Map<')) {
        baseType = 'object';
      } else {
        baseType = <String>['object', 'array'];
      }
    } else if (typeName == 'BLOB') {
      baseType = 'binData';
    } else {
      baseType = 'string';
    }

    if (!allowNull) {
      return baseType;
    }
    if (baseType is String) {
      return <String>[baseType, 'null'];
    }
    if (baseType is List) {
      final list = baseType.map((e) => e.toString()).toList(growable: false);
      if (!list.contains('null')) {
        return <String>[...list, 'null'];
      }
      return list;
    }
    return baseType;
  }

  List<dynamic> _extractValidateArgs(dynamic value) {
    if (value is List) {
      return value;
    }
    if (value is Map && value['args'] is List) {
      return List<dynamic>.from(value['args'] as List);
    }
    return const <dynamic>[];
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  num? _toNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Pattern helpers (§5.2.3)
  // ---------------------------------------------------------------------------

  /// Extracts the regex pattern string from an `is` / `not` rule value.
  /// The rule may be: a plain String, a List [pattern] or [pattern, flags],
  /// or a Map {msg, args: pattern | [pattern, flags]}.
  String? _extractPatternFromRule(dynamic rule) {
    if (rule == null) return null;
    if (rule is String) return rule;
    if (rule is List && rule.isNotEmpty) return rule.first?.toString();
    if (rule is Map) {
      final args = rule['args'];
      if (args is String) return args;
      if (args is List && args.isNotEmpty) return args.first?.toString();
    }
    return null;
  }

  /// Returns a JSON Schema §5.2.3 `pattern` from known named format validators.
  /// Priority order matches the field order in ValidateOption.toJson().
  String? _namedValidatorPattern(Map<dynamic, dynamic> validate) {
    if (_validatorEnabled(validate, 'isAlpha')) {
      return r'^[a-zA-Z]+$';
    }
    if (_validatorEnabled(validate, 'isAlphanumeric')) {
      return r'^[a-zA-Z0-9]+$';
    }
    if (_validatorEnabled(validate, 'isNumeric')) {
      // Allows optional decimal part (e.g. "3.14").
      return r'^[0-9]+(\.[0-9]+)?$';
    }
    if (_validatorEnabled(validate, 'isLowercase')) {
      return r'^[^A-Z]*$';
    }
    if (_validatorEnabled(validate, 'isUppercase')) {
      return r'^[^a-z]*$';
    }
    if (_validatorEnabled(validate, 'isEmail')) {
      return r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
    }
    if (_validatorEnabled(validate, 'isUrl')) {
      return r'^https?://[^\s/$.?#].[^\s]*$';
    }
    if (_validatorEnabled(validate, 'isIPv4')) {
      return r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
          r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';
    }
    if (_validatorEnabled(validate, 'isIPv6')) {
      // Simplified full-group IPv6 pattern.
      return r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$';
    }
    if (_validatorEnabled(validate, 'isUUID')) {
      return _uuidPattern(validate['isUUID']);
    }
    return null;
  }

  bool _validatorEnabled(Map<dynamic, dynamic> validate, String key) {
    final v = validate[key];
    return v != null && v != false;
  }

  /// Returns a UUID regex (§7.3 format) optionally narrowed to a version.
  String _uuidPattern(dynamic rule) {
    int? version;
    if (rule is int) {
      version = rule;
    } else if (rule is Map) {
      final args = rule['args'];
      if (args is int) version = args;
    }
    const versionParts = <int, String>{
      1: r'1[0-9a-fA-F]{3}',
      3: r'3[0-9a-fA-F]{3}',
      4: r'4[0-9a-fA-F]{3}',
      5: r'5[0-9a-fA-F]{3}',
    };
    final vPart = versionParts[version] ?? r'[0-9a-fA-F]{4}';
    return '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-$vPart'
        r'-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$';
  }

  // ---------------------------------------------------------------------------
  // Array / JSON type helpers (§5.3)
  // ---------------------------------------------------------------------------

  /// Returns the `bsonType` for the elements of a `List<X>` dartType hint.
  dynamic _itemsBsonTypeFromListDartType(String dartType) {
    final inner = _extractListInnerType(dartType);
    if (inner == null) return null;
    switch (inner) {
      case 'String':
        return 'string';
      case 'int':
        return <String>['int', 'long'];
      case 'double':
      case 'num':
        return <String>['double', 'decimal'];
      case 'bool':
        return 'bool';
      default:
        // List<Map<...>> or List<dynamic> → array of objects
        if (inner.startsWith('Map<') || inner == 'dynamic') return 'object';
        return null;
    }
  }

  String? _extractListInnerType(String dartType) {
    if (!dartType.startsWith('List<') || !dartType.endsWith('>')) return null;
    return dartType.substring(5, dartType.length - 1);
  }

  String? _resolveValidationLevel(Map<String, dynamic> options) {
    final modelValue = options['mongoValidationLevel']?.toString().trim();
    if (modelValue != null && modelValue.isNotEmpty) {
      return modelValue;
    }
    final defaultValue = defaultValidationLevel?.trim();
    if (defaultValue == null || defaultValue.isEmpty) {
      return null;
    }
    return defaultValue;
  }

  String? _resolveValidationAction(Map<String, dynamic> options) {
    final modelValue = options['mongoValidationAction']?.toString().trim();
    if (modelValue != null && modelValue.isNotEmpty) {
      return modelValue;
    }
    final defaultValue = defaultValidationAction?.trim();
    if (defaultValue == null || defaultValue.isEmpty) {
      return null;
    }
    return defaultValue;
  }

  Map<String, dynamic> _filterPersistableAttributes({
    required String modelName,
    required Map<String, dynamic> data,
    required dynamic sequelize,
    required dynamic model,
  }) {
    final metadata = _modelMetadataFor(
      modelName: modelName,
      sequelize: sequelize,
      model: model,
    );
    if (metadata == null) {
      return Map<String, dynamic>.from(data);
    }
    final attributesRaw = metadata['attributes'];
    if (attributesRaw is! Map) {
      return Map<String, dynamic>.from(data);
    }
    final attributeKeys = attributesRaw.keys.map((e) => e.toString()).toSet();
    if (attributeKeys.isEmpty) {
      return Map<String, dynamic>.from(data);
    }

    final filtered = <String, dynamic>{};
    for (final entry in data.entries) {
      if (attributeKeys.contains(entry.key)) {
        filtered[entry.key] = entry.value;
      }
    }
    return filtered;
  }

  Map<String, dynamic> _primaryWhereFromDocument(Map<String, dynamic> doc) {
    if (doc.containsKey('_id')) {
      return {'_id': doc['_id']};
    }
    if (doc.containsKey('id')) {
      return {'id': doc['id']};
    }
    if (doc.isNotEmpty) {
      final firstEntry = doc.entries.first;
      return {firstEntry.key: firstEntry.value};
    }
    return <String, dynamic>{};
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
      _logMongoQuery(
        operation: 'bulkCreate',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'count': data.length,
          'documents': data,
        },
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
      final affected = await _collection(modelName).updateMany(
        where: plan.where,
        update: {
          r'$set': data,
        },
      );
      _logMongoQuery(
        operation: 'update',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': plan.where,
          'update': {
            r'$set': data,
          },
          'affected': affected,
        },
      );
      return affected;
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
        _logMongoQuery(
          operation: 'count.aggregate',
          sequelize: sequelize,
          payload: {
            'collection': modelName,
            'pipeline': pipeline,
          },
        );
        final docs = await collection.aggregate(pipeline);
        if (docs.isEmpty) {
          return 0;
        }
        return _numValue(docs.first['result']).toInt();
      }
      final result = await collection.count(plan.where);
      _logMongoQuery(
        operation: 'count',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': plan.where,
          'result': result,
        },
      );
      return result;
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
      sequelize: sequelize,
      model: model,
      accumulator: r'$max',
      operation: 'max',
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
      sequelize: sequelize,
      model: model,
      accumulator: r'$min',
      operation: 'min',
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
      sequelize: sequelize,
      model: model,
      accumulator: r'$sum',
      operation: 'sum',
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
      sequelize: sequelize,
      model: model,
      sign: 1,
      operation: 'increment',
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
      sequelize: sequelize,
      model: model,
      sign: -1,
      operation: 'decrement',
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
      final replacement = _filterPersistableAttributes(
        modelName: modelName,
        data: currentData,
        sequelize: sequelize,
        model: model,
      );
      final filteredPrevious = previousData == null
          ? null
          : _filterPersistableAttributes(
              modelName: modelName,
              data: previousData,
              sequelize: sequelize,
              model: model,
            );
      final saved = await _collection(modelName).replaceOne(
        where: Map<String, dynamic>.from(primaryKeyValues),
        replacement: replacement,
        upsert: true,
      );
      _logMongoQuery(
        operation: 'save',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': primaryKeyValues,
          'replacement': replacement,
          if (filteredPrevious != null) 'previous': filteredPrevious,
          'upsert': true,
        },
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
      _logMongoQuery(
        operation: 'belongsToGet',
        sequelize: sequelize,
        payload: {
          'sourceModel': sourceModel,
          'association': associationName,
          'sourceWhere': primaryKeyValues,
          'targetCollection': association.targetCollection,
          'targetWhere': {
            association.foreignField: foreignKeyValue,
          },
        },
      );

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
      _logMongoQuery(
        operation: 'belongsToSet',
        sequelize: sequelize,
        payload: {
          'sourceModel': sourceModel,
          'association': associationName,
          'where': primaryKeyValues,
          'update': {
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
      _logMongoQuery(
        operation: 'belongsToCreate',
        sequelize: sequelize,
        payload: {
          'sourceModel': sourceModel,
          'association': associationName,
          'targetCollection': association.targetCollection,
          'data': data,
          'sourceWhere': primaryKeyValues,
          'set': {association.localField: targetKey},
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
        final affected = await collection.updateMany(
          where: scopedWhere,
          update: {
            r'$set': {
              deletedField: DateTime.now().toUtc().toIso8601String(),
            },
          },
        );
        _logMongoQuery(
          operation: 'destroy.softDelete',
          sequelize: sequelize,
          payload: {
            'collection': modelName,
            'where': scopedWhere,
            'affected': affected,
            'deletedField': deletedField,
          },
        );
        return affected;
      }
      final affected = await collection.deleteMany(where: where);
      _logMongoQuery(
        operation: 'destroy',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': where,
          'affected': affected,
          'force': force,
        },
      );
      return affected;
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to execute destroy()',
      );
    }
  }

  Future<List<ModelInstanceData>> findDocumentsNotMatchingSchema({
    required String modelName,
    Map<String, dynamic>? where,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final metadata = _modelMetadataFor(
        modelName: modelName,
        sequelize: sequelize,
        model: model,
      );
      final schema = _jsonSchemaFromMetadata(metadata);
      if (schema.isEmpty) {
        return const <ModelInstanceData>[];
      }
      final mismatchWhere = _buildSchemaMismatchWhere(schema);
      final merged = where == null || where.isEmpty
          ? mismatchWhere
          : _mergeAnd(where, mismatchWhere);
      final translatedWhere = _operatorTranslator.translateWhere(merged);
      final docs = await _collection(modelName).find(where: translatedWhere);
      _logMongoQuery(
        operation: 'findDocumentsNotMatchingSchema',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': translatedWhere,
        },
      );
      return docs.map((doc) => ModelInstanceData(data: doc)).toList();
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to find documents not matching schema',
      );
    }
  }

  Future<int> deleteDocumentsNotMatchingSchema({
    required String modelName,
    Map<String, dynamic>? where,
    dynamic sequelize,
    dynamic model,
    Transaction? transaction,
  }) async {
    try {
      final metadata = _modelMetadataFor(
        modelName: modelName,
        sequelize: sequelize,
        model: model,
      );
      final schema = _jsonSchemaFromMetadata(metadata);
      if (schema.isEmpty) {
        return 0;
      }
      final mismatchWhere = _buildSchemaMismatchWhere(schema);
      final merged = where == null || where.isEmpty
          ? mismatchWhere
          : _mergeAnd(where, mismatchWhere);
      final translatedWhere = _operatorTranslator.translateWhere(merged);
      final deleted = await _collection(modelName).deleteMany(
        where: translatedWhere,
      );
      _logMongoQuery(
        operation: 'deleteDocumentsNotMatchingSchema',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': translatedWhere,
          'deleted': deleted,
        },
      );
      return deleted;
    } catch (error, stackTrace) {
      throw _wrapError(
        error: error,
        stackTrace: stackTrace,
        context: 'Exception: failed to delete documents not matching schema',
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
      _logMongoQuery(
        operation: 'truncate',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
        },
      );
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
      _logMongoQuery(
        operation: 'restore',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': where,
          'deletedField': deletedField,
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
        _logMongoQuery(
          operation: 'instanceDestroy.softDelete',
          sequelize: sequelize,
          payload: {
            'collection': modelName,
            'where': primaryKeyValues,
            'deletedField': deletedField,
          },
        );
      } else {
        await _collection(modelName).deleteOne(
          where: Map<String, dynamic>.from(primaryKeyValues),
        );
        _logMongoQuery(
          operation: 'instanceDestroy',
          sequelize: sequelize,
          payload: {
            'collection': modelName,
            'where': primaryKeyValues,
            'force': force,
          },
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
      _logMongoQuery(
        operation: 'instanceRestore',
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': primaryKeyValues,
          'deletedField': deletedField,
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
          _logMongoQuery(
            operation: 'associationGet.hasOne',
            sequelize: sequelize,
            payload: {
              'sourceModel': sourceModel,
              'association': associationName,
              'targetCollection': association.targetCollection,
              'where': {association.foreignField: sourceKey},
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
          _logMongoQuery(
            operation: 'associationGet.hasMany',
            sequelize: sequelize,
            payload: {
              'sourceModel': sourceModel,
              'association': associationName,
              'targetCollection': association.targetCollection,
              'where': {association.foreignField: sourceKey},
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
      _logMongoQuery(
        operation: 'associationAdd',
        sequelize: sequelize,
        payload: {
          'sourceModel': sourceModel,
          'association': associationName,
          'targetCollection': association.targetCollection,
          'targetKeys': targetKeys,
          'set': {association.foreignField: sourceKey},
        },
      );
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
        _logMongoQuery(
          operation: 'associationRemove.belongsTo',
          sequelize: sequelize,
          payload: {
            'sourceModel': sourceModel,
            'association': associationName,
            'where': primaryKeyValues,
            'unset': association.localField,
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
      _logMongoQuery(
        operation: 'associationRemove',
        sequelize: sequelize,
        payload: {
          'sourceModel': sourceModel,
          'association': associationName,
          'targetCollection': association.targetCollection,
          'targetKeys': targetKeys,
          'unset': association.foreignField,
        },
      );
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
      _logMongoQuery(
        operation: 'associationCreate',
        sequelize: sequelize,
        payload: {
          'sourceModel': sourceModel,
          'association': associationName,
          'targetCollection': association.targetCollection,
          'payload': payload,
        },
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
    required dynamic sequelize,
    required dynamic model,
    required String accumulator,
    required String operation,
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
      _logMongoQuery(
        operation: operation,
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'column': column,
          'accumulator': accumulator,
          'pipeline': pipeline,
        },
      );
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
    required dynamic sequelize,
    required dynamic model,
    required int sign,
    required String operation,
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
      _logMongoQuery(
        operation: operation,
        sequelize: sequelize,
        payload: {
          'collection': modelName,
          'where': plan.where,
          'inc': inc,
        },
      );
      return findAll(
        modelName: modelName,
        query: query,
        sequelize: sequelize,
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
    required dynamic sequelize,
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
    _logMongoQuery(
      operation: 'aggregate.find',
      sequelize: sequelize,
      payload: {
        'collection': modelName,
        'pipeline': pipeline,
      },
    );
    final docs = await collection.aggregate(pipeline);
    return _normalizeIncludeDocuments(
      sourceModel: modelName,
      docs: docs,
      includes: plan.includes,
    );
  }

  List<Map<String, dynamic>> _normalizeIncludeDocuments({
    required String sourceModel,
    required List<Map<String, dynamic>> docs,
    required List<Map<String, dynamic>> includes,
  }) {
    if (includes.isEmpty || _associationResolver == null) {
      return docs;
    }

    return docs
        .map(
          (doc) => _normalizeIncludeDocument(
            sourceModel: sourceModel,
            doc: Map<String, dynamic>.from(doc),
            includes: includes,
          ),
        )
        .toList();
  }

  Map<String, dynamic> _normalizeIncludeDocument({
    required String sourceModel,
    required Map<String, dynamic> doc,
    required List<Map<String, dynamic>> includes,
  }) {
    final normalized = Map<String, dynamic>.from(doc);
    final resolver = _associationResolver;
    if (resolver == null) {
      return normalized;
    }

    for (final include in includes) {
      final associationName = include['association']?.toString();
      if (associationName == null || associationName.isEmpty) {
        continue;
      }

      final MongoAssociationDefinition? definition;
      try {
        definition = resolver(
          sourceModel: sourceModel,
          associationName: associationName,
        );
      } catch (_) {
        continue;
      }
      if (definition == null) {
        continue;
      }

      final nestedIncludes = _extractIncludes(include['include']);
      final key = normalized.containsKey(definition.as)
          ? definition.as
          : associationName;
      final rawValue = normalized[key];
      normalized[key] = _normalizeAssociationValue(
        definition: definition,
        rawValue: rawValue,
        nestedIncludes: nestedIncludes,
      );
    }

    return normalized;
  }

  dynamic _normalizeAssociationValue({
    required MongoAssociationDefinition definition,
    required dynamic rawValue,
    required List<Map<String, dynamic>> nestedIncludes,
  }) {
    switch (definition.associationType) {
      case MongoAssociationType.hasMany:
        if (rawValue is List) {
          return rawValue.map((item) {
            if (item is! Map) {
              return item;
            }
            if (nestedIncludes.isEmpty) {
              return item;
            }
            return _normalizeIncludeDocument(
              sourceModel: definition.targetCollection,
              doc: Map<String, dynamic>.from(item),
              includes: nestedIncludes,
            );
          }).toList();
        }
        if (rawValue is Map) {
          final item = nestedIncludes.isEmpty
              ? Map<String, dynamic>.from(rawValue)
              : _normalizeIncludeDocument(
                  sourceModel: definition.targetCollection,
                  doc: Map<String, dynamic>.from(rawValue),
                  includes: nestedIncludes,
                );
          return [item];
        }
        return rawValue ?? <dynamic>[];
      case MongoAssociationType.hasOne:
      case MongoAssociationType.belongsTo:
        dynamic single = rawValue;
        if (rawValue is List) {
          single = rawValue.isEmpty ? null : rawValue.first;
        }
        if (single is! Map) {
          return single;
        }
        if (nestedIncludes.isEmpty) {
          return Map<String, dynamic>.from(single);
        }
        return _normalizeIncludeDocument(
          sourceModel: definition.targetCollection,
          doc: Map<String, dynamic>.from(single),
          includes: nestedIncludes,
        );
    }
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

  List<Map<String, dynamic>> _inferIncludesFromData({
    required String modelName,
    required Map<String, dynamic> data,
  }) {
    if (_associationResolver == null) {
      return const <Map<String, dynamic>>[];
    }

    final includes = <Map<String, dynamic>>[];
    for (final entry in data.entries) {
      final value = entry.value;
      final looksLikeAssociationPayload =
          value is Map || (value is List && value.isNotEmpty);
      if (!looksLikeAssociationPayload) {
        continue;
      }
      final associationName = entry.key;
      final definition = _associationResolver(
        sourceModel: modelName,
        associationName: associationName,
      );
      if (definition == null) {
        continue;
      }
      includes.add({'association': associationName});
    }
    return includes;
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
      final value = primaryKeyValues[association.localField];
      if (value != null) {
        return value;
      }
    }
    if (primaryKeyValues.containsKey('_id')) {
      final value = primaryKeyValues['_id'];
      if (value != null) {
        return value;
      }
    }
    if (primaryKeyValues.containsKey('id')) {
      final value = primaryKeyValues['id'];
      if (value != null) {
        return value;
      }
    }
    if (primaryKeyValues.isNotEmpty) {
      for (final value in primaryKeyValues.values) {
        if (value != null) {
          return value;
        }
      }
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

  void _logMongoQuery({
    required String operation,
    required Map<String, dynamic> payload,
    dynamic sequelize,
  }) {
    final serialized = jsonEncode(_jsonSafe(payload));
    final message = '[mongo:$operation] $serialized';
    try {
      if (sequelize is Sequelize) {
        sequelize.log(message);
        return;
      }
      final dynamic candidate = sequelize;
      candidate?.log(message);
    } catch (_) {
      // Never fail query execution due to logging callback issues.
    }
  }

  dynamic _jsonSafe(dynamic value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is List) {
      return value.map(_jsonSafe).toList();
    }
    if (value is Map) {
      return value.map(
        (key, nested) => MapEntry(key.toString(), _jsonSafe(nested)),
      );
    }
    return value.toString();
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
