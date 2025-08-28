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
  ///   enableBinance: true,
  ///   enableCoinGecko: false,
  ///   enableCoinPaprika: true,
  ///   enableKomodoPrice: true,
  ///   customRepositories: [myCustomRepo],
  ///   selectionStrategy: MyCustomStrategy(),
  /// );
  /// ```
  const MarketDataConfig({
    this.enableBinance = true,
    this.enableCoinGecko = true,
    this.enableCoinPaprika = true,
    this.enableKomodoPrice = true,
    this.customRepositories = const [],
    this.selectionStrategy,
    this.binanceProvider,
    this.coinGeckoProvider,
    this.coinPaprikaProvider,
    this.komodoPriceProvider,
    this.repositoryPriority = const [
      RepositoryType.komodoPrice,
      RepositoryType.binance,
      RepositoryType.coinGecko,
      RepositoryType.coinPaprika,
    ],
  });

  /// Whether to enable Binance repository
  final bool enableBinance;

  /// Whether to enable CoinGecko repository
  final bool enableCoinGecko;

  /// Whether to enable CoinPaprika repository
  final bool enableCoinPaprika;

  /// Whether to enable Komodo price repository
  final bool enableKomodoPrice;

  /// Additional custom repositories to include
  final List<CexRepository> customRepositories;

  /// Custom selection strategy (uses default if null)
  final RepositorySelectionStrategy? selectionStrategy;

  /// Optional custom Binance provider (uses default if null)
  final IBinanceProvider? binanceProvider;

  /// Optional custom CoinGecko provider (uses default if null)
  final ICoinGeckoProvider? coinGeckoProvider;

  /// Optional custom CoinPaprika provider (uses default if null)
  final ICoinPaprikaProvider? coinPaprikaProvider;

  /// Optional custom Komodo price provider (uses default if null)
  final IKomodoPriceProvider? komodoPriceProvider;

  /// The priority order for repository selection
  final List<RepositoryType> repositoryPriority;
}

/// Enum representing available repository types
enum RepositoryType { komodoPrice, binance, coinGecko, coinPaprika }

/// Bootstrap factory for market data dependencies
class MarketDataBootstrap {
  const MarketDataBootstrap._();

  /// Registers all market data dependencies in the container
  static Future<void> register(
    GetIt container, {
    MarketDataConfig config = const MarketDataConfig(),
  }) async {
    // Register providers first
    await registerProviders(container, config);

    // Register repositories
    await registerRepositories(container, config);

    // Register selection strategy
    await registerSelectionStrategy(container, config);
  }

  /// Registers providers for market data sources
  static Future<void> registerProviders(
    GetIt container,
    MarketDataConfig config,
  ) async {
    if (config.enableCoinGecko) {
      container.registerSingletonAsync<ICoinGeckoProvider>(
        () async => config.coinGeckoProvider ?? CoinGeckoCexProvider(),
      );
    }

    if (config.enableCoinPaprika) {
      container.registerSingletonAsync<ICoinPaprikaProvider>(
        () async => config.coinPaprikaProvider ?? CoinPaprikaProvider(),
      );
    }

    if (config.enableKomodoPrice) {
      container.registerSingletonAsync<IKomodoPriceProvider>(
        () async => config.komodoPriceProvider ?? KomodoPriceProvider(),
      );
    }
  }

  /// Registers repository instances
  static Future<void> registerRepositories(
    GetIt container,
    MarketDataConfig config,
  ) async {
    if (config.enableBinance) {
      container.registerSingletonAsync<BinanceRepository>(
        () async => BinanceRepository(
          binanceProvider: config.binanceProvider ?? const BinanceProvider(),
        ),
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

    if (config.enableCoinPaprika) {
      container.registerSingletonAsync<CoinPaprikaRepository>(
        () async => CoinPaprikaRepository(
          coinPaprikaProvider: await container.getAsync<ICoinPaprikaProvider>(),
        ),
        dependsOn: [ICoinPaprikaProvider],
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
  static Future<void> registerSelectionStrategy(
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

    // Collect available repositories keyed by type
    final availableRepos = <RepositoryType, CexRepository>{};

    if (config.enableKomodoPrice) {
      availableRepos[RepositoryType.komodoPrice] =
          await container.getAsync<KomodoPriceRepository>();
    }

    if (config.enableBinance) {
      availableRepos[RepositoryType.binance] =
          await container.getAsync<BinanceRepository>();
    }

    if (config.enableCoinGecko) {
      availableRepos[RepositoryType.coinGecko] =
          await container.getAsync<CoinGeckoRepository>();
    }

    if (config.enableCoinPaprika) {
      availableRepos[RepositoryType.coinPaprika] =
          await container.getAsync<CoinPaprikaRepository>();
    }

    // Add repositories in configured priority order
    for (final type in config.repositoryPriority) {
      final repo = availableRepos[type];
      if (repo != null) {
        repositories.add(repo);
      }
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

    if (config.enableCoinPaprika) {
      dependencies.add(CoinPaprikaRepository);
    }

    if (config.enableKomodoPrice) {
      dependencies.add(KomodoPriceRepository);
    }

    return dependencies;
  }
}
