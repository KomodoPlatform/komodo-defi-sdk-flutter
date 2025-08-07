import 'package:komodo_cex_market_data/komodo_cex_market_data.dart'
    show PriceRequestType;
import 'package:komodo_cex_market_data/src/binance/binance.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_24hr_ticker.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

// Test provider implementations similar to repository_priority_manager_test.dart
class TestBinanceProvider implements IBinanceProvider {
  @override
  Future<Binance24hrTicker> fetch24hrTicker(
    String symbol, {
    String? baseUrl,
  }) async {
    throw UnimplementedError();
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
      timezone: 'UTC',
      serverTime: DateTime.now().millisecondsSinceEpoch,
      symbols: [
        SymbolReduced(
          symbol: 'BTCUSD',
          status: 'TRADING',
          baseAsset: 'BTC',
          baseAssetPrecision: 8,
          quoteAsset: 'USD',
          quotePrecision: 8,
          quoteAssetPrecision: 8,
          isSpotTradingAllowed: true,
        ),
      ],
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
    throw UnimplementedError();
  }
}

void main() {
  group('RepositorySelectionStrategy', () {
    late RepositorySelectionStrategy strategy;
    late BinanceRepository binance;
    late CoinGeckoRepository gecko;

    setUp(() {
      strategy = DefaultRepositorySelectionStrategy();
      binance = BinanceRepository(
        binanceProvider: TestBinanceProvider(),
        enableMemoization: false,
      );
      gecko = CoinGeckoRepository(
        coinGeckoProvider: CoinGeckoCexProvider(),
        enableMemoization: false,
      );
    });

    test('selects repository based on priority', () async {
      final asset = AssetId(
        id: 'BTC',
        name: 'BTC',
        symbol: AssetSymbol(assetConfigId: 'BTC'),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      );
      final fiat = FiatCurrency.usd;

      final repo = await strategy.selectRepository(
        assetId: asset,
        fiatCurrency: fiat,
        requestType: PriceRequestType.currentPrice,
        availableRepositories: [gecko, binance],
      );

      expect(repo, equals(binance));
    });
  });
}
