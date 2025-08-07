import 'package:get_it/get_it.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';

/// Configuration for market data repositories
class MarketDataConfig {
  /// Configuration class for market data settings and parameters.
  ///
  /// This class holds the configuration options needed to initialize and
  /// customize the behavior of the market data service. It defines various
  /// settings such as API endpoints, refresh intervals, data sources,
  /// and other parameters required for fetching and processing market data.
  ///
  /// Example:
  /// ```dart
  /// const config = MarketDataConfig(
  ///   // configuration parameters
  /// );
  /// ```
  const MarketDataConfig({
    this.enableBinance = true,
    this.enableCoinGecko = true,
    this.enableKomodoPrice = true,
    this.customRepositories = const [],
    this.selectionStrategy,
  });

  /// Whether to enable Binance repository
  final bool enableBinance;

  /// Whether to enable CoinGecko repository
  final bool enableCoinGecko;

  /// Whether to enable Komodo price repository
  final bool enableKomodoPrice;

  /// Additional custom repositories to include
  final List<CexRepository> customRepositories;

  /// Custom selection strategy (uses default if null)
  final RepositorySelectionStrategy? selectionStrategy;
}

/// Bootstrap factory for market data dependencies
class MarketDataBootstrap {
  const MarketDataBootstrap._();

  /// Registers all market data dependencies in the container
  static Future<void> register(
    GetIt container, {
    MarketDataConfig config = const MarketDataConfig(),
  }) async {
    // Register providers first
    await _registerProviders(container, config);

    // Register repositories
    await _registerRepositories(container, config);

    // Register selection strategy
    await _registerSelectionStrategy(container, config);
  }

  /// Registers providers for market data sources
  static Future<void> _registerProviders(
    GetIt container,
    MarketDataConfig config,
  ) async {
    if (config.enableCoinGecko) {
      container.registerSingletonAsync<ICoinGeckoProvider>(
        () async => CoinGeckoCexProvider(),
      );
    }

    if (config.enableKomodoPrice) {
      container.registerSingletonAsync<IKomodoPriceProvider>(
        () async => KomodoPriceProvider(),
      );
    }
  }

  /// Registers repository instances
  static Future<void> _registerRepositories(
    GetIt container,
    MarketDataConfig config,
  ) async {
    if (config.enableBinance) {
      container.registerSingletonAsync<BinanceRepository>(
        () async => BinanceRepository(binanceProvider: const BinanceProvider()),
      );
    }

    if (config.enableCoinGecko) {
      container.registerSingletonAsync<CoinGeckoRepository>(
        () async => CoinGeckoRepository(
          coinGeckoProvider: await container.getAsync<ICoinGeckoProvider>(),
        ),
        dependsOn: [ICoinGeckoProvider],
      );
    }

    if (config.enableKomodoPrice) {
      container.registerSingletonAsync<KomodoPriceRepository>(
        () async => KomodoPriceRepository(
          cexPriceProvider: await container.getAsync<IKomodoPriceProvider>(),
        ),
        dependsOn: [IKomodoPriceProvider],
      );
    }
  }

  /// Registers the repository selection strategy
  static Future<void> _registerSelectionStrategy(
    GetIt container,
    MarketDataConfig config,
  ) async {
    container.registerSingletonAsync<RepositorySelectionStrategy>(
      () async =>
          config.selectionStrategy ?? DefaultRepositorySelectionStrategy(),
    );
  }

  /// Builds the list of enabled repositories for use by SDK
  static Future<List<CexRepository>> buildRepositoryList(
    GetIt container,
    MarketDataConfig config,
  ) async {
    final repositories = <CexRepository>[];

    // Add repositories in priority order
    if (config.enableKomodoPrice) {
      repositories.add(await container.getAsync<KomodoPriceRepository>());
    }

    if (config.enableBinance) {
      repositories.add(await container.getAsync<BinanceRepository>());
    }

    if (config.enableCoinGecko) {
      repositories.add(await container.getAsync<CoinGeckoRepository>());
    }

    // Add any custom repositories
    repositories.addAll(config.customRepositories);

    return repositories;
  }

  /// Builds the dependency list based on enabled repositories for use by SDK
  static List<Type> buildDependencies(MarketDataConfig config) {
    final dependencies = <Type>[RepositorySelectionStrategy];

    if (config.enableBinance) {
      dependencies.add(BinanceRepository);
    }

    if (config.enableCoinGecko) {
      dependencies.add(CoinGeckoRepository);
    }

    if (config.enableKomodoPrice) {
      dependencies.add(KomodoPriceRepository);
    }

    return dependencies;
  }
}
