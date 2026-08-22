import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final firstUser = await Db.users.findOne();

  if (firstUser == null) {
    // print(firstUser?.createPost(data));
  }
}
