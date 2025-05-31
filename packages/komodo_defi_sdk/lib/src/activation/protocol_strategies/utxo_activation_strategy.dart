import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class UtxoActivationStrategy extends ProtocolActivationStrategy {
  const UtxoActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {
    CoinSubClass.utxo,
    CoinSubClass.smartChain,
    // CoinSubClass.smartBch,
  };

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children?.isNotEmpty == true) {
      throw UnsupportedError('UTXO protocol does not support batch activation');
    }

    final protocol = asset.protocol as UtxoProtocol;

    yield ActivationProgress(
      status: 'Starting ${asset.id.name} activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 5,
        additionalInfo: {
          'chainType': protocol.subClass.formatted,
          'mode': protocol.defaultActivationParams().mode?.rpc,
          'txVersion': protocol.txVersion,
          'pubtype': protocol.pubtype,
        },
      ),
    );

    try {
      yield const ActivationProgress(
        status: 'Validating protocol configuration...',
        progressPercentage: 20,
        progressDetails: ActivationProgressDetails(
          currentStep: 'validation',
          stepCount: 5,
        ),
      );

      final taskResponse = await client.rpc.utxo.enableUtxoInit(
        ticker: asset.id.id,
        params: protocol.defaultActivationParams(),
      );

      yield ActivationProgress(
        status: 'Establishing network connections...',
        progressPercentage: 40,
        progressDetails: ActivationProgressDetails(
          currentStep: 'connection',
          stepCount: 5,
          additionalInfo: {
            'electrumServers': protocol.requiredServers.toJsonRequest(),
            'protocolType': protocol.subClass.formatted,
          },
        ),
      );

      var isComplete = false;
      while (!isComplete) {
        final status = await client.rpc.utxo.taskEnableStatus(
          taskResponse.taskId,
        );

        if (status.isCompleted) {
          if (status.status == 'Ok') {
            yield ActivationProgress.success(
              details: ActivationProgressDetails(
                currentStep: 'complete',
                stepCount: 5,
                additionalInfo: {
                  'activatedChain': asset.id.name,
                  'activationTime': DateTime.now().toIso8601String(),
                  'txFee': protocol.txFee,
                  'overwintered': protocol.overwintered,
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
                stepCount: 5,
                errorCode: 'UTXO_ACTIVATION_ERROR',
                errorDetails: status.details,
              ),
            );
          }
          isComplete = true;
        } else {
          final progress = _parseUtxoStatus(status.status);
          yield ActivationProgress(
            status: progress.status,
            progressPercentage: progress.percentage,
            progressDetails: ActivationProgressDetails(
              currentStep: progress.step,
              stepCount: 5,
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
          currentStep: 'error',
          stepCount: 5,
          errorCode: 'UTXO_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }

  ({String status, double percentage, String step, Map<String, dynamic> info})
  _parseUtxoStatus(String status) {
    switch (status) {
      case 'ConnectingElectrum':
        return (
          status: 'Connecting to Electrum servers...',
          percentage: 60,
          step: 'electrum_connection',
          info: {'connectionType': 'Electrum'},
        );
      case 'LoadingBlockchain':
        return (
          status: 'Loading blockchain data...',
          percentage: 80,
          step: 'blockchain_sync',
          info: {'dataType': 'blockchain'},
        );
      case 'ScanningTransactions':
        return (
          status: 'Scanning transaction history...',
          percentage: 90,
          step: 'tx_scan',
          info: {'dataType': 'transactions'},
        );
      default:
        return (
          status: 'Processing activation...',
          percentage: 95,
          step: 'processing',
          info: {'status': status},
        );
    }
  }
}
