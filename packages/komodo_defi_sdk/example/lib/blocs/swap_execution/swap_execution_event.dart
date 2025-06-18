part of 'swap_execution_bloc.dart';

abstract class SwapExecutionEvent extends Equatable {
  const SwapExecutionEvent();

  @override
  List<Object?> get props => [];
}

class SellAssetSelected extends SwapExecutionEvent {
  const SellAssetSelected(this.asset);

  final Asset asset;

  @override
  List<Object?> get props => [asset];
}

class BuyAssetSelected extends SwapExecutionEvent {
  const BuyAssetSelected(this.asset);

  final Asset asset;

  @override
  List<Object?> get props => [asset];
}

class VolumeChanged extends SwapExecutionEvent {
  const VolumeChanged(this.volume);

  final Decimal volume;

  @override
  List<Object?> get props => [volume];
}

class PriceChanged extends SwapExecutionEvent {
  const PriceChanged(this.price);

  final Decimal price;

  @override
  List<Object?> get props => [price];
}

class PreviewSwapRequested extends SwapExecutionEvent {
  const PreviewSwapRequested();
}

class SwapRequested extends SwapExecutionEvent {
  const SwapRequested();
}

class SwapCancelRequested extends SwapExecutionEvent {
  const SwapCancelRequested();
}

class SwapProgressUpdated extends SwapExecutionEvent {
  const SwapProgressUpdated(this.progress);

  final SwapProgress progress;

  @override
  List<Object?> get props => [progress];
}

class ResetSwap extends SwapExecutionEvent {
  const ResetSwap();
}
