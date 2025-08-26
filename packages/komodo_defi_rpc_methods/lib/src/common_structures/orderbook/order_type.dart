/// Defines the types of orders in trading operations.
/// 
/// This enum represents whether an order is a buy order or a sell order,
/// which determines the direction of the trade from the perspective of
/// the order creator.
enum OrderType {
  /// Represents a buy order.
  /// 
  /// The order creator wants to buy the base coin using the rel coin.
  /// In a BTC/USDT pair, a buy order means buying BTC with USDT.
  buy,

  /// Represents a sell order.
  /// 
  /// The order creator wants to sell the base coin for the rel coin.
  /// In a BTC/USDT pair, a sell order means selling BTC for USDT.
  sell;

  /// Converts this [OrderType] to its JSON string representation.
  /// 
  /// Returns the lowercase string name of the enum value.
  /// - `buy` → `"buy"`
  /// - `sell` → `"sell"`
  String toJson() => name;
}

/// Represents a trading pair in the orderbook.
/// 
/// This class defines a pair of coins that can be traded against each other,
/// with a base coin and a rel (relative/quote) coin. The convention follows
/// traditional trading pairs where BASE/REL represents trading BASE for REL.
class OrderbookPair {
  /// Creates a new [OrderbookPair] instance.
  /// 
  /// - [base]: The base coin in the trading pair (what you're buying/selling)
  /// - [rel]: The rel/quote coin in the trading pair (what you're paying with/receiving)
  OrderbookPair({
    required this.base,
    required this.rel,
  });

  /// The base coin in the trading pair.
  /// 
  /// This is the coin being bought or sold. In a BTC/USDT pair,
  /// BTC would be the base coin.
  final String base;

  /// The rel (relative/quote) coin in the trading pair.
  /// 
  /// This is the coin used to price the base coin. In a BTC/USDT pair,
  /// USDT would be the rel coin.
  final String rel;

  /// Converts this [OrderbookPair] instance to a JSON map.
  /// 
  /// Returns a map with `base` and `rel` keys containing the respective
  /// coin tickers.
  Map<String, dynamic> toJson() => {
    'base': base,
    'rel': rel,
  };
}