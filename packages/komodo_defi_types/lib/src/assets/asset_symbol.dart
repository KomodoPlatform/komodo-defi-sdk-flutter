import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

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
    configSymbol,
    coinGeckoId,
    liveCoinWatchId,
    coinPaprikaId,
    binanceId,
  ];

  String get common =>
      symbolPriority.firstWhere((e) => e != null && e.isNotEmpty)!;

  static String symbolFromConfigId(String configId) {
    if (_configToSymbolCache.containsKey(configId)) {
      return _configToSymbolCache[configId]!;
    }
    String? symbol;

    if (!configId.contains('-') && !configId.contains('_')) {
      return _configToSymbolCache[configId] = configId;
    }

    // Remove the suffixes (Everything after the first '-')
    symbol = configId.split('-').first;

    return _configToSymbolCache[configId] = symbol;
  }

  JsonMap toJson() => {
    'coinpaprika_id': coinPaprikaId,
    'coingecko_id': coinGeckoId,
    'livecoinwatch_id': liveCoinWatchId,
    'binance_id': binanceId,
  };
}

final Map<String, String> _configToSymbolCache = {};
