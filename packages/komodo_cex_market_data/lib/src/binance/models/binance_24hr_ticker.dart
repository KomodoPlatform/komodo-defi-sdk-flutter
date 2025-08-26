import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_cex_market_data/src/models/json_converters.dart';

part 'binance_24hr_ticker.freezed.dart';
part 'binance_24hr_ticker.g.dart';

/// A model representing Binance 24hr ticker price change statistics.
@freezed
abstract class Binance24hrTicker with _$Binance24hrTicker {
  /// Creates a new instance of [Binance24hrTicker].
  const factory Binance24hrTicker({
    required String symbol,
    @DecimalConverter() required Decimal priceChange,
    @DecimalConverter() required Decimal priceChangePercent,
    @DecimalConverter() required Decimal weightedAvgPrice,
    @DecimalConverter() required Decimal prevClosePrice,
    @DecimalConverter() required Decimal lastPrice,
    @DecimalConverter() required Decimal lastQty,
    @DecimalConverter() required Decimal bidPrice,
    @DecimalConverter() required Decimal bidQty,
    @DecimalConverter() required Decimal askPrice,
    @DecimalConverter() required Decimal askQty,
    @DecimalConverter() required Decimal openPrice,
    @DecimalConverter() required Decimal highPrice,
    @DecimalConverter() required Decimal lowPrice,
    @DecimalConverter() required Decimal volume,
    @DecimalConverter() required Decimal quoteVolume,
    required int openTime,
    required int closeTime,
    required int firstId,
    required int lastId,
    required int count,
  }) = _Binance24hrTicker;

  /// Creates a new instance of [Binance24hrTicker] from a JSON object.
  factory Binance24hrTicker.fromJson(Map<String, dynamic> json) =>
      _$Binance24hrTickerFromJson(json);
}
