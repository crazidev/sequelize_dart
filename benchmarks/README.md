# Multi-Package ORM Benchmark Suite

A standardized, multi-package comparative benchmark suite evaluating Dart ORMs against a shared PostgreSQL database.

## Supported Packages

1. **Sequelize ORM (Dart)** – Bridge-powered TypeScript Sequelize integration.
2. **Drift** – Reactive persistence library & type-safe SQL query builder.
3. **Serverpod ORM** – Serverpod database ORM with code-generated schema models.

---

## Key Architecture & Design

- **Single Source of Truth**: Table schema and test data are created and seeded exclusively by `sequelize_orm` (`sync(force: true)`).
- **Identical Database Schema**: All 3 ORMs connect to the exact same PostgreSQL database (`localhost:5432/postgres`) and query the exact same tables (`users`, `posts`, `post_details`).
- **Benchmark Harness**: Uses official **[`benchmark_harness`](https://pub.dev/packages/benchmark_harness)** (`AsyncBenchmarkBase`) with dedicated warmup and continuous sampling to produce consistent, reproducible metrics.
- **Isolated Package Modules**: Each ORM implementation is isolated in `lib/packages/<package_name>/`.

---

## Running Benchmarks

### Option 1: Via Developer CLI (`sqtools`)

```bash
# Standard JIT benchmark run
sqtools benchmark

# Re-synchronize and re-seed the shared database
sqtools benchmark --seed

# Run in compiled Native AOT mode
sqtools benchmark --native

# Customize duration & warmup windows (ms)
sqtools benchmark --duration=800 --warmup=200
```

### Option 2: Direct Dart VM

```bash
cd benchmarks

# Run benchmark
dart run bin/benchmark.dart

# Re-seed database with custom counts
dart run bin/benchmark.dart --seed --users 100 --posts 500
```

### Option 3: Compile and Run Native AOT Binary

```bash
cd benchmarks

# Build native binary bundle (includes native build hooks)
dart build cli

# Execute native binary
./build/cli/macos_x64/bundle/bin/benchmark
```

---

## Query Tests Evaluated

| Test                          | Query Description                               |
| ----------------------------- | ----------------------------------------------- |
| `findAll (all posts)`         | Select all 200 records from `posts` table       |
| `findAll (limit 10)`          | Select first 10 posts with `limit: 10`          |
| `findOne (id = 1)`            | Primary key lookup by ID                        |
| `count`                       | Aggregate `COUNT(*)` query                      |
| `findAll (where id < 50)`     | Range filter condition                          |
| `findAll with include (join)` | Joined query between `posts` and `post_details` |
| `5 sequential findOnes`       | 5 sequential single-row lookups                 |
| `findAll (complex where)`     | Filter with multiple `AND` conditions & limit   |

---

## Adding a New ORM Package

1. Create a new folder at `lib/packages/<new_package_name>/`.
2. Define models, connection, and queries implementing `OrmBenchmark` (`lib/utils/base_benchmark.dart`).
3. Export your benchmark class and add it to the `benchmarks` list in `bin/benchmark.dart`.
