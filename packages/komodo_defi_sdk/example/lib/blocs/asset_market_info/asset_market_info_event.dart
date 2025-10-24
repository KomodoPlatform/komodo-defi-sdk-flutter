part of 'asset_market_info_bloc.dart';

abstract class AssetMarketInfoEvent extends Equatable {
  const AssetMarketInfoEvent();

  @override
  List<Object> get props => [];
}

class AssetMarketInfoRequested extends AssetMarketInfoEvent {
  const AssetMarketInfoRequested(this.asset);

  final Asset asset;

  @override
  List<Object> get props => [asset];
}
