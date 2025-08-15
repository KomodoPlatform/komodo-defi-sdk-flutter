import 'package:freezed_annotation/freezed_annotation.dart';

part 'runtime_update_config.freezed.dart';
part 'runtime_update_config.g.dart';

/// Configuration for the runtime update process.
///
/// Mirrors the `coins` section in build_config.json.
@freezed
abstract class RuntimeUpdateConfig with _$RuntimeUpdateConfig {
  /// Configuration for the runtime update process.
  ///
  /// Mirrors the `coins` section in build_config.json.
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

  /// Returns a default [RuntimeUpdateConfig] with conservative defaults.
  ///
  /// This is useful for fallback scenarios where the config is not available.
  factory RuntimeUpdateConfig.withDefaults() => const RuntimeUpdateConfig(
    fetchAtBuildEnabled: true,
    updateCommitOnBuild: true,
    bundledCoinsRepoCommit: 'master',
    coinsRepoApiUrl: 'https://api.github.com/repos/KomodoPlatform/coins',
    coinsRepoContentUrl:
        'https://raw.githubusercontent.com/KomodoPlatform/coins',
    coinsRepoBranch: 'master',
    runtimeUpdatesEnabled: true,
    mappedFiles: {
      'assets/config/coins_config.json': 'utils/coins_config_unfiltered.json',
      'assets/config/coins.json': 'coins',
      'assets/config/seed_nodes.json': 'seed-nodes.json',
    },
    mappedFolders: {'assets/coin_icons/png/': 'icons'},
    concurrentDownloadsEnabled: false,
    cdnBranchMirrors: {
      'master': 'https://komodoplatform.github.io/coins',
      'main': 'https://komodoplatform.github.io/coins',
    },
  );

  /// Creates a [RuntimeUpdateConfig] from a JSON map.
  factory RuntimeUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$RuntimeUpdateConfigFromJson(json);
}
