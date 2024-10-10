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

  List<Asset> get all {
    if (_assets == null) {
      throw StateError(
        'Assets have not been initialized. Call initialize() first.',
      );
    }

    return _assets!;
  }

  static Future<List<Asset>> fetchAssets() async {
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

      // TODO: Make supported coin logic self-contained in the Asset/Protocol
      // classes
      final supportedAssets = jsonData.entries
          .map((entry) {
            final coinData = entry.value as JsonMap;
            try {
              final maybeProtocol =
                  // ProtocolClass.fromJson(coinData.value<JsonMap>('protocol'));
                  ProtocolClass.tryParse(coinData);
              return maybeProtocol == null
                  ? null
                  : Asset(
                      id: AssetId.fromConfig(coinData),
                      protocol: maybeProtocol!,
                    );
            } catch (e) {
              print("Couldn't parse coin data: ${e.toString()}: $coinData");
              return null;
            }
          })
          // TODO: Some symbols missing!
          .where((element) => element != null)
          .cast<Asset>()
          .toList();

      return _assets = supportedAssets;
    } else {
      // Handle errors accordingly
      throw Exception('Failed to fetch assets');
    }
  }

  static List<Asset>? _assets;
}

// // Asset activation extension
// extension AssetActivation on Asset {
//   Stream<ActivationProgress> activate() =>
//       protocol.activationStrategy.activate(this);
// }
