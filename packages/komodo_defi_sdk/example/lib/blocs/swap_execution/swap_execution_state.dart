part of 'swap_execution_bloc.dart';

class SwapExecutionState extends Equatable {
  const SwapExecutionState({
    this.sellAsset,
    this.buyAsset,
    this.volume,
    this.price,
    this.swapPreview,
    this.swapProgress,
    this.isLoadingPreview = false,
    this.isSwapping = false,
    this.error,
  });

  final Asset? sellAsset;
  final Asset? buyAsset;
  final Decimal? volume;
  final Decimal? price;
  final SwapPreview? swapPreview;
  final SwapProgress? swapProgress;
  final bool isLoadingPreview;
  final bool isSwapping;
  final String? error;

  bool get canPreview =>
      sellAsset != null &&
      buyAsset != null &&
      volume != null &&
      price != null &&
      !isLoadingPreview;

  bool get canSwap => swapPreview != null && !isSwapping && !isLoadingPreview;

  bool get hasActiveSwap => swapProgress != null && isSwapping;

  SwapExecutionState copyWith({
    Asset? sellAsset,
    Asset? buyAsset,
    Decimal? volume,
    Decimal? price,
    SwapPreview? swapPreview,
    SwapProgress? swapProgress,
    bool? isLoadingPreview,
    bool? isSwapping,
    Object? error = _noUpdate,
  }) {
    return SwapExecutionState(
      sellAsset: sellAsset ?? this.sellAsset,
      buyAsset: buyAsset ?? this.buyAsset,
      volume: volume ?? this.volume,
      price: price ?? this.price,
      swapPreview: swapPreview ?? this.swapPreview,
      swapProgress: swapProgress ?? this.swapProgress,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      isSwapping: isSwapping ?? this.isSwapping,
      error: identical(error, _noUpdate) ? this.error : error as String?,
    );
  }

  static const _noUpdate = Object();

  @override
  List<Object?> get props => [
    sellAsset,
    buyAsset,
    volume,
    price,
    swapPreview,
    swapProgress,
    isLoadingPreview,
    isSwapping,
    error,
  ];
}
