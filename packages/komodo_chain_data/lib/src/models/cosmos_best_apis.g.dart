// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_best_apis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosBestApis _$CosmosBestApisFromJson(Map<String, dynamic> json) =>
    _CosmosBestApis(
      rest: (json['rest'] as List<dynamic>)
          .map((e) => CosmosApiEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      rpc: (json['rpc'] as List<dynamic>)
          .map((e) => CosmosApiEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CosmosBestApisToJson(_CosmosBestApis instance) =>
    <String, dynamic>{'rest': instance.rest, 'rpc': instance.rpc};
