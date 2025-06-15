/// Error codes for swap operations
enum SwapErrorCode {
  /// Insufficient funds for the swap
  insufficientFunds,

  /// Invalid trading pair
  invalidTradingPair,

  /// Network error occurred
  networkError,

  /// Order matching failed
  orderMatchingFailed,

  /// Price has changed significantly
  priceSlippage,

  /// User cancelled the operation
  userCancelled,

  /// Asset not activated
  assetNotActivated,

  /// Unknown error occurred
  unknownError;

  @override
  String toString() {
    switch (this) {
      case SwapErrorCode.insufficientFunds:
        return 'insufficient_funds';
      case SwapErrorCode.invalidTradingPair:
        return 'invalid_trading_pair';
      case SwapErrorCode.networkError:
        return 'network_error';
      case SwapErrorCode.orderMatchingFailed:
        return 'order_matching_failed';
      case SwapErrorCode.priceSlippage:
        return 'price_slippage';
      case SwapErrorCode.userCancelled:
        return 'user_cancelled';
      case SwapErrorCode.assetNotActivated:
        return 'asset_not_activated';
      case SwapErrorCode.unknownError:
        return 'unknown_error';
    }
  }
}
