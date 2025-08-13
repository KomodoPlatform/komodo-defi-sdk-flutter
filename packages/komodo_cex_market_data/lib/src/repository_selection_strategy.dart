import 'package:komodo_cex_market_data/komodo_cex_market_data.dart'
    show RepositoryPriorityManager;
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/models/cex_coin.dart';
import 'package:komodo_cex_market_data/src/models/quote_currency.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart' show Logger;

/// Enum for the type of price request
enum PriceRequestType { currentPrice, priceChange, priceHistory }

/// Strategy interface for selecting repositories
abstract class RepositorySelectionStrategy {
  /// Ensures the cache is initialized for the given repositories
  Future<void> ensureCacheInitialized(List<CexRepository> repositories);

  /// Selects the best repository for a given asset, fiat, and request type
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

  static final Logger _logger = Logger('DefaultRepositorySelectionStrategy');

  @override
  Future<void> ensureCacheInitialized(List<CexRepository> repositories) async {
    for (final repo in repositories) {
      if (!_supportCache.containsKey(repo)) {
        try {
          final coins = await repo.getCoinList();
          final fiatCurrencies =
              coins
                  .expand((c) => c.currencies.map((s) => s.toUpperCase()))
                  .toSet();
          _supportCache[repo] = _RepositorySupportCache(
            coins: coins,
            fiatCurrencies: fiatCurrencies,
          );
        } catch (e, st) {
          // Ignore repository initialization failures and continue.
          // Repositories that fail to initialize won't be selected.
          _logger.severe('Failed to initialize repository', e, st);
        }
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
    final candidates =
        availableRepositories
            .where((repo) => _supportsAssetAndFiat(repo, assetId, fiatCurrency))
            .toList()
          ..sort(
            (a, b) => RepositoryPriorityManager.getPriority(
              a,
            ).compareTo(RepositoryPriorityManager.getPriority(b)),
          );
    return candidates.isNotEmpty ? candidates.first : null;
  }

  /// Checks if a repository supports the given asset and fiat currency
  bool _supportsAssetAndFiat(
    CexRepository repo,
    AssetId assetId,
    QuoteCurrency fiatCurrency,
  ) {
    final cache = _supportCache[repo];
    if (cache == null) return false;

    final supportsAsset = cache.coins.any(
      (c) => c.id.toUpperCase() == assetId.symbol.configSymbol.toUpperCase(),
    );
    final supportsFiat = cache.fiatCurrencies.contains(
      fiatCurrency.symbol.toUpperCase(),
    );

    return supportsAsset && supportsFiat;
  }
}

class _RepositorySupportCache {
  _RepositorySupportCache({required this.coins, required this.fiatCurrencies});

  final List<CexCoin> coins;
  final Set<String> fiatCurrencies;
}
