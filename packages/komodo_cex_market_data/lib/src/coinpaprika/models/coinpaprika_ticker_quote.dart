import 'package:freezed_annotation/freezed_annotation.dart';

part 'coinpaprika_ticker_quote.freezed.dart';
part 'coinpaprika_ticker_quote.g.dart';

/// Represents a detailed quote for a specific currency from CoinPaprika's ticker endpoint.
@freezed
abstract class CoinPaprikaTickerQuote with _$CoinPaprikaTickerQuote {
  /// Creates a CoinPaprika ticker quote instance.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoinPaprikaTickerQuote({
    /// Current price in the quote currency
    required double price,

    /// 24-hour trading volume
    @Default(0.0) double volume24h,

    /// 24-hour volume change percentage
    @Default(0.0) double volume24hChange24h,

    /// Market capitalization
    @Default(0.0) double marketCap,

    /// 24-hour market cap change percentage
    @Default(0.0) double marketCapChange24h,

    /// Price change percentage in the last 15 minutes
    @Default(0.0) double percentChange15m,

    /// Price change percentage in the last 30 minutes
    @Default(0.0) double percentChange30m,

    /// Price change percentage in the last 1 hour
    @Default(0.0) double percentChange1h,

    /// Price change percentage in the last 6 hours
    @Default(0.0) double percentChange6h,

    /// Price change percentage in the last 12 hours
    @Default(0.0) double percentChange12h,

    /// Price change percentage in the last 24 hours
    @Default(0.0) double percentChange24h,

    /// Price change percentage in the last 7 days
    @Default(0.0) double percentChange7d,

    /// Price change percentage in the last 30 days
    @Default(0.0) double percentChange30d,

    /// Price change percentage in the last 1 year
    @Default(0.0) double percentChange1y,

    /// All-time high price (nullable)
    double? athPrice,

    /// Date of all-time high (nullable)
    DateTime? athDate,

    /// Percentage from all-time high price (nullable)
    double? percentFromPriceAth,
  }) = _CoinPaprikaTickerQuote;

  /// Creates a CoinPaprika ticker quote instance from JSON.
  factory CoinPaprikaTickerQuote.fromJson(Map<String, dynamic> json) =>
      _$CoinPaprikaTickerQuoteFromJson(json);
}
