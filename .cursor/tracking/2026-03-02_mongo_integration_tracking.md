# 2026-03-02 Mongo Integration Tracking

## Commit Timeline (today)

- `107dac0` - `fix(generator): strip association payloads from save() data in generated instance methods`
  - Generated instance `save()` now filters payload to model attributes before persistence.
  - Prevents nested association objects (`post`, `posts`, `user`, `postDetails`) from being written on parent saves.

- `3e10856` - `feat(mongodb): add schema validation, $where operator, and schema mismatch queries`
  - Added Mongo schema validation support and query operator handling improvements.
  - Added mismatch query capabilities for schema-related diagnostics/validation.

- `5e3bcb7` - `feat: enforce unique index on primary key fields during MongoDB collection sync`
  - Mongo sync path now enforces PK uniqueness using indexes.

- `ae644a6` - `fix(mongodb): skip empty logical operator arrays in query translation`
  - Query translation now avoids emitting invalid empty logical clauses (`$and`, `$or`) in Mongo pipelines.

- `f63528a` - `feat: integrate Mongo execution path into core query engine`
  - Added core query-engine dispatch/registry lifecycle integration for Mongo.
  - Added Mongo logging + formatter path and mongo-aware test runner plumbing.

- `fdd57be` - `test: add real mongodb integration coverage and examples`
  - Added Mongo local integration coverage and example workflows.

- `d777f4f` - `feat: scaffold mongodb query engine package`
  - Initial Mongo package scaffolding.

- `0c03092` - `Enhance MongoDB support and add bridge latency measurement`
  - General Mongo support enhancement baseline + benchmark work.

## Current Working-Tree Changes (to be committed now)

- Core/Generator
  - `packages/sequelize_orm/lib/src/sequelize/sequelize_impl.dart`
  - `packages/sequelize_orm_generator/lib/src/generators/methods/_generate_instance_methods.dart`

- Mongo package
  - `packages/sequelize_orm_mongodb/lib/src/mongo_connection_options.dart`
  - `packages/sequelize_orm_mongodb/lib/src/mongo_lookup_builder.dart`
  - `packages/sequelize_orm_mongodb/lib/src/mongo_operator_translator.dart`
  - `packages/sequelize_orm_mongodb/lib/src/mongo_query_engine.dart`
  - `packages/sequelize_orm_mongodb/lib/src/mongo_sequelize_integration.dart`
  - `packages/sequelize_orm_mongodb/test/mongo_auto_bootstrap_test.dart` (new)

- Example/Test updates
  - `example/lib/main.dart`
  - `example/lib/benchmark.dart`
  - `example/lib/db/seeders/seed_user_post.seeder.dart`
  - Multiple core tests adjusted for Mongo query-log semantics and dialect-specific expectations.

## Things We Need To Know

- Mongo include semantics:
  - `$lookup` naturally returns arrays; singular associations must be normalized (`[] -> null`, `[x] -> x`) before model parsing.

- Save semantics parity:
  - Parent `save()` should not cascade association persistence.
  - Association writes should happen through explicit child saves/association methods (`user.post.save()` etc.).

- Test expectations:
  - SQL-string assertion suites are not always directly portable to Mongo.
  - Mongo-aware assertions should validate operation/pipeline logs (e.g. `[mongo:...]`) rather than SQL text.

- Bootstrap behavior:
  - Mongo should auto-attach query engine via dialect initializer when using `MongoConnectionOptions`.
  - `sequelize.initialize()` is expected to open Mongo connection through query engine lifecycle hooks.

- Validation command used frequently:
  - `dart run tools/run.dart test --mongo --mongo-url=mongodb://localhost:27017`
