# sequelize_orm_mongodb

MongoDB support package for `sequelize_orm`.

This package provides:

- `MongoConnection` for MongoDB client lifecycle
- `MongoOperatorTranslator` for ORM JSON operators to Mongo query documents
- `MongoAggregationBuilder` and `MongoLookupBuilder` for aggregation/include translation
- `MongoQueryEngine` implementing `QueryEngineInterface`

## Status

This is an initial implementation focused on translation and query-engine
plumbing that can be tested without a live MongoDB instance by using adapter
fakes.

## Usage

```dart
import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
```

## Local integration tests

This package includes real MongoDB integration tests that run against:

- host: `localhost:27017`
- database: `sequelize_dart`

Run with:

```bash
MONGO_LOCAL_TESTS=1 dart test test/integration/mongo_local_integration_test.dart
```

The test file covers:

- connection lifecycle
- connection exceptions
- operator translation against real queries
- query lifecycle (create/update/aggregate/paranoid restore)
- association operations
