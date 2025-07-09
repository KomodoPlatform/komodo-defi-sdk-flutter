import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Core interface for orderbook manager
abstract interface class _OrderbookManager {
  /// Get the orderbook for a trading pair
  Future<OrderbookResponse> getOrderbook({
    required AssetId base,
    required AssetId rel,
  });

  /// Stream orderbook updates for a trading pair
  Stream<OrderbookResponse> getOrderbookStream({
    required AssetId base,
    required AssetId rel,
    Duration? pollingInterval,
  });

  /// Watch orderbook changes for a trading pair (placeholder for future
  /// task-based streaming)
  Stream<OrderbookResponse> watchOrderbook({
    required AssetId base,
    required AssetId rel,
  });

  /// Get best orders for a coin
  Future<BestOrdersResponse> getBestOrders({
    required AssetId assetId,
    required String action,
    required RequestBy requestBy,
    bool excludeMine = false,
  });

  /// Get orderbook depth for multiple trading pairs
  Future<OrderbookDepthResponse> getOrderbookDepth({
    required List<List<AssetId>> pairs,
  });
}

/// Implementation of orderbook management functionality
class OrderbookManager implements _OrderbookManager {
  /// Creates a new orderbook manager instance
  OrderbookManager(this._client, this._assetProvider, this._activationManager);

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final ActivationManager _activationManager;

  final _streamControllers = <String, StreamController<OrderbookResponse>>{};
  final _pollingTimers = <String, Timer>{};
  final _rateLimiter = _RateLimiter(const Duration(milliseconds: 500));

  static const _defaultPollingInterval = Duration(seconds: 10);
  static const _maxPollingRetries = 3;

  bool _isDisposed = false;

  @override
  Future<OrderbookResponse> getOrderbook({
    required AssetId base,
    required AssetId rel,
  }) async {
    if (_isDisposed) {
      throw StateError('OrderbookManager has been disposed');
    }

    await _ensureAssetsActivated([base, rel]);
    await _rateLimiter.throttle();

    return _client.rpc.swap.orderbook(base: base.id, rel: rel.id);
  }

  @override
  Stream<OrderbookResponse> getOrderbookStream({
    required AssetId base,
    required AssetId rel,
    Duration? pollingInterval,
  }) async* {
    if (_isDisposed) {
      throw StateError('OrderbookManager has been disposed');
    }

    await _ensureAssetsActivated([base, rel]);

    // Yield initial orderbook
    try {
      final initialOrderbook = await getOrderbook(base: base, rel: rel);
      yield initialOrderbook;
    } catch (e) {
      // If we can't get initial data, still continue with stream
    }

    // Create periodic stream
    final interval = pollingInterval ?? _defaultPollingInterval;

    try {
      while (!_isDisposed) {
        await Future<void>.delayed(interval);
        try {
          await _rateLimiter.throttle();
          final orderbook = await _client.rpc.swap.orderbook(
            base: base.id,
            rel: rel.id,
          );
          yield orderbook;
        } catch (e) {
          // Continue on error, don't break the stream
        }
      }
    } catch (e) {
      // Stream ended
    }
  }

  @override
  Stream<OrderbookResponse> watchOrderbook({
    required AssetId base,
    required AssetId rel,
  }) {
    if (_isDisposed) {
      throw StateError('OrderbookManager has been disposed');
    }

    final pairKey = '${base.id}_${rel.id}';

    final controller = _streamControllers.putIfAbsent(
      pairKey,
      () => StreamController<OrderbookResponse>.broadcast(
        onListen: () {
          if (!_pollingTimers.containsKey(pairKey)) {
            _startPolling(base, rel, pairKey);
          }
        },
        onCancel: () async {
          if (!_streamControllers[pairKey]!.hasListener) {
            _stopPolling(pairKey);
            await _streamControllers[pairKey]?.close();
            _streamControllers.remove(pairKey);
          }
        },
      ),
    );

    return controller.stream;
  }

  @override
  Future<BestOrdersResponse> getBestOrders({
    required AssetId assetId,
    required String action,
    required RequestBy requestBy,
    bool excludeMine = false,
  }) async {
    if (_isDisposed) {
      throw StateError('OrderbookManager has been disposed');
    }

    await _ensureAssetsActivated([assetId]);
    await _rateLimiter.throttle();

    return _client.rpc.swap.bestOrders(
      coin: assetId.id,
      action: action,
      requestBy: requestBy,
      excludeMine: excludeMine,
    );
  }

  @override
  Future<OrderbookDepthResponse> getOrderbookDepth({
    required List<List<AssetId>> pairs,
  }) async {
    if (_isDisposed) {
      throw StateError('OrderbookManager has been disposed');
    }

    // Extract all unique coins from pairs and ensure they're activated
    final allAssets = <AssetId>{};
    for (final pair in pairs) {
      if (pair.length >= 2) {
        allAssets.addAll([pair[0], pair[1]]);
      }
    }

    await _ensureAssetsActivated(allAssets.toList());
    await _rateLimiter.throttle();

    // Convert AssetId pairs to String pairs for the RPC call
    final stringPairs =
        pairs
            .map((pair) => pair.map((assetId) => assetId.id).toList())
            .toList();

    return _client.rpc.swap.orderbookDepthLegacy(pairs: stringPairs);
  }

  Future<void> _ensureAssetsActivated(List<AssetId> assetIds) async {
    for (final assetId in assetIds) {
      final assets = _assetProvider.findAssetsByConfigId(assetId.id);
      for (final asset in assets) {
        final activationStatus =
            await _activationManager.activateAsset(asset).last;
        if (activationStatus.isComplete && !activationStatus.isSuccess) {
          throw StateError(
            'Failed to activate asset ${asset.id.id}. '
            '${activationStatus.toJson()}',
          );
        }
      }
    }
  }

  void _startPolling(AssetId base, AssetId rel, String pairKey) {
    _stopPolling(pairKey);

    // Initial fetch
    _pollOrderbook(base, rel, pairKey);

    // Set up periodic polling
    _pollingTimers[pairKey] = Timer.periodic(
      _defaultPollingInterval,
      (_) => _pollOrderbook(base, rel, pairKey),
    );
  }

  Future<void> _pollOrderbook(
    AssetId base,
    AssetId rel,
    String pairKey, [
    int retryCount = 0,
  ]) async {
    if (_isDisposed || !_streamControllers.containsKey(pairKey)) return;

    try {
      await _rateLimiter.throttle();

      final orderbook = await _client.rpc.swap.orderbook(
        base: base.id,
        rel: rel.id,
      );

      final controller = _streamControllers[pairKey];
      if (controller != null && !controller.isClosed) {
        controller.add(orderbook);
      }
    } catch (e) {
      if (retryCount < _maxPollingRetries) {
        final delay = Duration(seconds: (retryCount + 1) * 2);
        Timer(delay, () => _pollOrderbook(base, rel, pairKey, retryCount + 1));
      }
    }
  }

  void _stopPolling(String pairKey) {
    _pollingTimers[pairKey]?.cancel();
    _pollingTimers.remove(pairKey);
  }

  /// Dispose of the orderbook manager and clean up resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final timers = _pollingTimers.values.toList();
    _pollingTimers.clear();
    for (final timer in timers) {
      timer.cancel();
    }

    final controllers = _streamControllers.values.toList();
    _streamControllers.clear();
    for (final controller in controllers) {
      await controller.close();
    }
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
