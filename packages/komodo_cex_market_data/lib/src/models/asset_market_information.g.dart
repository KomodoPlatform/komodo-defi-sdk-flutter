// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_market_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetMarketInformation _$AssetMarketInformationFromJson(
  Map<String, dynamic> json,
) => _AssetMarketInformation(
  ticker: json['ticker'] as String,
  lastPrice: Decimal.fromJson(json['last_price'] as String),
  lastUpdatedTimestamp: const TimestampConverter().fromJson(
    (json['last_updated_timestamp'] as num?)?.toInt(),
  ),
  priceProvider: const CexDataProviderConverter().fromJson(
    json['price_provider'] as String?,
  ),
  change24h: const DecimalConverter().fromJson(json['change24h'] as String?),
  change24hProvider: const CexDataProviderConverter().fromJson(
    json['change24h_provider'] as String?,
  ),
  volume24h: const DecimalConverter().fromJson(json['volume24h'] as String?),
  volumeProvider: const CexDataProviderConverter().fromJson(
    json['volume_provider'] as String?,
  ),
);

Map<String, dynamic> _$AssetMarketInformationToJson(
  _AssetMarketInformation instance,
) => <String, dynamic>{
  'ticker': instance.ticker,
  'last_price': instance.lastPrice,
  'last_updated_timestamp': const TimestampConverter().toJson(
    instance.lastUpdatedTimestamp,
  ),
  'price_provider': const CexDataProviderConverter().toJson(
    instance.priceProvider,
  ),
  'change24h': const DecimalConverter().toJson(instance.change24h),
  'change24h_provider': const CexDataProviderConverter().toJson(
    instance.change24hProvider,
  ),
  'volume24h': const DecimalConverter().toJson(instance.volume24h),
  'volume_provider': const CexDataProviderConverter().toJson(
    instance.volumeProvider,
  ),
};
