import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/src/swap/trading_fee.dart';

part 'swap_preview.freezed.dart';
part 'swap_preview.g.dart';

/// Preview information for a swap operation
@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
abstract class SwapPreview with _$SwapPreview {
  const factory SwapPreview({
    required TradingFee baseCoinFee,
    required TradingFee relCoinFee,
    required List<TradingFee> totalFees,
    @DecimalConverter() required Decimal volume,
    TradingFee? takerFee,
    TradingFee? feeToSendTakerFee,
  }) = _SwapPreview;
  const SwapPreview._();

  factory SwapPreview.fromJson(JsonMap json) => _$SwapPreviewFromJson(json);
}
