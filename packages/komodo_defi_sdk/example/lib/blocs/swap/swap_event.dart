part of 'swap_bloc.dart';

abstract class SwapEvent extends Equatable {
  const SwapEvent();

  @override
  List<Object?> get props => [];
}

class SellAssetSelected extends SwapEvent {
  const SellAssetSelected(this.asset);

  final Asset asset;

  @override
  List<Object?> get props => [asset];
}

class BuyAssetSelected extends SwapEvent {
  const BuyAssetSelected(this.asset);

  final Asset asset;

  @override
  List<Object?> get props => [asset];
}
