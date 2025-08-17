import 'package:decimal/decimal.dart';

/// Defines the side of a trade/order from the perspective of the base asset.
///
/// - [OrderSide.buy]: Acquire the base asset by paying with the rel/quote asset
/// - [OrderSide.sell]: Sell the base asset to receive the rel/quote asset
enum OrderSide {
  /// Buy the base asset using the rel/quote asset
  buy,

  /// Sell the base asset for the rel/quote asset
  sell,
}

/// High-level lifecycle status for an atomic swap.
///
/// This enum represents user-facing swap progress states that aggregate
/// the detailed engine states into a concise status for UI and flow control.
enum SwapStatus {
  /// Swap has started and is in progress
  inProgress,

  /// Swap finished successfully
  completed,

  /// Swap failed due to an error
  failed,

  /// Swap was cancelled before completion
  canceled,
}

/// Summary information about a placed maker or taker order.
///
/// This is a lightweight snapshot designed for UI list rendering and
/// basic order tracking. For full order details and engine-specific
/// metadata, query the RPC orderbook and my-orders endpoints.
class PlacedOrderSummary {
  /// Creates a new [PlacedOrderSummary].
  PlacedOrderSummary({
    required this.uuid,
    required this.base,
    required this.rel,
    required this.side,
    required this.price,
    required this.volume,
    required this.timestamp,
    required this.isMine,
  });

  /// Unique identifier of the order created by the DEX.
  final String uuid;

  /// Base asset ticker (e.g. "BTC").
  final String base;

  /// Rel/quote asset ticker (e.g. "KMD").
  final String rel;

  /// Whether this is a buy or sell order.
  final OrderSide side;

  /// Price per unit of [base] in [rel].
  final Decimal price;

  /// Order volume in [base] units.
  final Decimal volume;

  /// Creation timestamp (local clock).
  final DateTime timestamp;

  /// True if the order belongs to the current wallet.
  final bool isMine;
}

/// One aggregated level/entry in an orderbook snapshot.
///
/// Amounts are provided using Decimal to preserve full precision for UI and
/// calculations without floating point rounding errors.
class OrderbookEntry {
  /// Creates a new [OrderbookEntry].
  OrderbookEntry({
    required this.price,
    required this.baseAmount,
    required this.relAmount,
    this.uuid,
    this.pubkey,
    this.age,
  });

  /// Price for this order level (base in rel).
  final Decimal price;

  /// Available amount denominated in base asset units.
  final Decimal baseAmount;

  /// Available amount denominated in rel asset units.
  final Decimal relAmount;

  /// Unique order identifier, if known.
  final String? uuid;

  /// Maker's public node key, if available.
  final String? pubkey;

  /// How long the order has been on the book.
  final Duration? age;
}

/// Immutable snapshot of an orderbook for a trading pair.
///
/// The lists are already sorted as commonly expected by UIs:
/// - [asks]: ascending by price (best ask first)
/// - [bids]: descending by price (best bid first)
class OrderbookSnapshot {
  /// Creates a new [OrderbookSnapshot].
  OrderbookSnapshot({
    required this.base,
    required this.rel,
    required this.asks,
    required this.bids,
    required this.timestamp,
  });

  /// Base asset ticker of the pair.
  final String base;

  /// Rel/quote asset ticker of the pair.
  final String rel;

  /// Sorted list of sell orders (lowest price first).
  final List<OrderbookEntry> asks;

  /// Sorted list of buy orders (highest price first).
  final List<OrderbookEntry> bids;

  /// Snapshot timestamp (local clock).
  final DateTime timestamp;
}

/// Progress update event for an active swap, suitable for streaming to UI.
///
/// Provides a coarse [status] plus an optional human-readable [message] and
/// structured [details] for advanced consumers.
class SwapProgress {
  /// Creates a new [SwapProgress] event.
  SwapProgress({
    required this.status,
    this.message,
    this.swapUuid,
    this.details,
  });

  /// Current high-level status in the swap lifecycle.
  final SwapStatus status;

  /// Human-readable progress message.
  final String? message;

  /// Swap identifier, if available.
  final String? swapUuid;

  /// Additional structured details (implementation-specific).
  final Map<String, dynamic>? details;
}

/// Simple coin+amount pair using Decimal precision.
class CoinAmount {
  CoinAmount({required this.coin, required this.amount});

