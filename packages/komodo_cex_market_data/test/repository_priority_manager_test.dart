import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/_core_index.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

// Test provider implementations
class TestKomodoPriceProvider extends KomodoPriceProvider {
  @override
  Future<Map<String, AssetMarketInformation>> getKomodoPrices() async {
    return {
      'BTC': AssetMarketInformation(
        ticker: 'BTC',
        lastPrice: Decimal.fromInt(50000),
      ),
      'ETH': AssetMarketInformation(
        ticker: 'ETH',
        lastPrice: Decimal.fromInt(3000),
      ),
    };
  }
}

class TestBinanceProvider implements IBinanceProvider {
  @override
  Future<Binance24hrTicker> fetch24hrTicker(
    String symbol, {
    String? baseUrl,
  }) async {
    // Return mock data for testing
    return Binance24hrTicker(
      symbol: symbol,
      priceChange: Decimal.zero,
      priceChangePercent: Decimal.zero,
      weightedAvgPrice: Decimal.zero,
      prevClosePrice: Decimal.zero,
      lastPrice: Decimal.zero,
      lastQty: Decimal.zero,
      bidPrice: Decimal.zero,
      bidQty: Decimal.zero,
      askPrice: Decimal.zero,
      askQty: Decimal.zero,
      openPrice: Decimal.zero,
      highPrice: Decimal.zero,
      lowPrice: Decimal.zero,
      volume: Decimal.zero,
      quoteVolume: Decimal.zero,
      openTime: 0,
      closeTime: 0,
      firstId: 0,
      lastId: 0,
      count: 0,
    );
  }

  @override
  Future<BinanceExchangeInfoResponse> fetchExchangeInfo({
    String? baseUrl,
  }) async {
    return BinanceExchangeInfoResponse(
      symbols: [],
      rateLimits: [],
      serverTime: 0,
      timezone: '',
    );
  }

  @override
  Future<BinanceExchangeInfoResponseReduced> fetchExchangeInfoReduced({
    String? baseUrl,
  }) async {
    return BinanceExchangeInfoResponseReduced(
      symbols: [],
      serverTime: 0,
      timezone: '',
    );
  }

  @override
  Future<CoinOhlc> fetchKlines(
    String symbol,
    String interval, {
    int? startUnixTimestampMilliseconds,
    int? endUnixTimestampMilliseconds,
    int? limit,
    String? baseUrl,
  }) async {
    return const CoinOhlc(ohlc: []);
  }
}

class TestUnknownRepository implements CexRepository {
  @override
  Future<List<CexCoin>> getCoinList() async {
    return [];
  }

  @override
  Future<CoinOhlc> getCoinOhlc(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    GraphInterval interval, {
    DateTime? startAt,
    DateTime? endAt,
    int? limit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Decimal> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    return Decimal.zero;
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    return {};
  }

  @override
  Future<Decimal> getCoin24hrPriceChange(
    AssetId assetId, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    return Decimal.zero;
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    return '';
  }

  @override
  bool canHandleAsset(AssetId assetId) {
    return false;
  }

  @override
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  ) async {
    return false;
  }
}

