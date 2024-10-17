import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_types.dart';
// Assuming your Asset and AssetId models are already defined as you provided

class KomodoCoins {
  const KomodoCoins();

  /// Optional init to pre-fetch assets. Either call this method or
  /// [fetchAssets] before accessing the assets synchronously.
  @mustCallSuper
  Future<void> init() async {
    await fetchAssets();
  }

  static bool get isInitialized => _assets != null;

  Map<String, Asset> get all {
    if (_assets == null) {
      throw StateError(
        'Assets have not been initialized. Call initialize() first.',
      );
    }

    return _assets!;
  }

  static Future<Map<String, Asset>> fetchAssets() async {
    if (_assets != null) {
      return _assets!;
    }

    final url = Uri.parse(
      // 'https://komodoplatform.github.io/coins/utils/coins_config_tcp.json',
      'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
    );

    // Fetch the JSON from the URL
    final response = await http.get(url);

    // Check for a successful response
    if (response.statusCode == 200) {
      // Decode the JSON response
      final jsonData = jsonFromString(response.body);

      final supportedAssets = <String, Asset>{};
      // TODO: Make supported coin logic self-contained in the Asset/Protocol
      // classes
      for (final entry in jsonData.entries) {
        final coinData = entry.value as JsonMap;

        try {
          if (ProtocolClass.tryParse(coinData) == null) {
            continue;
          }

          final asset = Asset.fromJson(coinData);

          // TODO! Remove temporary workaround when all coins have derivation
          // paths
          // Skip it if it is a multi-address coin but doesn't have a
          // derivation path. This approach may need to be changed if we
          // refactor to use the mult-address strategy for single-address coins.
          if (asset.pubkeyStrategy.supportsMultipleAddresses &&
              asset.id.derivationPath == null) {
            print(
              'Skipping multi-address coin without '
              'derivation path: ${entry.key}',
            );
            continue;
          }

          supportedAssets[entry.key] = asset;
        } catch (e) {
          print("Couldn't parse coin data: $e: $coinData");
        }
      }

      return _assets = supportedAssets;
    } else {
      // Handle errors accordingly
      throw Exception('Failed to fetch assets');
    }
  }

  // TODO: Make Asset ID equality comparison safe and use it as the map key.
  static Map<String, Asset>? _assets;
}
