import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// OrderSide, SwapStatus, PlacedOrderSummary, OrderbookEntry, OrderbookSnapshot,
// and SwapProgress have been moved to the types library under
// `komodo_defi_types/src/trading/swap_types.dart` and re-exported via
// `package:komodo_defi_types/komodo_defi_types.dart`.

/// Abstraction over swaps and order management operations.
///
/// Follows SDK manager patterns: authentication-aware, activation-coordinated,
/// and stream-friendly APIs for easy UI integration.
class SwapManager {
  SwapManager(
    this._client,
    this._auth,
    this._assetLookup,
    this._activationCoordinator,
  ) {
    _authSubscription = _auth.authStateChanges.listen(_handleAuthStateChanged);
  }

  // ignore: unused_field
  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final IAssetLookup _assetLookup;
  final SharedActivationCoordinator _activationCoordinator;

  StreamSubscription<KdfUser?>? _authSubscription;
  WalletId? _currentWalletId;
  bool _isDisposed = false;

  final Map<String, StreamController<OrderbookSnapshot>> _orderbookControllers =
      {};
  final Map<String, StreamSubscription<dynamic>> _orderbookWatchers = {};

  final Map<String, StreamController<SwapProgress>> _swapControllers = {};
  final Map<String, StreamSubscription<dynamic>> _swapWatchers = {};

  /// Create a unique key for a pair
  String _pairKey(String base, String rel) =>
      '${base.toUpperCase()}__${rel.toUpperCase()}';

  Future<void> _handleAuthStateChanged(KdfUser? user) async {
    if (_isDisposed) return;
    final newWalletId = user?.walletId;
    if (_currentWalletId != newWalletId) {
      await _resetState();
      _currentWalletId = newWalletId;
    }
  }

  Future<void> _resetState() async {
    for (final sub in _orderbookWatchers.values) {
      await sub.cancel();
    }
    _orderbookWatchers.clear();
    for (final controller in _orderbookControllers.values) {
      await controller.close();
    }
    _orderbookControllers.clear();

    for (final sub in _swapWatchers.values) {
      await sub.cancel();
    }
    _swapWatchers.clear();
    for (final controller in _swapControllers.values) {
      await controller.close();
    }
    _swapControllers.clear();
  }

  /// Ensures both assets are activated if required for a swap
  Future<void> _ensurePairActivatedById(AssetId base, AssetId rel) async {
    // Validate pair
    if (base.isSameAsset(rel)) {
      throw ArgumentError('Base and rel must be different assets');
    }

    final baseAsset = _assetLookup.fromId(base);
    final relAsset = _assetLookup.fromId(rel);

    if (baseAsset == null || relAsset == null) {
      throw ArgumentError('Unknown asset(s): ${base.id}/${rel.id}');
    }

    // Only attempt activation if not active
    if (!await _activationCoordinator.isAssetActive(baseAsset.id)) {
      final result = await _activationCoordinator.activateAsset(baseAsset);
      if (!result.isSuccess) {
        throw StateError(
          'Failed to activate ${base.id}: ${result.errorMessage ?? 'Unknown error'}',
        );
      }
    }
    if (!await _activationCoordinator.isAssetActive(relAsset.id)) {
      final result = await _activationCoordinator.activateAsset(relAsset);
      if (!result.isSuccess) {
        throw StateError(
          'Failed to activate ${rel.id}: ${result.errorMessage ?? 'Unknown error'}',
        );
      }
    }
  }

