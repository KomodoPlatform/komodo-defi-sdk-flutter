// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_parameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwapParameters _$SwapParametersFromJson(Map<String, dynamic> json) =>
    _SwapParameters(
      base: const AssetIdConverter().fromJson(json['base'] as String),
      rel: const AssetIdConverter().fromJson(json['rel'] as String),
      price: const DecimalConverter().fromJson(json['price']),
      volume: const DecimalConverter().fromJson(json['volume']),
      swapMethod: json['swap_method'] as String? ?? 'setprice',
      minVolume: const DecimalConverter().fromJson(json['min_volume']),
      baseConfs: (json['base_confs'] as num?)?.toInt(),
      baseNota: json['base_nota'] as bool?,
      relConfs: (json['rel_confs'] as num?)?.toInt(),
      relNota: json['rel_nota'] as bool?,
      saveInHistory: json['save_in_history'] as bool? ?? true,
    );

Map<String, dynamic> _$SwapParametersToJson(_SwapParameters instance) =>
    <String, dynamic>{
      'base': const AssetIdConverter().toJson(instance.base),
      'rel': const AssetIdConverter().toJson(instance.rel),
      'price': const DecimalConverter().toJson(instance.price),
      'volume': const DecimalConverter().toJson(instance.volume),
      'swap_method': instance.swapMethod,
      'min_volume': _$JsonConverterToJson<dynamic, Decimal>(
          instance.minVolume, const DecimalConverter().toJson),
      'base_confs': instance.baseConfs,
      'base_nota': instance.baseNota,
      'rel_confs': instance.relConfs,
      'rel_nota': instance.relNota,
      'save_in_history': instance.saveInHistory,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
