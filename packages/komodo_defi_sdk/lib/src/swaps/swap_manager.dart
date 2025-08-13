import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/src/swaps/services/orderbook_service.dart';
import 'package:komodo_defi_sdk/src/swaps/services/swap_watch_service.dart';

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

  // Delegated services
  late final OrderbookService _orderbook = OrderbookService(_client);
  final Map<String, StreamController<SwapProgress>> _swapControllers = {};
  final Map<String, StreamSubscription<dynamic>> _swapWatchers = {};
  final Map<String, SwapProgress> _swapLastProgress = {};
  final Map<String, String> _swapLastSignature = {};
  // Reserved for future streaming API integration; not currently used
  // ignore: unused_field
  late final SwapWatchService _swapWatch = SwapWatchService(_client);

  // Unique pair key no longer used after service extraction

  Future<void> _handleAuthStateChanged(KdfUser? user) async {
    if (_isDisposed) return;
    final newWalletId = user?.walletId;
    if (_currentWalletId != newWalletId) {
      await _resetState();
      _currentWalletId = newWalletId;
    }
  }

  Future<void> _resetState() async {
    await _orderbook.dispose();

    for (final sub in _swapWatchers.values) {
      await sub.cancel();
    }
    _swapWatchers.clear();
    for (final controller in _swapControllers.values) {
      await controller.close();
    }
    _swapControllers.clear();

    // swap watch caches live within SwapWatchService
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
    // No activation required to view orderbook; delegate to service
    return _orderbook.getSnapshot(base: base, rel: rel);
  }

  /// Watch the orderbook for a pair with periodic polling
  Stream<OrderbookSnapshot> watchOrderbook({
    /// Base asset id
    required AssetId base,

    /// Rel/quote asset id
    required AssetId rel,
  }) {
    _assertNotDisposed();
    return _orderbook.watch(base: base, rel: rel);
  }

  // Orderbook mapping/signatures are handled inside OrderbookService

  /// Batch fetch orderbook depth for multiple pairs.
  Future<Map<String, OrderbookSnapshot>> getOrderbookDepth({
    required List<MapEntry<AssetId, AssetId>> pairs,
  }) async {
    _assertNotDisposed();
    return _orderbook.getDepth(pairs: pairs);
  }

  /// Get the best orders for a taker request and compute a taker quote.
  ///
  /// - For side=buy: requests best sell orders of [base], sweeping until [volume] is filled
  /// - For side=sell: requests best buy orders of [base], sweeping until [volume] is filled
  Future<TakerQuote> takerQuote({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal volume,
  }) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    if (volume <= Decimal.zero) {
      throw ArgumentError('volume must be positive');
    }

    // Ask for best orders for the base coin, action depends on desired side
    final action = side == OrderSide.buy ? OrderType.buy : OrderType.sell;
    final best = await _client.rpc.orderbook.bestOrders(
      coin: base.id.toUpperCase(),
      action: action,
      volume: volume.toString(),
    );

    // Build fills by sweeping levels until requested base volume is reached
    var remainingBase = volume;
    final fills = <LevelFill>[];
    Decimal accumulatedRel = Decimal.zero;
    Decimal accumulatedBase = Decimal.zero;
    for (final ord in best.orders) {
      if (remainingBase <= Decimal.zero) break;
      final price = Decimal.parse(ord.price);
      Decimal baseAvailable;
      if (ord.coin.toUpperCase() == base.id.toUpperCase()) {
        baseAvailable = Decimal.parse(ord.maxVolume);
      } else if (ord.coin.toUpperCase() == rel.id.toUpperCase()) {
        if (price == Decimal.zero) {
          baseAvailable = Decimal.zero;
        } else {
          baseAvailable = Decimal.parse(
            (Decimal.parse(ord.maxVolume) / price).toString(),
          );
        }
      } else {
        baseAvailable = Decimal.parse(ord.maxVolume);
      }
      final levelBase =
          baseAvailable < remainingBase ? baseAvailable : remainingBase;
      final levelRel = levelBase * price;
      fills.add(LevelFill(price: price, base: levelBase, rel: levelRel));
      accumulatedBase += levelBase;
      accumulatedRel += levelRel;
      remainingBase -= levelBase;
    }
    if (accumulatedBase < volume) {
      // Not enough liquidity; still produce partial quote.
    }
    final avgPrice =
        accumulatedBase == Decimal.zero
            ? Decimal.zero
            : Decimal.parse((accumulatedRel / accumulatedBase).toString());
    final fillEstimate = TakerFillEstimate(
      totalBase: accumulatedBase,
      totalRel: accumulatedRel,
      averagePrice: avgPrice,
      fills: fills,
    );

    // Combine with fee preimage for this taker side and volume
    final preimage = await preimageQuote(
      base: base,
      rel: rel,
      side: side,
      volume: volume,
    );

    return TakerQuote(fill: fillEstimate, preimage: preimage);
  }

  /// Validate a user-intended order or swap against network constraints.
  /// Throws if invalid; returns normally if valid.
  Future<void> validateTradeIntent({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal volume,
    Decimal? price,
  }) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    if (volume <= Decimal.zero) {
      throw ArgumentError('volume must be positive');
    }

    final minBase = await minTradingVolume(coin: base);
    if (volume < minBase) {
      throw StateError(
        'Volume ${volume.toString()} is below minimum ${minBase.toString()} for ${base.id.toUpperCase()}',
      );
    }

    // Also attempt a dry-run preimage to surface fee-related issues early
    await preimageQuote(
      base: base,
      rel: rel,
      side: side,
      volume: volume,
      price: price,
    );
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
      orderType: side == OrderSide.buy ? OrderType.buy : OrderType.sell,
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

  /// Cancel all open orders for the current wallet, optionally by coin.
  Future<bool> cancelAllOrders({AssetId? coin}) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.orderbook.cancelAllOrders(
      cancelType:
          coin == null
              ? CancelOrdersType.all()
              : CancelOrdersType.coin(coin.id.toUpperCase()),
    );
    return resp.cancelled;
  }

  /// Get current user's open orders.
  Future<List<PlacedOrderSummary>> myOrders() async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.orderbook.myOrders();
    return resp.orders
        .map(
          (o) => PlacedOrderSummary(
            uuid: o.uuid,
            base: o.base,
            rel: o.rel,
            side:
                o.orderType.toLowerCase() == 'buy'
                    ? OrderSide.buy
                    : OrderSide.sell,
            price: Decimal.parse(o.price),
            volume: Decimal.parse(o.volume),
            timestamp: DateTime.fromMillisecondsSinceEpoch(o.createdAt * 1000),
            isMine: true,
          ),
        )
        .toList();
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
  }) async* {
    _assertNotDisposed();

    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    if (amount <= Decimal.zero) {
      throw ArgumentError('Swap amount must be positive');
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
    final init = SwapProgress(
      status: SwapStatus.inProgress,
      message: 'Swap initiated',
      swapUuid: swapKey,
    );
    _swapLastProgress[swapKey] = init;
    _swapLastSignature[swapKey] = 'init';
    controller.add(init);

    // Poll actual swap status until terminal state
    await _swapWatchers[swapKey]?.cancel();
    final periodic = Stream<void>.periodic(const Duration(seconds: 5));
    _swapWatchers[swapKey] = periodic.listen((_) async {
      if (_isDisposed || controller.isClosed) return;
      try {
        final status = await _client.rpc.trading.swapStatus(uuid: swapKey);
        final info = status.swapInfo;
        final sig = _signatureForSwapInfo(info);
        if (_swapLastSignature[swapKey] == sig) return;
        _swapLastSignature[swapKey] = sig;
        if (info.isComplete) {
          final ev = SwapProgress(
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
          );
          _swapLastProgress[swapKey] = ev;
          controller.add(ev);
          await controller.close();
          await _swapWatchers[swapKey]?.cancel();
          _swapWatchers.remove(swapKey);
          _swapControllers.remove(swapKey);
        } else {
          final last =
              info.successEvents.isNotEmpty ? info.successEvents.last : null;
          final ev = SwapProgress(
            status: SwapStatus.inProgress,
            message: last ?? 'In progress',
            swapUuid: swapKey,
            details: info.toJson(),
          );
          _swapLastProgress[swapKey] = ev;
          controller.add(ev);
        }
      } catch (e) {
        // If status request fails, keep the stream alive unless disposed
      }
    });

    // Ensure any new subscriber receives the latest progress first
    yield* Stream<SwapProgress>.multi((emitter) {
      final last = _swapLastProgress[swapKey];
      if (last != null) emitter.add(last);
      final sub = controller.stream.listen(
        emitter.add,
        onError: emitter.addError,
        onDone: emitter.close,
        cancelOnError: false,
      );
      emitter.onCancel = () => sub.cancel();
    });
  }

  /// Compute a human-friendly trade preimage quote.
  Future<TradePreimageQuote> preimageQuote({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal volume,
    Decimal? price,
    bool max = false,
  }) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    final method =
        price == null
            ? (side == OrderSide.buy ? SwapMethod.buy : SwapMethod.sell)
            : SwapMethod.setPrice;

    final resp = await _client.rpc.trading.tradePreimage(
      base: base.id.toUpperCase(),
      rel: rel.id.toUpperCase(),
      swapMethod: method,
      volume: max ? null : volume.toString(),
      max: max ? true : null,
      price: price?.toString(),
    );

    CoinAmount? mapCoinFee(PreimageCoinFee? f) =>
        f == null
            ? null
            : CoinAmount(coin: f.coin, amount: Decimal.parse(f.amount));

    final totals =
        resp.totalFees
            .map(
              (t) => TotalFeeEntry(
                coin: t.coin,
                amount: Decimal.parse(t.amount),
                requiredBalance: Decimal.parse(t.requiredBalance),
              ),
            )
            .toList();

    return TradePreimageQuote(
      baseCoinFee: mapCoinFee(resp.baseCoinFee),
      relCoinFee: mapCoinFee(resp.relCoinFee),
      takerFee: mapCoinFee(resp.takerFee),
      feeToSendTakerFee: mapCoinFee(resp.feeToSendTakerFee),
      totalFees: totals,
    );
  }

  /// Convenience to fetch the maximum taker volume available for a coin.
  Future<Decimal> maxTakerVolume({required AssetId coin}) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.trading.maxTakerVolume(
      coin: coin.id.toUpperCase(),
    );
    return Decimal.parse(resp.amount);
  }

  /// Minimum trading volume for a coin.
  Future<Decimal> minTradingVolume({required AssetId coin}) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.trading.minTradingVolume(
      coin: coin.id.toUpperCase(),
    );
    return Decimal.parse(resp.amount);
  }

  /// List active swaps; optionally include detailed status.
  Future<List<SwapSummary>> activeSwaps({
    AssetId? coin,
    bool includeStatus = true,
  }) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.trading.activeSwaps(
      coin: coin?.id.toUpperCase(),
      includeStatus: includeStatus,
    );

    // When includeStatus is true in future, we can consume resp.statuses.
    if (resp.statuses != null && includeStatus) {
      return resp.statuses!.values.map(_mapSwapInfoToSummary).toList();
    }
    // Fallback: query each status to build summaries.
    final summaries = <SwapSummary>[];
    for (final id in resp.uuids) {
      final s = await _client.rpc.trading.swapStatus(uuid: id);
      summaries.add(
        _mapSwapInfoToSummary(
          ActiveSwapStatus(swapType: s.swapInfo.type, swapData: s.swapInfo),
        ),
      );
    }
    return summaries;
  }

  /// Recent swap history with optional pagination.
  Future<List<SwapSummary>> recentSwaps({
    int? limit,
    int? pageNumber,
    String? fromUuid,
    AssetId? coin,
  }) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.trading.recentSwaps(
      limit: limit,
      pageNumber: pageNumber,
      fromUuid: fromUuid,
      coin: coin?.id.toUpperCase(),
    );
    return resp.swaps
        .map(
          (s) => _mapSwapInfoToSummary(
            ActiveSwapStatus(swapType: s.type, swapData: s),
          ),
        )
        .toList();
  }

  /// Fetch current status for a specific swap UUID.
  Future<SwapSummary> getSwapStatus(String uuid) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final s = await _client.rpc.trading.swapStatus(uuid: uuid);
    return _mapSwapInfoToSummary(
      ActiveSwapStatus(swapType: s.swapInfo.type, swapData: s.swapInfo),
    );
  }

  /// Attempt to cancel an in-progress swap.
  Future<bool> cancelSwap(String uuid) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();
    final resp = await _client.rpc.trading.cancelSwap(uuid: uuid);
    return resp.cancelled;
  }

  /// Watch an existing swap by periodically polling its status.
  Stream<SwapProgress> watchSwap({required String uuid}) async* {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    final swapKey = uuid;
    late final StreamController<SwapProgress> controller;
    controller = StreamController<SwapProgress>(
      onCancel: () async {
        await _swapWatchers[swapKey]?.cancel();
        _swapWatchers.remove(swapKey);
        _swapControllers.remove(swapKey);
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );
    _swapControllers[swapKey] = controller;
    // Emit current status immediately (if available)
    try {
      final status = await _client.rpc.trading.swapStatus(uuid: swapKey);
      final info = status.swapInfo;
      final sig = _signatureForSwapInfo(info);
      if (_swapLastSignature[swapKey] != sig) {
        _swapLastSignature[swapKey] = sig;
      }
      final last =
          info.isComplete
              ? SwapProgress(
                status:
                    info.isSuccessful
                        ? SwapStatus.completed
                        : SwapStatus.failed,
                message:
                    info.isSuccessful
                        ? 'Swap completed'
                        : (info.errorEvents.isNotEmpty
                            ? 'Swap failed: ${info.errorEvents.last}'
                            : 'Swap failed'),
                swapUuid: swapKey,
                details: info.toJson(),
              )
              : SwapProgress(
                status: SwapStatus.inProgress,
                message:
                    info.successEvents.isNotEmpty
                        ? info.successEvents.last
                        : 'In progress',
                swapUuid: swapKey,
                details: info.toJson(),
              );
      _swapLastProgress[swapKey] = last;
      if (!controller.isClosed) controller.add(last);
    } catch (_) {}

    await _swapWatchers[swapKey]?.cancel();
    final periodic = Stream<void>.periodic(const Duration(seconds: 5));
    _swapWatchers[swapKey] = periodic.listen((_) async {
      if (_isDisposed || controller.isClosed) return;
      try {
        final status = await _client.rpc.trading.swapStatus(uuid: swapKey);
        final info = status.swapInfo;
        final sig = _signatureForSwapInfo(info);
        if (_swapLastSignature[swapKey] == sig) return;
        _swapLastSignature[swapKey] = sig;
        if (info.isComplete) {
          final ev = SwapProgress(
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
          );
          _swapLastProgress[swapKey] = ev;
          controller.add(ev);
          await controller.close();
          await _swapWatchers[swapKey]?.cancel();
          _swapWatchers.remove(swapKey);
          _swapControllers.remove(swapKey);
        } else {
          final last =
              info.successEvents.isNotEmpty ? info.successEvents.last : null;
          final ev = SwapProgress(
            status: SwapStatus.inProgress,
            message: last ?? 'In progress',
            swapUuid: swapKey,
            details: info.toJson(),
          );
          _swapLastProgress[swapKey] = ev;
          controller.add(ev);
        }
      } catch (_) {}
    });

    yield* Stream<SwapProgress>.multi((emitter) {
      final last = _swapLastProgress[swapKey];
      if (last != null) emitter.add(last);
      final sub = controller.stream.listen(
        emitter.add,
        onError: emitter.addError,
        onDone: emitter.close,
        cancelOnError: false,
      );
      emitter.onCancel = () => sub.cancel();
    });
  }

  SwapSummary _mapSwapInfoToSummary(ActiveSwapStatus status) {
    final info = status.swapData;
    return SwapSummary(
      uuid: info.uuid,
      makerCoin: info.makerCoin,
      takerCoin: info.takerCoin,
      makerAmount: Decimal.parse(info.makerAmount),
      takerAmount: Decimal.parse(info.takerAmount),
      isMaker: status.swapType.toLowerCase() == 'maker',
      successEvents: info.successEvents,
      errorEvents: info.errorEvents,
      startedAt:
          info.startedAt != null
              ? DateTime.fromMillisecondsSinceEpoch(info.startedAt! * 1000)
              : null,
      finishedAt:
          info.finishedAt != null
              ? DateTime.fromMillisecondsSinceEpoch(info.finishedAt! * 1000)
              : null,
    );
  }

  String _signatureForSwapInfo(SwapInfo info) {
    final lastSuccess =
        info.successEvents.isNotEmpty ? info.successEvents.last : '';
    final lastError = info.errorEvents.isNotEmpty ? info.errorEvents.last : '';
    return '${info.startedAt ?? 0}:${info.finishedAt ?? 0}:${info.type}:S${info.successEvents.length}:E${info.errorEvents.length}:LS$lastSuccess:LE$lastError';
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
