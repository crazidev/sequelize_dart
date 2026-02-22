# Transaction System Implementation (2026-02-22)

This document provides a comprehensive overview of the transaction system implementation, including the recent refactorings for Zone-based inheritance and the separation of managed/unmanaged transaction APIs.

## Implementation Overview

The transaction system is designed to provide both high-level "managed" transactions (automatic cleanup, scoping) and low-level "unmanaged" transactions (manual control), while leveraging Dart's `Zone` mechanism for automatic transaction inheritance.

### Core Modules

1. **Transaction Object (`Transaction`)**
   - Stores the unique `transactionId` returned by the Sequelize bridge.
   - Manages state via an `isFinished` flag to prevent double-closing or use-after-close.
   - **Zone Scoping**: Implements `scope(fn)` which uses `runZoned` to hold the transaction in `Zone.current`.

2. **Scoping & Inheritance**
   - **`Transaction.current`**: A static getter that retrieves the active transaction from the current `Zone`.
   - **`QueryEngine._resolveTransaction(manual)`**: The central authority for deciding which transaction an operation uses.
     - Prioritizes the `manual` transaction if provided.
     - Falls back to `Transaction.current`.
     - Validates that the transaction is not finished before allowing the operation.

3. **API Design (`Sequelize`)**
   - **`transaction(callback)`**: Managed transaction.
     - Starts a transaction in the bridge.
     - Creates a `Transaction` instance.
     - Invokes the callback inside a transaction scope.
     - Automatically **commits** on success and **rolls back** on exception.
     - Checks `isFinished` during cleanup to avoid masking errors with "transaction already finished" exceptions if the user manually closed it.
   - **`startUnmanagedTransaction()`**: Returns `Future<Transaction>`.
     - Strictly for manual control.
     - Does **not** provide automatic inheritance to prevent unexpected behavior in long-running unmanaged flows.

4. **Bridge Integration (`association.ts`)**
   - Handles the actual Sequelize call on the Node.js side.
   - **Association Support**: Implements robust method searching (`findAssociationMethod`) to bridge the gap between Dart pluralization and Sequelize's dynamic method naming (e.g., searching for both `createPosts` and `createPost`).

---

## Technical Details (Code Reference)

### Transaction Resolution Pattern
Used across all `QueryEngine` methods (findAll, create, update, etc.):
```dart
Transaction? _resolveTransaction(Transaction? transaction) {
  final tx = transaction ?? Transaction.current;
  if (tx != null && tx.isFinished) {
    throw SequelizeException(
      'Transaction cannot be used because it has already been committed or rolled back.',
      context: 'QueryEngine',
    );
  }
  return tx;
}
```

### Managed Lifecycle (Sequelize Implementation)
```dart
@override
Future<T> transaction<T>(Future<T> Function(Transaction transaction) callback) async {
  final response = await _bridge.call('startTransaction', {});
  final transaction = Transaction(response['transactionId'], _bridge);

  try {
    final result = await transaction.scope(() => callback(transaction));
    if (!transaction.isFinished) await transaction.commit();
    return result;
  } catch (e) {
    if (!transaction.isFinished) await transaction.rollback();
    rethrow;
  }
}
```

---

## File Manifest

| Path | Purpose | Key Changes |
| :--- | :--- | :--- |
| `lib/src/transaction/transaction.dart` | Atomic state and scoping | `isFinished` flag, `scope()` method, `Transaction.current`. |
| `lib/src/query/query_engine/query_engine_impl.dart` | Database operation orchestration | Integrated `_resolveTransaction` into all 30+ core methods. |
| `lib/src/sequelize/sequelize_impl.dart` | Public API Implementation | Added `startUnmanagedTransaction`, updated `transaction` lifecycle. |
| `lib/src/sequelize/sequelize_interface.dart` | API Definition | Documentation and method split for better IDE support. |
| `lib/src/bridge/sequelize_exceptions.dart` | Error reporting | Improved formatting of transaction lifecycle errors. |
| `js/src/handlers/association.ts` | JS-level method discovery | Dynamic method finding for association creators. |

---

## Testing Scenarios Verified

- [x] **Automatic Rollback**: Managed transactions roll back on callback errors.
- [x] **Automatic Inheritance**: Operations inside `transaction()` pick up the transaction without explicit passing.
- [x] **Association Inheritance**: `user.createPosts()` respects the surrounding transaction.
- [x] **State Guarding**: Throwing `StateError` when trying to use or close a finished transaction.
- [x] **Nested Call Guarding**: Managed transactions won't double-close if the user manually called `t.rollback()` inside the callback.
