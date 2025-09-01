import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_ticker_quote.dart';

part 'coinpaprika_ticker.freezed.dart';
part 'coinpaprika_ticker.g.dart';

/// Represents ticker data from CoinPaprika's ticker endpoint.
@freezed
abstract class CoinPaprikaTicker with _$CoinPaprikaTicker {
  /// Creates a CoinPaprika ticker instance.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoinPaprikaTicker({
    /// Unique identifier for the coin (e.g., "btc-bitcoin")
    @Default('') String id,

    /// Full name of the coin (e.g., "Bitcoin")
    @Default('') String name,

    /// Symbol/ticker of the coin (e.g., "BTC")
    @Default('') String symbol,

    /// Market ranking of the coin
    @Default(0) int rank,

    /// Circulating supply of the coin
    @Default(0) int circulatingSupply,

    /// Total supply of the coin
    @Default(0) int totalSupply,

    /// Maximum supply of the coin (nullable)
    int? maxSupply,

    /// Beta value (volatility measure)
    @Default(0.0) double betaValue,

    /// Date of first data point
    DateTime? firstDataAt,

    /// Last updated timestamp
    DateTime? lastUpdated,

    /// Map of quotes for different currencies (BTC, USD, etc.)
    required Map<String, CoinPaprikaTickerQuote> quotes,
  }) = _CoinPaprikaTicker;

  /// Creates a CoinPaprika ticker instance from JSON.
  factory CoinPaprikaTicker.fromJson(Map<String, dynamic> json) =>
      _$CoinPaprikaTickerFromJson(json);
}
