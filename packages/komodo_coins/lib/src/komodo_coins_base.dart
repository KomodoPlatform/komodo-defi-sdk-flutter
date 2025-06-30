import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_coins/src/config_transform.dart';
import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A high-level library that provides a simple way to access Komodo Platform
/// coin data and seed nodes.
///
/// NB: [init] must be called before accessing any assets.
class KomodoCoins {
  /// Creates an instance of [KomodoCoins] and initializes it.
  static Future<KomodoCoins> create() async {
    final instance = KomodoCoins();
    await instance.init();
    return instance;
  }

  Map<AssetId, Asset>? _assets;
  final Map<String, Map<AssetId, Asset>> _filterCache = {};

  @mustCallSuper
  Future<void> init() async {
    await fetchAssets();
  }

  bool get isInitialized => _assets != null;

  Map<AssetId, Asset> get all {
    if (!isInitialized) {
      throw StateError('Assets have not been initialized. Call init() first.');
    }
    return _assets!;
  }

  Future<Map<AssetId, Asset>> fetchAssets() async {
    if (_assets != null) return _assets!;

    final url = Uri.parse(
      'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch assets: ${response.statusCode}');
      }
      final jsonData = jsonFromString(response.body);

      // First pass: Parse all platform coin AssetIds
      final platformIds = <AssetId>{};
      for (final entry in jsonData.entries) {
        // Apply transforms before processing
        final coinData = (entry.value as JsonMap).applyTransforms;

        if (_hasNoParent(coinData)) {
          try {
            platformIds.addAll(AssetId.parseAllTypes(coinData, knownIds: {}));
          } catch (e) {
            debugPrint('Error parsing platform coin ${entry.key}: $e');
          }
        }
      }

      // Second pass: Create assets with proper parent relationships
      final assets = <AssetId, Asset>{};

      for (final entry in jsonData.entries) {
        // Apply transforms before processing
        final coinData = (entry.value as JsonMap).applyTransforms;

        // Filter out excluded coins
        if (const CoinFilter().shouldFilter(entry.value as JsonMap)) {
          debugPrint('[Komodo Coins] Excluding coin ${entry.key}');
          continue;
        }

        try {
          // Parse all possible AssetIds for this coin
          final assetIds = AssetId.parseAllTypes(
            coinData,
            knownIds: platformIds,
          ).map(
            (id) =>
                id.isChildAsset
                    ? AssetId.parse(coinData, knownIds: platformIds)
                    : id,
          );

          // Create Asset instance for each valid AssetId
          for (final assetId in assetIds) {
            final asset = Asset.fromJsonWithId(coinData, assetId: assetId);
            // if (asset != null) {
            assets[assetId] = asset;
            // }
          }
        } catch (e) {
          debugPrint(
            'Error parsing asset ${entry.key}: $e , '
            'with transformed data: \n${coinData.toJsonString()}\n',
          );
        }
      }

      _assets = assets;
      return assets;
    } catch (e) {
      debugPrint('Error fetching assets: $e');
      rethrow;
    }
  }

  static bool _hasNoParent(JsonMap coinData) {
    return !coinData.containsKey('parent_coin') ||
        coinData.valueOrNull<String>('parent_coin') == null;
  }

  /// Returns the assets filtered using the provided [strategy].
  ///
  /// This allows higher-level components, such as [AssetManager], to tailor
  /// the visible asset list to the active authentication context. For example,
  /// a hardware wallet may only support a subset of coins, which can be
  /// enforced by supplying an appropriate [AssetFilterStrategy].
  Map<AssetId, Asset> filteredAssets(AssetFilterStrategy strategy) {
    if (!isInitialized) {
      throw StateError('Assets have not been initialized. Call init() first.');
    }
    final cacheKey = strategy.name;
    final cached = _filterCache[cacheKey];
    if (cached != null) return cached;

    final result = <AssetId, Asset>{};
    for (final entry in _assets!.entries) {
      final config = entry.value.protocol.config;
      if (strategy.shouldInclude(entry.value, config)) {
        result[entry.key] = entry.value;
      }
    }
    _filterCache[cacheKey] = result;
    return result;
  }

  // Helper methods
  Asset? findByTicker(String ticker, CoinSubClass subClass) {
    return all.entries
        .where((e) => e.key.id == ticker && e.key.subClass == subClass)
        .map((e) => e.value)
        .firstOrNull;
  }

  Set<Asset> findVariantsOfCoin(String ticker) {
    return all.entries
        .where((e) => e.key.id == ticker)
        .map((e) => e.value)
        .toSet();
  }

  Set<Asset> findChildAssets(AssetId parentId) {
    return all.entries
        .where((e) => e.key.isChildAsset && e.key.parentId == parentId)
        .map((e) => e.value)
        .toSet();
  }

  static Future<JsonList> fetchAndTransformCoinsList() async {
    const coinsUrl = 'https://komodoplatform.github.io/coins/coins';

    try {
      final response = await http.get(Uri.parse(coinsUrl));

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch coins list. Status code: ${response.statusCode}',
          uri: Uri.parse(coinsUrl),
        );
      }

      final coins = jsonListFromString(response.body);
      return coins.applyTransforms;
    } catch (e) {
      debugPrint('Error fetching and transforming coins list: $e');
      throw Exception('Failed to fetch or process coins list: $e');
    }
  }
}
