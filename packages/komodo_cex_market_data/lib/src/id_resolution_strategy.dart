import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for resolving platform-specific asset identifiers
abstract class IdResolutionStrategy {
  /// Resolves the trading symbol for the given asset
  String? resolveTradingSymbol(AssetId assetId);

  /// Returns the priority order for ID resolution
  List<String?> getIdPriority(AssetId assetId);

  /// Platform identifier for logging/debugging
  String get platformName;
}

/// Binance-specific ID resolution strategy
class BinanceIdResolutionStrategy implements IdResolutionStrategy {
  @override
  String get platformName => 'Binance';

  @override
  List<String?> getIdPriority(AssetId assetId) => [
        assetId.symbol.binanceId,
        assetId.symbol.configSymbol,
      ];

  @override
  String? resolveTradingSymbol(AssetId assetId) {
    return getIdPriority(assetId)
        .firstWhere((id) => id != null && id.isNotEmpty, orElse: () => null);
  }
}

/// CoinGecko-specific ID resolution strategy
class CoinGeckoIdResolutionStrategy implements IdResolutionStrategy {
  @override
  String get platformName => 'CoinGecko';

  @override
  List<String?> getIdPriority(AssetId assetId) => [
        assetId.symbol.coinGeckoId,
        assetId.symbol.configSymbol,
      ];

  @override
  String? resolveTradingSymbol(AssetId assetId) {
    return getIdPriority(assetId)
        .firstWhere((id) => id != null && id.isNotEmpty, orElse: () => null);
  }
}

/// Komodo-specific ID resolution strategy
class KomodoIdResolutionStrategy implements IdResolutionStrategy {
  @override
  String get platformName => 'Komodo';

  @override
  List<String?> getIdPriority(AssetId assetId) => [
        assetId.symbol.configSymbol,
      ];

  @override
  String? resolveTradingSymbol(AssetId assetId) {
    return getIdPriority(assetId)
        .firstWhere((id) => id != null && id.isNotEmpty, orElse: () => null);
  }
}
