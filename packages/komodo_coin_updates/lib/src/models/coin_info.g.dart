// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinInfo _$CoinInfoFromJson(Map<String, dynamic> json) => _CoinInfo(
  coin: Coin.fromJson(json['coin'] as Map<String, dynamic>),
  coinConfig:
      json['coin_config'] == null
          ? null
          : CoinConfig.fromJson(json['coin_config'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CoinInfoToJson(_CoinInfo instance) => <String, dynamic>{
  'coin': instance.coin,
  'coin_config': instance.coinConfig,
};
