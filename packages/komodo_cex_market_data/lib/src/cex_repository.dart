import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// An abstract class that defines the methods for fetching data from a
/// cryptocurrency exchange. The exchange-specific repository classes should
/// implement this class.
abstract class CexRepository {
  /// Fetches a list of all available coins on the exchange.
  ///
  /// Throws an [Exception] if the request fails.
  ///
  /// # Example usage:
  /// ```dart
  /// import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
  ///
  /// final CexRepository repo =
  ///   BinanceRepository(binanceProvider: BinanceProvider());
  /// final List<CexCoin> coins = await repo.getCoinList();
  /// ```
  Future<List<CexCoin>> getCoinList();

  /// Fetches OHLC data for a given coin symbol.
  ///
  /// [symbol]: The trading symbol for which to fetch the OHLC data.
  /// [interval]: The time interval for the OHLC data.
  /// [startTime]: The start time for the OHLC data (optional).
  /// [endTime]: The end time for the OHLC data (optional).
  /// [limit]: The maximum number of data points to fetch (optional).
  ///
  /// Throws an [Exception] if the request fails.
  ///
  /// The [startAt] and [endAt] parameters are used to restrict the time
  /// range of the OHLC data when provided. When [startAt] is provided, the
  /// first data point will start at or after the specified time. When [endAt]
  /// is provided, the last data point will end at or before the specified time.
  ///
  /// # Example usage:
  /// ```dart
  /// import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
  ///
  /// final CexRepository repo =
  ///   BinanceRepository(binanceProvider: BinanceProvider());
  /// final CoinOhlc ohlcData =
  ///   await repo.getCoinOhlc('BTCUSDT', '1d', limit: 100);
  /// ```
  Future<CoinOhlc> getCoinOhlc(
    CexCoinPair symbol,
    GraphInterval interval, {
    DateTime? startAt,
    DateTime? endAt,
    int? limit,
  });

  /// Fetches the value of the given asset in terms of the specified fiat
  /// currency at the specified timestamp.
  ///
  /// [assetId]: The asset for which to fetch the price.
  /// [priceDate]: The date and time for which to fetch the price.
  /// [fiatCoinId]: The fiat currency symbol in which to fetch the price.
  ///
  /// Throws an [Exception] if the request fails.
  ///
  /// # Example usage:
  /// ```dart
  /// import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
  ///
  /// final CexRepository repo =
  ///   BinanceRepository(binanceProvider: BinanceProvider());
  /// final double price = await repo.getCoinFiatPrice(
  ///   assetId,
  ///   priceDate: DateTime.now(),
  ///   fiatCoinId: 'usdt'
  /// );
  /// ```
  Future<double> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCoinId = 'usdt',
  });

  /// Fetches the value of the given asset in terms of the specified fiat currency
  /// at the specified timestamps.
  ///
  /// [assetId]: The asset for which to fetch the price.
  /// [dates]: The list of dates and times for which to fetch the price.
  /// [fiatCoinId]: The fiat currency symbol in which to fetch the price.
  ///
  /// Throws an [Exception] if the request fails.
  ///
  /// # Example usage:
  /// ```dart
  /// import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
  ///
  /// final CexRepository repo = BinanceRepository(
  ///   binanceProvider: BinanceProvider(),
  /// );
  /// final Map<String, double> prices = await repo.getCoinFiatPrices(
  ///  assetId,
  /// [DateTime.now(), DateTime.now().subtract(Duration(days: 1))],
  /// fiatCoinId: 'usdt',
  /// );
  /// ```
  Future<Map<DateTime, double>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCoinId = 'usdt',
  });

  /// Resolves the platform-specific trading symbol for this repository.
  /// Each implementation should override this to use their preferred ID.
  String resolveTradingSymbol(AssetId assetId);

  /// Checks if this repository can handle the given asset.
  /// Returns false if no suitable ID can be resolved.
  bool canHandleAsset(AssetId assetId);

  /// Checks if this repository supports the given asset, fiat, and request type.
  Future<bool> supports(
    AssetId assetId,
    AssetId fiatAssetId,
    PriceRequestType requestType,
  );
}
