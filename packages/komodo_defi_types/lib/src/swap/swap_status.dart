/// Status of a swap operation
enum SwapStatus {
  /// Swap is being initialized
  initializing,

  /// Looking for matching orders
  searchingForOrders,

  /// Placing maker order
  placingMakerOrder,

  /// Placing taker order
  placingTakerOrder,

  /// Swap is in progress
  inProgress,

  /// Swap completed successfully
  complete,

  /// Swap failed or was cancelled
  error;

  @override
  String toString() {
    switch (this) {
      case SwapStatus.initializing:
        return 'initializing';
      case SwapStatus.searchingForOrders:
        return 'searching_for_orders';
      case SwapStatus.placingMakerOrder:
        return 'placing_maker_order';
      case SwapStatus.placingTakerOrder:
        return 'placing_taker_order';
      case SwapStatus.inProgress:
        return 'in_progress';
      case SwapStatus.complete:
        return 'complete';
      case SwapStatus.error:
        return 'error';
    }
  }
}
