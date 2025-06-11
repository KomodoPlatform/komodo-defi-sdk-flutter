import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'swap_error_code.dart';
import 'swap_result.dart';
import 'swap_status.dart';

part 'swap_progress.freezed.dart';

/// Progress information for an ongoing swap
@Freezed(fromJson: false, toJson: false)
class SwapProgress with _$SwapProgress {
  const SwapProgress._();
  const factory SwapProgress({
    required SwapStatus status,
    required String message,
    SwapResult? swapResult,
    SwapErrorCode? errorCode,
    String? errorMessage,
    String? uuid,
  }) = _SwapProgress;

  factory SwapProgress.fromJson(JsonMap json) => SwapProgress(
        status: SwapStatus.values
            .firstWhere((e) => e.toString() == 'SwapStatus.${json['status']}'),
        message: json['message'] as String,
        swapResult: json['swap_result'] != null
            ? SwapResult.fromJson(json['swap_result'] as JsonMap)
            : null,
        errorCode: json['error_code'] != null
            ? SwapErrorCode.values.firstWhere(
                (e) => e.toString() == 'SwapErrorCode.${json['error_code']}',
              )
            : null,
        errorMessage: json['error_message'] as String?,
        uuid: json['uuid'] as String?,
      );

  JsonMap toJson() => {
        'status': status.toString().split('.').last,
        'message': message,
        if (swapResult != null) 'swap_result': swapResult!.toJson(),
        if (errorCode != null) 'error_code': errorCode.toString().split('.').last,
        if (errorMessage != null) 'error_message': errorMessage,
        if (uuid != null) 'uuid': uuid,
      };
}
