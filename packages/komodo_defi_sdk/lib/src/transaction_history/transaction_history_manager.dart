import 'dart:async';
import 'dart:math' as math;

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
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
  TransactionHistoryManager(
    this._client,
    this._auth,
  ) : _storage = TransactionStorage.defaultForPlatform() {
    _initializeStreamController();
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final TransactionStorage _storage;
  final _streamControllers = <AssetId, StreamController<Transaction>>{};
  final _pollingTimers = <AssetId, Timer>{};
  final _syncInProgress = <AssetId>{};

  static const _defaultPollingInterval = Duration(seconds: 30);
  static const _maxPollingRetries = 3;
  static const _maxBatchSize = 50;

  void _initializeStreamController() {
    unawaited(() async {
      await for (final user in _auth.authStateChanges) {
        if (user == null) {
          _stopAllPolling();
        }
      }
    }());
  }

  void _stopAllPolling() {
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }

  @override
  Future<TransactionPage> getTransactionHistory(
    Asset asset, {
    TransactionPagination? pagination,
  }) async {
    // Default to first page if no pagination specified
    pagination ??= const PagePagination(pageNumber: 1, itemsPerPage: 10);

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

    // Fetch from API using the appropriate strategy
    final response = await strategy.fetchTransactionHistory(
      _client,
      asset,
      pagination,
    );

    // Convert API response to domain model
    final transactions =
        response.transactions.map((tx) => tx.asTransaction(asset.id)).toList();

    // Store in local storage
    await _storage.storeTransactions(transactions);

    return TransactionPage(
      transactions: transactions,
      total: response.total,
      nextPageId: response.fromId,
      currentPage: response.pageNumber ?? 1,
      totalPages: response.totalPages,
    );
  }

  @override
  Stream<List<Transaction>> getTransactionsStreamed(Asset asset) {
    final controller = StreamController<List<Transaction>>();

    void addTransactions(List<Transaction> transactions) {
      if (!controller.isClosed) {
        controller.add(transactions);
      }
    }

    void close() {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    _getTransactionsStreamed(asset, addTransactions, close);

    return controller.stream;
  }

  void _getTransactionsStreamed(
    Asset asset,
    void Function(List<Transaction>) addTransactions,
    void Function() close,
  ) {
    final strategy = TransactionHistoryStrategyFactory.forAsset(asset);

    void handleResponse(MyTxHistoryResponse response) {
      final transactions = response.transactions
          .map((tx) => tx.asTransaction(asset.id))
          .toList();

      addTransactions(transactions);

      if (response.fromId != null) {
        strategy
            .fetchTransactionHistory(
              _client,
              asset,
              TransactionBasedPagination(
                fromId: response.fromId!,
                itemCount: _maxBatchSize,
              ),
            )
            .then(handleResponse);
      } else {
        close();
      }

      _storage
          .storeTransactions(transactions)
          .catchError((e) => print('Error storing transactions: $e'));
    }

    strategy
        .fetchTransactionHistory(
          _client,
          asset,
          const PagePagination(pageNumber: 1, itemsPerPage: _maxBatchSize),
        )
        .then(handleResponse)
        .catchError((e) {
      print('Error fetching transactions: $e');
      close();
    });
  }

  @override
  Stream<Transaction> watchTransactions(Asset asset) {
    if (!_streamControllers.containsKey(asset.id)) {
      _streamControllers[asset.id] = StreamController<Transaction>.broadcast(
        onListen: () => _startPolling(asset),
        onCancel: () => _stopPolling(asset.id),
      );
    }
    return _streamControllers[asset.id]!.stream;
  }

  void _startPolling(Asset asset) {
    _stopPolling(asset.id);

    _pollingTimers[asset.id] = Timer.periodic(
      _defaultPollingInterval,
      (_) => _pollNewTransactions(asset),
    );
  }

  Future<void> _pollNewTransactions(
    Asset asset, [
    int retryCount = 0,
  ]) async {
    if (_syncInProgress.contains(asset.id)) return;

    try {
      final strategy = TransactionHistoryStrategyFactory.forAsset(asset);
      final lastTx = await _storage.getLatestTransactionId(asset.id);

      final response = await strategy.fetchTransactionHistory(
        _client,
        asset,
        lastTx != null
            ? TransactionBasedPagination(
                fromId: lastTx,
                itemCount: _maxBatchSize,
              )
            : const PagePagination(pageNumber: 1, itemsPerPage: _maxBatchSize),
      );

      if (response.transactions.isNotEmpty) {
        final newTransactions = response.transactions
            .map((tx) => tx.asTransaction(asset.id))
            .toList();

        await _storage.storeTransactions(newTransactions);

        final controller = _streamControllers[asset.id];
        if (controller != null && !controller.isClosed) {
          for (final tx in newTransactions) {
            controller.add(tx);
          }
        }
      }
    } catch (e) {
      if (retryCount < _maxPollingRetries) {
        await Future.delayed(
          Duration(seconds: math.pow(2, retryCount).toInt()),
          () => _pollNewTransactions(asset, retryCount + 1),
        );
      }
    }
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
    } catch (e) {
      throw Exception(
        'Failed to fetch transactions for asset ${asset.id.name} '
        'because the asset could not be activated',
      );
    }
  }

  @override
  Future<void> syncTransactionHistory(Asset asset) async {
    if (_syncInProgress.contains(asset.id)) return;
    _syncInProgress.add(asset.id);

    try {
      final strategy = TransactionHistoryStrategyFactory.forAsset(asset);
      var fromId = await _storage.getLatestTransactionId(asset.id);

      while (true) {
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

        await _storage.storeTransactions(transactions);
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
    await _storage.clearTransactions(asset.id);
    _stopPolling(asset.id);
    await _streamControllers[asset.id]?.close();
    _streamControllers.remove(asset.id);
  }

  void dispose() {
    for (final assetId in _pollingTimers.keys.toList()) {
      _stopPolling(assetId);
    }

    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    _syncInProgress.clear();
  }
}
