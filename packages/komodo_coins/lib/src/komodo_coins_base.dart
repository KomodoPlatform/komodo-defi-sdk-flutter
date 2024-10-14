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

      final supportedAssets = Map<String, Asset>();
      // TODO: Make supported coin logic self-contained in the Asset/Protocol
      // classes
      for (final entry in jsonData.entries) {
        final coinData = entry.value as JsonMap;
        try {
          final maybeProtocol = ProtocolClass.tryParse(coinData);
          if (maybeProtocol == null) {
            // print("Couldn't parse unsupported coin data: ${entry.key}");
            continue;
          }
          supportedAssets[entry.key] = Asset(
            id: AssetId.fromConfig(coinData),
            protocol: maybeProtocol,
          );
        } catch (e) {
          print("Couldn't parse coin data: ${e.toString()}: $coinData");
        }
      }
      // final supportedAssets = jsonData.entries
      //     .map((entry) {
      //       final coinData = entry.value as JsonMap;
      //       try {
      //         final maybeProtocol =
      //             // ProtocolClass.fromJson(coinData.value<JsonMap>('protocol'));
      //             ProtocolClass.tryParse(coinData);
      //         return maybeProtocol == null
      //             ? null
      //             : MapEntry<String, Asset>(
      //                 entry.key,
      //                 Asset(
      //                   id: AssetId.fromConfig(coinData),
      //                   protocol: maybeProtocol!,
      //                 ),
      //               );
      //       } catch (e) {
      //         print("Couldn't parse coin data: ${e.toString()}: $coinData");
      //         return null;
      //       }
      //     })
      //     // TODO: Some symbols missing!
      //     .where((element) => element != null)
      // .cast<MapEntry<String, Asset>>();
      // .cast<Asset>();

      return _assets = supportedAssets;
    } else {
      // Handle errors accordingly
      throw Exception('Failed to fetch assets');
    }
  }

  // TODO: Make Asset ID equality comparison safe and use it as the map key.
  static Map<String, Asset>? _assets;
}

// // Asset activation extension
// extension AssetActivation on Asset {
//   Stream<ActivationProgress> activate() =>
//       protocol.activationStrategy.activate(this);
// }
