import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

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
  static final Logger _logger = Logger('BinanceIdResolutionStrategy');

  @override
  String get platformName => 'Binance';

  @override
  List<String> getIdPriority(AssetId assetId) {
    final binanceId = assetId.symbol.binanceId;
    final configSymbol = assetId.symbol.configSymbol;

    if (binanceId == null || binanceId.isEmpty) {
      _logger.warning(
        'Missing binanceId for asset ${assetId.symbol.configSymbol}, '
        'falling back to configSymbol. This may cause API issues.',
      );
    }

    return [
      binanceId,
      configSymbol,
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

    final resolvedSymbol = ids.first;
    _logger.finest(
      'Resolved trading symbol for ${assetId.symbol.configSymbol}: $resolvedSymbol '
      '(priority: ${ids.join(', ')})',
    );

    return resolvedSymbol;
  }
}

/// CoinGecko-specific ID resolution strategy
class CoinGeckoIdResolutionStrategy implements IdResolutionStrategy {
  static final Logger _logger = Logger('CoinGeckoIdResolutionStrategy');

  @override
  String get platformName => 'CoinGecko';

  @override
  List<String> getIdPriority(AssetId assetId) {
    final coinGeckoId = assetId.symbol.coinGeckoId;
    final configSymbol = assetId.symbol.configSymbol;

    if (coinGeckoId == null || coinGeckoId.isEmpty) {
      _logger.warning(
        'Missing coinGeckoId for asset ${assetId.symbol.configSymbol}, '
        'falling back to configSymbol. This may cause API issues.',
      );
    }

    return [
      coinGeckoId,
      configSymbol,
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

    final resolvedSymbol = ids.first;
    _logger.finest(
      'Resolved trading symbol for ${assetId.symbol.configSymbol}: $resolvedSymbol '
      '(priority: ${ids.join(', ')})',
    );

    return resolvedSymbol;
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
