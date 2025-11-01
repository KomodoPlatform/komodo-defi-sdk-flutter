import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_cex_market_data/src/binance/models/symbol_reduced.dart';

SymbolReduced _createSymbol({
  required String symbol,
  required String baseAsset,
  required String quoteAsset,
}) {
  return SymbolReduced(
    symbol: symbol,
    status: 'TRADING',
    baseAsset: baseAsset,
    baseAssetPrecision: 8,
    quoteAsset: quoteAsset,
    quotePrecision: 8,
    quoteAssetPrecision: 8,
    isSpotTradingAllowed: true,
  );
}

BinanceExchangeInfoResponseReduced buildComprehensiveExchangeInfo({
  int? serverTime,
}) {
  return BinanceExchangeInfoResponseReduced(
    timezone: 'UTC',
    serverTime:
        serverTime ?? 1640995200000, // Fixed timestamp: 2022-01-01 00:00:00 UTC
    symbols: [
      _createSymbol(symbol: 'BTCUSDT', baseAsset: 'BTC', quoteAsset: 'USDT'),
      _createSymbol(symbol: 'BTCUSDC', baseAsset: 'BTC', quoteAsset: 'USDC'),
      _createSymbol(symbol: 'BTCBUSD', baseAsset: 'BTC', quoteAsset: 'BUSD'),
      _createSymbol(symbol: 'BTCEUR', baseAsset: 'BTC', quoteAsset: 'EUR'),
      _createSymbol(symbol: 'ETHUSDT', baseAsset: 'ETH', quoteAsset: 'USDT'),
      _createSymbol(symbol: 'ETHUSDC', baseAsset: 'ETH', quoteAsset: 'USDC'),
      _createSymbol(symbol: 'BTCTUSD', baseAsset: 'BTC', quoteAsset: 'TUSD'),
      _createSymbol(symbol: 'BTCDAI', baseAsset: 'BTC', quoteAsset: 'DAI'),
      _createSymbol(symbol: 'BTCUSDP', baseAsset: 'BTC', quoteAsset: 'USDP'),
      _createSymbol(symbol: 'BTCEURS', baseAsset: 'BTC', quoteAsset: 'EURS'),
      _createSymbol(symbol: 'BTCEURT', baseAsset: 'BTC', quoteAsset: 'EURT'),
      _createSymbol(symbol: 'BTCFRAX', baseAsset: 'BTC', quoteAsset: 'FRAX'),
      _createSymbol(symbol: 'BTCLUSD', baseAsset: 'BTC', quoteAsset: 'LUSD'),
      _createSymbol(symbol: 'BTCGUSD', baseAsset: 'BTC', quoteAsset: 'GUSD'),
      _createSymbol(symbol: 'BTCSUSD', baseAsset: 'BTC', quoteAsset: 'SUSD'),
      _createSymbol(symbol: 'BTCFEI', baseAsset: 'BTC', quoteAsset: 'FEI'),
      // VIA coin - only supports BNB and ETH, not USDT (to test currency mapping bug)
      _createSymbol(symbol: 'VIABNB', baseAsset: 'VIA', quoteAsset: 'BNB'),
      _createSymbol(symbol: 'VIAETH', baseAsset: 'VIA', quoteAsset: 'ETH'),
      // TEST coin - only supports BUSD and USDC, not USDT (to test USD stablecoin fallback)
      _createSymbol(symbol: 'TESTBUSD', baseAsset: 'TEST', quoteAsset: 'BUSD'),
      _createSymbol(symbol: 'TESTUSDC', baseAsset: 'TEST', quoteAsset: 'USDC'),
    ],
  );
}

BinanceExchangeInfoResponseReduced buildMinimalExchangeInfo({int? serverTime}) {
  return BinanceExchangeInfoResponseReduced(
    timezone: 'UTC',
    serverTime:
        serverTime ?? 1640995200000, // Fixed timestamp: 2022-01-01 00:00:00 UTC
    symbols: [
      _createSymbol(symbol: 'BTCEUR', baseAsset: 'BTC', quoteAsset: 'EUR'),
    ],
  );
}

