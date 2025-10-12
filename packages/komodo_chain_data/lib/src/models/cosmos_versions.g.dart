// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_versions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosVersions _$CosmosVersionsFromJson(Map<String, dynamic> json) =>
    _CosmosVersions(
      applicationVersion: json['application_version'] as String?,
      cosmosSdkVersion: json['cosmos_sdk_version'] as String?,
      tendermintVersion: json['tendermint_version'] as String?,
    );

Map<String, dynamic> _$CosmosVersionsToJson(_CosmosVersions instance) =>
    <String, dynamic>{
      'application_version': instance.applicationVersion,
      'cosmos_sdk_version': instance.cosmosSdkVersion,
      'tendermint_version': instance.tendermintVersion,
    };
