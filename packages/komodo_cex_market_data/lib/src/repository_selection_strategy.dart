import 'package:komodo_cex_market_data/komodo_cex_market_data.dart'
    show RepositoryPriorityManager;
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/models/cex_coin.dart';
import 'package:komodo_cex_market_data/src/models/quote_currency.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Enum for the type of price request
enum PriceRequestType { currentPrice, priceChange, priceHistory }

/// Strategy interface for selecting repositories
abstract class RepositorySelectionStrategy {
  Future<void> ensureCacheInitialized(List<CexRepository> repositories);

  Future<CexRepository?> selectRepository({
    required AssetId assetId,
    required QuoteCurrency fiatCurrency,
    required PriceRequestType requestType,
    required List<CexRepository> availableRepositories,
  });
}

/// Default strategy for selecting the best repository for a given asset
class DefaultRepositorySelectionStrategy
    implements RepositorySelectionStrategy {
  final Map<CexRepository, _RepositorySupportCache> _supportCache = {};

  @override
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
  @override
  Future<CexRepository?> selectRepository({
    required AssetId assetId,
    required QuoteCurrency fiatCurrency,
    required PriceRequestType requestType,
    required List<CexRepository> availableRepositories,
  }) async {
    await ensureCacheInitialized(availableRepositories);
    final fiatSymbol = fiatCurrency.symbol.toUpperCase();
    final candidates =
        availableRepositories.where((repo) {
            final cache = _supportCache[repo];
            if (cache == null) return false;
            final supportsAsset = cache.coins.any(
              (c) =>
                  c.id.toUpperCase() ==
                  assetId.symbol.configSymbol.toUpperCase(),
            );
            final supportsFiat = cache.fiatCurrencies.contains(fiatSymbol);
            return supportsAsset && supportsFiat;
          }).toList()
          ..sort(
            (a, b) => RepositoryPriorityManager.getPriority(
              a,
            ).compareTo(RepositoryPriorityManager.getPriority(b)),
          );
    return candidates.isNotEmpty ? candidates.first : null;
  }
}

class _RepositorySupportCache {
  final List<CexCoin> coins;
  final Set<String> fiatCurrencies;
  _RepositorySupportCache({required this.coins, required this.fiatCurrencies});
}
