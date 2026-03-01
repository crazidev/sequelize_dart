import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/src/mongo_adapter.dart';
import 'package:sequelize_orm_mongodb/src/mongo_association.dart';
import 'package:sequelize_orm_mongodb/src/mongo_connection.dart';
import 'package:sequelize_orm_mongodb/src/mongo_lookup_builder.dart';
import 'package:sequelize_orm_mongodb/src/mongo_operator_translator.dart';
import 'package:sequelize_orm_mongodb/src/mongo_query_engine.dart';

/// Integration helper that wires [MongoQueryEngine] into `sequelize_orm` core.
class MongoSequelizeIntegration {
  const MongoSequelizeIntegration._();

  /// Registers Mongo as the active query engine for this sequelize instance.
  ///
  /// This keeps the generated `Db.*` APIs unchanged and routes their calls to
  /// Mongo through core `QueryEngine` dispatch.
  static void attach({
    required Sequelize sequelize,
    MongoDatabaseAdapter? database,
    MongoConnectionConfig? config,
    MongoAssociationResolver? associationResolver,
    MongoOperatorTranslator? operatorTranslator,
    MongoLookupBuilder? lookupBuilder,
    String defaultParanoidField = 'deletedAt',
  }) {
    final resolvedConfig = config ??
        (database == null
            ? _configFromSequelize(sequelize)
            : _configDefaultsFromSequelize(sequelize));
    final resolvedDatabase = database ??
        MongoDartDatabaseAdapter(
          config: resolvedConfig,
        );
    final resolver =
        associationResolver ?? _buildAssociationResolver(sequelize);
    final engine = MongoQueryEngine(
      database: resolvedDatabase,
      associationResolver: resolver,
      operatorTranslator: operatorTranslator,
      lookupBuilder: lookupBuilder,
      defaultParanoidField: defaultParanoidField,
      defaultValidationLevel: resolvedConfig.mongoValidationLevel,
      defaultValidationAction: resolvedConfig.mongoValidationAction,
    );

    sequelize.setQueryEngine(engine, useBridge: false);
  }

  static MongoConnectionConfig _configFromSequelize(Sequelize sequelize) {
    final cfg = sequelize.connectionConfig;
    final url = cfg?['url']?.toString();
    final database = cfg?['database']?.toString();
    if (url == null || url.isEmpty || database == null || database.isEmpty) {
      throw StateError(
        'Mongo configuration not found on sequelize instance. '
        'Use MongoConnectionOptions in createInstance or pass config/database explicitly.',
      );
    }
    return MongoConnectionConfig(
      url: url,
      database: database,
      mongoValidationLevel: cfg?['mongoValidationLevel']?.toString(),
      mongoValidationAction: cfg?['mongoValidationAction']?.toString(),
    );
  }

  static MongoConnectionConfig _configDefaultsFromSequelize(
    Sequelize sequelize,
  ) {
    final cfg = sequelize.connectionConfig;
    return MongoConnectionConfig(
      url: cfg?['url']?.toString() ?? '',
      database: cfg?['database']?.toString() ?? '',
      mongoValidationLevel: cfg?['mongoValidationLevel']?.toString(),
      mongoValidationAction: cfg?['mongoValidationAction']?.toString(),
    );
  }

  static MongoAssociationResolver _buildAssociationResolver(
    Sequelize sequelize,
  ) {
    return ({
      required String sourceModel,
      required String associationName,
    }) {
      final association = sequelize.getAssociationDefinition(
        sourceModel: sourceModel,
        associationName: associationName,
      );
      if (association == null) {
        return null;
      }
      return _toMongoAssociation(
        sequelize: sequelize,
        association: association,
      );
    };
  }

  static MongoAssociationDefinition? _toMongoAssociation({
    required Sequelize sequelize,
    required Map<String, dynamic> association,
  }) {
    final sourceModel = association['sourceModel']?.toString();
    final associationName = association['associationName']?.toString();
    final targetModel = association['targetModel']?.toString();
    final rawType = association['associationType']?.toString();

    if (sourceModel == null ||
        associationName == null ||
        targetModel == null ||
        rawType == null) {
      return null;
    }

    final associationType = _parseAssociationType(rawType);
    if (associationType == null) {
      return null;
    }

    final sourcePrimaryKey = _primaryKeyFor(sequelize, sourceModel);
    final targetPrimaryKey = _primaryKeyFor(sequelize, targetModel);
    final foreignKey = association['foreignKey']?.toString();
    final sourceKey = association['sourceKey']?.toString();
    final targetKey = association['targetKey']?.toString();

    switch (associationType) {
      case MongoAssociationType.hasOne:
      case MongoAssociationType.hasMany:
        return MongoAssociationDefinition(
          sourceModel: sourceModel,
          associationName: associationName,
          targetCollection: targetModel,
          associationType: associationType,
          localField: sourceKey ?? sourcePrimaryKey,
          foreignField: foreignKey ?? _defaultForeignKey(sourceModel),
        );
      case MongoAssociationType.belongsTo:
        return MongoAssociationDefinition(
          sourceModel: sourceModel,
          associationName: associationName,
          targetCollection: targetModel,
          associationType: associationType,
          localField: foreignKey ?? _defaultForeignKey(targetModel),
          foreignField: targetKey ?? targetPrimaryKey,
        );
    }
  }

  static MongoAssociationType? _parseAssociationType(String associationType) {
    switch (associationType) {
      case 'hasOne':
        return MongoAssociationType.hasOne;
      case 'hasMany':
        return MongoAssociationType.hasMany;
      case 'belongsTo':
        return MongoAssociationType.belongsTo;
      default:
        return null;
    }
  }

  static String _primaryKeyFor(Sequelize sequelize, String modelName) {
    final keys = sequelize.getModelPrimaryKeys(modelName);
    if (keys.contains('_id')) {
      return '_id';
    }
    if (keys.isNotEmpty) {
      return keys.first;
    }
    return '_id';
  }

  static String _defaultForeignKey(String modelName) {
    if (modelName.isEmpty) {
      return 'parentId';
    }
    final base = '${modelName[0].toLowerCase()}${modelName.substring(1)}';
    return '${base}Id';
  }

}

extension MongoSequelizeExtension on Sequelize {
  /// Convenience extension to attach Mongo query engine integration.
  void useMongoQueryEngine({
    MongoDatabaseAdapter? database,
    MongoConnectionConfig? config,
    MongoAssociationResolver? associationResolver,
    MongoOperatorTranslator? operatorTranslator,
    MongoLookupBuilder? lookupBuilder,
    String defaultParanoidField = 'deletedAt',
  }) {
    MongoSequelizeIntegration.attach(
      sequelize: this,
      database: database,
      config: config,
      associationResolver: associationResolver,
      operatorTranslator: operatorTranslator,
      lookupBuilder: lookupBuilder,
      defaultParanoidField: defaultParanoidField,
    );
  }
}
