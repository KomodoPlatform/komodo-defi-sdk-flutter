// TODO(komodo-team): Allow passing the start sync mode; currently hard-coded
// to sync from the time of activation.

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Convenience wrapper around [ActivationProgress] that exposes the canonical
/// progress snapshots used throughout ZHTLC activation.
class ZhtlcActivationProgress extends ActivationProgress {
  const ZhtlcActivationProgress._({
    required super.status,
    super.isComplete,
    super.errorMessage,
    super.progressDetails,
  });

  /// Creates the initial "starting activation" progress update.
  factory ZhtlcActivationProgress.starting(Asset asset) {
    return ZhtlcActivationProgress._(
      status: 'Starting ZHTLC activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.initialization,
        stepCount: 6,
        additionalInfo: {'protocol': 'ZHTLC', 'asset': asset.id.name},
      ),
    );
  }

  /// Emits progress while validating protocol configuration before task start.
  factory ZhtlcActivationProgress.validation(ZhtlcProtocol protocol) {
    return ZhtlcActivationProgress._(
      status: 'Validating ZHTLC parameters...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.validation,
        stepCount: 6,
        additionalInfo: {
          'electrumServers': protocol.requiredServers.toJsonRequest(),
          'zcashParamsPath': protocol.zcashParamsPath,
        },
      ),
    );
  }

  /// Emits a terminal failure progress snapshot for unexpected exceptions.
  factory ZhtlcActivationProgress.failure(Object error, StackTrace stack) {
    return ZhtlcActivationProgress._(
      status: 'Activation failed',
      errorMessage: error.toString(),
      isComplete: true,
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.error,
        stepCount: 6,
        errorCode: 'ZHTLC_ACTIVATION_ERROR',
        errorDetails: error.toString(),
        stackTrace: stack.toString(),
        additionalInfo: {
          'errorType': error.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  /// Emits a terminal failure snapshot when required Zcash params are missing.
  factory ZhtlcActivationProgress.missingZcashParams() {
    return const ZhtlcActivationProgress._(
      status: 'Zcash params path required',
      errorMessage: 'Zcash params path required',
      isComplete: true,
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.error,
        stepCount: 1,
      ),
    );
  }
}

/// Additional helpers for creating ZHTLC-specific [ActivationProgress] states.
extension ActivationProgressZhtlc on ActivationProgress {
  /// Convenience helper for the missing Zcash params terminal state.
  static ActivationProgress missingZcashParams() {
    return ZhtlcActivationProgress.missingZcashParams();
  }

  /// Convenience helper for wrapping unexpected activation failures.
  static ActivationProgress failure(Object error, StackTrace stack) {
    return ZhtlcActivationProgress.failure(error, stack);
  }
}
