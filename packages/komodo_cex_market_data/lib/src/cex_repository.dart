import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/models/_models_index.dart';
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
    AssetId assetId,
    QuoteCurrency quoteCurrency,
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
  /// [fiatCurrency]: The fiat currency in which to fetch the price.
  ///
  /// Throws an [Exception] if the request fails.
  ///
  /// # Example usage:
  /// ```dart
  /// import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
  ///
  /// final CexRepository repo =
  ///   BinanceRepository(binanceProvider: BinanceProvider());
  /// final Decimal price = await repo.getCoinFiatPrice(
  ///   assetId,
  ///   priceDate: DateTime.now(),
  ///   fiatCurrency: Stablecoin.usdt
  /// );
  /// ```
  Future<Decimal> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  });

  /// Fetches the value of the given asset in terms of the specified fiat currency
  /// at the specified timestamps.
  ///
  /// [assetId]: The asset for which to fetch the price.
  /// [dates]: The list of dates and times for which to fetch the price.
  /// [fiatCurrency]: The fiat currency in which to fetch the price.
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
  /// final Map<String, Decimal> prices = await repo.getCoinFiatPrices(
  ///  assetId,
  /// [DateTime.now(), DateTime.now().subtract(Duration(days: 1))],
  /// fiatCurrency: Stablecoin.usdt,
  /// );
  /// ```
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  });

  /// Fetches the 24-hour price change percentage for a given asset.
  ///
  /// [assetId]: The asset for which to fetch the 24-hour price change.
  /// [fiatCurrency]: The fiat currency in which to calculate the change.
  ///
  /// Returns the percentage change as a [Decimal] (e.g., 5.25 for +5.25%).
  ///
  /// Subclasses must provide their own implementation of this method.
  ///
  /// # Example usage:
  /// ```dart
  /// import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
  ///
  /// final CexRepository repo = BinanceRepository(
  ///   binanceProvider: BinanceProvider(),
  /// );
  /// final Decimal changePercent = await repo.getCoin24hrPriceChange(
  ///   assetId,
  ///   fiatCurrency: Stablecoin.usdt,
  /// );
  /// ```
  Future<Decimal> getCoin24hrPriceChange(
    AssetId assetId, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  });

  /// Resolves the platform-specific trading symbol for this repository.
  ///
  /// Each implementation should override this to use their preferred ID format.
  ///
  /// [assetId]: The asset to resolve the trading symbol for.
  ///
  /// Returns the platform-specific symbol/ticker as a [String]. If the asset
  /// cannot be resolved to a valid trading symbol, implementations should
  /// return an empty string rather than throwing an exception.
  ///
  /// # Example usage:
  /// ```dart
  /// final symbol = repository.resolveTradingSymbol(assetId);
  /// if (symbol.isEmpty) {
  ///   // Handle unsupported asset
  /// }
  /// ```
  String resolveTradingSymbol(AssetId assetId);

  /// Checks if this repository can handle the given asset.
  ///
  /// This method should perform a quick check to determine if the repository
  /// can process requests for the given asset. It should not throw exceptions
  /// for unsupported assets.
  ///
  /// [assetId]: The asset to check support for.
  ///
  /// Returns `true` if the repository can handle this asset, `false` otherwise.
  /// When this returns `false`, other methods in this repository should not be
  /// called with this asset as they may throw exceptions.
  ///
  /// # Example usage:
  /// ```dart
  /// if (repository.canHandleAsset(assetId)) {
  ///   final price = await repository.getCoinFiatPrice(assetId);
  /// }
  /// ```
  bool canHandleAsset(AssetId assetId);

  /// Checks if this repository supports the given asset, fiat currency, and request type.
  ///
  /// This method provides a comprehensive capability check that considers not just
  /// the asset, but also the target fiat currency and the type of data being requested.
  ///
  /// [assetId]: The asset to check support for.
  /// [fiatCurrency]: The target fiat currency for price conversion.
  /// [requestType]: The type of price request. Possible values are:
  ///   - [PriceRequestType.currentPrice]: Current/live price data
  ///   - [PriceRequestType.priceChange]: 24-hour price change data
  ///   - [PriceRequestType.priceHistory]: Historical price data
  ///
  /// Returns `true` if the repository supports all the specified parameters,
  /// `false` otherwise. This method should not throw exceptions.
  ///
  /// # Example usage:
  /// ```dart
  /// final canGetCurrentPrice = await repository.supports(
  ///   assetId,
  ///   Stablecoin.usdt,
  ///   PriceRequestType.currentPrice,
  /// );
  /// ```
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  );

  /// Releases any resources held by the repository.
  ///
  /// Repositories that allocate resources such as HTTP clients or file handles
  /// should override this method to dispose them when no longer needed.
  void dispose() {}
}
