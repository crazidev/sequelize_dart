import 'package:orm_benchmarks/packages/sequelize/models/post.model.dart';
import 'package:orm_benchmarks/packages/sequelize/models/post_details.model.dart';
import 'package:orm_benchmarks/packages/sequelize/models/users.model.dart';
import 'package:sequelize_orm/sequelize_orm.dart';

const postgresConnectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Creates a configured Sequelize instance connected to default Postgres
Sequelize createSequelizeInstance() {
  return Sequelize().createInstance(
    connection: SequelizeConnection.postgres(url: postgresConnectionString),
    normalizeJsonTypes: false,
  );
}

/// Initializes Sequelize and registers all models
Future<Sequelize> initSequelize() async {
  final sequelize = createSequelizeInstance();

  await sequelize.initialize(
    models: [
      Users.model,
      Post.model,
      PostDetails.model,
    ],
  );

  return sequelize;
}
