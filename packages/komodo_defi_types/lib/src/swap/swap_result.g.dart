// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwapResult _$SwapResultFromJson(Map<String, dynamic> json) => _SwapResult(
      uuid: json['uuid'] as String,
      base: json['base'] as String,
      rel: json['rel'] as String,
      price: const DecimalConverter().fromJson(json['price']),
      volume: const DecimalConverter().fromJson(json['volume']),
      orderType: json['orderType'] as String,
      txHash: json['txHash'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SwapResultToJson(_SwapResult instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'base': instance.base,
      'rel': instance.rel,
      'price': const DecimalConverter().toJson(instance.price),
      'volume': const DecimalConverter().toJson(instance.volume),
      'orderType': instance.orderType,
      'txHash': instance.txHash,
      'createdAt': instance.createdAt,
    };
