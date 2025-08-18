import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_cex_market_data/src/models/json_converters.dart';

part 'coin_ohlc.freezed.dart';
part 'coin_ohlc.g.dart';

/// Represents Open-High-Low-Close (OHLC) data.
class CoinOhlc extends Equatable {
  /// Creates a new instance of [CoinOhlc].
  const CoinOhlc({required this.ohlc});

  /// Creates a new instance of [CoinOhlc] from an array of klines.
  factory CoinOhlc.fromJson(List<dynamic> json, {OhlcSource? source}) {
    return CoinOhlc(
      ohlc:
          json
              .map(
                (dynamic kline) =>
                    Ohlc.fromKlineArray(kline as List<dynamic>, source: source),
              )
              .toList(),
    );
  }

  /// Creates a new instance of [CoinOhlc] with constant price data between
  /// [startAt] and [endAt] with an interval of [intervalSeconds].
  factory CoinOhlc.fromConstantPrice({
    required DateTime startAt,
    required DateTime endAt,
    required int intervalSeconds,
    double constantValue = 1.0,
  }) {
    final coinOhlc = CoinOhlc(
      ohlc: List.generate(
        (endAt.difference(startAt).inSeconds / intervalSeconds).ceil(),
        (index) {
          final time = startAt.add(Duration(seconds: index * intervalSeconds));
          return Ohlc.binance(
            high: Decimal.parse(constantValue.toString()),
            low: Decimal.parse(constantValue.toString()),
            open: Decimal.parse(constantValue.toString()),
            close: Decimal.parse(constantValue.toString()),
            openTime: time.millisecondsSinceEpoch,
            closeTime: time.millisecondsSinceEpoch,
          );
        },
      ),
    );

    coinOhlc.ohlc.add(
      Ohlc.binance(
        high: Decimal.parse(constantValue.toString()),
        low: Decimal.parse(constantValue.toString()),
        open: Decimal.parse(constantValue.toString()),
        close: Decimal.parse(constantValue.toString()),
        openTime: endAt.millisecondsSinceEpoch,
        closeTime: endAt.millisecondsSinceEpoch,
      ),
    );

    return coinOhlc;
  }

  /// The list of klines (candlestick data).
  final List<Ohlc> ohlc;

  /// Converts the [CoinOhlc] object to a JSON array.
  List<dynamic> toJson() {
    return ohlc.map((Ohlc kline) => kline.toJson()).toList();
  }

  @override
  List<Object?> get props => <Object?>[ohlc];
}

/// Extension for converting a list of [Ohlc] objects to a `CoinOhlc` object.

extension OhlcListToCoinOhlc on List<Ohlc> {
  /// Converts a list of [Ohlc] objects to a `CoinOhlc` object.
  CoinOhlc toCoinOhlc() {
    return CoinOhlc(ohlc: this);
  }
}

/// Represents a Binance Kline (candlestick) data.
@freezed
abstract class Ohlc with _$Ohlc {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Ohlc.coingecko({
    required int timestamp,
    @DecimalConverter() required Decimal open,
    @DecimalConverter() required Decimal high,
    @DecimalConverter() required Decimal low,
    @DecimalConverter() required Decimal close,
  }) = CoinGeckoOhlc;

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Ohlc.binance({
    required int openTime,
    @DecimalConverter() required Decimal open,
    @DecimalConverter() required Decimal high,
    @DecimalConverter() required Decimal low,
    @DecimalConverter() required Decimal close,
    required int closeTime,
    @DecimalConverter() Decimal? volume,
    @DecimalConverter() Decimal? quoteAssetVolume,
    int? numberOfTrades,
    @DecimalConverter() Decimal? takerBuyBaseAssetVolume,
    @DecimalConverter() Decimal? takerBuyQuoteAssetVolume,
  }) = BinanceOhlc;

  factory Ohlc.fromJson(Map<String, dynamic> json) => _$OhlcFromJson(json);

  /// Creates a new instance of [Ohlc] from a JSON array.
  factory Ohlc.fromKlineArray(List<dynamic> json, {OhlcSource? source}) {
    Decimal asDecimal(dynamic value) {
      final dec = const DecimalConverter().fromJson(value);
      if (dec == null) {
        throw ArgumentError('Cannot convert value "$value" to Decimal');
      }
      return dec;
    }

    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.parse(value);
      throw ArgumentError('Cannot convert value "$value" to int');
    }

    // Prefer explicit source; fall back to heuristic by length
    if (source == OhlcSource.coingecko ||
        (source == null && json.length == 5)) {
      final ts = asInt(json[0]);
      return Ohlc.coingecko(
        timestamp: ts,
        open: asDecimal(json[1]),
        high: asDecimal(json[2]),
        low: asDecimal(json[3]),
        close: asDecimal(json[4]),
      );
    }

    // Binance-like arrays have >= 11 elements
    if (source == OhlcSource.binance || json.length >= 11) {
      return Ohlc.binance(
        openTime: asInt(json[0]),
        open: asDecimal(json[1]),
        high: asDecimal(json[2]),
        low: asDecimal(json[3]),
        close: asDecimal(json[4]),
        volume:
            json.length > 5 ? const DecimalConverter().fromJson(json[5]) : null,
        closeTime: json.length > 6 ? asInt(json[6]) : asInt(json[0]),
        quoteAssetVolume:
            json.length > 7 ? const DecimalConverter().fromJson(json[7]) : null,
        numberOfTrades: json.length > 8 ? asInt(json[8]) : null,
        takerBuyBaseAssetVolume:
            json.length > 9 ? const DecimalConverter().fromJson(json[9]) : null,
        takerBuyQuoteAssetVolume:
            json.length > 10
                ? const DecimalConverter().fromJson(json[10])
                : null,
      );
    }

    throw ArgumentError(
      'Invalid OHLC array length: ${json.length}. Expected 5 (CoinGecko) or >=11 (Binance).',
    );
  }
}

/// Source hint for parsing OHLC arrays
enum OhlcSource { coingecko, binance }

extension OhlcGetters on Ohlc {
  int get openTimeMs =>
      map(coingecko: (c) => c.timestamp, binance: (b) => b.openTime);
  int get closeTimeMs =>
      map(coingecko: (c) => c.timestamp, binance: (b) => b.closeTime);
  Decimal get openDecimal =>
      map(coingecko: (c) => c.open, binance: (b) => b.open);
  Decimal get highDecimal =>
      map(coingecko: (c) => c.high, binance: (b) => b.high);
  Decimal get lowDecimal => map(coingecko: (c) => c.low, binance: (b) => b.low);
  Decimal get closeDecimal =>
      map(coingecko: (c) => c.close, binance: (b) => b.close);
}
