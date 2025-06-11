// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderbook_depth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderbookDepthResponse _$OrderbookDepthResponseFromJson(
  Map<String, dynamic> json,
) => _OrderbookDepthResponse(
  mmrpc: json['mmrpc'] as String?,
  id: json['id'] as String?,
  result:
      (json['result'] as List<dynamic>)
          .map((e) => PairDepth.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$OrderbookDepthResponseToJson(
  _OrderbookDepthResponse instance,
) => <String, dynamic>{
  'mmrpc': instance.mmrpc,
  'id': instance.id,
  'result': instance.result,
};

_PairDepth _$PairDepthFromJson(Map<String, dynamic> json) => _PairDepth(
  pair: (json['pair'] as List<dynamic>).map((e) => e as String).toList(),
  depth: DepthInfo.fromJson(json['depth'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PairDepthToJson(_PairDepth instance) =>
    <String, dynamic>{'pair': instance.pair, 'depth': instance.depth};

_DepthInfo _$DepthInfoFromJson(Map<String, dynamic> json) => _DepthInfo(
  asks: (json['asks'] as num).toInt(),
  bids: (json['bids'] as num).toInt(),
);

Map<String, dynamic> _$DepthInfoToJson(_DepthInfo instance) =>
    <String, dynamic>{'asks': instance.asks, 'bids': instance.bids};
