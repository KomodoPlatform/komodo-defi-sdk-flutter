import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/src/swap/swap_error_code.dart';
import 'package:komodo_defi_types/src/swap/swap_result.dart';
import 'package:komodo_defi_types/src/swap/swap_status.dart';

part 'swap_progress.freezed.dart';
part 'swap_progress.g.dart';

/// Progress information for an ongoing swap
@freezed
sealed class SwapProgress with _$SwapProgress {
  const factory SwapProgress({
    @SwapStatusConverter() required SwapStatus status,
    required String message,
    @JsonKey(name: 'swap_result') SwapResult? swapResult,
    @JsonKey(name: 'error_code')
    @SwapErrorCodeConverter()
    SwapErrorCode? errorCode,
    @JsonKey(name: 'error_message') String? errorMessage,
    String? uuid,
  }) = _SwapProgress;
  const SwapProgress._();

  factory SwapProgress.fromJson(JsonMap json) => _$SwapProgressFromJson(json);
}
