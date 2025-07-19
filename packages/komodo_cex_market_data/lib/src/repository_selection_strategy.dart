import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/binance/binance.dart';
import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/komodo/komodo.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for selecting the best repository for a given asset and operation
class RepositorySelectionStrategy {
  /// Selects repositories in priority order for price fetching
  List<CexRepository> selectPriceRepositories(
    AssetId assetId,
    List<CexRepository> availableRepositories,
  ) {
    return availableRepositories
        .where((repo) => repo.canHandleAsset(assetId))
        .toList()
      // Priority: Komodo > CoinGecko > Binance
      ..sort((a, b) {
        final aPriority = _getRepositoryPriority(a);
        final bPriority = _getRepositoryPriority(b);
        return aPriority.compareTo(bPriority);
      });
  }

  int _getRepositoryPriority(CexRepository repo) {
    if (repo is KomodoPriceRepository) return 1;
    if (repo is CoinGeckoRepository) return 2;
    if (repo is BinanceRepository) return 3;
    return 999; // Unknown repositories get lowest priority
  }
}
