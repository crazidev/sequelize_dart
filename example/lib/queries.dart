import 'package:sequelize_orm_example/db/models/users.model.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final user = await Users.model.findAll(
    include: (includeUsers) => [
      includeUsers.post(
        required: true,
        include: (i) => [
          i.postDetails(required: true),
        ],
      ),
    ],
  );
}
