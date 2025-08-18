import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class QtumActivationStrategy extends ProtocolActivationStrategy {
  const QtumActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.qrc20};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children?.isNotEmpty ?? false) {
      throw UnsupportedError('QTUM protocol does not support batch activation');
    }

    yield ActivationProgress(
      status: 'Starting QTUM activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.initialization,
        stepCount: 4,
        additionalInfo: {
          'protocol': 'QTUM',
          'pubtype': (asset.protocol as QtumProtocol).pubtype,
        },
      ),
    );

    try {
      final taskResponse = await client.rpc.qtum.enableQtumInit(
        ticker: asset.id.id,
        params: asset.protocol.defaultActivationParams(),
      );

      var isComplete = false;
      while (!isComplete) {
        final status = await client.rpc.qtum.enableQtumStatus(
          taskResponse.taskId,
        );

        if (status.isCompleted) {
          if (status.status == 'Ok') {
            yield ActivationProgress.success(
              details: ActivationProgressDetails(
                currentStep: ActivationStep.complete,
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
                currentStep: ActivationStep.error,
                stepCount: 4,
                errorCode: 'QTUM_ACTIVATION_ERROR',
                errorDetails: status.details,
              ),
            );
          }
          isComplete = true;
        } else {
          final progress = _parseQtumStatus(status.status);
          yield ActivationProgress(
            status: progress.status,
            progressPercentage: progress.percentage,
            progressDetails: ActivationProgressDetails(
              currentStep: progress.step,
              stepCount: 4,
              additionalInfo: progress.info,
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
          currentStep: ActivationStep.error,
          stepCount: 4,
          errorCode: 'QTUM_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }

  ({String status, double percentage, ActivationStep step, Map<String, dynamic> info})
      _parseQtumStatus(String status) {
    switch (status) {
      case 'ConnectingNodes':
        return (
          status: 'Connecting to QTUM nodes...',
          percentage: 25,
          step: ActivationStep.connection,
          info: {'status': status},
        );
      case 'ValidatingConfig':
        return (
          status: 'Validating configuration...',
          percentage: 50,
          step: ActivationStep.validation,
          info: {'status': status},
        );
      case 'LoadingContracts':
        return (
          status: 'Loading smart contracts...',
          percentage: 75,
          step: ActivationStep.contracts,
          info: {'status': status},
        );
      default:
        return (
          status: 'Processing activation...',
          percentage: 85,
          step: ActivationStep.processing,
          info: {'status': status},
        );
    }
  }
}
