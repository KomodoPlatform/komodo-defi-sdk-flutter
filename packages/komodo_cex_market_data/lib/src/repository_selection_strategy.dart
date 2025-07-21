import 'package:komodo_cex_market_data/src/binance/binance.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/komodo/komodo.dart';
import 'package:komodo_cex_market_data/src/models/cex_coin.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Enum for the type of price request
enum PriceRequestType {
  currentPrice,
  priceChange,
  priceHistory,
}

/// Strategy for selecting the best repository for a given asset and operation
class RepositorySelectionStrategy {
  final Map<CexRepository, _RepositorySupportCache> _supportCache = {};

  Future<void> ensureCacheInitialized(List<CexRepository> repositories) async {
    for (final repo in repositories) {
      if (!_supportCache.containsKey(repo)) {
        final coins = await repo.getCoinList();
        final fiatCurrencies = coins.expand((c) => c.currencies).toSet();
        _supportCache[repo] = _RepositorySupportCache(
          coins: coins,
          fiatCurrencies: fiatCurrencies,
        );
      }
    }
  }

  /// Selects the best repository for a given asset, fiat, and request type
  Future<CexRepository?> selectRepository({
    required AssetId assetId,
    required AssetId fiatAssetId,
    required PriceRequestType requestType,
    required List<CexRepository> availableRepositories,
  }) async {
    await ensureCacheInitialized(availableRepositories);
    final fiatSymbol = fiatAssetId.symbol.configSymbol.toUpperCase();
    final candidates = availableRepositories.where((repo) {
      final cache = _supportCache[repo];
      if (cache == null) return false;
      final supportsAsset = cache.coins.any(
        (c) => c.id.toUpperCase() == assetId.symbol.configSymbol.toUpperCase(),
      );
      final supportsFiat = cache.fiatCurrencies.contains(fiatSymbol);
      return supportsAsset && supportsFiat;
    }).toList();
    candidates.sort(
      (a, b) => _getRepositoryPriority(a).compareTo(_getRepositoryPriority(b)),
    );
    return candidates.isNotEmpty ? candidates.first : null;
  }

  int _getRepositoryPriority(CexRepository repo) {
    if (repo is KomodoPriceRepository) return 1;
    if (repo is BinanceRepository) return 2;
    if (repo is CoinGeckoRepository) return 3;
    return 999; // Unknown repositories get lowest priority
  }
}

class _RepositorySupportCache {
  final List<CexCoin> coins;
  final Set<String> fiatCurrencies;
  _RepositorySupportCache({required this.coins, required this.fiatCurrencies});
}
