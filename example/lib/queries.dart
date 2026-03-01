import 'package:mongo_dart/mongo_dart.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final db = Db('mongodb://localhost:27017/sequelize_dart');
  await db.open();

  final where = SelectorBuilder().eq('email', 'dev@example.com');

  print(where.map);

  db.collection('users').find();

  // await sequelize.transaction((t) async {
  //   await Users.model.create(
  //     CreateUsers(
  //       email: 'dev@example.com',
  //       firstName: 'Crazibeat',
  //       lastName: 'Dev',
  //     ),
  //   );
  // });

  // final tx = await sequelize.startUnmanagedTransaction();
  // try {
  //   await Users.model.create(
  //     CreateUsers(
  //       email: 'dev@example.com',
  //       firstName: 'Crazibeat',
  //       lastName: 'Dev',
  //     ),
  //     transaction: tx,
  //   );

  //   await tx.commit();
  // } catch (e) {
  //   await tx.rollback();
  //   rethrow;
  // }
}