void main() {
  group('RepositoryPriorityManager', () {
    late CexRepository komodoRepo;
    late CexRepository binanceRepo;
    late CexRepository coinGeckoRepo;
    late CexRepository unknownRepo;

    setUp(() {
      komodoRepo = KomodoPriceRepository(
        cexPriceProvider: TestKomodoPriceProvider(),
      );
      binanceRepo = BinanceRepository(binanceProvider: TestBinanceProvider());
      coinGeckoRepo = CoinGeckoRepository(
        coinGeckoProvider: CoinGeckoCexProvider(),
      );
      unknownRepo = TestUnknownRepository();
    });

    group('getPriority', () {
      test('returns correct priority for KomodoPriceRepository', () {
        expect(RepositoryPriorityManager.getPriority(komodoRepo), equals(1));
      });

      test('returns correct priority for BinanceRepository', () {
        expect(RepositoryPriorityManager.getPriority(binanceRepo), equals(2));
      });

      test('returns correct priority for CoinGeckoRepository', () {
        expect(RepositoryPriorityManager.getPriority(coinGeckoRepo), equals(4));
      });

      test('returns 999 for unknown repository types', () {
        expect(RepositoryPriorityManager.getPriority(unknownRepo), equals(999));
      });
    });

    group('getSparklinePriority', () {
      test('returns correct priority for BinanceRepository', () {
        expect(
          RepositoryPriorityManager.getSparklinePriority(binanceRepo),
          equals(1),
        );
      });

      test('returns correct priority for CoinGeckoRepository', () {
        expect(
          RepositoryPriorityManager.getSparklinePriority(coinGeckoRepo),
          equals(3),
        );
      });

      test(
        'returns 999 for KomodoPriceRepository (not in sparkline priorities)',
        () {
          expect(
            RepositoryPriorityManager.getSparklinePriority(komodoRepo),
            equals(999),
          );
        },
      );

      test('returns 999 for unknown repository types', () {
        expect(
          RepositoryPriorityManager.getSparklinePriority(unknownRepo),
          equals(999),
        );
      });
    });

    group('getPriorityWithCustomMap', () {
      test('uses custom priority map', () {
        final customPriorities = <Type, int>{
          BinanceRepository: 10,
          CoinGeckoRepository: 20,
        };

        expect(
          RepositoryPriorityManager.getPriorityWithCustomMap(
            binanceRepo,
            customPriorities,
          ),
          equals(10),
        );
        expect(
          RepositoryPriorityManager.getPriorityWithCustomMap(
            coinGeckoRepo,
            customPriorities,
          ),
          equals(20),
        );
        expect(
          RepositoryPriorityManager.getPriorityWithCustomMap(
            komodoRepo,
            customPriorities,
          ),
          equals(999),
        );
      });
    });

    group('sortByPriority', () {
      test('sorts repositories by default priority', () {
        final repositories = [
          coinGeckoRepo,
          komodoRepo,
          binanceRepo,
          unknownRepo,
        ];
        final sorted = RepositoryPriorityManager.sortByPriority(repositories);

        expect(sorted, hasLength(4));
        expect(sorted[0], isA<KomodoPriceRepository>());
        expect(sorted[1], isA<BinanceRepository>());
        expect(sorted[2], isA<CoinGeckoRepository>());
        expect(sorted[3], isA<TestUnknownRepository>());
      });

      test('returns new list without modifying original', () {
        final repositories = [coinGeckoRepo, binanceRepo, komodoRepo];
        final originalOrder = List.of(repositories);
        final sorted = RepositoryPriorityManager.sortByPriority(repositories);

        expect(repositories, equals(originalOrder));
        expect(sorted, isNot(same(repositories)));
      });
    });

    group('sortBySparklinePriority', () {
      test('sorts repositories by sparkline priority', () {
        final repositories = [
          coinGeckoRepo,
          komodoRepo,
          binanceRepo,
          unknownRepo,
        ];
        final sorted = RepositoryPriorityManager.sortBySparklinePriority(
          repositories,
        );

        expect(sorted, hasLength(4));
        expect(sorted[0], isA<BinanceRepository>());
        expect(sorted[1], isA<CoinGeckoRepository>());
        // KomodoPriceRepository and unknown should have priority 999, order may vary
        expect(
          sorted[2],
          anyOf(isA<KomodoPriceRepository>(), isA<TestUnknownRepository>()),
        );
        expect(
          sorted[3],
          anyOf(isA<KomodoPriceRepository>(), isA<TestUnknownRepository>()),
        );
      });
    });

    group('sortByCustomPriority', () {
      test('sorts repositories by custom priority map', () {
        final customPriorities = <Type, int>{
          CoinGeckoRepository: 1,
          BinanceRepository: 2,
          KomodoPriceRepository: 3,
        };

        final repositories = [
          komodoRepo,
          binanceRepo,
          coinGeckoRepo,
          unknownRepo,
        ];
        final sorted = RepositoryPriorityManager.sortByCustomPriority(
          repositories,
          customPriorities,
        );

        expect(sorted, hasLength(4));
        expect(sorted[0], isA<CoinGeckoRepository>());
        expect(sorted[1], isA<BinanceRepository>());
        expect(sorted[2], isA<KomodoPriceRepository>());
        expect(sorted[3], isA<TestUnknownRepository>());
      });
    });

    group('priority constants', () {
      test('defaultPriorities contains expected values', () {
        expect(
          RepositoryPriorityManager.defaultPriorities[KomodoPriceRepository],
          equals(1),
        );
        expect(
          RepositoryPriorityManager.defaultPriorities[BinanceRepository],
          equals(2),
        );
        expect(
          RepositoryPriorityManager.defaultPriorities[CoinGeckoRepository],
          equals(4),
        );
      });

      test('sparklinePriorities contains expected values', () {
        expect(
          RepositoryPriorityManager.sparklinePriorities[BinanceRepository],
          equals(1),
        );
        expect(
          RepositoryPriorityManager.sparklinePriorities[CoinGeckoRepository],
          equals(3),
        );
        expect(
          RepositoryPriorityManager.sparklinePriorities[KomodoPriceRepository],
          isNull,
        );
      });
    });
  });
}
