import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import '../utils/decimal_converter.dart';

part 'trading_fee.freezed.dart';
part 'trading_fee.g.dart';

/// Trading fee information
@freezed
class TradingFee with _$TradingFee {
  const TradingFee._();
  const factory TradingFee({
    required String coin,
    @DecimalConverter() required Decimal amount,
  }) = _TradingFee;

  factory TradingFee.fromJson(JsonMap json) => _$TradingFeeFromJson(json);

  JsonMap toJson() => _$TradingFeeToJson(this);
}
