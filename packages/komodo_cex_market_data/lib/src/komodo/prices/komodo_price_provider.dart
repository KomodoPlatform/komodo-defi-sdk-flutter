import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_cex_market_data/src/models/_models_index.dart';

/// Interface for fetching prices from Komodo API.
abstract class IKomodoPriceProvider {
  Future<Map<String, AssetMarketInformation>> getKomodoPrices();
}

/// A class for fetching prices from Komodo API.
class KomodoPriceProvider implements IKomodoPriceProvider {
  /// Creates a new instance of [KomodoPriceProvider].
  KomodoPriceProvider({List<String>? priceEndpoints})
    : priceEndpoints = priceEndpoints ?? _defaultEndpoints;

  /// The list of price endpoints to try in order.
  final List<String> priceEndpoints;

  /// Default price endpoints to use if none are provided.
  static const List<String> _defaultEndpoints = [
    'https://prices.komodian.info/api/v2/tickers',
    'https://prices.cipig.net:1717/api/v2/tickers',
    'https://cache.defi-stats.komodo.earth/api/v3/prices/tickers_v2.json',
  ];

  /// Fetches prices from Komodo API.
  ///
  /// Cycles through the configured endpoints until one succeeds.
  /// Returns a map of coin IDs to their prices.
  ///
  /// Throws an error if all endpoints fail.
  ///
  /// Example:
  /// ```dart
  /// final Map<String, AssetMarketInformation> prices =
  ///   await komodoPriceProvider.getKomodoPrices();
  /// ```
  @override
  Future<Map<String, AssetMarketInformation>> getKomodoPrices() async {
    Exception? lastException;

    for (final endpoint in priceEndpoints) {
      try {
        final uri = Uri.parse(endpoint);
        final res = await http.get(uri);

        if (res.statusCode != 200) {
          lastException = Exception(
            'HTTP ${res.statusCode}: Failed to fetch prices from $endpoint',
          );
          continue;
        }

        final json = jsonDecode(res.body) as Map<String, dynamic>?;

        if (json == null) {
          lastException = Exception(
            'Invalid response from $endpoint: empty JSON',
          );
          continue;
        }

        final prices = <String, AssetMarketInformation>{};
        json.forEach((String priceTicker, dynamic pricesData) {
          prices[priceTicker] = AssetMarketInformation.fromJson(
            pricesData as Map<String, dynamic>,
          ).copyWith(ticker: priceTicker);
        });
        return prices;
      } catch (e) {
        lastException = Exception('Failed to fetch prices from $endpoint: $e');
        continue;
      }
    }

    // If we get here, all endpoints failed
    throw lastException ?? Exception('All price endpoints failed');
  }
}
