import 'package:komodo_cex_market_data/src/binance/_binance_index.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coingecko/_coingecko_index.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/_coinpaprika_index.dart';
import 'package:komodo_cex_market_data/src/komodo/_komodo_index.dart';

/// Utility class for managing repository priorities using a map-based approach.
///
/// This class provides a centralized way to define and retrieve repository
/// priorities, eliminating code duplication across different components.
class RepositoryPriorityManager {
  /// Default priority map for repositories.
  /// Lower numbers indicate higher priority.
  static const Map<Type, int> defaultPriorities = {
    KomodoPriceRepository: 1,
    BinanceRepository: 2,
    CoinPaprikaRepository: 3,
    CoinGeckoRepository: 4,
  };

  /// Priority map optimized for sparkline data fetching.
  /// Binance is prioritized for sparkline data due to better data quality.
  static const Map<Type, int> sparklinePriorities = {
    BinanceRepository: 1,
    CoinPaprikaRepository: 2,
    CoinGeckoRepository: 3,
  };

  /// Gets the priority of a repository using the default priority scheme.
  ///
  /// Returns 999 for unknown repository types (lowest priority).
  ///
  /// [repo] The repository to get the priority for.
  static int getPriority(CexRepository repo) {
    return defaultPriorities[repo.runtimeType] ?? 999;
  }

  /// Gets the priority of a repository using a custom priority map.
  ///
  /// Returns 999 for unknown repository types (lowest priority).
  ///
  /// [repo] The repository to get the priority for.
  /// [customPriorities] Custom priority map to use instead of defaults.
  static int getPriorityWithCustomMap(
    CexRepository repo,
    Map<Type, int> customPriorities,
  ) {
    return customPriorities[repo.runtimeType] ?? 999;
  }

  /// Gets the priority of a repository using the sparkline-optimized scheme.
  ///
  /// Returns 999 for unknown repository types (lowest priority).
  ///
  /// [repo] The repository to get the priority for.
  static int getSparklinePriority(CexRepository repo) {
    return sparklinePriorities[repo.runtimeType] ?? 999;
  }

  /// Sorts a list of repositories by their priority using the default scheme.
  ///
  /// [repositories] The list of repositories to sort.
  /// Returns a new sorted list with highest priority repositories first.
  static List<CexRepository> sortByPriority(List<CexRepository> repositories) {
    final sorted = repositories.toList();
    sorted.sort((a, b) => getPriority(a).compareTo(getPriority(b)));
    return sorted;
  }

  /// Sorts a list of repositories by their priority using a custom priority map.
  ///
  /// [repositories] The list of repositories to sort.
  /// [customPriorities] Custom priority map to use for sorting.
  /// Returns a new sorted list with highest priority repositories first.
  static List<CexRepository> sortByCustomPriority(
    List<CexRepository> repositories,
    Map<Type, int> customPriorities,
  ) {
    final sorted = repositories.toList()
      ..sort(
        (a, b) => getPriorityWithCustomMap(
          a,
          customPriorities,
        ).compareTo(getPriorityWithCustomMap(b, customPriorities)),
      );
    return sorted;
  }

  /// Sorts a list of repositories by their priority using the sparkline scheme.
  ///
  /// [repositories] The list of repositories to sort.
  /// Returns a new sorted list with highest priority repositories first.
  static List<CexRepository> sortBySparklinePriority(
    List<CexRepository> repositories,
  ) {
    final sorted = repositories.toList()
      ..sort(
        (a, b) => getSparklinePriority(a).compareTo(getSparklinePriority(b)),
      );
    return sorted;
  }
}
