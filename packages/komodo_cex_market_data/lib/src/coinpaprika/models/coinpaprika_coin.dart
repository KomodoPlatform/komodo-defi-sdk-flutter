import 'package:freezed_annotation/freezed_annotation.dart';

part 'coinpaprika_coin.freezed.dart';
part 'coinpaprika_coin.g.dart';

/// Represents a coin from CoinPaprika's coins list endpoint.
@freezed
abstract class CoinPaprikaCoin with _$CoinPaprikaCoin {
  /// Creates a CoinPaprika coin instance.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoinPaprikaCoin({
    /// Unique identifier for the coin (e.g., "btc-bitcoin")
    required String id,

    /// Full name of the coin (e.g., "Bitcoin")
    required String name,

    /// Symbol/ticker of the coin (e.g., "BTC")
    required String symbol,

    /// Market ranking of the coin
    required int rank,

    /// Whether this is a new coin (added within last 5 days)
    required bool isNew,

    /// Whether this coin is currently active
    required bool isActive,

    /// Type of cryptocurrency ("coin" or "token")
    required String type,
  }) = _CoinPaprikaCoin;

  /// Creates a CoinPaprika coin instance from JSON.
  factory CoinPaprikaCoin.fromJson(Map<String, dynamic> json) =>
      _$CoinPaprikaCoinFromJson(json);
}
