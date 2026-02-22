---
sidebar_position: 9
---

# Transactions

Sequelize Dart provides full transaction support for atomic, consistent database operations. You can choose between **managed** transactions (automatic lifecycle) or **unmanaged** transactions (explicit manual control).

## Managed Transactions

A managed transaction is the simplest and safest way to work with transactions. You pass a callback to `sequelize.transaction()`. The transaction is automatically:
- **Committed** if the callback returns without throwing.
- **Rolled back** if the callback throws any error.

```dart
await sequelize.transaction((t) async {
  await Users.model.create(
    CreateUsers(email: 'alice@example.com', firstName: 'Alice', lastName: 'Smith'),
  );

  await Users.model.create(
    CreateUsers(email: 'bob@example.com', firstName: 'Bob', lastName: 'Jones'),
  );
});
```

:::tip Automatic Inheritance
Inside a managed transaction callback, **you do not need to pass the transaction explicitly** to every model method. Sequelize Dart uses Dart `Zone`s to automatically make the transaction available to all operations in the same scope — including nested calls and association helpers.
:::

### How Inheritance Works

Under the hood, `sequelize.transaction()` runs your callback inside a `Zone` that carries the transaction. Any model method that calls `_resolveTransaction` will detect and use this zone-bound transaction automatically.

```dart
await sequelize.transaction((t) async {
  // No 'transaction: t' needed here — inherited from Zone
  final user = await Users.model.create(userData);

  // Association creators also inherit the transaction
  await user.createPosts({'title': 'Hello World'});

  // Reads are also automatically transactional
  final found = await Users.model.findOne(where: (u) => u.email.eq(email));
});
```

### Deliberate Rollback

To trigger a rollback on purpose, simply throw any exception from within the callback:

```dart
await sequelize.transaction((t) async {
  await Users.model.create(userData);

  // Simulate failure
  throw Exception('Something went wrong');
  // Transaction is automatically rolled back
});
```

---

## Nested Transactions

You can nest `sequelize.transaction()` calls. Each nested transaction is a **new, independent** transaction. If the inner transaction commits successfully but the outer one later fails, only the outer transaction is rolled back — the inner transaction's result has already been committed.

```dart
await sequelize.transaction((tOuter) async {
  await Users.model.create(
    CreateUsers(email: 'outer@example.com', firstName: 'Outer', lastName: 'User'),
  );

  // Nested managed transaction
  await sequelize.transaction((tInner) async {
    await Users.model.create(
      CreateUsers(email: 'inner@example.com', firstName: 'Inner', lastName: 'User'),
    );
    // Inner commits here
  });

  // tOuter is still open...
  throw Exception('Outer fails after inner committed');
  // Only tOuter is rolled back
});
```

---

## Unmanaged Transactions

For scenarios where you need manual control over when a transaction is committed or rolled back, use `startUnmanagedTransaction()`. This returns a typed `Transaction` object with full IDE support.

```dart
final tx = await sequelize.startUnmanagedTransaction();
try {
  await Users.model.create(
    CreateUsers(email: 'alice@example.com', firstName: 'Alice', lastName: 'A'),
    transaction: tx,
  );

  await tx.commit();
} catch (e) {
  await tx.rollback();
  rethrow;
}
```

:::caution
Unmanaged transactions do **not** support automatic zone inheritance. You must pass `transaction: tx` explicitly to every model method that should participate in the transaction.
:::

---

## Using Unmanaged Inside Managed

You can use an unmanaged transaction alongside a managed one. The unmanaged transaction operates independently on its own lifecycle, while the managed transaction is automatically scoped.

```dart
// Start unmanaged transaction separately
final txUnmanaged = await sequelize.startUnmanagedTransaction();

try {
  await sequelize.transaction((tManaged) async {
    // This is auto-inherited (no explicit tx needed)
    await Users.model.create(userData1);

    // This goes into the UNMANAGED transaction explicitly
    await Users.model.create(
      userData2,
      transaction: txUnmanaged,
    );

    // If tManaged fails here, only userData1 is rolled back
    // userData2 in txUnmanaged is unaffected
  });

  // Manually commit the unmanaged transaction after managed is done
  await txUnmanaged.commit();
} catch (e) {
  if (!txUnmanaged.isFinished) await txUnmanaged.rollback();
}
```

---

## Transaction Lifecycle Safety

Sequelize Dart enforces strict lifecycle rules on transactions:

| Scenario | Behavior |
| :--- | :--- |
| Using a committed transaction | Throws `SequelizeException` immediately |
| Using a rolled-back transaction | Throws `SequelizeException` immediately |
| Calling `commit()` twice | Throws `StateError` |
| Calling `rollback()` after `commit()` | Throws `StateError` |

This protects you from subtle bugs where a finished transaction is accidentally reused.

```dart
final tx = await sequelize.startUnmanagedTransaction();
await tx.commit();

// This will throw SequelizeException
await Users.model.findAll(transaction: tx);

// This will throw StateError
await tx.rollback();
```

---

## API Reference

| Method | Returns | Description |
| :--- | :--- | :--- |
| `sequelize.transaction(callback)` | `Future<T>` | Manages the full lifecycle of a transaction. |
| `sequelize.startUnmanagedTransaction()` | `Future<Transaction>` | Returns a manually controlled transaction. |
| `transaction.commit()` | `Future<void>` | Commits the transaction. Throws `StateError` if already finished. |
| `transaction.rollback()` | `Future<void>` | Rolls back the transaction. Throws `StateError` if already finished. |
| `transaction.isFinished` | `bool` | Whether the transaction has been committed or rolled back. |
| `Transaction.current` | `Transaction?` | Gets the active transaction from the current Dart `Zone`. |
