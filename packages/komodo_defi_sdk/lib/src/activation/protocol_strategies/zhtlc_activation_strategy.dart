// TODO: Refactor so that the start sync mode can be passed. For now, it is
// hard-coded to sync from the time of activation.

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ZhtlcActivationStrategy extends ProtocolActivationStrategy {
  const ZhtlcActivationStrategy(super.client, this.privKeyPolicy);

  final PrivateKeyPolicy privKeyPolicy;

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.zhtlc};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children?.isNotEmpty ?? false) {
      throw UnsupportedError(
        'ZHTLC protocol does not support batch activation',
      );
    }

    yield ActivationProgress(
      status: 'Starting ZHTLC activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 6,
        additionalInfo: {
          'protocol': 'ZHTLC',
          'asset': asset.id.name,
          'scanBlocksPerIteration': 200,
        },
      ),
    );

    try {
      final protocol = asset.protocol as ZhtlcProtocol;
      final params = ActivationParams.fromConfigJson(
        protocol.config,
      ).genericCopyWith(
        scanBlocksPerIteration: 200,
        scanIntervalMs: 200,
        zcashParamsPath: protocol.zcashParamsPath,
        privKeyPolicy: privKeyPolicy,
      );

      // Setup parameters

      yield ActivationProgress(
        status: 'Validating ZHTLC parameters...',
        progressPercentage: 20,
        progressDetails: ActivationProgressDetails(
          currentStep: 'validation',
          stepCount: 6,
          additionalInfo: {
            'electrumServers': protocol.requiredServers.toJsonRequest(),
            'zcashParamsPath': protocol.zcashParamsPath,
          },
        ),
      );

      // Initialize task
      final taskResponse = await client.rpc.task.execute(
        TaskEnableZhtlcInit(params: params, ticker: asset.id.id),
      );

      var isComplete = false;
      var buildingWalletDb = false;
      var scanningBlocks = false;
      var currentBlock = 0;

      while (!isComplete) {
        final status = await client.rpc.task.execute(
          TaskEnableZhtlcStatus(taskId: taskResponse.taskId),
        );

        switch (status.details) {
          case 'BuildingWalletDb':
            if (!buildingWalletDb) {
              buildingWalletDb = true;
              yield const ActivationProgress(
                status: 'Building wallet database...',
                progressPercentage: 40,
                progressDetails: ActivationProgressDetails(
                  currentStep: 'database',
                  stepCount: 6,
                  additionalInfo: {'dbStatus': 'building'},
                ),
              );
            }

          case 'WaitingLightwalletd':
            yield const ActivationProgress(
              status: 'Connecting to Lightwalletd server...',
              progressPercentage: 60,
              progressDetails: ActivationProgressDetails(
                currentStep: 'connection',
                stepCount: 6,
                additionalInfo: {'connectionStatus': 'connecting'},
              ),
            );

          case 'ScanningBlocks':
            if (!scanningBlocks) {
              scanningBlocks = true;
              currentBlock = await _getCurrentBlock();
            }

            yield ActivationProgress(
              status: 'Scanning blockchain...',
              progressPercentage: 80,
              progressDetails: ActivationProgressDetails(
                currentStep: 'scanning',
                stepCount: 6,
                additionalInfo: {
                  'currentBlock': currentBlock,
                  'scanStatus': 'inProgress',
                },
              ),
            );

          case 'Error':
            yield ActivationProgress(
              status: 'Activation failed',
              errorMessage: status.details,
              isComplete: true,
              progressDetails: ActivationProgressDetails(
                currentStep: 'error',
                stepCount: 6,
                errorCode: 'ZHTLC_ACTIVATION_ERROR',
                errorDetails: status.details,
              ),
            );
            isComplete = true;

          case 'Success':
            yield ActivationProgress.success(
              details: ActivationProgressDetails(
                currentStep: 'complete',
                stepCount: 6,
                additionalInfo: {
                  'activatedChain': asset.id.name,
                  'activationTime': DateTime.now().toIso8601String(),
                  'finalBlock': currentBlock,
                },
              ),
            );
            isComplete = true;

          default:
            yield ActivationProgress(
              status: status.details,
              progressDetails: ActivationProgressDetails(
                currentStep: 'processing',
                stepCount: 6,
                additionalInfo: {
                  'status': status.details,
                  'lastKnownBlock': currentBlock,
                },
              ),
            );
        }

        if (!isComplete) {
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
          stepCount: 6,
          errorCode: 'ZHTLC_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
          additionalInfo: {
            'errorType': e.runtimeType.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );
    }
  }

  Future<int> _getCurrentBlock() async {
    throw UnimplementedError();
  }
}
