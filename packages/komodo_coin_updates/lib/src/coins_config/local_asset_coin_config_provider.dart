import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:komodo_coin_updates/src/coins_config/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/coins_config/config_transform.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Local asset-backed implementation of [CoinConfigProvider].
///
/// Loads the coins configuration from an asset bundled with the app, typically
/// produced by the build transformer according to `build_config.json` mappings.
class LocalAssetCoinConfigProvider implements CoinConfigProvider {
  /// Creates a provider from a runtime configuration.
  ///
  /// - [packageName]: the name of the package containing the coins config asset.
  /// - [coinsConfigAssetPath]: the path to the coins config asset.
  /// - [bundledCommit]: the commit hash of the bundled coins repo.
  /// - [transformer]: the transformer to apply to the coins config.
  /// - [bundle]: the asset bundle to load the coins config from.
  LocalAssetCoinConfigProvider({
    required this.packageName,
    required this.coinsConfigAssetPath,
    required this.bundledCommit,
    CoinConfigTransformer? transformer,
    AssetBundle? bundle,
  }) : _transformer = transformer ?? const CoinConfigTransformer(),
       _bundle = bundle ?? rootBundle;

  /// Convenience ctor deriving the asset path from [RuntimeUpdateConfig].
  factory LocalAssetCoinConfigProvider.fromConfig(
    RuntimeUpdateConfig config, {
    String packageName = 'komodo_defi_framework',
    CoinConfigTransformer? transformer,
    AssetBundle? bundle,
  }) {
    final coinsConfigAsset =
        config.mappedFiles['assets/config/coins_config.json'] ??
        'assets/config/coins_config.json';
    return LocalAssetCoinConfigProvider(
      packageName: packageName,
      coinsConfigAssetPath: coinsConfigAsset,
      bundledCommit: config.bundledCoinsRepoCommit,
      transformer: transformer,
      bundle: bundle,
    );
  }

  /// Creates a provider from a runtime configuration.
  final String packageName;

  /// The path to the coins config asset.
  final String coinsConfigAssetPath;

  /// The commit hash of the bundled coins repo.
  final String bundledCommit;

  /// The transformer to apply to the coins config.
  final CoinConfigTransformer _transformer;

  /// The asset bundle to load the coins config from.
  final AssetBundle _bundle;

  @override
  Future<List<Asset>> getAssetsForCommit(String commit) => _loadAssets();

  @override
  Future<List<Asset>> getAssets({String? branch}) => _loadAssets();

  @override
  Future<String> getLatestCommit({
    String? branch,
    String? apiBaseUrl,
    String? githubToken,
  }) async => bundledCommit;

  Future<List<Asset>> _loadAssets() async {
    final key = 'packages/$packageName/$coinsConfigAssetPath';
    final content = await _bundle.loadString(key);
    final items = jsonDecode(content) as Map<String, dynamic>;

    final transformedItems = <String, Map<String, dynamic>>{
      for (final entry in items.entries)
        entry.key: _transformer.apply(
          Map<String, dynamic>.from(entry.value as Map<String, dynamic>),
        ),
    };

    // First pass: Parse platform coin AssetIds (no parent relationship needed)
    final platformIds = <AssetId>{};
    for (final entry in transformedItems.entries) {
      final coinData = entry.value;
      if (_rawCoinHasNoParent(coinData)) {
        try {
          platformIds.addAll(
            AssetId.parseAllTypes(coinData, knownIds: const {}),
          );
        } catch (_) {
          // Ignore malformed platform entries in local bundle
        }
      }
    }

    // Second pass: Create assets with proper parent relationships
    final assets = <Asset>[];
    for (final entry in transformedItems.entries) {
      final coinData = entry.value;

      if (const CoinFilter().shouldFilter(coinData)) {
        continue;
      }

      try {
        final assetIds = AssetId.parseAllTypes(
          coinData,
          knownIds: platformIds,
        ).map(
          (id) =>
              id.isChildAsset
                  ? AssetId.parse(coinData, knownIds: platformIds)
                  : id,
        );

        for (final assetId in assetIds) {
          final asset = Asset.fromJsonWithId(coinData, assetId: assetId);
          assets.add(asset);
        }
      } on MissingProtocolFieldException {
        // Skip assets with missing protocol fields in local bundle
      } catch (_) {
        // Swallow errors for local parsing to avoid crashing the app
      }
    }
    return assets;
  }

  bool _rawCoinHasNoParent(Map<String, dynamic> coinData) =>
      coinData['parent_coin'] == null;
}
