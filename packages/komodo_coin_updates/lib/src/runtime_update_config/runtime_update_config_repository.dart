import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';

/// Loads the coins runtime update configuration from a build_config.json
/// bundled in a dependency package (defaults to `komodo_defi_framework`).
class RuntimeUpdateConfigRepository {
  /// Creates a runtime update config repository.
  ///
  /// - [packageName]: the name of the package containing the runtime update config asset.
  /// - [assetPath]: the path to the runtime update config asset.
  /// - [bundle]: the asset bundle to load the runtime update config from.
  RuntimeUpdateConfigRepository({
    this.packageName = 'komodo_defi_framework',
    this.assetPath = 'app_build/build_config.json',
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  /// The package that declares the `build_config.json` as an asset.
  final String packageName;

  /// The path to the `build_config.json` within the package.
  final String assetPath;

  final AssetBundle _bundle;

  /// Loads the coins runtime configuration from the `build_config.json` asset.
  /// Returns `null` if loading or parsing fails.
  Future<RuntimeUpdateConfig?> tryLoad() async {
    final assetUri = 'packages/$packageName/$assetPath';
    try {
      final content = await _bundle.loadString(assetUri);
      final json = jsonDecode(content) as Map<String, dynamic>;
      final coins = json['coins'] as Map<String, dynamic>;
      return RuntimeUpdateConfig.fromJson(coins);
    } catch (_) {
      // Swallow errors and let caller decide on fallback
      return null;
    }
  }
}
