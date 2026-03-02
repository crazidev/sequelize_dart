import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_mongodb/src/mongo_sequelize_integration.dart';

enum MongoValidationLevel {
  off,
  strict,
  moderate,
}

enum MongoValidationAction {
  error,
  warn,
}

/// Mongo connection options usable with `Sequelize.createInstance`.
///
/// Importing `sequelize_orm_mongodb.dart` auto-registers Mongo initialization,
/// so no additional setup call is required for standard usage.
class MongoConnectionOptions extends SequelizeCoreOptions {
  MongoConnectionOptions({
    required String url,
    required String database,
    this.mongoValidationLevel,
    this.mongoValidationAction,
    this.defaultParanoidField = 'deletedAt',
  }) : super(
          url: url,
          database: database,
        ) {
    _ensureMongoDialectInitializerRegistered();
  }

  final MongoValidationLevel? mongoValidationLevel;
  final MongoValidationAction? mongoValidationAction;
  final String defaultParanoidField;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': 'mongo',
      if (mongoValidationLevel != null)
        'mongoValidationLevel': mongoValidationLevel!.name,
      if (mongoValidationAction != null)
        'mongoValidationAction': mongoValidationAction!.name,
      'mongoDefaultParanoidField': defaultParanoidField,
    };
  }
}

bool _mongoDialectInitializerRegistered = false;

void _ensureMongoDialectInitializerRegistered() {
  if (_mongoDialectInitializerRegistered) {
    return;
  }

  Sequelize.registerDialectInitializer(
    dialect: 'mongo',
    initializer: (sequelize) {
      final config = sequelize.connectionConfig;
      final defaultParanoidField =
          config?['mongoDefaultParanoidField']?.toString() ?? 'deletedAt';
      MongoSequelizeIntegration.attach(
        sequelize: sequelize,
        defaultParanoidField: defaultParanoidField,
      );
    },
  );

  _mongoDialectInitializerRegistered = true;
}
