import 'package:komodo_cex_market_data/src/binance/models/binance_24hr_ticker.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_cex_market_data/src/models/coin_ohlc.dart';

abstract class IBinanceProvider {
  /// Fetches candlestick chart data from Binance API.
  ///
  /// Retrieves the candlestick chart data for a specific symbol and interval
  /// from the Binance API.
  /// Optionally, you can specify the start time, end time, and limit of the
  /// data to fetch.
  ///
  /// Parameters:
  /// - [symbol]: The trading symbol for which to fetch the candlestick
  /// chart data.
  /// - [interval]: The time interval for the candlestick chart data
  /// (e.g., '1m', '1h', '1d').
  /// - [startTime]: The start time (in milliseconds since epoch, Unix time) of
  /// the data range to fetch (optional).
  /// - [endTime]: The end time (in milliseconds since epoch, Unix time) of the
  /// data range to fetch (optional).
  /// - [limit]: The maximum number of data points to fetch (optional). Defaults
  /// to 500, maximum is 1000.
  ///
  /// Returns:
  /// A [Future] that resolves to a [CoinOhlc] object containing the fetched
  /// candlestick chart data.
  ///
  /// Example usage:
  /// ```dart
  /// final BinanceKlinesResponse klines = await fetchKlines(
  ///   'BTCUSDT',
  ///   '1h',
  ///   limit: 100,
  /// );
  /// ```
  ///
  /// Throws:
  /// - [Exception] if the API request fails.
  Future<CoinOhlc> fetchKlines(
    String symbol,
    String interval, {
    int? startUnixTimestampMilliseconds,
    int? endUnixTimestampMilliseconds,
    int? limit,
    String? baseUrl,
  });

  /// Fetches the exchange information from Binance.
  ///
  /// Returns a [Future] that resolves to a [BinanceExchangeInfoResponse] object
  /// Throws an [Exception] if the request fails.
  Future<BinanceExchangeInfoResponse> fetchExchangeInfo({String? baseUrl});

  /// Fetches the exchange information from Binance.
  ///
  /// Returns a [Future] that resolves to a [BinanceExchangeInfoResponseReduced]
  /// object.
  /// Throws an [Exception] if the request fails.
  Future<BinanceExchangeInfoResponseReduced> fetchExchangeInfoReduced({
    String? baseUrl,
  });

  /// Fetches 24hr ticker price change statistics from Binance API.
  ///
  /// Retrieves the 24hr ticker price change statistics for a specific symbol
  /// from the Binance API.
  ///
  /// Parameters:
  /// - [symbol]: The trading symbol for which to fetch the 24hr ticker data.
  /// - [baseUrl]: Optional base URL to override the default API endpoint.
  ///
  /// Returns:
  /// A [Future] that resolves to a [Binance24hrTicker] object containing the
  /// 24hr price change statistics.
  ///
  /// Example usage:
  /// ```dart
  /// final Binance24hrTicker ticker = await fetch24hrTicker('BTCUSDT');
  /// ```
  ///
  /// Throws:
  /// - [Exception] if the API request fails.
  Future<Binance24hrTicker> fetch24hrTicker(String symbol, {String? baseUrl});
}
