// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coinpaprika_coin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinPaprikaCoin _$CoinPaprikaCoinFromJson(Map<String, dynamic> json) =>
    _CoinPaprikaCoin(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      rank: (json['rank'] as num).toInt(),
      isNew: json['is_new'] as bool,
      isActive: json['is_active'] as bool,
      type: json['type'] as String,
    );

Map<String, dynamic> _$CoinPaprikaCoinToJson(_CoinPaprikaCoin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'symbol': instance.symbol,
      'rank': instance.rank,
      'is_new': instance.isNew,
      'is_active': instance.isActive,
      'type': instance.type,
    };
