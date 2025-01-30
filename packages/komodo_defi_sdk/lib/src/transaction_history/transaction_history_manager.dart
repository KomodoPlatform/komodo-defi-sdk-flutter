import 'dart:async';
import 'dart:math' as math;

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/transaction_history/transaction_history_strategies.dart';
import 'package:komodo_defi_sdk/src/transaction_history/transaction_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Core interface for transaction history manager
abstract interface class _TransactionHistoryManager {
  /// Get transaction history with pagination support
  Future<TransactionPage> getTransactionHistory(
    Asset asset, {
    TransactionPagination? pagination,
  });

  /// Stream of new transactions for an asset
  Stream<Transaction> watchTransactions(Asset asset);

  /// Sync transaction history for an asset
  Future<void> syncTransactionHistory(Asset asset);

  /// Clear transaction history for an asset
  Future<void> clearTransactionHistory(Asset asset);

  /// Similar to [getTransactionHistory] but returns a stream of transactions
  /// with the initial batch from storage and the latest transactions from
  /// the API. The stream will close when the latest transaction is reached.
  Stream<List<Transaction>> getTransactionsStreamed(Asset asset);
}

class TransactionHistoryManager implements _TransactionHistoryManager {
  TransactionHistoryManager._(
    this._client,
    this._auth,
    this._storage,
  ) {
    _initializeStreamController();
  }
  static Future<TransactionHistoryManager> create(
    ApiClient client,
    KomodoDefiLocalAuth auth,
  ) async {
    final storage = await InMemoryTransactionStorage.create();
    return TransactionHistoryManager._(client, auth, storage);
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final TransactionStorage _storage;
  final _streamControllers = <AssetId, StreamController<Transaction>>{};
  final _pollingTimers = <AssetId, Timer>{};
  final _syncInProgress = <AssetId>{};
  final _rateLimiter = _RateLimiter(const Duration(milliseconds: 500));

  static const _defaultPollingInterval = Duration(seconds: 30);
  static const _maxPollingRetries = 3;
  static const _maxBatchSize = 50;

  bool _isDisposed = false;
  StreamSubscription<KdfUser?>? _authSubscription;

  void _initializeStreamController() {
    _authSubscription = _auth.authStateChanges.listen((user) {
      if (user == null) {
        _stopAllPolling();
      }
    });
  }

  void _stopAllPolling() {
    if (_isDisposed) return;

    // Cancel all polling timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    // Close controllers in a separate iteration to avoid modification during iteration
    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      controller.close();
    }
  }

  @override

  ///!NB! Prefer stream-based transaction fetching even for once-off fetches.
  Future<TransactionPage> getTransactionHistory(
    Asset asset, {
    TransactionPagination? pagination,
  }) async {
    try {
      if (_isDisposed) {
        throw StateError('TransactionHistoryManager has been disposed');
      }

      // Default to first page if no pagination specified
      pagination ??= const PagePagination(
        pageNumber: 1,
        itemsPerPage: _maxBatchSize,
      );

      // First try to get from local storage
      final localPage = await _storage.getTransactions(
        asset.id,
        fromId:
            pagination is TransactionBasedPagination ? pagination.fromId : null,
        pageNumber: pagination is PagePagination ? pagination.pageNumber : null,
        limit: pagination.limit ?? _maxBatchSize,
      );

      // If we have enough local data and it's not a first page request, return it
      if (localPage.transactions.isNotEmpty &&
          (pagination is PagePagination && pagination.pageNumber > 1 ||
              pagination is TransactionBasedPagination)) {
        return localPage;
      }

      await _ensureAssetActivated(asset);

      // Get appropriate strategy for the asset
      final strategy = TransactionHistoryStrategyFactory.forAsset(asset);

      // Apply rate limiting
      await _rateLimiter.throttle();

      // Fetch from API using the appropriate strategy
      final response = await strategy.fetchTransactionHistory(
        _client,
        asset,
        pagination,
      );

      // Convert API response to domain model
      final transactions = response.transactions
          .map((tx) => tx.asTransaction(asset.id))
          .toList();

      // Store in local storage efficiently
      await _batchStoreTransactions(transactions);

      return TransactionPage(
        transactions: transactions,
        total: response.total,
        nextPageId: response.fromId,
        currentPage: response.pageNumber ?? 1,
        totalPages: response.totalPages,
      );
    } catch (e) {
      if (e is TransactionStorageException) {
        // Propagate storage-specific errors
        rethrow;
      }
      throw Exception(
        'Failed to fetch transaction history: ${e is Error ? e : e.toString()}',
      );
    }
  }

