import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

/// Core interface for transaction history storage implementations
abstract interface class TransactionStorage {
  factory TransactionStorage.defaultForPlatform() =>
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

  /// Get a specific transaction by internal ID
  Future<Transaction?> getTransactionById(String internalId);

  /// Clear stored transactions for an asset
  Future<void> clearTransactions(AssetId assetId);

  /// Get latest transaction's internal ID for an asset
  Future<String?> getLatestTransactionId(AssetId assetId);

  /// Get storage statistics
  Future<StorageStats> getStats();
}

class InMemoryTransactionStorage implements TransactionStorage {
  InMemoryTransactionStorage() : _storage = {};

  static Future<InMemoryTransactionStorage> create() async {
    final instance = InMemoryTransactionStorage();
    await instance._initializeStorage();
    return instance;
  }

  final _mutex = Mutex();
  final Map<AssetId, SplayTreeMap<String, Transaction>> _storage;
  static const int? _maxTransactionsPerAsset = null;

  /// Compare transactions for ordering within the SplayTreeMap
  static int _compareTransactions(
    String a,
    String b,
    Map<String, Transaction> transactions,
  ) {
    final txA = transactions[a];
    final txB = transactions[b];

    if (txA == null || txB == null) {
      throw TransactionStorageException('Transaction not found in comparison');
    }

    // Order by timestamp descending, then by internalId for stable ordering
    return txB.timestamp.compareTo(txA.timestamp) != 0
        ? txB.timestamp.compareTo(txA.timestamp)
        : b.compareTo(a);
  }

  Future<void> _initializeStorage() async {
    await _mutex.protect(() async {
      for (final assetId in _storage.keys) {
        final assetTransactions = _storage[assetId] ?? <String, Transaction>{};
        _storage[assetId] = SplayTreeMap<String, Transaction>(
          (a, b) => _compareTransactions(a, b, assetTransactions),
        );
      }
    });
  }

  @override
  Future<void> storeTransaction(Transaction transaction) async {
    if (transaction.internalId.isEmpty) {
      throw TransactionStorageException(
        'Transaction internal ID cannot be empty',
      );
    }

    try {
      await _mutex.protect(() async {
        final assetTransactions = _storage.putIfAbsent(
          transaction.assetId,
          () => SplayTreeMap<String, Transaction>(
            (a, b) => _compareTransactions(
              a,
              b,
              {transaction.internalId: transaction},
            ),
          ),
        );

        assetTransactions[transaction.internalId] = transaction;
      });

      await _enforceStorageLimit(transaction.assetId);
    } catch (e) {
      throw TransactionStorageException('Failed to store transaction', e);
    }
  }

  @override
  Future<void> storeTransactions(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    try {
      await _mutex.protect(() async {
        final grouped = groupBy(transactions, (tx) => tx.assetId);

        for (final entry in grouped.entries) {
          final txMap = Map.fromEntries(
            entry.value.map((tx) => MapEntry(tx.internalId, tx)),
          );

          _storage
              .putIfAbsent(
                entry.key,
                () => SplayTreeMap<String, Transaction>(
                  (a, b) => _compareTransactions(a, b, txMap),
                ),
              )
              .addEntries(txMap.entries);
        }

        for (final assetId in grouped.keys) {
          await _enforceStorageLimit(assetId);
        }
      });
    } catch (e) {
      throw TransactionStorageException('Failed to store transactions', e);
    }
  }

  @override
  Future<TransactionPage> getTransactions(
    AssetId assetId, {
    String? fromId,
    int? pageNumber,
    int limit = 10,
  }) async {
    return _mutex.protect(() async {
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

      var transactions = assetTransactions.values.toList();

      if (fromId != null) {
        final startIndex =
            transactions.indexWhere((t) => t.internalId == fromId);
        if (startIndex == -1) {
          throw TransactionStorageException('Starting transaction not found');
        }
        transactions = transactions.sublist(startIndex + 1);
      } else if (pageNumber != null && pageNumber > 1) {
        final startIndex = (pageNumber - 1) * limit;
        if (startIndex >= transactions.length) {
          transactions = [];
        } else {
          transactions = transactions.sublist(startIndex);
        }
      }

      final page = transactions.take(limit).toList();
      final totalPages = (total / limit).ceil();

      return TransactionPage(
        transactions: page,
        total: total,
        nextPageId: page.lastOrNull?.internalId,
        currentPage: pageNumber ?? 1,
        totalPages: totalPages,
      );
    });
  }

  @override
  Future<Transaction?> getTransactionById(String internalId) async {
    return _mutex.protect(() async {
      for (final assetTransactions in _storage.values) {
        if (assetTransactions.containsKey(internalId)) {
          return assetTransactions[internalId];
        }
      }
      return null;
    });
  }

  @override
  Future<void> clearTransactions(AssetId assetId) async {
    await _mutex.protect(() async {
      _storage.remove(assetId);
    });
  }

  @override
  Future<String?> getLatestTransactionId(AssetId assetId) async {
    return _mutex.protect(() async {
      final transactions = _storage[assetId]?.values;
      if (transactions == null || transactions.isEmpty) return null;
      return transactions.first.internalId;
    });
  }

  Future<void> _enforceStorageLimit(AssetId assetId) async {
    if (_maxTransactionsPerAsset == null) return;

    await _mutex.protect(() async {
      final assetTransactions = _storage[assetId];
      if (assetTransactions == null) return;

      if (assetTransactions.length > _maxTransactionsPerAsset!) {
        final excess = assetTransactions.length - _maxTransactionsPerAsset!;
        final sortedEntries = assetTransactions.entries.toList()
          ..sort((a, b) {
            final timestampComparison =
                a.value.timestamp.compareTo(b.value.timestamp);
            return timestampComparison != 0
                ? timestampComparison
                : a.value.internalId.compareTo(b.value.internalId);
          });

        final keysToRemove =
            sortedEntries.take(excess).map((e) => e.key).toList();

        for (final key in keysToRemove) {
          assetTransactions.remove(key);
        }
      }
    });
  }

  @override
  Future<StorageStats> getStats() async {
    return _mutex.protect(() async {
      final allTransactions = _storage.values
          .expand((assetTransactions) => assetTransactions.values)
          .toList();

      if (allTransactions.isEmpty) {
        throw TransactionStorageException('No transactions available');
      }

      final totalTransactions = allTransactions.length;

      final transactionsPerAsset = _storage.map(
        (assetId, assetTransactions) =>
            MapEntry(assetId, assetTransactions.length),
      );

      final oldestTransaction = allTransactions
          .map((tx) => tx.timestamp)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final newestTransaction = allTransactions
          .map((tx) => tx.timestamp)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      return StorageStats(
        totalTransactions: totalTransactions,
        transactionsPerAsset: transactionsPerAsset,
        oldestTransaction: oldestTransaction,
        newestTransaction: newestTransaction,
      );
    });
  }
}

class TransactionStorageException implements Exception {
  TransactionStorageException(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'TransactionStorageException: $message${cause != null ? ' ($cause)' : ''}';
}

class StorageStats {
  StorageStats({
    required this.totalTransactions,
    required this.transactionsPerAsset,
    required this.oldestTransaction,
    required this.newestTransaction,
  });

  final int totalTransactions;
  final Map<AssetId, int> transactionsPerAsset;
  final DateTime oldestTransaction;
  final DateTime newestTransaction;
}
