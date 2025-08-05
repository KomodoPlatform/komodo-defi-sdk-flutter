import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for resolving platform-specific asset identifiers
abstract class IdResolutionStrategy {
  /// Checks if this strategy can resolve a trading symbol for the given asset
  bool canResolve(AssetId assetId);

  /// Resolves the trading symbol for the given asset
  /// Throws [ArgumentError] if the asset cannot be resolved
  String resolveTradingSymbol(AssetId assetId);

  /// Returns the priority order for ID resolution (filtered to non-null, non-empty values)
  List<String> getIdPriority(AssetId assetId);

  /// Platform identifier for logging/debugging
  String get platformName;
}

/// Binance-specific ID resolution strategy
class BinanceIdResolutionStrategy implements IdResolutionStrategy {
  @override
  String get platformName => 'Binance';

  @override
  List<String> getIdPriority(AssetId assetId) {
    return [
      assetId.symbol.binanceId,
      assetId.symbol.configSymbol,
    ].where((id) => id != null && id.isNotEmpty).cast<String>().toList();
  }

  @override
  bool canResolve(AssetId assetId) {
    return getIdPriority(assetId).isNotEmpty;
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    final ids = getIdPriority(assetId);
    if (ids.isEmpty) {
      throw ArgumentError(
        'Cannot resolve trading symbol for asset ${assetId.id} on $platformName',
      );
    }
    return ids.first;
  }
}

/// CoinGecko-specific ID resolution strategy
class CoinGeckoIdResolutionStrategy implements IdResolutionStrategy {
  @override
  String get platformName => 'CoinGecko';

  @override
  List<String> getIdPriority(AssetId assetId) {
    return [
      assetId.symbol.coinGeckoId,
      assetId.symbol.configSymbol,
    ].where((id) => id != null && id.isNotEmpty).cast<String>().toList();
  }

  @override
  bool canResolve(AssetId assetId) {
    return getIdPriority(assetId).isNotEmpty;
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    final ids = getIdPriority(assetId);
    if (ids.isEmpty) {
      throw ArgumentError(
        'Cannot resolve trading symbol for asset ${assetId.id} on $platformName',
      );
    }
    return ids.first;
  }
}

/// Komodo-specific ID resolution strategy
class KomodoIdResolutionStrategy implements IdResolutionStrategy {
  @override
  String get platformName => 'Komodo';

  @override
  List<String> getIdPriority(AssetId assetId) {
    return [assetId.symbol.configSymbol].where((id) => id.isNotEmpty).toList();
  }

  @override
  bool canResolve(AssetId assetId) {
    return getIdPriority(assetId).isNotEmpty;
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    final ids = getIdPriority(assetId);
    if (ids.isEmpty) {
      throw ArgumentError(
        'Cannot resolve trading symbol for asset ${assetId.id} on $platformName',
      );
    }
    return ids.first;
  }
}
