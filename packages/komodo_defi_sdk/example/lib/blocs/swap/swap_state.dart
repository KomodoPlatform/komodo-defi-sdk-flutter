part of 'swap_bloc.dart';

class SwapState extends Equatable {
  const SwapState({
    this.sellAsset,
    this.buyAsset,
    this.bestOrders,
    this.orderbook,
    this.loadingBestOrders = false,
    this.loadingOrderbook = false,
    this.error,
  });

  final Asset? sellAsset;
  final Asset? buyAsset;
  final BestOrdersResponse? bestOrders;
  final OrderbookResponse? orderbook;
  final bool loadingBestOrders;
  final bool loadingOrderbook;
  final String? error;

  SwapState copyWith({
    Asset? sellAsset,
    Asset? buyAsset,
    BestOrdersResponse? bestOrders,
    OrderbookResponse? orderbook,
    bool? loadingBestOrders,
    bool? loadingOrderbook,
    Object? error = _noUpdate,
  }) {
    return SwapState(
      sellAsset: sellAsset ?? this.sellAsset,
      buyAsset: buyAsset ?? this.buyAsset,
      bestOrders: bestOrders ?? this.bestOrders,
      orderbook: orderbook ?? this.orderbook,
      loadingBestOrders: loadingBestOrders ?? this.loadingBestOrders,
      loadingOrderbook: loadingOrderbook ?? this.loadingOrderbook,
      error: identical(error, _noUpdate) ? this.error : error as String?,
    );
  }

  static const _noUpdate = Object();

  @override
  List<Object?> get props => [
    sellAsset,
    buyAsset,
    bestOrders,
    orderbook,
    loadingBestOrders,
    loadingOrderbook,
    error,
  ];
}
