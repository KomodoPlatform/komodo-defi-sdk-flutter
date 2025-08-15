// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runtime_update_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RuntimeUpdateConfig _$RuntimeUpdateConfigFromJson(Map<String, dynamic> json) =>
    _RuntimeUpdateConfig(
      fetchAtBuildEnabled: json['fetch_at_build_enabled'] as bool,
      updateCommitOnBuild: json['update_commit_on_build'] as bool,
      bundledCoinsRepoCommit: json['bundled_coins_repo_commit'] as String,
      coinsRepoApiUrl: json['coins_repo_api_url'] as String,
      coinsRepoContentUrl: json['coins_repo_content_url'] as String,
      coinsRepoBranch: json['coins_repo_branch'] as String,
      runtimeUpdatesEnabled: json['runtime_updates_enabled'] as bool,
      mappedFiles: Map<String, String>.from(json['mapped_files'] as Map),
      mappedFolders: Map<String, String>.from(json['mapped_folders'] as Map),
      concurrentDownloadsEnabled: json['concurrent_downloads_enabled'] as bool,
      cdnBranchMirrors: Map<String, String>.from(
        json['cdn_branch_mirrors'] as Map,
      ),
    );

Map<String, dynamic> _$RuntimeUpdateConfigToJson(
  _RuntimeUpdateConfig instance,
) => <String, dynamic>{
  'fetch_at_build_enabled': instance.fetchAtBuildEnabled,
  'update_commit_on_build': instance.updateCommitOnBuild,
  'bundled_coins_repo_commit': instance.bundledCoinsRepoCommit,
  'coins_repo_api_url': instance.coinsRepoApiUrl,
  'coins_repo_content_url': instance.coinsRepoContentUrl,
  'coins_repo_branch': instance.coinsRepoBranch,
  'runtime_updates_enabled': instance.runtimeUpdatesEnabled,
  'mapped_files': instance.mappedFiles,
  'mapped_folders': instance.mappedFolders,
  'concurrent_downloads_enabled': instance.concurrentDownloadsEnabled,
  'cdn_branch_mirrors': instance.cdnBranchMirrors,
};
