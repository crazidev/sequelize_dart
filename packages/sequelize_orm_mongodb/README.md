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
