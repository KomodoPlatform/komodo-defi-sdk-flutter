import 'package:freezed_annotation/freezed_annotation.dart';

part 'runtime_update_config.freezed.dart';
part 'runtime_update_config.g.dart';

@freezed
abstract class RuntimeUpdateConfig with _$RuntimeUpdateConfig {
  const factory RuntimeUpdateConfig({
    // Mirrors `coins` section in build_config.json
    required bool fetchAtBuildEnabled,
    required bool updateCommitOnBuild,
    required String bundledCoinsRepoCommit,
    required String coinsRepoApiUrl,
    required String coinsRepoContentUrl,
    required String coinsRepoBranch,
    required bool runtimeUpdatesEnabled,
    required Map<String, String> mappedFiles,
    required Map<String, String> mappedFolders,
    required bool concurrentDownloadsEnabled,
    required Map<String, String> cdnBranchMirrors,
  }) = _RuntimeUpdateConfig;

  factory RuntimeUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$RuntimeUpdateConfigFromJson(json);
}
