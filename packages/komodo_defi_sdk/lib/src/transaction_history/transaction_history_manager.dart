import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/streaming/event_streaming_manager.dart';
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
  TransactionHistoryManager(
    this._client,
    this._auth,
    this._assetProvider,
    this._activationCoordinator, {
    required PubkeyManager pubkeyManager,
    required EventStreamingManager eventStreamingManager,
    TransactionStorage? storage,
  }) : _storage = storage ?? TransactionStorage.defaultForPlatform(),
       _strategyFactory = TransactionHistoryStrategyFactory(
         pubkeyManager,
         _auth,
       ),
       _eventStreamingManager = eventStreamingManager {
    // Subscribe to auth changes directly in constructor
    _authSubscription = _auth.authStateChanges.listen((user) {
      if (user == null) {
        _stopAllStreaming();
      }
    });
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final IAssetProvider _assetProvider;
  final SharedActivationCoordinator _activationCoordinator;
  final TransactionStorage _storage;
  final EventStreamingManager _eventStreamingManager;

  final _streamControllers = <AssetId, StreamController<Transaction>>{};
  final _txHistorySubscriptions = <AssetId, StreamSubscription<dynamic>>{};
  final _syncInProgress = <AssetId>{};
  final _rateLimiter = _RateLimiter(const Duration(milliseconds: 500));

  static const _maxBatchSize = 50;

  bool _isDisposed = false;
  StreamSubscription<KdfUser?>? _authSubscription;

  final TransactionHistoryStrategyFactory _strategyFactory;

  void _stopAllStreaming() {
    if (_isDisposed) return;

    // Cancel all transaction history subscriptions
    for (final sub in _txHistorySubscriptions.values) {
      sub.cancel();
    }
    _txHistorySubscriptions.clear();

    // Close controllers in a separate iteration to avoid modification during iteration
    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      controller.close();
    }
  }

  @override
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
        await _getCurrentWalletId(),
        fromId: pagination is TransactionBasedPagination
            ? pagination.fromId
            : null,
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
      final strategy = _strategyFactory.forAsset(asset);

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
      throw Exception('Failed to fetch transaction history: $e');
    }
  }

  @override
  Stream<List<Transaction>> getTransactionsStreamed(Asset asset) async* {
    if (_isDisposed) {
      throw StateError('TransactionHistoryManager has been disposed');
    }

    // Verify asset exists before proceeding
    if (_assetProvider.fromId(asset.id) == null) {
      throw ArgumentError('Asset ${asset.id.name} not found');
    }

    await _ensureAssetActivated(asset);
    final strategy = _strategyFactory.forAsset(asset);

    // First try to get any cached transactions
    final localPage = await _storage.getTransactions(
      asset.id,
      await _getCurrentWalletId(),
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

        if (response.transactions.isEmpty) {
          hasMore = false;
          continue;
        }

        final transactions = response.transactions
            .map((tx) => tx.asTransaction(asset.id))
            .toList();

        await _batchStoreTransactions(transactions);
        yield transactions;

        fromId = response.fromId;

        if (response.transactions.length < _maxBatchSize || fromId == null) {
          hasMore = false;
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          hasMore = false;
        } else {
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

    final controller = _streamControllers.putIfAbsent(
      asset.id,
      () => StreamController<Transaction>.broadcast(
        onListen: () {
          // Start transaction history streaming only once per asset
          if (!_txHistorySubscriptions.containsKey(asset.id)) {
            _startStreaming(asset);
          }
        },
        onCancel: () async {
          if (!_streamControllers[asset.id]!.hasListener) {
            _stopStreaming(asset.id);
            await _streamControllers[asset.id]?.close();
            _streamControllers.remove(asset.id);
          }
        },
      ),
    );

    return controller.stream;
  }

  @override
  Future<void> syncTransactionHistory(Asset asset) async {
    if (_isDisposed || _syncInProgress.contains(asset.id)) return;
    _syncInProgress.add(asset.id);

    try {
      final strategy = _strategyFactory.forAsset(asset);
      var fromId = await _storage.getLatestTransactionId(
        asset.id,
        await _getCurrentWalletId(),
      );
      var hasMore = true;

      while (hasMore && !_isDisposed) {
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

        if (response.transactions.isEmpty) {
          hasMore = false;
          continue;
        }

        final transactions = response.transactions
            .map((tx) => tx.asTransaction(asset.id))
            .toList();

        await _batchStoreTransactions(transactions);
        fromId = response.fromId;

        if (response.transactions.length < _maxBatchSize) {
          hasMore = false;
        }
      }
    } finally {
      _syncInProgress.remove(asset.id);
    }
  }

  @override
  Future<void> clearTransactionHistory(Asset asset) async {
    if (_isDisposed) return;

    await _storage.clearTransactions(asset.id, await _getCurrentWalletId());
    _stopStreaming(asset.id);
    await _streamControllers[asset.id]?.close();
    _streamControllers.remove(asset.id);
  }

  Future<void> _ensureAssetActivated(Asset asset) async {
    final activationResult = await _activationCoordinator.activateAsset(asset);
    if (activationResult.isFailure) {
      throw StateError(
        'Failed to activate asset ${asset.id.name}. ${activationResult.errorMessage}',
      );
    }
  }

  Future<WalletId> _getCurrentWalletId() async {
    final currentUser = await _auth.currentUser;
    if (currentUser == null) {
      throw StateError('User is not logged in');
    }
    return currentUser.walletId;
  }

  Future<void> _batchStoreTransactions(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    try {
      await _storage.storeTransactions(
        transactions,
        await _getCurrentWalletId(),
      );
    } catch (e) {
      throw Exception('Failed to store transactions batch: $e');
    }
  }

  Future<void> _startStreaming(Asset asset) async {
    // Ensure we don't duplicate subscriptions
    _stopStreaming(asset.id);

    // Ensure asset is activated before subscribing
    try {
      await _ensureAssetActivated(asset);
    } catch (e) {
      final controller = _streamControllers[asset.id];
      if (controller != null && !controller.isClosed) {
        controller.addError(e);
      }
      return;
    }

    // Subscribe to transaction history event stream for real-time updates
    try {
      final txHistoryStreamSubscription = await _eventStreamingManager
          .subscribeToTxHistory(coin: asset.id.name);

      // Check again to avoid race condition: only store if not already present
      if (_txHistorySubscriptions.containsKey(asset.id)) {
        await txHistoryStreamSubscription.cancel();
        return;
      }

      _txHistorySubscriptions[asset.id] = txHistoryStreamSubscription
        ..onData((txHistoryEvent) async {
          if (_isDisposed) return;

          // Verify the event is for the correct coin
          if (txHistoryEvent.coin != asset.id.name) return;

          // Process new transactions
          final transactions = txHistoryEvent.transactions
              .map((tx) => tx.asTransaction(asset.id))
              .toList();

          if (transactions.isEmpty) return;

          // Store transactions in local storage
          await _batchStoreTransactions(transactions);

          // Emit each transaction to listeners
          final controller = _streamControllers[asset.id];
          if (controller != null && !controller.isClosed) {
            for (final tx in transactions) {
              controller.add(tx);
            }
          }
        })
        ..onError((Object error) {
          final controller = _streamControllers[asset.id];
          if (controller != null && !controller.isClosed) {
            controller.addError(error);
          }
        })
        ..onDone(() {
          _stopStreaming(asset.id);
        });
    } catch (e) {
      final controller = _streamControllers[asset.id];
      if (controller != null && !controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  void _stopStreaming(AssetId assetId) {
    // Cancel transaction history subscription
    _txHistorySubscriptions[assetId]?.cancel();
    _txHistorySubscriptions.remove(assetId);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _authSubscription?.cancel();

    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      await controller.close();
    }

    _syncInProgress.clear();
  }
}

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
