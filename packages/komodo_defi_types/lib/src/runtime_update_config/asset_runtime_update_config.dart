import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_runtime_update_config.freezed.dart';
part 'asset_runtime_update_config.g.dart';

/// Configuration for the runtime update process.
///
/// Mirrors the `coins` section in build_config.json.
@freezed
abstract class AssetRuntimeUpdateConfig with _$AssetRuntimeUpdateConfig {
  /// Configuration for the runtime update process.
  ///
  /// Mirrors the `coins` section in build_config.json.
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory AssetRuntimeUpdateConfig({
    // Mirrors `coins` section in build_config.json
    @Default(true) bool fetchAtBuildEnabled,
    @Default(true) bool updateCommitOnBuild,
    @Default('master') String bundledCoinsRepoCommit,
    @Default('https://api.github.com/repos/KomodoPlatform/coins')
    String coinsRepoApiUrl,
    @Default('https://raw.githubusercontent.com/KomodoPlatform/coins')
    String coinsRepoContentUrl,
    @Default('master') String coinsRepoBranch,
    @Default(true) bool runtimeUpdatesEnabled,
    @Default(<String, String>{
      'assets/config/coins_config.json': 'utils/coins_config_unfiltered.json',
      'assets/config/coins.json': 'coins',
      'assets/config/seed_nodes.json': 'seed-nodes.json',
    })
    Map<String, String> mappedFiles,
    @Default(<String, String>{'assets/coin_icons/png/': 'icons'})
    Map<String, String> mappedFolders,
    @Default(false) bool concurrentDownloadsEnabled,
    @Default(<String, String>{
      'master': 'https://komodoplatform.github.io/coins',
      'main': 'https://komodoplatform.github.io/coins',
    })
    Map<String, String> cdnBranchMirrors,
  }) = _AssetRuntimeUpdateConfig;

  /// Creates a [AssetRuntimeUpdateConfig] from a JSON map.
  factory AssetRuntimeUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$AssetRuntimeUpdateConfigFromJson(json);
}
