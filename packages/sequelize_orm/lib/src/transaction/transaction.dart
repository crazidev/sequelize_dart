import 'dart:async';

import 'package:sequelize_orm/src/bridge/bridge_client.dart';

/// Represents a transaction.
///
/// Transactions can be managed (using [Sequelize.transaction] with a callback)
/// or unmanaged (manual [commit]/[rollback]).
///
/// {@category Querying}
class Transaction {
  static const _zoneKey = Symbol('sequelize_transaction');

  /// The unique ID of the transaction in the bridge.
  final String transactionId;
  final BridgeClientInterface _bridge;
  bool _finished = false;

  Transaction(this.transactionId, this._bridge);

  /// Get the current transaction in the active [Zone], if any.
  static Transaction? get current => Zone.current[_zoneKey] as Transaction?;

  /// Runs [fn] within a [Zone] where this transaction is automatically
  /// inherited by Sequelize operations.
  Future<T> scope<T>(Future<T> Function() fn) {
    return runZoned(fn, zoneValues: {_zoneKey: this});
  }

  /// Commit the transaction.
  Future<void> commit() async {
    if (_finished) {
      throw StateError(
          'Transaction has already been committed or rolled back.');
    }
    _finished = true;
    try {
      await _bridge.call('commitTransaction', {'transactionId': transactionId});
    } catch (e) {
      // Even if it fails, we consider it finished/unusable
      rethrow;
    }
  }

  /// Rollback the transaction.
  Future<void> rollback() async {
    if (_finished) {
      throw StateError(
          'Transaction has already been committed or rolled back.');
    }
    _finished = true;
    try {
      await _bridge
          .call('rollbackTransaction', {'transactionId': transactionId});
    } catch (e) {
      // Even if it fails, we consider it finished/unusable
      rethrow;
    }
  }

  /// Whether the transaction has been committed or rolled back.
  bool get isFinished => _finished;
}
