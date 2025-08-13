import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:collection/collection.dart';

/// Order side for limit orders
enum OrderSide { buy, sell }

/// Status of a swap lifecycle
enum SwapStatus { inProgress, completed, failed, canceled }

/// Summary of a placed order
class PlacedOrderSummary {
  PlacedOrderSummary({
    required this.uuid,
    required this.base,
    required this.rel,
    required this.side,
    required this.price,
    required this.volume,
    required this.timestamp,
    this.isMine = true,
  });

  final String uuid;
  final String base;
  final String rel;
  final OrderSide side;
  final Decimal price;
  final Decimal volume;
  final DateTime timestamp;
  final bool isMine;
}

/// One orderbook entry
class OrderbookEntry {
  OrderbookEntry({
    required this.price,
    required this.baseAmount,
    required this.relAmount,
    this.uuid,
    this.pubkey,
    this.age,
  });

  final Decimal price;
  final Decimal baseAmount;
  final Decimal relAmount;
  final String? uuid;
  final String? pubkey;
  final Duration? age;
}

/// Orderbook snapshot for a trading pair
class OrderbookSnapshot {
  OrderbookSnapshot({
    required this.base,
    required this.rel,
    required this.asks,
    required this.bids,
    required this.timestamp,
  });

  final String base;
  final String rel;
  final List<OrderbookEntry> asks;
  final List<OrderbookEntry> bids;
  final DateTime timestamp;
}

/// Progress update for an active swap
class SwapProgress {
  SwapProgress({
    required this.status,
    this.message,
    this.swapUuid,
    this.details,
  });

  final SwapStatus status;
  final String? message;
  final String? swapUuid;
  final Map<String, dynamic>? details;
}

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
  Future<void> _ensurePairActivated(String base, String rel) async {
    // Validate pair
    if (base.trim().toUpperCase() == rel.trim().toUpperCase()) {
      throw ArgumentError('Base and rel must be different assets');
    }

    final baseAsset = _assetLookup.findAssetsByConfigId(base).firstOrNull;
    final relAsset = _assetLookup.findAssetsByConfigId(rel).firstOrNull;

    if (baseAsset == null || relAsset == null) {
      throw ArgumentError('Unknown asset(s): $base/$rel');
    }

    // Only attempt activation if not active
    if (!await _activationCoordinator.isAssetActive(baseAsset.id)) {
      final result = await _activationCoordinator.activateAsset(baseAsset);
      if (!result.isSuccess) {
        throw StateError(
          'Failed to activate $base: ${result.errorMessage ?? 'Unknown error'}',
        );
      }
    }
    if (!await _activationCoordinator.isAssetActive(relAsset.id)) {
      final result = await _activationCoordinator.activateAsset(relAsset);
      if (!result.isSuccess) {
        throw StateError(
          'Failed to activate $rel: ${result.errorMessage ?? 'Unknown error'}',
        );
      }
    }
  }

  /// Fetch a one-time orderbook snapshot
  Future<OrderbookSnapshot> getOrderbook({
    required String base,
    required String rel,
  }) async {
    _assertNotDisposed();
    // NB: Orderbook queries don't require wallet auth, but we still record auth state
    final now = DateTime.now();
    // Placeholder implementation until RPC mapping is ready
    // Return empty orderbook to keep API stable
    return OrderbookSnapshot(
      base: base.toUpperCase(),
      rel: rel.toUpperCase(),
      asks: const [],
      bids: const [],
      timestamp: now,
    );
  }

  /// Watch the orderbook for a pair with periodic polling
  Stream<OrderbookSnapshot> watchOrderbook({
    required String base,
    required String rel,
    Duration interval = const Duration(seconds: 5),
  }) {
    _assertNotDisposed();
    final key = _pairKey(base, rel);

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
    String base,
    String rel,
    Duration interval,
  ) async {
    final key = _pairKey(base, rel);
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
    required String base,
    required String rel,
    required OrderSide side,
    required Decimal price,
    required Decimal volume,
  }) async {
    _assertNotDisposed();

    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    await _ensurePairActivated(base, rel);

    // Placeholder: in future, call RPC buy/sell and return UUID
    // For now, return a synthetic UUID-like string for dev/testing flows
    final pseudoUuid = 'order_${DateTime.now().millisecondsSinceEpoch}';
    return pseudoUuid;
  }

  /// Cancel an order by UUID
  Future<bool> cancelOrder(String uuid) async {
    _assertNotDisposed();
    final user = await _auth.currentUser;
    if (user == null) throw AuthException.notSignedIn();

    // Placeholder: invoke RPC cancel
    return true;
  }

  /// Execute a simple market swap and stream its progress until completion.
  ///
  /// The [amount] is in base units regardless of [side].
  /// - buy: acquire [amount] of base using rel
  /// - sell: sell [amount] of base for rel
  Stream<SwapProgress> marketSwap({
    required String base,
    required String rel,
    required OrderSide side,
    required Decimal amount,
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

    await _ensurePairActivated(base, rel);

    // Create controller per swap
    final swapKey = 'swap_${DateTime.now().microsecondsSinceEpoch}';
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

    // Emit initial in-progress status
    controller.add(
      SwapProgress(
        status: SwapStatus.inProgress,
        message: 'Swap initiated',
        swapUuid: swapKey,
      ),
    );

    // Placeholder polling loop to simulate progress until completion
    // Replace with RPC `my_swaps`/`swap_status` polling when available
    int ticks = 0;
    _swapWatchers[swapKey]?.cancel();
    final periodic = Stream<void>.periodic(statusPollInterval);
    _swapWatchers[swapKey] = periodic.listen((_) async {
      if (_isDisposed || controller.isClosed) return;
      ticks += 1;
      if (ticks >= 3) {
        controller.add(
          SwapProgress(
            status: SwapStatus.completed,
            message: 'Swap completed',
            swapUuid: swapKey,
          ),
        );
        await controller.close();
        await _swapWatchers[swapKey]?.cancel();
        _swapWatchers.remove(swapKey);
        _swapControllers.remove(swapKey);
      } else {
        controller.add(
          SwapProgress(
            status: SwapStatus.inProgress,
            message: 'Processing... (${ticks}/3)',
            swapUuid: swapKey,
          ),
        );
      }
    });

    yield* controller.stream;
  }

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
