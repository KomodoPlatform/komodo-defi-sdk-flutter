import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetSymbol {
  AssetSymbol({
    required this.assetConfigId,
    this.coinPaprikaId,
    this.coinGeckoId,
    this.liveCoinWatchId,
    this.binanceId,
  });

  factory AssetSymbol.fromConfig(JsonMap json) {
    return AssetSymbol(
      assetConfigId: json.value<String>('coin'),
      coinPaprikaId: json.valueOrNull<String>('coinpaprika_id').nullIfEmpty,
      coinGeckoId: json.valueOrNull<String>('coingecko_id').nullIfEmpty,
      liveCoinWatchId: json.valueOrNull<String>('livecoinwatch_id').nullIfEmpty,
      binanceId: json.valueOrNull<String>('binance_id').nullIfEmpty,
    );
  }

  String? coinPaprikaId;
  String? coinGeckoId;
  String? liveCoinWatchId;
  String? binanceId;

  // The original coin ID from the coins config used as a fallback in case there
  // is no symbol available.
  String assetConfigId;

  String get configSymbol => symbolFromConfigId(assetConfigId);

  List<String?> get symbolPriority => [
        binanceId,
        coinPaprikaId,
        coinGeckoId,
        liveCoinWatchId,
        configSymbol,
      ];

  String get common => symbolPriority.firstWhere((e) => e != null)!;

  static String symbolFromConfigId(String configId) {
    if (_configToSymbolCache.containsKey(configId)) {
      return _configToSymbolCache[configId]!;
    }
    if (!configId.contains('-') && !configId.contains('_')) return configId;

    final filteredSuffixes = [
      ...CoinSubClass.values.map((e) => e.formatted),
      'IBC_IRIS',
      'IBC-IRIS',
      'IRIS',
      'segwit',
      'OLD',
      'IBC_NUCLEUSTEST',
    ];

    // Join the suffixes with '|' to form the regex pattern
    final regexPattern = '(${filteredSuffixes.join('|')})';

    final ticker = configId
        .replaceAll(RegExp('-$regexPattern'), '')
        .replaceAll(RegExp('_$regexPattern'), '');

    _configToSymbolCache[ticker] = ticker;
    return ticker;
  }
}

final Map<String, String> _configToSymbolCache = {};
