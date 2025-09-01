// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coinpaprika_ticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinPaprikaTicker _$CoinPaprikaTickerFromJson(Map<String, dynamic> json) =>
    _CoinPaprikaTicker(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      circulatingSupply: (json['circulating_supply'] as num?)?.toInt() ?? 0,
      totalSupply: (json['total_supply'] as num?)?.toInt() ?? 0,
      maxSupply: (json['max_supply'] as num?)?.toInt(),
      betaValue: (json['beta_value'] as num?)?.toDouble() ?? 0.0,
      firstDataAt: json['first_data_at'] == null
          ? null
          : DateTime.parse(json['first_data_at'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      quotes: (json['quotes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          CoinPaprikaTickerQuote.fromJson(e as Map<String, dynamic>),
        ),
      ),
    );

Map<String, dynamic> _$CoinPaprikaTickerToJson(_CoinPaprikaTicker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'symbol': instance.symbol,
      'rank': instance.rank,
      'circulating_supply': instance.circulatingSupply,
      'total_supply': instance.totalSupply,
      'max_supply': instance.maxSupply,
      'beta_value': instance.betaValue,
      'first_data_at': instance.firstDataAt?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'quotes': instance.quotes,
    };
