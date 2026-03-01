import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final users = await Db.users.findOne(
    where: (c) => or([
      c.firstName.eq('Seed 20'),
      c.metadata.key('isAdmin').eq(true),
    ]),
    include: (includeUsers) => [
      includeUsers.post(
        where: (c) => c.views.eq(20),
        required: true,
      ),
    ],
  );

  users?.lastName = 'Updated Last Name';
  await users?.save();

  print('==================== USERS ====================');
  print(users.toString());
}
