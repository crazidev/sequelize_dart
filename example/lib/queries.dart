import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final users = await Db.users.findOne(
    where: (c) => and([
      // c.id.eq(1),
      // c.metadata.key('isAdmin').eq(true),
    ]),
    // include: (includeUsers) => [
    //   includeUsers.post(
    //     include: (i) => [
    //       i.postDetails(),
    //     ],
    //   ),
    // ],
  );

  users?.lastName = 'Updated Last Name';
  users?.post?.views = 100;
  users?.post?.title = 'Updated Title';
  await users?.save();
  await users?.post?.save();

  print('==================== USERS ====================');
  print(users.toString());
}
