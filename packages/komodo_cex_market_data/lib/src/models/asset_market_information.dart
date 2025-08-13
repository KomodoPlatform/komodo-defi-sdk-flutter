import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_cex_market_data/src/models/json_converters.dart';

part 'asset_market_information.freezed.dart';
part 'asset_market_information.g.dart';

/// A class for representing price information of an asset in a centralized exchange (CEX).
/// This class includes details such as the ticker symbol, last price, last updated timestamp,
/// price provider, 24-hour price change, and volume information.
/// TODO: consider migrating to [CoinMarketData] or adding more fields from that model here.
@freezed
abstract class AssetMarketInformation with _$AssetMarketInformation {
  /// Creates a new instance of [AssetMarketInformation].
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AssetMarketInformation({
    required String ticker,
    @DecimalConverter() required Decimal lastPrice,
    @TimestampConverter() DateTime? lastUpdatedTimestamp,
    @CexDataProviderConverter() CexDataProvider? priceProvider,
    @JsonKey(name: 'change_24h') @DecimalConverter() Decimal? change24h,
    @JsonKey(name: 'change_24h_provider')
    @CexDataProviderConverter()
    CexDataProvider? change24hProvider,
    @DecimalConverter() Decimal? volume24h,
    @CexDataProviderConverter() CexDataProvider? volumeProvider,
  }) = _AssetMarketInformation;

  /// Creates a new instance of [AssetMarketInformation] from a JSON object.
  factory AssetMarketInformation.fromJson(Map<String, dynamic> json) =>
      _$AssetMarketInformationFromJson(json);
}

/// An enum for representing a CEX data provider.
enum CexDataProvider {
  /// Binance API.
  binance,

  /// CoinGecko API.
  coingecko,

  /// CoinMarketCap API.
  coinpaprika,

  /// CryptoCompare API.
  nomics,

  /// Unknown provider.
  unknown;

  /// Returns a [CexDataProvider] from a string. If the string does not match any
  /// of the known providers, [CexDataProvider.unknown] is returned.
  static CexDataProvider fromString(String string) {
    return CexDataProvider.values.firstWhere(
      (CexDataProvider e) => e.name == string,
      orElse: () => CexDataProvider.unknown,
    );
  }

  @override
  String toString() => name;
}

/// Custom converter for CexDataProvider
class CexDataProviderConverter
    implements JsonConverter<CexDataProvider?, String?> {
  const CexDataProviderConverter();

  @override
  CexDataProvider? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    return CexDataProvider.fromString(json);
  }

  @override
  String? toJson(CexDataProvider? provider) {
    return provider?.name;
  }
}
