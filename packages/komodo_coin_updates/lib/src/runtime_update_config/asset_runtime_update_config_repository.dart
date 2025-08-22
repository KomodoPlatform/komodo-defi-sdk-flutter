import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:komodo_defi_types/komodo_defi_types.dart'
    show AssetRuntimeUpdateConfig;
import 'package:logging/logging.dart';

/// Loads the coins runtime update configuration from a build_config.json
/// bundled in a dependency package (defaults to `komodo_defi_framework`).
class AssetRuntimeUpdateConfigRepository {
  /// Creates a runtime update config repository.
  ///
  /// - [packageName]: the name of the package containing the runtime update config asset.
  /// - [assetPath]: the path to the runtime update config asset.
  /// - [bundle]: the asset bundle to load the runtime update config from.
  AssetRuntimeUpdateConfigRepository({
    this.packageName = 'komodo_defi_framework',
    this.assetPath = 'app_build/build_config.json',
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  /// The package that declares the `build_config.json` as an asset.
  final String packageName;

  /// The path to the `build_config.json` within the package.
  final String assetPath;

  final AssetBundle _bundle;

  static final Logger _log = Logger('RuntimeUpdateConfigRepository');

  /// Loads the coins runtime configuration from the `build_config.json` asset.
  /// Returns `null` if loading or parsing fails.
  Future<AssetRuntimeUpdateConfig?> tryLoad() async {
    try {
      return await load();
    } catch (e, s) {
      _log.fine(
        'Failed to load AssetRuntimeUpdateConfigRepository (tryLoad)',
        e,
        s,
      );
      return null;
    }
  }

  /// Loads the coins runtime configuration from the `build_config.json` asset.
  /// Throws on any failure. Prefer this for fail-fast flows; use [tryLoad]
  /// when a silent fallback behavior is desired.
  Future<AssetRuntimeUpdateConfig> load() async {
    final assetUri = 'packages/$packageName/$assetPath';
    _log.fine(
      'Loading AssetRuntimeUpdateConfigRepository from asset: $assetUri',
    );

    // Load asset content (propagates errors)
    final content = await _bundle.loadString(assetUri);

    // Parse JSON content
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const FormatException('Root JSON is not an object');
    }

    final root = Map<String, dynamic>.from(decoded);
    final coinsNode = root['coins'];
    if (coinsNode is! Map) {
      throw const FormatException(
        'Missing or invalid "coins" object in config',
      );
    }
    final coins = Map<String, dynamic>.from(coinsNode);

    final config = AssetRuntimeUpdateConfig.fromJson(coins);
    _log.fine('Loaded AssetRuntimeUpdateConfigRepository successfully');
    return config;
  }
}
