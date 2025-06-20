import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SiaActivationStrategy extends ProtocolActivationStrategy {
  const SiaActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.sia};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children?.isNotEmpty ?? false) {
      throw UnsupportedError('SIA protocol does not support batch activation');
    }

    yield ActivationProgress(
      status: 'Starting SIA activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 4,
        additionalInfo: {'protocol': 'SIA', 'asset': asset.id.name},
      ),
    );

    try {
      final protocol = asset.protocol as SiaProtocol;
      final params = SiaActivationParams(
        serverUrl: protocol.serverUrl ?? 'https://api.siascan.com/wallet/api',
        txHistory: true,
        requiredConfirmations: protocol.requiredConfirmations,
      );

      yield const ActivationProgress(
        status: 'Connecting to Siascan API...',
        progressPercentage: 25,
        progressDetails: ActivationProgressDetails(
          currentStep: 'connection',
          stepCount: 4,
        ),
      );

      final taskResponse = await client.rpc.sia.enableSiaInit(
        ticker: asset.id.id,
        params: params,
      );

      var isComplete = false;
      while (!isComplete) {
        final status = await client.rpc.sia.enableSiaStatus(
          taskResponse.taskId,
        );

        if (status.isCompleted) {
          if (status.status == 'Ok') {
            yield ActivationProgress.success(
              details: ActivationProgressDetails(
                currentStep: 'complete',
                stepCount: 4,
                additionalInfo: {
                  'activatedChain': asset.id.name,
                  'activationTime': DateTime.now().toIso8601String(),
                },
              ),
            );
          } else {
            yield ActivationProgress(
              status: 'Activation failed: ${status.details}',
              errorMessage: status.details,
              isComplete: true,
              progressDetails: ActivationProgressDetails(
                currentStep: 'error',
                stepCount: 4,
                errorCode: 'SIA_ACTIVATION_ERROR',
                errorDetails: status.details,
              ),
            );
          }
          isComplete = true;
        } else {
          yield ActivationProgress(
            status: 'Processing activation...',
            progressPercentage: 50,
            progressDetails: ActivationProgressDetails(
              currentStep: 'processing',
              stepCount: 4,
              additionalInfo: {'status': status.status},
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e, stack) {
      yield ActivationProgress(
        status: 'Activation failed',
        errorMessage: e.toString(),
        isComplete: true,
        progressDetails: ActivationProgressDetails(
          currentStep: 'error',
          stepCount: 4,
          errorCode: 'SIA_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }
}
