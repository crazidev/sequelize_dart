import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

part 'database.g.dart';

@DataClassName('DriftUser')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get firstName => text().named('first_name')();
  TextColumn get lastName => text().named('last_name').nullable()();
  Int64Column get phoneNumber => int64().named('phone_number').nullable()();
  Column<PgDateTime> get deletedAt => customType(PgTypes.timestampWithTimezone)
      .named('deleted_at')
      .nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get scores => text().nullable()();
  TextColumn get metadata => text().nullable()();
  Column<PgDateTime> get createdAt => customType(PgTypes.timestampWithTimezone)
      .named('created_at')
      .nullable()();
  Column<PgDateTime> get updatedAt => customType(PgTypes.timestampWithTimezone)
      .named('updated_at')
      .nullable()();
}

@DataClassName('DriftPost')
class Posts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text().nullable()();
  IntColumn get userId => integer().named('user_id').nullable()();
  IntColumn get views =>
      integer().named('views').withDefault(const Constant(0))();
}

@DataClassName('DriftPostDetail')
class PostDetails extends Table {
  @override
  String get tableName => 'post_details';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get likes => integer().nullable()();
  TextColumn get metadata => text().nullable()();
  IntColumn get postId => integer().named('post_id').nullable()();
  IntColumn get userId => integer().named('user_id').nullable()();
  Column<PgDateTime> get createdAt => customType(PgTypes.timestampWithTimezone)
      .named('created_at')
      .nullable()();
  Column<PgDateTime> get updatedAt => customType(PgTypes.timestampWithTimezone)
      .named('updated_at')
      .nullable()();
}

@DriftDatabase(tables: [Users, Posts, PostDetails])
class DriftAppDatabase extends _$DriftAppDatabase {
  DriftAppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
