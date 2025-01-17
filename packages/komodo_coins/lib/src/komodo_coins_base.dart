import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_coins/src/config_transform.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// lib/src/komodo_coins_base.dart
class KomodoCoins {
  factory KomodoCoins() => _instance;
  KomodoCoins._internal();
  static final KomodoCoins _instance = KomodoCoins._internal();

  static Map<AssetId, Asset>? _assets;

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

  static Future<Map<AssetId, Asset>> fetchAssets() async {
    if (_assets != null) return _assets!;

    final url = Uri.parse(
      'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
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
            final assetIds =
                AssetId.parseAllTypes(coinData, knownIds: platformIds).map(
              (id) => id.isChildAsset
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
      } else {
        throw Exception('Failed to fetch assets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching assets: $e');
      rethrow;
    }
  }

  static bool _hasNoParent(JsonMap coinData) {
    return !coinData.containsKey('parent_coin') ||
        coinData.valueOrNull<String>('parent_coin') == null;
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
}
