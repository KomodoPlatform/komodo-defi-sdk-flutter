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
        currentStep: ActivationStep.initialization,
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
      final params = ZhtlcActivationParams.fromConfigJson(protocol.config)
          .copyWith(
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
          currentStep: ActivationStep.validation,
          stepCount: 6,
          additionalInfo: {
            'electrumServers': protocol.requiredServers.toJsonRequest(),
            'zcashParamsPath': protocol.zcashParamsPath,
          },
        ),
      );

      // Initialize task and watch via TaskShepherd
      final stream = client.rpc.zhtlc
          .enableZhtlcInit(ticker: asset.id.id, params: params)
          .watch<TaskStatusResponse>(
            getTaskStatus: (int taskId) => client.rpc.zhtlc.enableZhtlcStatus(
              taskId,
              forgetIfFinished: false,
            ),
            isTaskComplete: (TaskStatusResponse s) =>
                s.status == 'Ok' || s.status == 'Error',
            cancelTask: (int taskId) async {
              await client.rpc.zhtlc.enableZhtlcCancel(taskId: taskId);
            },
            pollingInterval: const Duration(milliseconds: 500),
          );

      var buildingWalletDb = false;
      var scanningBlocks = false;
      var currentBlock = 0;
      TaskStatusResponse? lastStatus;

      await for (final status in stream) {
        lastStatus = status;
        switch (status.details) {
          case 'BuildingWalletDb':
            if (!buildingWalletDb) {
              buildingWalletDb = true;
              yield const ActivationProgress(
                status: 'Building wallet database...',
                progressPercentage: 40,
                progressDetails: ActivationProgressDetails(
                  currentStep: ActivationStep.database,
                  stepCount: 6,
                  additionalInfo: {'dbStatus': 'building'},
                ),
              );
            }
            break;

          case 'WaitingLightwalletd':
            yield const ActivationProgress(
              status: 'Connecting to Lightwalletd server...',
              progressPercentage: 60,
              progressDetails: ActivationProgressDetails(
                currentStep: ActivationStep.connection,
                stepCount: 6,
                additionalInfo: {'connectionStatus': 'connecting'},
              ),
            );
            break;

          case 'ScanningBlocks':
            if (!scanningBlocks) {
              scanningBlocks = true;
              currentBlock = await _getCurrentBlock(asset.id.id);
            }
            yield ActivationProgress(
              status: 'Scanning blockchain...',
              progressPercentage: 80,
              progressDetails: ActivationProgressDetails(
                currentStep: ActivationStep.scanning,
                stepCount: 6,
                additionalInfo: {
                  'currentBlock': currentBlock,
                  'scanStatus': 'inProgress',
                },
              ),
            );
            break;

          case 'Error':
            yield ActivationProgress(
              status: 'Activation failed',
              errorMessage: status.details,
              isComplete: true,
              progressDetails: ActivationProgressDetails(
                currentStep: ActivationStep.error,
                stepCount: 6,
                errorCode: 'ZHTLC_ACTIVATION_ERROR',
                errorDetails: status.details,
              ),
            );
            return;

          // For any other progress states, fall through to default handler

          default:
            yield ActivationProgress(
              status: status.details,
              progressDetails: ActivationProgressDetails(
                currentStep: ActivationStep.processing,
                stepCount: 6,
                additionalInfo: {
                  'status': status.details,
                  'lastKnownBlock': currentBlock,
                },
              ),
            );
            break;
        }

        if (status.status == 'Ok') {
          yield ActivationProgress.success(
            details: ActivationProgressDetails(
              currentStep: ActivationStep.complete,
              stepCount: 6,
              additionalInfo: {
                'activatedChain': asset.id.name,
                'activationTime': DateTime.now().toIso8601String(),
                'finalBlock': currentBlock,
              },
            ),
          );
        }
      }

      // If the task ended with an error status but without emitting a specific
      // error detail case, emit a failure result now.
      if (lastStatus != null && lastStatus!.status == 'Error') {
        yield ActivationProgress(
          status: 'Activation failed',
          errorMessage: lastStatus!.details,
          isComplete: true,
          progressDetails: ActivationProgressDetails(
            currentStep: ActivationStep.error,
            stepCount: 6,
            errorCode: 'ZHTLC_ACTIVATION_ERROR',
            errorDetails: lastStatus!.details,
          ),
        );
      }
    } catch (e, stack) {
      yield ActivationProgress(
        status: 'Activation failed',
        errorMessage: e.toString(),
        isComplete: true,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.error,
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

  Future<int> _getCurrentBlock(String coin) async {
    final resp = await client.rpc.transactionHistory.zCoinTxHistory(
      coin: coin,
      limit: 1,
    );
    return resp.currentBlock;
  }
}
