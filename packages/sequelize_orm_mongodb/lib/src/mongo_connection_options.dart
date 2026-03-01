import 'package:sequelize_orm/sequelize_orm.dart';

/// Mongo connection options usable with `Sequelize.createInstance`.
///
/// This allows a single entry-point config while Mongo execution is provided by
/// `useMongoQueryEngine()`.
class MongoConnectionOptions extends SequelizeCoreOptions {
  MongoConnectionOptions({
    required String url,
    required String database,
    this.mongoValidationLevel,
    this.mongoValidationAction,
  }) : super(
          url: url,
          database: database,
        );

  final String? mongoValidationLevel;
  final String? mongoValidationAction;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': 'mongo',
      if (mongoValidationLevel != null)
        'mongoValidationLevel': mongoValidationLevel,
      if (mongoValidationAction != null)
        'mongoValidationAction': mongoValidationAction,
    };
  }
}
