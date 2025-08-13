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
