import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    as rpc
    show SwapStatus;
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Core interface for swap history manager
abstract interface class _SwapHistoryManager {
  /// Get swap history with pagination support and optional filters
  Future<SwapHistoryPage> getSwapHistory({
    SwapHistoryPagination? pagination,
    AssetId? myCoin,
    AssetId? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  });

  /// Stream of new swaps
  Stream<rpc.SwapStatus> watchSwaps({AssetId? myCoin, AssetId? otherCoin});

  /// Sync swap history
  Future<void> syncSwapHistory();

  /// Clear swap history cache
  Future<void> clearSwapHistory();

  /// Stream all swaps with initial batch and continuous updates
  Stream<List<rpc.SwapStatus>> getSwapsStreamed({
    AssetId? myCoin,
    AssetId? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  });

  /// Get currently active swaps
  Future<List<String>> getActiveSwaps({bool includeStatus = false});

  /// Watch active swaps for changes
  Stream<List<String>> watchActiveSwaps();
}

/// Manages swap history with fetching, streaming, and watching capabilities
class SwapHistoryManager implements _SwapHistoryManager {
  /// Creates a new swap history manager instance
  SwapHistoryManager(
    this._client,
    this._auth,
    this._activationManager,
    this._assetLookup, {
    SwapHistoryStorage? storage,
  }) : _storage = storage ?? SwapHistoryStorage.defaultForPlatform(),
       _strategyFactory = SwapHistoryStrategyFactory() {
    // Subscribe to auth changes directly in constructor
    _authSubscription = _auth.authStateChanges.listen((user) {
      if (user == null) {
        _stopAllPolling();
      }
    });
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final ActivationManager _activationManager;
  final IAssetLookup _assetLookup;
  final SwapHistoryStorage _storage;

  final _streamControllers = <String, StreamController<rpc.SwapStatus>>{};
  final _activeSwapControllers = <StreamController<List<String>>>{};
  final _pollingTimers = <String, Timer>{};
  final _activeSwapTimer = <Timer>{};
  final _syncInProgress = <String>{};

  /// Rate limiter to prevent API spamming
  final _rateLimiter = _RateLimiter(const Duration(milliseconds: 500));

  static const _defaultPollingInterval = Duration(seconds: 30);
  static const _maxPollingRetries = 3;
  static const _maxBatchSize = 50;

  bool _isDisposed = false;
  StreamSubscription<KdfUser?>? _authSubscription;

  final SwapHistoryStrategyFactory _strategyFactory;

  void _stopAllPolling() {
    if (_isDisposed) return;

    // Cancel all polling timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    for (final timer in _activeSwapTimer) {
      timer.cancel();
    }
    _activeSwapTimer.clear();

    // Close controllers in a separate iteration to avoid modification during iteration
    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      controller.close();
    }

