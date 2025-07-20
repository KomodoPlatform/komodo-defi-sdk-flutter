part of 'asset_market_info_cubit.dart';

class AssetMarketInfoState extends Equatable {
  const AssetMarketInfoState({this.usdBalance, this.price, this.change24h});

  final Decimal? usdBalance;
  final Decimal? price;
  final Decimal? change24h;

  AssetMarketInfoState copyWith({
    Decimal? usdBalance,
    Decimal? price,
    Decimal? change24h,
  }) {
    return AssetMarketInfoState(
      usdBalance: usdBalance ?? this.usdBalance,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
    );
  }

  @override
  List<Object?> get props => [usdBalance, price, change24h];
}
