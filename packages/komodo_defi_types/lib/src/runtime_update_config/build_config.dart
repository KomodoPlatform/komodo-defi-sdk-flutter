import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:komodo_defi_types/src/runtime_update_config/api_build_update_config.dart';
import 'package:komodo_defi_types/src/runtime_update_config/asset_runtime_update_config.dart';

part 'build_config.freezed.dart';
part 'build_config.g.dart';

/// Full app build configuration as embedded in app_build/build_config.json
@freezed
abstract class BuildConfig with _$BuildConfig {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory BuildConfig({
    required ApiBuildUpdateConfig api,
    required AssetRuntimeUpdateConfig coins,
  }) = _BuildConfig;

  factory BuildConfig.fromJson(Map<String, dynamic> json) =>
      _$BuildConfigFromJson(json);
}
