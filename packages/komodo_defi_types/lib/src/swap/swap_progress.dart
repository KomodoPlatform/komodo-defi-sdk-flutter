import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/src/swap/swap_error_code.dart';
import 'package:komodo_defi_types/src/swap/swap_result.dart';
import 'package:komodo_defi_types/src/swap/swap_status.dart';

/// Progress information for an ongoing swap
class SwapProgress extends Equatable {
  const SwapProgress({
    required this.status,
    required this.message,
    this.swapResult,
    this.errorCode,
    this.errorMessage,
    this.uuid,
  });

  /// Current status of the swap
  final SwapStatus status;

  /// Descriptive message about the current state
  final String message;

  /// Result data if swap completed successfully
  final SwapResult? swapResult;

  /// Error code if swap failed
  final SwapErrorCode? errorCode;

  /// Error message if swap failed
  final String? errorMessage;

  /// UUID of the order/swap
  final String? uuid;

  @override
  List<Object?> get props => [
        status,
        message,
        swapResult,
        errorCode,
        errorMessage,
        uuid,
      ];
}
