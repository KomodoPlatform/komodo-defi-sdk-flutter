import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'swap_result.freezed.dart';
part 'swap_result.g.dart';

/// Result of a completed swap operation
@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
abstract class SwapResult with _$SwapResult {
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
  const SwapResult._();

  factory SwapResult.fromJson(JsonMap json) => _$SwapResultFromJson(json);
}