    final activeControllers = _activeSwapControllers.toList();
    _activeSwapControllers.clear();
    for (final controller in activeControllers) {
      controller.close();
    }
  }

  @override
  Future<SwapHistoryPage> getSwapHistory({
    SwapHistoryPagination? pagination,
    AssetId? myCoin,
    AssetId? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  }) async {
    try {
      if (_isDisposed) {
        throw StateError('SwapHistoryManager has been disposed');
      }

      await _ensureAssetsActivated(myCoin: myCoin, otherCoin: otherCoin);

      // Default to first page if no pagination specified
      pagination ??= const PageBasedSwapPagination(
        pageNumber: 1,
        itemsPerPage: _maxBatchSize,
      );

      // First try to get from local storage
      final localPage = await _storage.getSwaps(
        await _getCurrentWalletId(),
        myCoin: myCoin?.id,
        otherCoin: otherCoin?.id,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        fromUuid:
            pagination is UuidBasedSwapPagination ? pagination.fromUuid : null,
        pageNumber:
            pagination is PageBasedSwapPagination
                ? pagination.pageNumber
                : null,
        limit: pagination.limit ?? _maxBatchSize,
      );

      // If we have enough local data and it's not a first page request, return it
      if (localPage.swaps.isNotEmpty &&
          (pagination is PageBasedSwapPagination && pagination.pageNumber > 1 ||
              pagination is UuidBasedSwapPagination)) {
        return localPage;
      }

      // Get appropriate strategy for general swap history
      final strategy = _strategyFactory.general;

      await _rateLimiter.throttle();

      // Fetch from API using the appropriate strategy
      final response = await strategy.fetchSwapHistory(
        _client,
        pagination,
        myCoin: myCoin?.id,
        otherCoin: otherCoin?.id,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
      );

      // Store in local storage efficiently
      await _batchStoreSwaps(response.swaps);

      return SwapHistoryPage(
        swaps: response.swaps,
        total: response.total,
        nextFromUuid: response.fromUuid,
        currentPage: response.pageNumber ?? 1,
        totalPages: response.totalPages,
        foundRecords: response.foundRecords,
      );
    } catch (e) {
      if (e is SwapHistoryStorageException) {
        // Propagate storage-specific errors
        rethrow;
      }
      throw Exception('Failed to fetch swap history: $e');
    }
  }

  @override
  Stream<List<rpc.SwapStatus>> getSwapsStreamed({
    AssetId? myCoin,
    AssetId? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  }) async* {
    if (_isDisposed) {
      throw StateError('SwapHistoryManager has been disposed');
    }

    await _ensureAssetsActivated(myCoin: myCoin, otherCoin: otherCoin);

    final strategy = _strategyFactory.general;

    // First try to get any cached swaps
    final localPage = await _storage.getSwaps(
      await _getCurrentWalletId(),
      myCoin: myCoin?.id,
      otherCoin: otherCoin?.id,
      fromTimestamp: fromTimestamp,
      toTimestamp: toTimestamp,
      limit: _maxBatchSize,
    );

    if (localPage.swaps.isNotEmpty) {
      yield localPage.swaps;
    }

    String? fromUuid;
    var hasMore = true;
    var retryCount = 0;
    const maxRetries = 3;

    while (hasMore && !_isDisposed) {
      try {
        final response = await strategy.fetchSwapHistory(
          _client,
          fromUuid != null
              ? UuidBasedSwapPagination(
                fromUuid: fromUuid,
                itemCount: _maxBatchSize,
              )
              : const PageBasedSwapPagination(
                pageNumber: 1,
                itemsPerPage: _maxBatchSize,
              ),
          myCoin: myCoin?.id,
          otherCoin: otherCoin?.id,
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
        );

        if (response.swaps.isEmpty) {
          hasMore = false;
          continue;
        }

        await _batchStoreSwaps(response.swaps);
        yield response.swaps;

        fromUuid = response.fromUuid;

        if (response.swaps.length < _maxBatchSize || fromUuid == null) {
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
  Stream<rpc.SwapStatus> watchSwaps({AssetId? myCoin, AssetId? otherCoin}) {
    if (_isDisposed) {
      throw StateError('SwapHistoryManager has been disposed');
    }

    final key = _generateWatchKey(myCoin?.id, otherCoin?.id);
    final controller = _streamControllers.putIfAbsent(
      key,
      () => StreamController<rpc.SwapStatus>.broadcast(
        onListen: () async {
          if (!_pollingTimers.containsKey(key)) {
            await _ensureAssetsActivated(myCoin: myCoin, otherCoin: otherCoin);
            _startPolling(key, myCoin: myCoin?.id, otherCoin: otherCoin?.id);
          }
        },
        onCancel: () async {
          if (!_streamControllers[key]!.hasListener) {
            _stopPolling(key);
            await _streamControllers[key]?.close();
            _streamControllers.remove(key);
          }
        },
      ),
    );

    return controller.stream;
  }

  @override
  Future<void> syncSwapHistory() async {
    if (_isDisposed || _syncInProgress.contains('general')) return;
    _syncInProgress.add('general');

    try {
      final strategy = _strategyFactory.general;
      var fromUuid = await _storage.getLatestSwapUuid(
        await _getCurrentWalletId(),
      );
      var hasMore = true;

      while (hasMore && !_isDisposed) {
        await _rateLimiter.throttle();

        final response = await strategy.fetchSwapHistory(
          _client,
          fromUuid != null
              ? UuidBasedSwapPagination(
                fromUuid: fromUuid,
                itemCount: _maxBatchSize,
              )
              : const PageBasedSwapPagination(
                pageNumber: 1,
                itemsPerPage: _maxBatchSize,
              ),
        );

        if (response.swaps.isEmpty) {
          hasMore = false;
          continue;
        }

        await _batchStoreSwaps(response.swaps);
        fromUuid = response.fromUuid;

        if (response.swaps.length < _maxBatchSize) {
          hasMore = false;
        }
      }
    } finally {
      _syncInProgress.remove('general');
    }
  }

  @override
  Future<void> clearSwapHistory() async {
    if (_isDisposed) return;

    await _storage.clearSwaps(await _getCurrentWalletId());
    _stopAllPolling();
  }

  @override
  Future<List<String>> getActiveSwaps({bool includeStatus = false}) async {
    if (_isDisposed) {
      throw StateError('SwapHistoryManager has been disposed');
    }

    await _rateLimiter.throttle();

    final response = await _client.rpc.swap.activeSwaps(
      includeStatus: includeStatus,
    );

    return response.uuids;
  }

  @override
  Stream<List<String>> watchActiveSwaps() {
    if (_isDisposed) {
      throw StateError('SwapHistoryManager has been disposed');
    }

    final controller = StreamController<List<String>>.broadcast(
      onListen: () {
        if (_activeSwapTimer.isEmpty) {
          _startActiveSwapPolling();
        }
      },
      onCancel: () async {
        if (_activeSwapControllers.every((c) => !c.hasListener)) {
          _stopActiveSwapPolling();
        }
      },
    );

    _activeSwapControllers.add(controller);
    return controller.stream;
  }

  Future<void> _pollNewSwaps(
    String key, {
    String? myCoin,
    String? otherCoin,
    int retryCount = 0,
  }) async {
    if (_isDisposed || _syncInProgress.contains(key)) return;

    try {
      final strategy = _strategyFactory.general;
      final lastSwapUuid = await _storage.getLatestSwapUuid(
        await _getCurrentWalletId(),
        myCoin: myCoin,
        otherCoin: otherCoin,
      );

      await _rateLimiter.throttle();

      final response = await strategy.fetchSwapHistory(
        _client,
        lastSwapUuid != null
            ? UuidBasedSwapPagination(
              fromUuid: lastSwapUuid,
              itemCount: _maxBatchSize,
            )
            : const PageBasedSwapPagination(
              pageNumber: 1,
              itemsPerPage: _maxBatchSize,
            ),
        myCoin: myCoin,
        otherCoin: otherCoin,
      );

      if (!_pollingTimers.containsKey(key)) return;

      if (response.swaps.isNotEmpty) {
        await _batchStoreSwaps(response.swaps);

        final controller = _streamControllers[key];
        if (controller != null && !controller.isClosed) {
          for (final swap in response.swaps) {
            controller.add(swap);
          }
        }
      }
    } catch (e) {
      if (retryCount < _maxPollingRetries) {
        final delay = Duration(seconds: math.pow(2, retryCount).toInt());
        await Future.delayed(
          delay,
          () => _pollNewSwaps(
            key,
            myCoin: myCoin,
            otherCoin: otherCoin,
            retryCount: retryCount + 1,
          ),
        );
      }
    }
  }

  Future<void> _pollActiveSwaps([int retryCount = 0]) async {
    if (_isDisposed) return;

    try {
      await _rateLimiter.throttle();

      final response = await _client.rpc.swap.activeSwaps();

      if (_activeSwapTimer.isEmpty) return;

      for (final controller in _activeSwapControllers) {
        if (!controller.isClosed) {
          controller.add(response.uuids);
        }
      }
    } catch (e) {
      if (retryCount < _maxPollingRetries) {
        final delay = Duration(seconds: math.pow(2, retryCount).toInt());
        await Future.delayed(delay, () => _pollActiveSwaps(retryCount + 1));
      }
    }
  }

  Future<WalletId> _getCurrentWalletId() async {
    final currentUser = await _auth.currentUser;
    if (currentUser == null) {
      throw StateError('User is not logged in');
    }
    return currentUser.walletId;
  }

  Future<void> _batchStoreSwaps(List<rpc.SwapStatus> swaps) async {
    if (swaps.isEmpty) return;

    try {
      await _storage.storeSwaps(swaps, await _getCurrentWalletId());
    } catch (e) {
      throw Exception('Failed to store swaps batch: $e');
    }
  }

  String _generateWatchKey(String? myCoin, String? otherCoin) {
    return '${myCoin ?? 'all'}-${otherCoin ?? 'all'}';
  }

  void _startPolling(String key, {String? myCoin, String? otherCoin}) {
    _stopPolling(key);
    _pollingTimers[key] = Timer.periodic(
      _defaultPollingInterval,
      (_) => _pollNewSwaps(key, myCoin: myCoin, otherCoin: otherCoin),
    );
    _pollNewSwaps(key, myCoin: myCoin, otherCoin: otherCoin);
  }

  void _stopPolling(String key) {
    _pollingTimers[key]?.cancel();
    _pollingTimers.remove(key);
  }

  void _startActiveSwapPolling() {
    _stopActiveSwapPolling();
    final timer = Timer.periodic(
      _defaultPollingInterval,
      (_) => _pollActiveSwaps(),
    );
    _activeSwapTimer.add(timer);
    _pollActiveSwaps();
  }

  void _stopActiveSwapPolling() {
    for (final timer in _activeSwapTimer) {
      timer.cancel();
    }
    _activeSwapTimer.clear();
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _authSubscription?.cancel();

    final timers = _pollingTimers.values.toList();
    _pollingTimers.clear();
    for (final timer in timers) {
      timer.cancel();
    }

    for (final timer in _activeSwapTimer) {
      timer.cancel();
    }
    _activeSwapTimer.clear();

    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      await controller.close();
    }

    final activeControllers = _activeSwapControllers.toList();
    _activeSwapControllers.clear();
    for (final controller in activeControllers) {
      await controller.close();
    }

    _syncInProgress.clear();
  }

  /// Activates assets if they are provided (not null)
  /// Similar pattern to PubkeyManager's asset activation
  Future<void> _ensureAssetsActivated({
    AssetId? myCoin,
    AssetId? otherCoin,
  }) async {
    final assetsToActivate = <Asset>[];

    // Resolve AssetIds to Assets and collect them
    if (myCoin != null) {
      final asset = _assetLookup.fromId(myCoin);
      if (asset != null) {
        assetsToActivate.add(asset);
      }
    }

    if (otherCoin != null) {
      final asset = _assetLookup.fromId(otherCoin);
      if (asset != null) {
        assetsToActivate.add(asset);
      }
    }

    // Activate all assets that need activation
    for (final asset in assetsToActivate) {
      await retry(
        () => _activationManager.activateAsset(asset).last,
        shouldRetry: (Object e) => e is! StateError,
      );
    }
  }
}

/// Rate limiter utility class for throttling API calls
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

/// Represents a page of swap history results
class SwapHistoryPage {
  /// Creates a new swap history page
  const SwapHistoryPage({
    required this.swaps,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.foundRecords,
    this.nextFromUuid,
  });

  /// The swaps in this page
  final List<rpc.SwapStatus> swaps;

  /// Total number of swaps available
  final int total;

  /// UUID to use for next page (if using UUID-based pagination)
  final String? nextFromUuid;

  /// Current page number
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Number of records found in this page
  final int foundRecords;
}

/// Storage interface for swap history
abstract class SwapHistoryStorage {
  /// Creates a default platform-specific implementation
  factory SwapHistoryStorage.defaultForPlatform() =>
      _DefaultSwapHistoryStorage();

  /// Retrieves swaps with optional filtering and pagination
  Future<SwapHistoryPage> getSwaps(
    WalletId walletId, {
    String? myCoin,
    String? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
    String? fromUuid,
    int? pageNumber,
    int? limit,
  });

  /// Stores swaps in the storage
  Future<void> storeSwaps(List<rpc.SwapStatus> swaps, WalletId walletId);

  /// Gets the latest swap UUID for pagination
  Future<String?> getLatestSwapUuid(
    WalletId walletId, {
    String? myCoin,
    String? otherCoin,
  });

  /// Clears all swaps for a wallet
  Future<void> clearSwaps(WalletId walletId);
}

/// Default implementation of swap history storage
class _DefaultSwapHistoryStorage implements SwapHistoryStorage {
  final Map<String, SplayTreeSet<rpc.SwapStatus>> _storage = {};

  @override
  Future<SwapHistoryPage> getSwaps(
    WalletId walletId, {
    String? myCoin,
    String? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
    String? fromUuid,
    int? pageNumber,
    int? limit,
  }) async {
    final key = '${walletId.name}-$myCoin-$otherCoin';
    final swapSet = _storage[key] ?? _createSwapSet();

    // Apply filters - convert to list for easier filtering
    final swapsList = swapSet.toList();
    final filteredSwaps =
        swapsList.where((rpc.SwapStatus swap) {
          final startedAt =
              swap.events.isNotEmpty ? swap.events.first.timestamp : null;
          if (fromTimestamp != null && startedAt != null) {
            if (startedAt < fromTimestamp) return false;
          }
          if (toTimestamp != null && startedAt != null) {
            if (startedAt > toTimestamp) return false;
          }
          return true;
        }).toList();

    // Apply pagination
    final startIndex = ((pageNumber ?? 1) - 1) * (limit ?? 50);
    final pageSwaps = filteredSwaps.skip(startIndex).take(limit ?? 50).toList();

    return SwapHistoryPage(
      swaps: pageSwaps,
      total: filteredSwaps.length,
      currentPage: pageNumber ?? 1,
      totalPages: ((filteredSwaps.length - 1) ~/ (limit ?? 50)) + 1,
      foundRecords: pageSwaps.length,
    );
  }

  @override
  Future<void> storeSwaps(List<rpc.SwapStatus> swaps, WalletId walletId) async {
    for (final swap in swaps) {
      final myCoin =
          swap.makerCoin; // This might need adjustment based on rpc.SwapStatus structure
      final otherCoin = swap.takerCoin;
      final key = '${walletId.name}-$myCoin-$otherCoin';

      _storage.putIfAbsent(key, _createSwapSet);

      // Add to the sorted set - duplicates are automatically handled
      _storage[key]!.add(swap);
    }
  }

  @override
  Future<String?> getLatestSwapUuid(
    WalletId walletId, {
    String? myCoin,
    String? otherCoin,
  }) async {
    final key = '${walletId.name}-$myCoin-$otherCoin';
    final swaps = _storage[key] ?? _createSwapSet();
    return swaps.isNotEmpty ? swaps.first.uuid : null;
  }

  /// Creates a new SplayTreeSet with the appropriate comparator for swaps
  SplayTreeSet<rpc.SwapStatus> _createSwapSet() {
    return SplayTreeSet<rpc.SwapStatus>((rpc.SwapStatus a, rpc.SwapStatus b) {
      // First compare by timestamp (most recent first)
      final aTime = a.events.isNotEmpty ? a.events.first.timestamp : 0;
      final bTime = b.events.isNotEmpty ? b.events.first.timestamp : 0;
      final timeComparison = bTime.compareTo(aTime);

      // If timestamps are equal, compare by UUID to ensure uniqueness
      if (timeComparison == 0) {
        return a.uuid.compareTo(b.uuid);
      }

      return timeComparison;
    });
  }

  @override
  Future<void> clearSwaps(WalletId walletId) async {
    _storage.removeWhere((key, value) => key.startsWith('${walletId.name}-'));
  }
}

/// Exception thrown by swap history storage operations
class SwapHistoryStorageException implements Exception {
  /// Creates a new swap history storage exception
  const SwapHistoryStorageException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'SwapHistoryStorageException: $message';
}