  /// Fetch a one-time orderbook snapshot
  Future<OrderbookSnapshot> getOrderbook({
    required AssetId base,
    required AssetId rel,
  }) async {
    _assertNotDisposed();
    // No activation required to view orderbook
    final response = await _client.rpc.orderbook.orderbook(
      base: base.id.toUpperCase(),
      rel: rel.id.toUpperCase(),
    );

    OrderbookEntry mapOrderToEntry(
      OrderInfo o,
      String baseTicker,
      String relTicker,
    ) {
      final price = Decimal.parse(o.price);
      Decimal baseAmount;
      if (o.coin.toUpperCase() == baseTicker.toUpperCase()) {
        baseAmount = Decimal.parse(o.maxVolume);
      } else if (o.coin.toUpperCase() == relTicker.toUpperCase()) {
        // Convert rel volume to base using price; guard against zero
        final relVol = Decimal.parse(o.maxVolume);
        if (price == Decimal.zero) {
          baseAmount = Decimal.zero;
        } else {
          baseAmount = Decimal.parse((relVol / price).toString());
        }
      } else {
        // Fallback: treat provided max_volume as base units
        baseAmount = Decimal.parse(o.maxVolume);
      }
      final relAmount = Decimal.parse((baseAmount * price).toString());
      return OrderbookEntry(
        price: price,
        baseAmount: baseAmount,
        relAmount: relAmount,
        uuid: o.uuid,
        pubkey: o.pubkey,
        age: Duration(seconds: o.age),
      );
    }

    final asks =
        response.asks
            .map((o) => mapOrderToEntry(o, response.base, response.rel))
            .toList();
    final bids =
        response.bids
            .map((o) => mapOrderToEntry(o, response.base, response.rel))
            .toList();

    final ts = DateTime.fromMillisecondsSinceEpoch(response.timestamp * 1000);
    return OrderbookSnapshot(
      base: response.base,
      rel: response.rel,
      asks: asks,
      bids: bids,
      timestamp: ts,
    );
  }

  /// Watch the orderbook for a pair with periodic polling
  Stream<OrderbookSnapshot> watchOrderbook({
    /// Base asset id
    required AssetId base,

    /// Rel/quote asset id
    required AssetId rel,

    /// Polling interval for refreshing snapshots
    Duration interval = const Duration(seconds: 5),
  }) {
    _assertNotDisposed();
    final key = _pairKey(base.id, rel.id);

    final controller = _orderbookControllers.putIfAbsent(
      key,
      () => StreamController<OrderbookSnapshot>.broadcast(
        onListen: () => _startWatchingOrderbook(base, rel, interval),
        onCancel: () => _stopWatchingOrderbook(key),
      ),
    );

    return controller.stream;
  }

  Future<void> _startWatchingOrderbook(
    AssetId base,
    AssetId rel,
    Duration interval,
  ) async {
    final key = _pairKey(base.id, rel.id);
    final controller = _orderbookControllers[key];
    if (controller == null || _isDisposed) return;

    await _orderbookWatchers[key]?.cancel();

    // Emit initial snapshot
    try {
      final snapshot = await getOrderbook(base: base, rel: rel);
      if (!controller.isClosed) controller.add(snapshot);
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }

    // Periodic polling
    final periodic = Stream<void>.periodic(interval);
    _orderbookWatchers[key] = periodic
        .asyncMap<OrderbookSnapshot?>((_) async {
          if (_isDisposed) return null;
          try {
            return await getOrderbook(base: base, rel: rel);
          } catch (_) {
            return null;
          }
        })
        .listen(
          (snapshot) {
            if (snapshot != null && !controller.isClosed) {
              controller.add(snapshot);
            }
          },
          onError: (Object error, StackTrace st) {
            if (!controller.isClosed) controller.addError(error, st);
          },
          onDone: () => _stopWatchingOrderbook(key),
          cancelOnError: false,
        );
  }

  void _stopWatchingOrderbook(String key) {
    _orderbookWatchers[key]?.cancel();
    _orderbookWatchers.remove(key);
  }

  /// Place a limit order. Returns the order UUID.
  Future<String> placeLimitOrder({
    /// Base asset id
    required AssetId base,

    /// Rel/quote asset id
    required AssetId rel,

    /// Buy or sell side
    required OrderSide side,

    /// Price per unit of [base] in [rel]
    required Decimal price,

    /// Volume in [base] units
    required Decimal volume,
  }) async {
    _assertNotDisposed();

    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    await _ensurePairActivatedById(base, rel);

    final resp = await _client.rpc.orderbook.setOrder(
      base: base.id.toUpperCase(),
      rel: rel.id.toUpperCase(),
      price: price.toString(),
      volume: volume.toString(),
    );

    return resp.orderInfo.uuid;
  }

