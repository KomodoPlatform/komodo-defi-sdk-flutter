import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import '../utils/decimal_converter.dart';

part 'swap_result.freezed.dart';
part 'swap_result.g.dart';

/// Result of a completed swap operation
@freezed
class SwapResult with _$SwapResult {
  const SwapResult._();
  const factory SwapResult({
    required String uuid,
    required String base,
    required String rel,
    @DecimalConverter() required Decimal price,
    @DecimalConverter() required Decimal volume,
    required String orderType,
    String? txHash,
    int? createdAt,
  }) = _SwapResult;

  factory SwapResult.fromJson(JsonMap json) => _$SwapResultFromJson(json);

  JsonMap toJson() => _$SwapResultToJson(this);
}
