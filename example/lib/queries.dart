import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final createdUser = await Users.model.bulkCreate(
    List.generate(
      4,
      (i) => CreateUsers(
        email: 'bulk_create_user_$i@example.com',
        firstName: 'Bulk',
        lastName: 'User',
        status: UsersStatus.active,
        phoneNumber: const SequelizeBigInt('081234567890'),
      ),
    ),
  );

  print(createdUser.map((e) => e.toJson()));
}
