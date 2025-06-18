part of 'bridge_bloc.dart';

enum BridgeStep { form, confirm }

class BridgeState extends Equatable {
  const BridgeState({
    this.error,
    this.selectedTicker,
    this.availableTickers = const [],
    this.showTickerDropdown = false,
    this.showSourceDropdown = false,
    this.showTargetDropdown = false,
    this.sellAsset,
    this.sellAmount,
    this.buyAmount,
    this.sourceAssets = const [],
    this.bestOrder,
    this.bestOrders,
    this.maxSellAmount,
    this.minSellAmount,
    this.preimageData,
    this.inProgress = false,
    this.step = BridgeStep.form,
    this.swapUuid,
    this.autovalidate = false,
  });

  final String? error;
  final String? selectedTicker;
  final List<String> availableTickers;
  final bool showTickerDropdown;
  final bool showSourceDropdown;
  final bool showTargetDropdown;
  final Asset? sellAsset;
  final Decimal? sellAmount;
  final Decimal? buyAmount;
  final List<Asset> sourceAssets;
  final OrderData? bestOrder;
  final BestOrdersResponse? bestOrders;
  final Decimal? maxSellAmount;
  final Decimal? minSellAmount;
  final SwapPreview? preimageData;
  final bool inProgress;
  final BridgeStep step;
  final String? swapUuid;
  final bool autovalidate;

  static const BridgeState initial = BridgeState();

  BridgeState copyWith({
    Object? error = _noUpdate,
    String? selectedTicker,
    List<String>? availableTickers,
    bool? showTickerDropdown,
    bool? showSourceDropdown,
    bool? showTargetDropdown,
    Asset? sellAsset,
    Object? sellAmount = _noUpdate,
    Object? buyAmount = _noUpdate,
    List<Asset>? sourceAssets,
    Object? bestOrder = _noUpdate,
    BestOrdersResponse? bestOrders,
    Object? maxSellAmount = _noUpdate,
    Object? minSellAmount = _noUpdate,
    Object? preimageData = _noUpdate,
    bool? inProgress,
    BridgeStep? step,
    Object? swapUuid = _noUpdate,
    bool? autovalidate,
  }) {
    return BridgeState(
      error: identical(error, _noUpdate) ? this.error : error as String?,
      selectedTicker: selectedTicker ?? this.selectedTicker,
      availableTickers: availableTickers ?? this.availableTickers,
      showTickerDropdown: showTickerDropdown ?? this.showTickerDropdown,
      showSourceDropdown: showSourceDropdown ?? this.showSourceDropdown,
      showTargetDropdown: showTargetDropdown ?? this.showTargetDropdown,
      sellAsset: sellAsset ?? this.sellAsset,
      sellAmount:
          identical(sellAmount, _noUpdate)
              ? this.sellAmount
              : sellAmount as Decimal?,
      buyAmount:
          identical(buyAmount, _noUpdate)
              ? this.buyAmount
              : buyAmount as Decimal?,
      sourceAssets: sourceAssets ?? this.sourceAssets,
      bestOrder:
          identical(bestOrder, _noUpdate)
              ? this.bestOrder
              : bestOrder as OrderData?,
      bestOrders: bestOrders ?? this.bestOrders,
      maxSellAmount:
          identical(maxSellAmount, _noUpdate)
              ? this.maxSellAmount
              : maxSellAmount as Decimal?,
      minSellAmount:
          identical(minSellAmount, _noUpdate)
              ? this.minSellAmount
              : minSellAmount as Decimal?,
      preimageData:
          identical(preimageData, _noUpdate)
              ? this.preimageData
              : preimageData as SwapPreview?,
      inProgress: inProgress ?? this.inProgress,
      step: step ?? this.step,
      swapUuid:
          identical(swapUuid, _noUpdate) ? this.swapUuid : swapUuid as String?,
      autovalidate: autovalidate ?? this.autovalidate,
    );
  }

  static const _noUpdate = Object();

  @override
  List<Object?> get props => [
    error,
    selectedTicker,
    availableTickers,
    showTickerDropdown,
    showSourceDropdown,
    showTargetDropdown,
    sellAsset,
    sellAmount,
    buyAmount,
    sourceAssets,
    bestOrder,
    bestOrders,
    maxSellAmount,
    minSellAmount,
    preimageData,
    inProgress,
    step,
    swapUuid,
    autovalidate,
  ];
}
