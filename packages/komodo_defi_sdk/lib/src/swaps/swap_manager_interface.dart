import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/src/swaps/match_by_filter.dart';

/// Interface describing the high-level Swap and Orderbook operations exposed by
/// the SDK.
///
/// Design goals:
/// - Readable, UI-friendly methods with clear parameter semantics and units
/// - Authentication-aware: calls that require a signed-in user should document
///   the requirement and errors thrown when not authenticated
/// - Activation-aware: concrete implementations may lazily activate assets
///   before submitting orders or swaps
/// - Stream-first where applicable: long-running processes expose
///   `Stream<SwapProgress>` for easy UI integration
///
/// Type and unit conventions:
/// - All monetary amounts use [Decimal] for precision; do not round to double
/// - For pair parameters, `base` is the asset being bought/sold, `rel` is the
///   quote asset
/// - Volumes are specified in the units of the `base` asset
/// - Prices are specified in `rel` per 1 `base`
///
/// Authentication & errors:
/// - Methods that require a signed-in user will throw an `AuthException`
///   (from `komodo_defi_local_auth`) if not authenticated
/// - Input validation failures surface as `ArgumentError`
/// - Network/state failures surface as `StateError` where appropriate
///
/// Notes on underlying transport:
/// - Implementations typically delegate to Komodo DeFi node RPCs
///   (e.g. `orderbook.*`, `trading.*`) via an `ApiClient`
/// - Implementations may perform background polling to synthesize progress
///   events for swap streams
abstract class ISwapManager {
  /// Fetch a one-time orderbook snapshot for a trading pair.
  ///
  /// Does not require authentication.
  Future<OrderbookSnapshot> getOrderbook({
    required AssetId base,
    required AssetId rel,
  });

  /// Watch the orderbook for a trading pair using periodic polling.
  ///
  /// - Emits an [OrderbookSnapshot] on each polling interval when changes are
  ///   detected.
  /// - Does not require authentication.
  Stream<OrderbookSnapshot> watchOrderbook({
    required AssetId base,
    required AssetId rel,
  });

  /// Batch fetch shallow depth snapshots for multiple pairs.
  ///
  /// Returns a map keyed by an implementation-defined pair identifier (typically
  /// `BASE/REL`, uppercased), each value an [OrderbookSnapshot].
  ///
  /// Does not require authentication.
  Future<Map<String, OrderbookSnapshot>> getOrderbookDepth({
    required List<MapEntry<AssetId, AssetId>> pairs,
  });

  /// Compute a taker quote by sweeping best orders until [volume] of `base` is
  /// filled.
  ///
  /// Behavior by [side]:
  /// - buy: acquire [volume] of `base` paying `rel`
  /// - sell: sell [volume] of `base` receiving `rel`
  ///
  /// Returns a [TakerQuote] containing the level-by-level fills and a
  /// [TradePreimageQuote] that summarizes fees expected for the taker action.
  ///
  /// Requires authentication. Throws `ArgumentError` if [volume] <= 0.
  Future<TakerQuote> takerQuote({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal volume,
    CounterpartyMatch? match,
  });

  /// Validate a user-intended order or swap against network constraints.
  ///
  /// Ensures the entered [volume] is above the minimum trading volume for the
  /// `base` coin, and performs a dry-run preimage to surface fee-related issues.
  ///
  /// Requires authentication. Throws `ArgumentError` if [volume] <= 0.
  Future<void> validateTradeIntent({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal volume,
    Decimal? price,
  });

  /// Place a limit order and return its UUID.
  ///
  /// - [price]: price in `rel` per 1 `base`
  /// - [volume]: amount in `base` units
  ///
  /// Requires authentication. Implementations may lazily activate the assets
  /// if they are not already active in the current wallet.
  Future<String> placeLimitOrder({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal price,
    required Decimal volume,
  });

  /// Cancel an order by its UUID. Returns true if cancellation was acknowledged.
  ///
  /// Requires authentication.
  Future<bool> cancelOrder(String uuid);

  /// Cancel all open orders for the current wallet.
  ///
  /// - If [coin] is provided, cancels only orders involving that coin.
  /// - Returns true if cancellation was acknowledged.
  ///
  /// Requires authentication.
  Future<bool> cancelAllOrders({AssetId? coin});

  /// Retrieve current user's open orders.
  ///
  /// Requires authentication.
  Future<List<PlacedOrderSummary>> myOrders();

  /// Execute a taker market swap and stream its progress until completion.
  ///
  /// Semantics:
  /// - [amount] is in `base` units regardless of [side]
  /// - buy: acquire [amount] of `base` using `rel`
  /// - sell: sell [amount] of `base` for `rel`
  ///
  /// Stream behavior:
  /// - Emits an initial in-progress event immediately
  /// - Polls periodically to fetch status and synthesizes [SwapProgress]
  /// - Closes upon terminal state (completed or failed)
  /// - Canceling the subscription should stop polling and may attempt to cancel
  ///   the swap at the node
  ///
  /// Requires authentication. Throws `ArgumentError` if [amount] <= 0.
  Stream<SwapProgress> marketSwap({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal amount,
    CounterpartyMatch? match,
  });

  /// Compute a human-friendly trade preimage/fee quote for the provided intent.
  ///
  /// - If [price] is null, computes taker fees for a market-style action
  /// - If [price] is provided, computes maker/limit-style preimage via
  ///   `SwapMethod.setPrice`
  /// - If [max] is true, asks the node to compute for "max" amount available
  ///   (mutually exclusive with [volume])
  ///
  /// Requires authentication.
  Future<TradePreimageQuote> preimageQuote({
    required AssetId base,
    required AssetId rel,
    required OrderSide side,
    required Decimal volume,
    Decimal? price,
    bool max = false,
  });

  /// Query the maximum taker volume available for [coin] given balances and
  /// fees.
  ///
  /// Requires authentication.
  Future<Decimal> maxTakerVolume({required AssetId coin});

  /// Query the minimum trading volume for [coin].
  ///
  /// Requires authentication.
  Future<Decimal> minTradingVolume({required AssetId coin});

  /// List active swaps for the current wallet, optionally including status.
  ///
  /// - If [includeStatus] is true, implementations may return richer summaries
  ///   using the node's batched statuses when available.
  /// - If [coin] is provided, filters swaps related to that coin.
  ///
  /// Requires authentication.
  Future<List<SwapSummary>> activeSwaps({
    AssetId? coin,
    bool includeStatus = true,
  });

  /// Retrieve recent swap history with pagination options.
  ///
  /// Requires authentication.
  Future<List<SwapSummary>> recentSwaps({
    int? limit,
    int? pageNumber,
    String? fromUuid,
    AssetId? coin,
  });

  /// Fetch the current status for a specific swap UUID.
  ///
  /// Requires authentication.
  Future<SwapSummary> getSwapStatus(String uuid);

  /// Attempt to cancel an in-progress swap by UUID.
  ///
  /// Requires authentication.
  Future<bool> cancelSwap(String uuid);

  /// Watch an existing swap by periodically polling its status.
  ///
  /// Emits the latest known [SwapProgress] immediately (if retrievable), then
  /// continues polling until a terminal state is reached.
  ///
  /// Requires authentication.
  Stream<SwapProgress> watchSwap({required String uuid});

  /// Dispose internal resources. After calling this, the instance must not be
  /// used.
  Future<void> dispose();
}
