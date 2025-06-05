import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Handles protocol-specific error translation and categorization
abstract class ProtocolErrorHandler {
  const ProtocolErrorHandler();

  /// Categorize and enrich error information
  ActivationProgressDetails handleError(Object error, StackTrace stack);

  /// Extract error code from error
  String? getErrorCode(Object error);

  /// Get user-friendly error message
  String getUserMessage(Object error);
}

class Erc20ErrorHandler extends ProtocolErrorHandler {
  const Erc20ErrorHandler();

  @override
  ActivationProgressDetails handleError(Object error, StackTrace stack) {
    final code = getErrorCode(error);
    return ActivationProgressDetails(
      currentStep: 'error',
      stepCount: 2,
      errorCode: code,
      errorDetails: getUserMessage(error),
      stackTrace: stack.toString(),
      additionalInfo: _getAdditionalInfo(error),
    );
  }

  @override
  String? getErrorCode(Object error) {
    if (error.toString().contains('insufficient funds')) {
      return 'ERC20_INSUFFICIENT_FUNDS';
    }
    if (error.toString().contains('nonce too low')) {
      return 'ERC20_NONCE_ERROR';
    }
    // Add more error codes...
    return 'ERC20_UNKNOWN_ERROR';
  }

  @override
  String getUserMessage(Object error) {
    final code = getErrorCode(error);
    switch (code) {
      case 'ERC20_INSUFFICIENT_FUNDS':
        return 'Insufficient funds to activate token';
      case 'ERC20_NONCE_ERROR':
        return 'Transaction nonce error - please try again';
      default:
        return 'Failed to activate ERC20 token: $error';
    }
  }

  Map<String, dynamic> _getAdditionalInfo(Object error) {
    // Extract any useful information from the error
    return {
      'errorType': error.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
