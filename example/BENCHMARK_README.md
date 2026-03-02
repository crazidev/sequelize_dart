# Sequelize Dart Profiling & Benchmarking

This directory contains profiling and benchmark tools to compare **MongoDB (native)** vs **PostgreSQL (bridge)** integration.

## Profiling: Step-by-Step Logging

Profile where time is spent across initialization, query building, translation, and DB execution.

### MongoDB (native driver)

```bash
dart run lib/profiling/profiling_mongo.dart
```

Logs steps:
- `connection` – open connection
- `query_to_json` – serialize Query to JSON
- `build_query_plan` – parse/plan
- `translate_where` – Sequelize operators → MongoDB operators
- `paranoid_merge` – soft-delete scope (if paranoid)
- `include_extract` – include/join config
- `db_find` / `db_find_one` / `db_aggregate` – DB execution
- `result_transform` – docs → ModelInstanceData

### PostgreSQL (bridge → Node/Sequelize.js)

```bash
dart run lib/profiling/profiling_postgres.dart
```

Logs:
- `init` – total initialization (bridge start, connect, define models)
- `bridge_call` – per-RPC latency (via `BridgeLatencyInfo`)
- `total` – per-query total time

**Note:** Postgres uses the bridge (JSON-RPC over stdio). MongoDB talks directly to the DB via `mongo_dart`, so there is no bridge overhead.

## Benchmarks: benchmark_harness

Uses Dart’s official `benchmark_harness` for structured benchmarks.

### Run full suite

```bash
dart run benchmark/benchmark_suite.dart
```

### Benchmarks

| Benchmark        | MongoDB                    | PostgreSQL        |
|------------------|----------------------------|-------------------|
| Init             | `MongoInit`                | `PostgresInit`    |
| Single findOne   | `MongoFindOne`             | `PostgresFindOne` |
| Batch findAll    | `MongoFindAll`             | `PostgresFindAll` |
| Throughput (RPS) | `MongoRps(100)`            | `PostgresRps(100)`|

### Prerequisites

- **PostgreSQL:** Running at `postgresql://postgres:postgres@localhost:5432/postgres`
- **MongoDB:** Running at `mongodb://localhost:27017`
- **Seeding:** Postgres benchmark expects `Post` model with data. Mongo benchmark expects `mongo_example_posts` / `mongo_example_users` collections.

Run `main_mongo.dart` first to seed MongoDB; use the example seeders for Postgres.

### Comparison notes

- **MongoDB:** Native Dart driver, no IPC. Lower overhead per query.
- **PostgreSQL:** Bridge (stdio) → Node → Sequelize.js. Higher per-call overhead, but can reuse connection pool in Node.

Profiling highlights:
- Mongo: time in `translate_where`, `db_find`, `result_transform`
- Postgres: time in `bridge_call` (round-trip + Node execution)