BinanceExchangeInfoResponseReduced buildExchangeInfoWithFallbackStablecoins({
  int? serverTime,
}) {
  return BinanceExchangeInfoResponseReduced(
    timezone: 'UTC',
    serverTime:
        serverTime ?? 1640995200000, // Fixed timestamp: 2022-01-01 00:00:00 UTC
    symbols: [
      // BTC has all major USD stablecoins
      _createSymbol(symbol: 'BTCUSDT', baseAsset: 'BTC', quoteAsset: 'USDT'),
      _createSymbol(symbol: 'BTCUSDC', baseAsset: 'BTC', quoteAsset: 'USDC'),
      _createSymbol(symbol: 'BTCBUSD', baseAsset: 'BTC', quoteAsset: 'BUSD'),
      // FALLBACK coin - only has BUSD (no USDT or USDC)
      _createSymbol(
        symbol: 'FALLBACKBUSD',
        baseAsset: 'FALLBACK',
        quoteAsset: 'BUSD',
      ),
      // ONLYUSDC coin - only has USDC (no USDT or BUSD)
      _createSymbol(
        symbol: 'ONLYUSDCUSDC',
        baseAsset: 'ONLYUSDC',
        quoteAsset: 'USDC',
      ),
      // NOUSD coin - has no USD stablecoins at all
      _createSymbol(symbol: 'NOUSDEUR', baseAsset: 'NOUSD', quoteAsset: 'EUR'),
      _createSymbol(symbol: 'NOUSDBNB', baseAsset: 'NOUSD', quoteAsset: 'BNB'),
    ],
  );
}

BinanceExchangeInfoResponseReduced buildRealWorldExampleExchangeInfo({
  int? serverTime,
}) {
  return BinanceExchangeInfoResponseReduced(
    timezone: 'UTC',
    serverTime:
        serverTime ?? 1640995200000, // Fixed timestamp: 2022-01-01 00:00:00 UTC
    symbols: [
      // BTC - has all major USD stablecoins
      _createSymbol(symbol: 'BTCUSDT', baseAsset: 'BTC', quoteAsset: 'USDT'),
      _createSymbol(symbol: 'BTCUSDC', baseAsset: 'BTC', quoteAsset: 'USDC'),
      _createSymbol(symbol: 'BTCBUSD', baseAsset: 'BTC', quoteAsset: 'BUSD'),
      _createSymbol(symbol: 'BTCTUSD', baseAsset: 'BTC', quoteAsset: 'TUSD'),
      _createSymbol(symbol: 'BTCPAX', baseAsset: 'BTC', quoteAsset: 'PAX'),
      _createSymbol(symbol: 'BTCFDUSD', baseAsset: 'BTC', quoteAsset: 'FDUSD'),
      _createSymbol(symbol: 'BTCDAI', baseAsset: 'BTC', quoteAsset: 'DAI'),

      // ETH - has most USD stablecoins but missing USDT
      _createSymbol(symbol: 'ETHUSDC', baseAsset: 'ETH', quoteAsset: 'USDC'),
      _createSymbol(symbol: 'ETHBUSD', baseAsset: 'ETH', quoteAsset: 'BUSD'),
      _createSymbol(symbol: 'ETHTUSD', baseAsset: 'ETH', quoteAsset: 'TUSD'),
      _createSymbol(symbol: 'ETHPAX', baseAsset: 'ETH', quoteAsset: 'PAX'),
      _createSymbol(symbol: 'ETHFDUSD', baseAsset: 'ETH', quoteAsset: 'FDUSD'),

      // BNB - only has BUSD and FDUSD (no USDT or USDC)
      _createSymbol(symbol: 'BNBBUSD', baseAsset: 'BNB', quoteAsset: 'BUSD'),
      _createSymbol(symbol: 'BNBFDUSD', baseAsset: 'BNB', quoteAsset: 'FDUSD'),
      _createSymbol(symbol: 'BNBRUB', baseAsset: 'BNB', quoteAsset: 'RUB'),
      _createSymbol(symbol: 'BNBTRY', baseAsset: 'BNB', quoteAsset: 'TRY'),

      // ADA - only has lower priority stablecoins
      _createSymbol(symbol: 'ADAPAX', baseAsset: 'ADA', quoteAsset: 'PAX'),
      _createSymbol(symbol: 'ADATUSD', baseAsset: 'ADA', quoteAsset: 'TUSD'),
      _createSymbol(symbol: 'ADAEUR', baseAsset: 'ADA', quoteAsset: 'EUR'),

      // RARE coin - only has one obscure USD stablecoin
      _createSymbol(symbol: 'RAREUSDS', baseAsset: 'RARE', quoteAsset: 'USDS'),

      // NOUSDC coin - has no USD stablecoins at all
      _createSymbol(
        symbol: 'NOUSDCEUR',
        baseAsset: 'NOUSDC',
        quoteAsset: 'EUR',
      ),
      _createSymbol(
        symbol: 'NOUSDCGBP',
        baseAsset: 'NOUSDC',
        quoteAsset: 'GBP',
      ),
      _createSymbol(
        symbol: 'NOUSDCJPY',
        baseAsset: 'NOUSDC',
        quoteAsset: 'JPY',
      ),
    ],
  );
}
