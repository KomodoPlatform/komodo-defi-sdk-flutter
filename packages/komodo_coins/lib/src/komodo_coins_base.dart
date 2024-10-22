import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoCoins {
  // Singleton pattern to ensure a single instance of KomodoCoins
  static final KomodoCoins _instance = KomodoCoins._internal();
  factory KomodoCoins() => _instance;
  KomodoCoins._internal();

  static Map<String, Asset>? _assets;

  /// Optional init to pre-fetch assets. Either call this method or
  /// [fetchAssets] before accessing the assets synchronously.
  @mustCallSuper
  Future<void> init() async {
    await fetchAssets();
  }

  // Checks if assets are initialized
  static bool get isInitialized => _assets != null;

  // Provides access to all assets after initialization
  Map<String, Asset> get all {
    if (!isInitialized) {
      throw StateError(
        'Assets have not been initialized. Call init() first.',
      );
    }
    return _assets!;
  }

  /// Fetches assets from a remote source
  static Future<Map<String, Asset>> fetchAssets() async {
    // Return cached assets if already fetched
    if (_assets != null) {
      return _assets!;
    }

    final url = Uri.parse(
      'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonFromString(response.body);
        final supportedAssets = <String, Asset>{};

        // Move coin filtering logic to Asset/ProtocolClass for better encapsulation
        for (final entry in jsonData.entries) {
          final coinData = entry.value as JsonMap;

          // Ensure asset is valid and supported based on protocol and derivation path logic
          if (Asset.isSupported(coinData)) {
            final asset = Asset.fromJson(coinData);

            // Filter out multi-address coins without a derivation path (handled in Asset)
            if (!asset.isFilteredOut()) {
              supportedAssets[entry.key] = asset;
            }
          }
        }

        _assets = supportedAssets;
        return supportedAssets;
      } else {
        throw Exception(
            'Failed to fetch assets with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log and handle errors gracefully
      print("Error fetching assets: $e");
      throw Exception('Error fetching assets: $e');
    }
  }
}
