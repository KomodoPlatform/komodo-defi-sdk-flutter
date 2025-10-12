// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_api_endpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosApiEndpoint _$CosmosApiEndpointFromJson(Map<String, dynamic> json) =>
    _CosmosApiEndpoint(
      address: json['address'] as String,
      provider: json['provider'] as String?,
    );

Map<String, dynamic> _$CosmosApiEndpointToJson(_CosmosApiEndpoint instance) =>
    <String, dynamic>{
      'address': instance.address,
      'provider': instance.provider,
    };
