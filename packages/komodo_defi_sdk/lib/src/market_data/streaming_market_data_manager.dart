import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_sdk/src/common/streaming_data_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Identifier for market data sources
class MarketDataKey extends DataSourceId {
  const MarketDataKey({
    required this.assetId,
    required this.fiatCurrency,
    this.priceDate,
  });

  final AssetId assetId;
  final String fiatCurrency;
  final DateTime? priceDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketDataKey &&
          assetId == other.assetId &&
          fiatCurrency == other.fiatCurrency &&
          priceDate == other.priceDate;

  @override
  int get hashCode => Object.hash(assetId, fiatCurrency, priceDate);
}

/// Market data including price and additional metrics
class MarketData {
  const MarketData({
    required this.price,
    this.priceChange24h,
    this.volume24h,
    this.marketCap,
    this.lastUpdated,
  });

  final Decimal price;
  final Decimal? priceChange24h;
  final Decimal? volume24h;
  final Decimal? marketCap;
  final DateTime? lastUpdated;

  MarketData copyWith({
    Decimal? price,
    Decimal? priceChange24h,
    Decimal? volume24h,
    Decimal? marketCap,
    DateTime? lastUpdated,
  }) {
    return MarketData(
      price: price ?? this.price,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      volume24h: volume24h ?? this.volume24h,
      marketCap: marketCap ?? this.marketCap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Enhanced market data manager with streaming support
abstract class StreamingMarketDataManager {
  Future<void> init();

  Future<MarketData> getMarketData(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  });

  Stream<MarketData> watchMarketData(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  });

  Future<Decimal> fiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  });

  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  });

  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCurrency = 'usdt',
  });

  Future<void> dispose();
}

/// Implementation using the generic streaming base
class CexStreamingMarketDataManager
    extends StreamingDataManager<MarketDataKey, MarketData>
    implements StreamingMarketDataManager {
  CexStreamingMarketDataManager({
    required CexRepository priceRepository,
    required KomodoPriceRepository komodoPriceRepository,
    StreamingConfig? config,
  }) : _priceRepository = priceRepository,
       _komodoPriceRepository = komodoPriceRepository,
       super(
         config:
             config ??
             const StreamingConfig(
               pollingInterval: Duration(seconds: 30),
               cacheExpiry: Duration(minutes: 5),
             ),
       );

  final CexRepository _priceRepository;
  final KomodoPriceRepository _komodoPriceRepository;
  Set<String>? _knownTickers;

  @override
  Future<void> init() async {
    await super.initialize();
  }

  @override
  Future<void> onInitialize() async {
    _knownTickers =
        (await _priceRepository.getCoinList()).map((e) => e.symbol).toSet();
  }

  @override
  Future<MarketData> fetchData(MarketDataKey key) async {
    _assertInitialized();

    try {
      final priceDouble = await _priceRepository.getCoinFiatPrice(
        _getTradingSymbol(key.assetId),
        priceDate: key.priceDate,
        fiatCoinId: key.fiatCurrency,
      );
      final price = Decimal.parse(priceDouble.toString());

      Decimal? priceChange24h;
      if (key.priceDate == null) {
        try {
          final prices = await _komodoPriceRepository.getKomodoPrices();
          final priceData = prices[key.assetId.symbol.configSymbol];
          if (priceData?.change24h != null) {
            priceChange24h = Decimal.parse(priceData!.change24h.toString());
          }
        } catch (_) {
          // ignore optional data errors
        }
      }

      return MarketData(
        price: price,
        priceChange24h: priceChange24h,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw StateError(
        'Failed to fetch market data for ${key.assetId.name}: $e',
      );
    }
  }

  @override
  Future<MarketData> getMarketData(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  }) {
    final key = MarketDataKey(assetId: assetId, fiatCurrency: fiatCurrency);
    return getData(key);
  }

  @override
  Stream<MarketData> watchMarketData(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  }) {
    final key = MarketDataKey(assetId: assetId, fiatCurrency: fiatCurrency);
    return watchData(key);
  }

  @override
  Future<Decimal> fiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) async {
    final key = MarketDataKey(
      assetId: assetId,
      fiatCurrency: fiatCurrency,
      priceDate: priceDate,
    );
    final data = await getData(key);
    return data.price;
  }

  @override
  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) {
    final key = MarketDataKey(
      assetId: assetId,
      fiatCurrency: fiatCurrency,
      priceDate: priceDate,
    );
    return getCached(key)?.price;
  }

  @override
  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCurrency = 'usdt',
  }) async {
    _assertInitialized();

    try {
      final priceDoubleMap = await _priceRepository.getCoinFiatPrices(
        assetId.symbol.configSymbol,
        dates,
        fiatCoinId: fiatCurrency,
      );

      final priceMap = <DateTime, Decimal>{};
      for (final entry in priceDoubleMap.entries) {
        final price = Decimal.parse(entry.value.toString());
        priceMap[entry.key] = price;

        final key = MarketDataKey(
          assetId: assetId,
          fiatCurrency: fiatCurrency,
          priceDate: entry.key,
        );
        updateCache(key, MarketData(price: price));
      }

      return priceMap;
    } catch (e) {
      throw StateError(
        'Failed to get historical prices for ${assetId.name}: $e',
      );
    }
  }

  String _getTradingSymbol(AssetId assetId) {
    return assetId.symbol.configSymbol;
  }

  void _assertInitialized() {
    if (_knownTickers == null) {
      throw StateError('MarketDataManager has not been initialized');
    }
  }

  @override
  Future<void> dispose() async {
    _knownTickers = null;
    await super.dispose();
  }
}

/// Factory for creating market data managers
class MarketDataManagerFactory {
  static StreamingMarketDataManager create({
    required CexRepository priceRepository,
    required KomodoPriceRepository komodoPriceRepository,
    StreamingConfig? config,
  }) {
    return CexStreamingMarketDataManager(
      priceRepository: priceRepository,
      komodoPriceRepository: komodoPriceRepository,
      config: config,
    );
  }
}
