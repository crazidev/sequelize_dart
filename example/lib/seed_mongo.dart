import 'package:mongo_dart/mongo_dart.dart';

const mongoUrl = 'mongodb://localhost:27017/sequelize_dart';

Future<void> main() async {
  final db = Db(mongoUrl);
  await db.open();

  try {
    final users = await _recreateUsersCollection(db);
    // await _seedUsers(users);
    // await _ensureIndexes(users);

    // final count = await users.count();
    // print('Seed complete. users count: $count');
  } finally {
    await db.close();
  }
}

Future<DbCollection> _recreateUsersCollection(Db db) async {
  final users = db.collection('users');
  await users.drop();

  await db.createCollection(
    'users',
    createCollectionOptions: CreateCollectionOptions(
      validator: {
        r'$jsonSchema': {
          'bsonType': 'object',
          'required': ['email', 'firstName', 'lastName', 'role', 'isActive'],
          'properties': {
            'email': {
              'bsonType': 'string',
              'description': 'User email address',
            },
            'firstName': {
              'bsonType': 'string',
              'description': 'User first name',
            },
            'lastName': {
              'bsonType': 'string',
              'description': 'User last name',
            },
            'role': {
              'enum': ['admin', 'developer', 'viewer'],
              'description': 'User role',
            },
            'isActive': {
              'bsonType': 'bool',
              'description': 'Active account flag',
            },
            'tags': {
              'bsonType': 'array',
              'items': {'bsonType': 'string'},
            },
            'createdAt': {'bsonType': 'date'},
            'lastLoginAt': {'bsonType': 'date'},
          },
        },
      },
      validationLevel: 'strict',
      validationAction: 'error',
    ),
  );

  return users;
}

Future<void> _seedUsers(DbCollection users) async {
  final now = DateTime.now().toUtc();
  final docs = [
    {
      'email': 'dev@example.com',
      'firstName': 'Crazibeat',
      'lastName': 'Dev',
      'role': 'developer',
      'isActive': true,
      'tags': ['core', 'query-testing'],
      'createdAt': now.subtract(const Duration(days: 90)),
      'lastLoginAt': now.subtract(const Duration(hours: 2)),
    },
    {
      'email': 'admin@example.com',
      'firstName': 'Ada',
      'lastName': 'Lovelace',
      'role': 'admin',
      'isActive': true,
      'tags': ['ops', 'maintainer'],
      'createdAt': now.subtract(const Duration(days: 140)),
      'lastLoginAt': now.subtract(const Duration(days: 1)),
    },
    {
      'email': 'viewer@example.com',
      'firstName': 'Grace',
      'lastName': 'Hopper',
      'role': 'viewer',
      'isActive': false,
      'tags': ['readonly'],
      'createdAt': now.subtract(const Duration(days: 45)),
      'lastLoginAt': now.subtract(const Duration(days: 12)),
    },
  ];

  await users.insertMany(docs, ordered: true);
}

Future<void> _ensureIndexes(DbCollection users) async {
  await users.createIndex(
    keys: {'email': 1},
    name: 'email_unique',
    unique: true,
  );

  await users.createIndex(
    keys: {'role': 1, 'isActive': 1},
    name: 'role_is_active',
  );
}
