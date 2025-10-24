// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuildConfig _$BuildConfigFromJson(Map<String, dynamic> json) => _BuildConfig(
  api: ApiBuildUpdateConfig.fromJson(json['api'] as Map<String, dynamic>),
  coins: AssetRuntimeUpdateConfig.fromJson(
    json['coins'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$BuildConfigToJson(_BuildConfig instance) =>
    <String, dynamic>{
      'api': instance.api.toJson(),
      'coins': instance.coins.toJson(),
    };
