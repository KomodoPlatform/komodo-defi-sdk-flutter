/// Defines the method types available for swap operations.
///
/// This enum represents the different ways a swap can be initiated
/// in the Komodo DeFi Framework, determining the role and behavior
/// of the participant in the swap.
enum SwapMethod {
  /// Sets a maker order at a specific price.
  ///
  /// When using this method, the user becomes a maker, placing an order
  /// on the orderbook that waits to be matched by a taker. The order
  /// remains active until it's either matched, cancelled, or expires.
  setPrice,

  /// Initiates a buy swap as a taker.
  ///
  /// When using this method, the user becomes a taker, immediately
  /// attempting to match with the best available sell orders on the
  /// orderbook. The swap executes at the best available price.
  buy,

  /// Initiates a sell swap as a taker.
  ///
  /// When using this method, the user becomes a taker, immediately
  /// attempting to match with the best available buy orders on the
  /// orderbook. The swap executes at the best available price.
  sell;

  /// Converts this [SwapMethod] to its JSON representation.
  ///
  /// Returns a map with a single key corresponding to the method type,
  /// containing an empty map as its value. This format matches the
  /// expected API structure.
  ///
  /// Example outputs:
  /// - `setPrice` → `{"set_price": {}}`
  /// - `buy` → `{"buy": {}}`
  /// - `sell` → `{"sell": {}}`
  Map<String, Map<String, dynamic>> toJson() {
    switch (this) {
      case SwapMethod.setPrice:
        return <String, Map<String, dynamic>>{'set_price': <String, dynamic>{}};
      case SwapMethod.buy:
        return <String, Map<String, dynamic>>{'buy': <String, dynamic>{}};
      case SwapMethod.sell:
        return <String, Map<String, dynamic>>{'sell': <String, dynamic>{}};
    }
  }
}
