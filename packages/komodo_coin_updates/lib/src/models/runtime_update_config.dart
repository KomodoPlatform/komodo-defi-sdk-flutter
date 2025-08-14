import 'package:freezed_annotation/freezed_annotation.dart';

part 'runtime_update_config.freezed.dart';
part 'runtime_update_config.g.dart';

@freezed
abstract class RuntimeUpdateConfig with _$RuntimeUpdateConfig {
  const factory RuntimeUpdateConfig({
    required String bundledCoinsRepoCommit,
    required String coinsRepoApiUrl,
    required String coinsRepoContentUrl,
    required String coinsRepoBranch,
    required bool runtimeUpdatesEnabled,
  }) = _RuntimeUpdateConfig;

  factory RuntimeUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$RuntimeUpdateConfigFromJson(json);
}
