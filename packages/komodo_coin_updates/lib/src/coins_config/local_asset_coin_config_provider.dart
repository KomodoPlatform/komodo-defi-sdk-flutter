import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:komodo_coin_updates/src/coins_config/asset_parser.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/coins_config/config_transform.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

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
    // For local asset-backed provider, always load from the bundled asset path.
    // Runtime mapped file paths are intended for remote providers.
    const coinsConfigAsset = 'assets/config/coins_config.json';
    return LocalAssetCoinConfigProvider(
      packageName: packageName,
      coinsConfigAssetPath: coinsConfigAsset,
      bundledCommit: config.bundledCoinsRepoCommit,
      transformer: transformer,
      bundle: bundle,
    );
  }
  static final Logger _log = Logger('LocalAssetCoinConfigProvider');

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
    _log.info('Loading coins config from asset: $key');
    final content = await _bundle.loadString(key);
    final items = jsonDecode(content) as Map<String, dynamic>;
    _log.info('Loaded ${items.length} coin configurations from asset');

    final transformedItems = <String, Map<String, dynamic>>{
      for (final entry in items.entries)
        entry.key: _transformer.apply(
          Map<String, dynamic>.from(entry.value as Map<String, dynamic>),
        ),
    };

    // Use the standardized AssetParser to parse all assets
    const parser = AssetParser(
      loggerName: 'LocalAssetCoinConfigProvider',
    );

    return parser.parseAssetsFromConfig(
      transformedItems,
      shouldFilterCoin: (coinData) => const CoinFilter().shouldFilter(coinData),
      logContext: 'from local bundle',
    );
  }
}