  @override
  Stream<List<Transaction>> getTransactionsStreamed(Asset asset) async* {
    if (_isDisposed) {
      throw StateError('TransactionHistoryManager has been disposed');
    }

    await _ensureAssetActivated(asset);
    final strategy = TransactionHistoryStrategyFactory.forAsset(asset);

    // First try to get any cached transactions
    final localPage = await _storage.getTransactions(
      asset.id,
      limit: _maxBatchSize,
    );

    if (localPage.transactions.isNotEmpty) {
      yield localPage.transactions;
    }

    String? fromId;
    var hasMore = true;
    var retryCount = 0;
    const maxRetries = 3;

    while (hasMore && !_isDisposed) {
      try {
        final response = await strategy.fetchTransactionHistory(
          _client,
          asset,
          fromId != null
              ? TransactionBasedPagination(
                  fromId: fromId,
                  itemCount: _maxBatchSize,
                )
              : const PagePagination(
                  pageNumber: 1,
                  itemsPerPage: _maxBatchSize,
                ),
        );

        // Reset retry count on successful fetch
        retryCount = 0;

        if (response.transactions.isEmpty) {
          hasMore = false;
          continue;
        }

        final transactions = response.transactions
            .map((tx) => tx.asTransaction(asset.id))
            .toList();

        await _batchStoreTransactions(transactions);
        yield transactions;

        // Update fromId for next batch
        fromId = response.fromId;

        // If we got less than requested or no fromId, we're done
        if (response.transactions.length < _maxBatchSize || fromId == null) {
          hasMore = false;
        } else {
          // Only throttle between successful batches
          // Use a shorter delay for streaming compared to regular requests
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
      } catch (e, stack) {
        print('Error fetching transactions: $e\n$stack');
        retryCount++;

        if (retryCount >= maxRetries) {
          hasMore = false;
        } else {
          // Exponential backoff for retries
          await Future<void>.delayed(
            Duration(milliseconds: 500 * (1 << retryCount)),
          );
        }
      }
    }
  }

  @override
  Stream<Transaction> watchTransactions(Asset asset) {
    if (_isDisposed) {
      throw StateError('TransactionHistoryManager has been disposed');
    }

    // Get or create controller for this asset
    final controller = _streamControllers.putIfAbsent(
      asset.id,
      () => StreamController<Transaction>.broadcast(
        onListen: () {
          // Only start polling if there isn't already an active timer
          if (!_pollingTimers.containsKey(asset.id)) {
            _startPolling(asset);
          }
        },
        onCancel: () async {
          // Only stop polling if there are no more listeners
          if (!_streamControllers[asset.id]!.hasListener) {
            _stopPolling(asset.id);

            // Clean up the controller if it's no longer needed
            await _streamControllers[asset.id]?.close();
            _streamControllers.remove(asset.id);
          }
        },
      ),
    );

    return controller.stream;
  }

  Future<void> _pollNewTransactions(Asset asset, [int retryCount = 0]) async {
    if (_isDisposed || _syncInProgress.contains(asset.id)) return;

    try {
      final strategy = TransactionHistoryStrategyFactory.forAsset(asset);
      final lastTx = await _storage.getLatestTransactionId(asset.id);

      // Rate limit check moved here, specific to polling
      await _rateLimiter.throttle();

      final response = await strategy.fetchTransactionHistory(
        _client,
        asset,
        lastTx != null
            ? TransactionBasedPagination(
                fromId: lastTx,
                itemCount: _maxBatchSize,
              )
            : const PagePagination(
                pageNumber: 1,
                itemsPerPage: _maxBatchSize,
              ),
      );

      if (!_pollingTimers.containsKey(asset.id)) return;

      if (response.transactions.isNotEmpty) {
        final newTransactions = response.transactions
            .map((tx) => tx.asTransaction(asset.id))
            .toList();

        await _batchStoreTransactions(newTransactions);

        final controller = _streamControllers[asset.id];
        if (controller != null && !controller.isClosed) {
          for (final tx in newTransactions) {
            controller.add(tx);
          }
        }
      }
    } catch (e, stack) {
      if (retryCount < _maxPollingRetries) {
        final delay = Duration(seconds: math.pow(2, retryCount).toInt());
        await Future.delayed(
          delay,
          () => _pollNewTransactions(asset, retryCount + 1),
        );
      } else {
        print(
          'Failed to poll transactions for ${asset.id} after $retryCount retries: $e\n$stack',
        );
      }
    }
  }

  void _startPolling(Asset asset) {
    // Always ensure we clean up any existing timer first
    _stopPolling(asset.id);

    _pollingTimers[asset.id] = Timer.periodic(
      _defaultPollingInterval,
      (_) => _pollNewTransactions(asset),
    );

    // Trigger immediate first poll
    _pollNewTransactions(asset);
  }

  void _stopPolling(AssetId assetId) {
    _pollingTimers[assetId]?.cancel();
    _pollingTimers.remove(assetId);
  }

  Future<void> _ensureAssetActivated(Asset asset) async {
    try {
      final finalStatus =
          await KomodoDefiSdk.global.assets.activateAsset(asset).last;

      if (finalStatus.isComplete && !finalStatus.isSuccess) {
        throw StateError(
          'Failed to activate asset ${asset.id.name}. ${finalStatus.toJson()}',
        );
      }
    } catch (e, stack) {
      throw Exception(
        'Failed to fetch transactions for asset ${asset.id.name} '
        'because the asset could not be activated: $e\n$stack',
      );
    }
  }

  Future<void> _batchStoreTransactions(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    try {
      // Store all transactions in a single operation
      await _storage.storeTransactions(transactions);
    } catch (e) {
      throw Exception(
        'Failed to store transactions batch: ${e is Error ? e : e.toString()}',
      );
    }
  }

  @override
  Future<void> syncTransactionHistory(Asset asset) async {
    if (_isDisposed || _syncInProgress.contains(asset.id)) return;
    _syncInProgress.add(asset.id);

    try {
      final strategy = TransactionHistoryStrategyFactory.forAsset(asset);
      var fromId = await _storage.getLatestTransactionId(asset.id);

      while (true) {
        if (_isDisposed) break;

        await _rateLimiter.throttle();

        final response = await strategy.fetchTransactionHistory(
          _client,
          asset,
          fromId != null
              ? TransactionBasedPagination(
                  fromId: fromId,
                  itemCount: _maxBatchSize,
                )
              : const PagePagination(
                  pageNumber: 1,
                  itemsPerPage: _maxBatchSize,
                ),
        );

        if (response.transactions.isEmpty) break;

        final transactions = response.transactions
            .map((tx) => tx.asTransaction(asset.id))
            .toList();

        await _batchStoreTransactions(transactions);
        fromId = transactions.last.internalId;

        // Break if we've reached the end
        if (response.transactions.length < _maxBatchSize) break;
      }
    } finally {
      _syncInProgress.remove(asset.id);
    }
  }

  @override
  Future<void> clearTransactionHistory(Asset asset) async {
    if (_isDisposed) return;

    await _storage.clearTransactions(asset.id);
    _stopPolling(asset.id);
    await _streamControllers[asset.id]?.close();
    _streamControllers.remove(asset.id);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _authSubscription?.cancel();

    // Wait for any pending storage operations
    try {
      final stats = await _storage.getStats();
      print('Final storage stats: $stats');
    } catch (e) {
      // Ignore stats error during disposal
    }

    final timers = _pollingTimers.values.toList();
    _pollingTimers.clear();
    for (final timer in timers) {
      timer.cancel();
    }

    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      controller.close();
    }

    _syncInProgress.clear();
  }
}

/// Helper class for rate limiting API requests
class _RateLimiter {
  _RateLimiter(this.interval);
  final Duration interval;
  DateTime? _lastCall;

  Future<void> throttle() async {
    if (_lastCall != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastCall!);
      if (timeSinceLastCall < interval) {
        await Future<void>.delayed(interval - timeSinceLastCall);
      }
    }
    _lastCall = DateTime.now();
  }
}
