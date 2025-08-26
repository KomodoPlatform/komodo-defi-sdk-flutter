// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_build_update_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiPlatformConfig _$ApiPlatformConfigFromJson(Map<String, dynamic> json) =>
    _ApiPlatformConfig(
      matchingPattern: json['matching_pattern'] as String,
      path: json['path'] as String,
      validZipSha256Checksums:
          (json['valid_zip_sha256_checksums'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ApiPlatformConfigToJson(_ApiPlatformConfig instance) =>
    <String, dynamic>{
      'matching_pattern': instance.matchingPattern,
      'path': instance.path,
      'valid_zip_sha256_checksums': instance.validZipSha256Checksums,
    };

_ApiBuildUpdateConfig _$ApiBuildUpdateConfigFromJson(
  Map<String, dynamic> json,
) => _ApiBuildUpdateConfig(
  apiCommitHash: json['api_commit_hash'] as String,
  branch: json['branch'] as String,
  fetchAtBuildEnabled: json['fetch_at_build_enabled'] as bool? ?? true,
  concurrentDownloadsEnabled:
      json['concurrent_downloads_enabled'] as bool? ?? false,
  sourceUrls:
      (json['source_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  platforms:
      (json['platforms'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ApiPlatformConfig.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, ApiPlatformConfig>{},
);

Map<String, dynamic> _$ApiBuildUpdateConfigToJson(
  _ApiBuildUpdateConfig instance,
) => <String, dynamic>{
  'api_commit_hash': instance.apiCommitHash,
  'branch': instance.branch,
  'fetch_at_build_enabled': instance.fetchAtBuildEnabled,
  'concurrent_downloads_enabled': instance.concurrentDownloadsEnabled,
  'source_urls': instance.sourceUrls,
  'platforms': instance.platforms.map((k, e) => MapEntry(k, e.toJson())),
};
