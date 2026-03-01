import 'package:sequelize_orm/sequelize_orm.dart';

class MongoOrmException extends SequelizeException {
  MongoOrmException(
    super.message, {
    super.code,
    super.stack,
    super.original,
    super.context,
    super.name = 'MongoOrmException',
  });
}

class MongoConnectionException extends MongoOrmException {
  MongoConnectionException(
    super.message, {
    super.code,
    super.stack,
    super.original,
    super.context,
    super.name = 'MongoConnectionException',
  });
}

class MongoQueryException extends MongoOrmException {
  MongoQueryException(
    super.message, {
    super.code,
    super.stack,
    super.original,
    super.context,
    super.name = 'MongoQueryException',
  });
}

class MongoUnsupportedFeatureException extends MongoOrmException {
  MongoUnsupportedFeatureException(
    super.message, {
    super.code,
    super.stack,
    super.original,
    super.context,
    super.name = 'MongoUnsupportedFeatureException',
  });
}

class MongoAssociationResolutionException extends MongoOrmException {
  MongoAssociationResolutionException(
    super.message, {
    super.code,
    super.stack,
    super.original,
    super.context,
    super.name = 'MongoAssociationResolutionException',
  });
}
