import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'trading_fee.freezed.dart';
part 'trading_fee.g.dart';

/// Trading fee information
@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
abstract class TradingFee with _$TradingFee {
  const factory TradingFee({
    required String coin,
    @DecimalConverter() required Decimal amount,
  }) = _TradingFee;
  const TradingFee._();

  factory TradingFee.fromJson(JsonMap json) => _$TradingFeeFromJson(json);
}
