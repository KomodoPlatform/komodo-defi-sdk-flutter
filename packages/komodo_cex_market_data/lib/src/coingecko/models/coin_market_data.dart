import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_cex_market_data/src/models/json_converters.dart';

part 'coin_market_data.freezed.dart';
part 'coin_market_data.g.dart';

/// Represents the market data of a coin.
@freezed
abstract class CoinMarketData with _$CoinMarketData {
  /// Creates a new instance of [CoinMarketData].
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoinMarketData({
    String? id,
    String? symbol,
    String? name,
    String? image,
    @DecimalConverter() Decimal? currentPrice,
    @DecimalConverter() Decimal? marketCap,
    @DecimalConverter() Decimal? marketCapRank,
    @DecimalConverter() Decimal? fullyDilutedValuation,
    @DecimalConverter() Decimal? totalVolume,
    @DecimalConverter() Decimal? high24h,
    @DecimalConverter() Decimal? low24h,
    @DecimalConverter() Decimal? priceChange24h,
    @DecimalConverter() Decimal? priceChangePercentage24h,
    @DecimalConverter() Decimal? marketCapChange24h,
    @DecimalConverter() Decimal? marketCapChangePercentage24h,
    @DecimalConverter() Decimal? circulatingSupply,
    @DecimalConverter() Decimal? totalSupply,
    @DecimalConverter() Decimal? maxSupply,
    @DecimalConverter() Decimal? ath,
    @DecimalConverter() Decimal? athChangePercentage,
    DateTime? athDate,
    @DecimalConverter() Decimal? atl,
    @DecimalConverter() Decimal? atlChangePercentage,
    DateTime? atlDate,
    dynamic roi,
    DateTime? lastUpdated,
  }) = _CoinMarketData;

  /// Creates a new instance of [CoinMarketData] from a JSON object.
  factory CoinMarketData.fromJson(Map<String, dynamic> json) =>
      _$CoinMarketDataFromJson(json);
}