  /// Cancel an order by UUID
  Future<bool> cancelOrder(String uuid) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    final resp = await _client.rpc.orderbook.cancelOrder(uuid: uuid);
    return resp.cancelled;
  }

  /// Execute a simple market swap and stream its progress until completion.
  ///
  /// The [amount] is in base units regardless of [side].
  /// - buy: acquire [amount] of base using rel
  /// - sell: sell [amount] of base for rel
  Stream<SwapProgress> marketSwap({
    /// Base asset id
    required AssetId base,

    /// Rel/quote asset id
    required AssetId rel,

    /// Buy or sell side
    required OrderSide side,

    /// Amount in [base] units
    required Decimal amount,

    /// Polling interval for progress updates
    Duration statusPollInterval = const Duration(seconds: 5),
  }) async* {
    _assertNotDisposed();

    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    if (amount <= Decimal.zero) {
      throw ArgumentError('Swap amount must be positive');
    }
    if (statusPollInterval.inMicroseconds <= 0) {
      throw ArgumentError('statusPollInterval must be positive');
    }

    await _ensurePairActivatedById(base, rel);

    // Start the swap using trading.startSwap and stream progress by polling
    final method = side == OrderSide.buy ? SwapMethod.buy : SwapMethod.sell;
    final start = await _client.rpc.trading.startSwap(
      swapRequest: SwapRequest(
        base: base.id.toUpperCase(),
        rel: rel.id.toUpperCase(),
        // Preserve precision by sending string params directly
        baseCoinAmount: amount.toString(),
        // For taker swaps, one side amount is primary; set the other to "0"
        relCoinAmount: '0',
        method: method,
      ),
    );

    final swapKey = start.uuid;
    late final StreamController<SwapProgress> controller;
    controller = StreamController<SwapProgress>(
      onCancel: () async {
        await _swapWatchers[swapKey]?.cancel();
        _swapWatchers.remove(swapKey);
        _swapControllers.remove(swapKey);
        // Attempt to cancel the swap at the node if still active
        try {
          await _client.rpc.trading.cancelSwap(uuid: swapKey);
        } catch (_) {}
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );
    _swapControllers[swapKey] = controller;

    // Emit initial in-progress status
    controller.add(
      SwapProgress(
        status: SwapStatus.inProgress,
        message: 'Swap initiated',
        swapUuid: swapKey,
      ),
    );

    // Poll actual swap status until terminal state
    await _swapWatchers[swapKey]?.cancel();
    final periodic = Stream<void>.periodic(statusPollInterval);
    _swapWatchers[swapKey] = periodic.listen((_) async {
      if (_isDisposed || controller.isClosed) return;
      try {
        final status = await _client.rpc.trading.swapStatus(uuid: swapKey);
        final info = status.swapInfo;
        if (info.isComplete) {
          controller.add(
            SwapProgress(
              status:
                  info.isSuccessful ? SwapStatus.completed : SwapStatus.failed,
              message:
                  info.isSuccessful
                      ? 'Swap completed'
                      : (info.errorEvents.isNotEmpty
                          ? 'Swap failed: ${info.errorEvents.last}'
                          : 'Swap failed'),
              swapUuid: swapKey,
              details: info.toJson(),
            ),
          );
          await controller.close();
          await _swapWatchers[swapKey]?.cancel();
          _swapWatchers.remove(swapKey);
          _swapControllers.remove(swapKey);
        } else {
          final last =
              info.successEvents.isNotEmpty ? info.successEvents.last : null;
          controller.add(
            SwapProgress(
              status: SwapStatus.inProgress,
              message: last ?? 'In progress',
              swapUuid: swapKey,
              details: info.toJson(),
            ),
          );
        }
      } catch (e) {
        // If status request fails, keep the stream alive unless disposed
      }
    });

    yield* controller.stream;
  }

  /// Disposes internal resources and cancels background watchers.
  ///
  /// After calling this method the instance must not be used.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _authSubscription?.cancel();
    _authSubscription = null;

    await _resetState();
  }

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('SwapManager has been disposed');
    }
  }
}
