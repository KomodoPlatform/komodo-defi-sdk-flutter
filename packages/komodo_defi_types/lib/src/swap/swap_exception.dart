import 'package:komodo_defi_types/src/swap/swap_error_code.dart';

/// Exception thrown during swap operations
class SwapException implements Exception {
  SwapException(this.message, this.code);

  final String message;
  final SwapErrorCode code;

  @override
  String toString() => message;

  /// Maps error messages from the API to appropriate error codes
  static SwapErrorCode mapErrorToCode(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('insufficient funds') ||
        errorLower.contains('not enough funds') ||
        errorLower.contains('balance')) {
      return SwapErrorCode.insufficientFunds;
    }

    if (errorLower.contains('invalid pair') ||
        errorLower.contains('invalid trading pair')) {
      return SwapErrorCode.invalidTradingPair;
    }

    if (errorLower.contains('network') ||
        errorLower.contains('connection') ||
        errorLower.contains('timeout')) {
      return SwapErrorCode.networkError;
    }

    if (errorLower.contains('no matching orders') ||
        errorLower.contains('order matching')) {
      return SwapErrorCode.orderMatchingFailed;
    }

    if (errorLower.contains('price') ||
        errorLower.contains('slippage')) {
      return SwapErrorCode.priceSlippage;
    }

    if (errorLower.contains('not activated') ||
        errorLower.contains('activation')) {
      return SwapErrorCode.assetNotActivated;
    }

    if (errorLower.contains('cancelled') ||
        errorLower.contains('canceled')) {
      return SwapErrorCode.userCancelled;
    }

    return SwapErrorCode.unknownError;
  }
}