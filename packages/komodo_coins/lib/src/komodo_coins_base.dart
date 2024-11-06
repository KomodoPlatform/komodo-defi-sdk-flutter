import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoCoins {
  factory KomodoCoins() => _instance;
  KomodoCoins._internal();
  static final KomodoCoins _instance = KomodoCoins._internal();

  static Map<String, Asset>? _assets;

  @mustCallSuper
  Future<void> init() async {
    await fetchAssets();
  }

  bool get isInitialized => _assets != null;

  Map<String, Asset> get all {
    if (!isInitialized) {
      throw StateError('Assets have not been initialized. Call init() first.');
    }
    final hasAvax = _assets!.containsKey('AVAX');
    return _assets!;
  }

  /// Fetches assets from a remote source using a two-pass approach to handle parent relationships
  static Future<Map<String, Asset>> fetchAssets() async {
    if (_assets != null) return _assets!;

    final url = Uri.parse(
      'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonFromString(response.body);

        // First pass: Create AssetIds for platform coins
        final platformAssetIds = <String, AssetId>{};
        for (final entry in jsonData.entries) {
          final coinData = entry.value as JsonMap;
          if (_isPlatformCoin(coinData)) {
            try {
              final assetId = AssetId.fromConfig(coinData);
              platformAssetIds[entry.key] = assetId;
            } catch (e) {
              debugPrint('Error parsing platform coin ${entry.key}: $e');
            }
          }
        }

        // Second pass: Create all Assets with proper parent relationships
        final assets = <String, Asset>{};
        for (final entry in jsonData.entries) {
          final coinData = entry.value as JsonMap;

          // Skip if it's an NFT. They are not supported yet, and will likely
          // belong elsewhere in the codebase.
          if (coinData.valueOrNull<String>('protocol', 'type') == 'NFT') {
            continue;
          }

          try {
            final assetId =
                AssetId.fromConfig(coinData, knownIds: platformAssetIds);
            final asset = Asset.tryParse(coinData, assetId: assetId);

            if (asset != null) {
              assets[entry.key] = asset;
            }
          } catch (e) {
            debugPrint('Error parsing asset ${entry.key}: $e');
          }
        }

        _assets = assets;
        return assets;
      } else {
        throw Exception(
          'Failed to fetch assets with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching assets: $e');
      rethrow;
    }
  }

  static bool _isPlatformCoin(JsonMap coinData) {
    // Check if it's a platform coin based on config properties
    return !coinData.containsKey('parent_coin') ||
        coinData.valueOrNull<String>('parent_coin') == null;
  }
}
