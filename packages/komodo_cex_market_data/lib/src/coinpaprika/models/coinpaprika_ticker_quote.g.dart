// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coinpaprika_ticker_quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinPaprikaTickerQuote _$CoinPaprikaTickerQuoteFromJson(
  Map<String, dynamic> json,
) => _CoinPaprikaTickerQuote(
  price: (json['price'] as num).toDouble(),
  volume24h: (json['volume24h'] as num?)?.toDouble() ?? 0.0,
  volume24hChange24h: (json['volume24h_change24h'] as num?)?.toDouble() ?? 0.0,
  marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
  marketCapChange24h: (json['market_cap_change24h'] as num?)?.toDouble() ?? 0.0,
  percentChange15m: (json['percent_change15m'] as num?)?.toDouble() ?? 0.0,
  percentChange30m: (json['percent_change30m'] as num?)?.toDouble() ?? 0.0,
  percentChange1h: (json['percent_change1h'] as num?)?.toDouble() ?? 0.0,
  percentChange6h: (json['percent_change6h'] as num?)?.toDouble() ?? 0.0,
  percentChange12h: (json['percent_change12h'] as num?)?.toDouble() ?? 0.0,
  percentChange24h: (json['percent_change24h'] as num?)?.toDouble() ?? 0.0,
  percentChange7d: (json['percent_change7d'] as num?)?.toDouble() ?? 0.0,
  percentChange30d: (json['percent_change30d'] as num?)?.toDouble() ?? 0.0,
  percentChange1y: (json['percent_change1y'] as num?)?.toDouble() ?? 0.0,
  athPrice: (json['ath_price'] as num?)?.toDouble(),
  athDate: json['ath_date'] == null
      ? null
      : DateTime.parse(json['ath_date'] as String),
  percentFromPriceAth: (json['percent_from_price_ath'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CoinPaprikaTickerQuoteToJson(
  _CoinPaprikaTickerQuote instance,
) => <String, dynamic>{
  'price': instance.price,
  'volume24h': instance.volume24h,
  'volume24h_change24h': instance.volume24hChange24h,
  'market_cap': instance.marketCap,
  'market_cap_change24h': instance.marketCapChange24h,
  'percent_change15m': instance.percentChange15m,
  'percent_change30m': instance.percentChange30m,
  'percent_change1h': instance.percentChange1h,
  'percent_change6h': instance.percentChange6h,
  'percent_change12h': instance.percentChange12h,
  'percent_change24h': instance.percentChange24h,
  'percent_change7d': instance.percentChange7d,
  'percent_change30d': instance.percentChange30d,
  'percent_change1y': instance.percentChange1y,
  'ath_price': instance.athPrice,
  'ath_date': instance.athDate?.toIso8601String(),
  'percent_from_price_ath': instance.percentFromPriceAth,
};
