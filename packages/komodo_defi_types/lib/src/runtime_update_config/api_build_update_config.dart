import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_build_update_config.freezed.dart';
part 'api_build_update_config.g.dart';

/// Platform-specific binary configuration used by API build updates.
@freezed
abstract class ApiPlatformConfig with _$ApiPlatformConfig {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory ApiPlatformConfig({
    required String matchingPattern,
    required String path,
    @Default(<String>[]) List<String> validZipSha256Checksums,
  }) = _ApiPlatformConfig;

  factory ApiPlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$ApiPlatformConfigFromJson(json);
}

/// Configuration for the KDF API/build binary update process.
@freezed
abstract class ApiBuildUpdateConfig with _$ApiBuildUpdateConfig {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory ApiBuildUpdateConfig({
    required String apiCommitHash,
    required String branch,
    @Default(true) bool fetchAtBuildEnabled,
    @Default(false) bool concurrentDownloadsEnabled,
    @Default(<String>[]) List<String> sourceUrls,
    @Default(<String, ApiPlatformConfig>{})
    Map<String, ApiPlatformConfig> platforms,
  }) = _ApiBuildUpdateConfig;

  factory ApiBuildUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$ApiBuildUpdateConfigFromJson(json);
}
