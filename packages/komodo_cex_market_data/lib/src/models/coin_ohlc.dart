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
      ohlc: json
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

/// Represents OHLC (Open-High-Low-Close) candlestick data from various sources.
///
/// This is a union type that can represent data from different sources:
/// - [CoinGeckoOhlc]: OHLC data from CoinGecko API
/// - [BinanceOhlc]: Kline data from Binance API with additional trading information
/// - [CoinPaprikaOhlc]: OHLC data from CoinPaprika API
@freezed
abstract class Ohlc with _$Ohlc {
  /// Creates an OHLC data point from CoinGecko API format.
  ///
  /// CoinGecko provides basic OHLC data with a single timestamp.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Ohlc.coingecko({
    /// Unix timestamp in milliseconds for this data point
    required int timestamp,

    /// Opening price as a [Decimal] for precision
    @DecimalConverter() required Decimal open,

    /// Highest price reached during this period as a [Decimal]
    @DecimalConverter() required Decimal high,

    /// Lowest price reached during this period as a [Decimal]
    @DecimalConverter() required Decimal low,

    /// Closing price as a [Decimal] for precision
    @DecimalConverter() required Decimal close,
  }) = CoinGeckoOhlc;

  /// Creates a kline (candlestick) data point from Binance API format.
  ///
  /// Binance provides comprehensive trading data including volume and trade counts.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Ohlc.binance({
    /// Unix timestamp in milliseconds when this kline opened
    required int openTime,

    /// Opening price as a [Decimal] for precision
    @DecimalConverter() required Decimal open,

    /// Highest price reached during this kline as a [Decimal]
    @DecimalConverter() required Decimal high,

    /// Lowest price reached during this kline as a [Decimal]
    @DecimalConverter() required Decimal low,

    /// Closing price as a [Decimal] for precision
    @DecimalConverter() required Decimal close,

    /// Unix timestamp in milliseconds when this kline closed
    required int closeTime,

    /// Trading volume during this kline as a [Decimal]
    @DecimalConverter() Decimal? volume,

    /// Quote asset volume during this kline as a [Decimal]
    @DecimalConverter() Decimal? quoteAssetVolume,

    /// Number of trades executed during this kline
    int? numberOfTrades,

    /// Volume of the asset bought by takers during this kline as a [Decimal]
    @DecimalConverter() Decimal? takerBuyBaseAssetVolume,

    /// Quote asset volume of the asset bought by takers during this kline as a [Decimal]
    @DecimalConverter() Decimal? takerBuyQuoteAssetVolume,
  }) = BinanceOhlc;

  /// Creates an OHLC data point from CoinPaprika API format.
  ///
  /// CoinPaprika provides OHLC data with separate open and close timestamps.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Ohlc.coinpaprika({
    /// Unix timestamp in milliseconds when this period opened
    required int timeOpen,

    /// Unix timestamp in milliseconds when this period closed
    required int timeClose,

    /// Opening price as a [Decimal] for precision
    @DecimalConverter() required Decimal open,

    /// Highest price reached during this period as a [Decimal]
    @DecimalConverter() required Decimal high,

    /// Lowest price reached during this period as a [Decimal]
    @DecimalConverter() required Decimal low,

    /// Closing price as a [Decimal] for precision
    @DecimalConverter() required Decimal close,

    /// Trading volume during this period as a [Decimal]
    @DecimalConverter() Decimal? volume,

    /// Market capitalization as a [Decimal]
    @DecimalConverter() Decimal? marketCap,
  }) = CoinPaprikaOhlc;

  /// Creates an [Ohlc] instance from a JSON map.
  factory Ohlc.fromJson(Map<String, dynamic> json) => _$OhlcFromJson(json);

  /// Creates a new instance of [Ohlc] from a JSON array.
  ///
  /// The array format varies by source:
  /// - CoinGecko: [timestamp, open, high, low, close] (5 elements)
  /// - Binance: [openTime, open, high, low, close, volume, closeTime, quoteAssetVolume, numberOfTrades, takerBuyBaseAssetVolume, takerBuyQuoteAssetVolume] (11+ elements)
  ///
  /// If [source] is provided, it forces parsing in that format.
  /// If [source] is null, the parser uses array length heuristics.
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
        volume: json.length > 5
            ? const DecimalConverter().fromJson(json[5])
            : null,
        closeTime: json.length > 6 ? asInt(json[6]) : asInt(json[0]),
        quoteAssetVolume: json.length > 7
            ? const DecimalConverter().fromJson(json[7])
            : null,
        numberOfTrades: json.length > 8 ? asInt(json[8]) : null,
        takerBuyBaseAssetVolume: json.length > 9
            ? const DecimalConverter().fromJson(json[9])
            : null,
        takerBuyQuoteAssetVolume: json.length > 10
            ? const DecimalConverter().fromJson(json[10])
            : null,
      );
    }

    // CoinPaprika format (not typically used with arrays, but included for completeness)
    if (source == OhlcSource.coinpaprika) {
      throw ArgumentError(
        'CoinPaprika OHLC data should be parsed from JSON objects, not arrays.',
      );
    }

    throw ArgumentError(
      'Invalid OHLC array length: ${json.length}. Expected 5 (CoinGecko) or >=11 (Binance).',
    );
  }
}

/// Source hint for parsing OHLC arrays.
///
/// Used to disambiguate between different API response formats when parsing
/// raw array data into [Ohlc] objects.
enum OhlcSource {
  /// CoinGecko API format: 5-element arrays
  coingecko,

  /// Binance API format: 11+ element arrays
  binance,

  /// CoinPaprika API format: JSON objects
  coinpaprika,
}

/// Extension providing unified accessors for [Ohlc] data regardless of source.
///
/// This extension normalizes the different field names and structures between
/// CoinGecko and Binance formats, providing consistent access patterns.
extension OhlcGetters on Ohlc {
  /// Gets the opening time in milliseconds since epoch.
  ///
  /// For CoinGecko data, this returns the timestamp.
  /// For Binance data, this returns the openTime.
  /// For CoinPaprika data, this returns the timeOpen.
  int get openTimeMs => map(
    coingecko: (c) => c.timestamp,
    binance: (b) => b.openTime,
    coinpaprika: (cp) => cp.timeOpen,
  );

  /// Gets the closing time in milliseconds since epoch.
  ///
  /// For CoinGecko data, this returns the timestamp (same as open time).
  /// For Binance data, this returns the closeTime.
  /// For CoinPaprika data, this returns the timeClose.
  int get closeTimeMs => map(
    coingecko: (c) => c.timestamp,
    binance: (b) => b.closeTime,
    coinpaprika: (cp) => cp.timeClose,
  );

  /// Gets the opening price as a [Decimal] for precision.
  Decimal get openDecimal => map(
    coingecko: (c) => c.open,
    binance: (b) => b.open,
    coinpaprika: (cp) => cp.open,
  );

  /// Gets the highest price as a [Decimal] for precision.
  Decimal get highDecimal => map(
    coingecko: (c) => c.high,
    binance: (b) => b.high,
    coinpaprika: (cp) => cp.high,
  );

  /// Gets the lowest price as a [Decimal] for precision.
  Decimal get lowDecimal => map(
    coingecko: (c) => c.low,
    binance: (b) => b.low,
    coinpaprika: (cp) => cp.low,
  );

  /// Gets the closing price as a [Decimal] for precision.
  Decimal get closeDecimal => map(
    coingecko: (c) => c.close,
    binance: (b) => b.close,
    coinpaprika: (cp) => cp.close,
  );
}
