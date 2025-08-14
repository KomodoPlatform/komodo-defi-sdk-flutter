// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runtime_update_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RuntimeUpdateConfig _$RuntimeUpdateConfigFromJson(Map<String, dynamic> json) =>
    _RuntimeUpdateConfig(
      bundledCoinsRepoCommit: json['bundled_coins_repo_commit'] as String,
      coinsRepoApiUrl: json['coins_repo_api_url'] as String,
      coinsRepoContentUrl: json['coins_repo_content_url'] as String,
      coinsRepoBranch: json['coins_repo_branch'] as String,
      runtimeUpdatesEnabled: json['runtime_updates_enabled'] as bool,
    );

Map<String, dynamic> _$RuntimeUpdateConfigToJson(
  _RuntimeUpdateConfig instance,
) => <String, dynamic>{
  'bundled_coins_repo_commit': instance.bundledCoinsRepoCommit,
  'coins_repo_api_url': instance.coinsRepoApiUrl,
  'coins_repo_content_url': instance.coinsRepoContentUrl,
  'coins_repo_branch': instance.coinsRepoBranch,
  'runtime_updates_enabled': instance.runtimeUpdatesEnabled,
};
