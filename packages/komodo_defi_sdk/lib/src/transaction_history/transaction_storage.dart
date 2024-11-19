import 'dart:collection';

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Core interface for transaction history storage implementations
abstract interface class TransactionStorage {
  factory TransactionStorage.defaultForPlatform() =>
      // TODO: Other implementations
      InMemoryTransactionStorage();

  /// Store a new transaction
  Future<void> storeTransaction(Transaction transaction);

  /// Store multiple transactions in batch
  Future<void> storeTransactions(List<Transaction> transactions);

  /// Retrieve transactions for an asset with pagination
  Future<TransactionPage> getTransactions(
    AssetId assetId, {
    String? fromId,
    int? pageNumber,
    int limit = 10,
  });

  /// Get a specific transaction by ID
  Future<Transaction?> getTransactionById(String transactionId);

  /// Clear stored transactions for an asset
  Future<void> clearTransactions(AssetId assetId);

  /// Get latest transaction ID for an asset to use as pagination reference
  Future<String?> getLatestTransactionId(AssetId assetId);
}

class InMemoryTransactionStorage implements TransactionStorage {
  final _storage = <AssetId, SplayTreeMap<String, Transaction>>{};

  @override
  Future<void> storeTransaction(Transaction transaction) async {
    final assetTransactions = _storage.putIfAbsent(
      transaction.assetId,
      SplayTreeMap<String, Transaction>.new,
    );
    assetTransactions[transaction.id] = transaction;
  }

  @override
  Future<void> storeTransactions(List<Transaction> transactions) async {
    for (final transaction in transactions) {
      await storeTransaction(transaction);
    }
  }

  @override
  Future<TransactionPage> getTransactions(
    AssetId assetId, {
    String? fromId,
    int? pageNumber,
    int limit = 10,
  }) async {
    final assetTransactions = _storage[assetId] ?? SplayTreeMap();
    final total = assetTransactions.length;

    if (total == 0) {
      return TransactionPage(
        transactions: const [],
        total: 0,
        currentPage: pageNumber ?? 1,
        totalPages: 0,
      );
    }

    final transactions = assetTransactions.values.toList();

    if (fromId != null) {
      final startIndex = transactions.indexWhere((t) => t.id == fromId);
      if (startIndex != -1) {
        transactions.removeRange(0, startIndex + 1);
      }
    } else if (pageNumber != null && pageNumber > 1) {
      final startIndex = (pageNumber - 1) * limit;
      if (startIndex < transactions.length) {
        transactions.removeRange(0, startIndex);
      }
    }

    final page = transactions.take(limit).toList();
    final totalPages = (total / limit).ceil();

    return TransactionPage(
      transactions: page,
      total: total,
      nextPageId: page.lastOrNull?.id,
      currentPage: pageNumber ?? 1,
      totalPages: totalPages,
    );
  }

  @override
  Future<Transaction?> getTransactionById(String transactionId) async {
    for (final assetTransactions in _storage.values) {
      if (assetTransactions.containsKey(transactionId)) {
        return assetTransactions[transactionId];
      }
    }
    return null;
  }

  @override
  Future<void> clearTransactions(AssetId assetId) async {
    _storage.remove(assetId);
  }

  @override
  Future<String?> getLatestTransactionId(AssetId assetId) async {
    return _storage[assetId]?.keys.lastOrNull;
  }
}