  /// Coin ticker, e.g. "BTC".
  final String coin;

  /// Amount in coin units using Decimal precision.
  final Decimal amount;
}

/// Total fee entry for a coin with required balance information.
class TotalFeeEntry {
  TotalFeeEntry({
    required this.coin,
    required this.amount,
    required this.requiredBalance,
  });

  /// Coin ticker, e.g. "KMD".
  final String coin;

  /// Fee amount for this coin.
  final Decimal amount;

  /// Total required balance to perform the trade.
  final Decimal requiredBalance;
}

/// High-level estimate produced by a trade preimage call.
///
/// Presents fees as Decimal amounts and omits engine-specific rationals.
class TradePreimageQuote {
  TradePreimageQuote({
    this.baseCoinFee,
    this.relCoinFee,
    this.takerFee,
    this.feeToSendTakerFee,
    required this.totalFees,
  });

  /// Estimated fee taken from the base coin, if applicable.
  final CoinAmount? baseCoinFee;

  /// Estimated fee taken from the rel/quote coin, if applicable.
  final CoinAmount? relCoinFee;

  /// Estimated taker fee, if applicable.
  final CoinAmount? takerFee;

  /// Fee required to send the taker fee, if applicable.
  final CoinAmount? feeToSendTakerFee;

  /// Aggregated total fees and required balances per coin.
  final List<TotalFeeEntry> totalFees;
}

/// Concise summary of a swap suitable for listings and history views.
class SwapSummary {
  SwapSummary({
    required this.uuid,
    required this.makerCoin,
    required this.takerCoin,
    required this.makerAmount,
    required this.takerAmount,
    required this.isMaker,
    required this.successEvents,
    required this.errorEvents,
    this.startedAt,
    this.finishedAt,
  });

  /// Swap UUID.
  final String uuid;

  /// Maker side coin ticker.
  final String makerCoin;

  /// Taker side coin ticker.
  final String takerCoin;

  /// Amount sent by maker.
  final Decimal makerAmount;

  /// Amount sent by taker.
  final Decimal takerAmount;

  /// Whether current wallet participated as maker.
  final bool isMaker;

  /// Successful lifecycle events.
  final List<String> successEvents;

  /// Error lifecycle events.
  final List<String> errorEvents;

  /// Start time, if known.
  final DateTime? startedAt;

  /// Finish time, if known.
  final DateTime? finishedAt;

  /// True if swap reached a terminal state.
  bool get isComplete => finishedAt != null;

  /// True if swap completed without errors.
  bool get isSuccessful => isComplete && errorEvents.isEmpty;
}

/// Minimal representation of a best order from the DEX for a coin/action.
class BestOrder {
  BestOrder({
    required this.uuid,
    required this.price,
    required this.maxVolume,
    required this.coin,
    this.pubkey,
    this.age,
    this.address,
  });

  final String uuid;
  final Decimal price;
  final Decimal maxVolume;
  final String coin;
  final String? pubkey;
  final Duration? age;
  final String? address;
}

/// Result of aggregating best orders for a taker volume query.
class BestOrdersResult {
  BestOrdersResult({required this.orders});

  final List<BestOrder> orders;
}

/// One level fill of a taker orderbook sweep on a specific pair.
class LevelFill {
  LevelFill({required this.price, required this.base, required this.rel});

  /// Price (base in rel) at this level.
  final Decimal price;

  /// Base amount filled at this level.
  final Decimal base;

  /// Rel amount corresponding to [base] at [price].
  final Decimal rel;
}

/// Estimated taker fill on a pair, including average price and slippage breakdown.
class TakerFillEstimate {
  TakerFillEstimate({
    required this.totalBase,
    required this.totalRel,
    required this.averagePrice,
    required this.fills,
  });

  /// Total base amount to be filled.
  final Decimal totalBase;

  /// Total rel amount spent/received.
  final Decimal totalRel;

  /// Volume-weighted average price for the fill.
  final Decimal averagePrice;

  /// Per-level fills that compose the total.
  final List<LevelFill> fills;
}

/// High-level taker quote that combines orderbook sweep with a fee preimage.
class TakerQuote {
  TakerQuote({required this.fill, required this.preimage});

  final TakerFillEstimate fill;
  final TradePreimageQuote preimage;
}
