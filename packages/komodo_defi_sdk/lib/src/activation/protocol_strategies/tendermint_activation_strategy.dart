import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Activation strategy for Tendermint platform coins with batch token support.
/// Handles platform chains (ATOM, IRIS, OSMO) and can activate multiple tokens together.
class TendermintWithTokensActivationStrategy
    extends ProtocolActivationStrategy {
  /// Creates a new [TendermintWithTokensActivationStrategy] with the given client and
  /// private key policy.
  const TendermintWithTokensActivationStrategy(
    super.client,
    this.privKeyPolicy,
  );

  /// The private key policy to use for activation.
  final PrivateKeyPolicy privKeyPolicy;

  @override
  Set<CoinSubClass> get supportedProtocols => {
    CoinSubClass.tendermint,
    CoinSubClass.tendermintToken,
  };

  @override
  bool get supportsBatchActivation => true;

  @override
  bool canHandle(Asset asset) {
    // Use tendermint-with-tokens for platform assets (not trezor)
    final isPlatformAsset = asset.id.parentId == null;
    return isPlatformAsset &&
        privKeyPolicy != const PrivateKeyPolicy.trezor() &&
        super.canHandle(asset);
  }

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    final protocol = asset.protocol as TendermintProtocol;

    if (children?.isNotEmpty == true) {
      yield ActivationProgress(
        status:
            'Activating ${asset.id.name} with ${children!.length} tokens...',
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.initialization,
          stepCount: 5,
          additionalInfo: {
            'assetType': 'platform',
            'protocol': asset.protocol.subClass.formatted,
            'tokenCount': children.length,
            'chainId': protocol.chainId,
            'accountPrefix': protocol.accountPrefix,
          },
        ),
      );
    } else {
      yield ActivationProgress(
        status: 'Activating ${asset.id.name}...',
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.initialization,
          stepCount: 5,
          additionalInfo: {
            'assetType': 'platform',
            'protocol': asset.protocol.subClass.formatted,
            'chainId': protocol.chainId,
            'accountPrefix': protocol.accountPrefix,
          },
        ),
      );
    }

    try {
      yield ActivationProgress(
        status: 'Validating RPC endpoints...',
        progressPercentage: 20,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.validation,
          stepCount: 5,
          additionalInfo: {
            'rpcEndpoints': protocol.rpcUrlsMap.length,
            if (protocol.chainId != null) 'chainId': protocol.chainId,
          },
        ),
      );

      yield const ActivationProgress(
        status: 'Initializing task-based activation...',
        progressPercentage: 40,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.initialization,
          stepCount: 5,
        ),
      );

      final taskResponse = await client.rpc.tendermint.taskEnableTendermintInit(
        ticker: asset.id.id,
        tokensParams:
            children
                ?.map((child) => TendermintTokenParams(ticker: child.id.id))
                .toList() ??
            [],
        nodes: protocol.rpcUrlsMap.map(TendermintNode.fromJson).toList(),
      );

      yield ActivationProgress(
        status: 'Monitoring activation progress...',
        progressPercentage: 60,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.processing,
          stepCount: 5,
          additionalInfo: {
            'taskId': taskResponse.taskId,
            'method': 'task::enable_tendermint::init',
          },
        ),
      );

      var isComplete = false;
      while (!isComplete) {
        final status = await client.rpc.tendermint.taskEnableTendermintStatus(
          taskId: taskResponse.taskId,
        );

        status.details.throwIfError();

        if (status.status == SyncStatusEnum.success) {
          yield ActivationProgress.success(
            details: ActivationProgressDetails(
              currentStep: ActivationStep.complete,
              stepCount: 5,
              additionalInfo: {
                'activatedChain': asset.id.name,
                'activationTime': DateTime.now().toIso8601String(),
                'address': status.details.data?.address,
                'currentBlock': status.details.data?.currentBlock,
                'childCount': children?.length ?? 0,
                'method': 'task::enable_tendermint',
              },
            ),
          );
          isComplete = true;
        } else if (status.status == SyncStatusEnum.error) {
          yield ActivationProgress(
            status: 'Activation failed: ${status.details.error}',
            errorMessage: status.details.error ?? 'Unknown error',
            isComplete: true,
            progressDetails: ActivationProgressDetails(
              currentStep: ActivationStep.error,
              stepCount: 5,
              errorCode: 'TENDERMINT_TASK_ACTIVATION_ERROR',
              errorDetails: status.details.error,
            ),
          );
          isComplete = true;
        } else {
          final progress = _parseTendermintStatus(status.status);
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
          currentStep: ActivationStep.error,
          stepCount: 5,
          errorCode: 'TENDERMINT_WITH_TOKENS_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }

  ({
    String status,
    double percentage,
    ActivationStep step,
    Map<String, dynamic> info,
  })
  _parseTendermintStatus(SyncStatusEnum status) {
    switch (status) {
      case SyncStatusEnum.notStarted:
        return (
          status: 'Initializing Tendermint activation...',
          percentage: 50,
          step: ActivationStep.initialization,
          info: {'stage': 'init', 'type': 'tendermint'},
        );
      case SyncStatusEnum.inProgress:
        return (
          status: 'Synchronizing with Tendermint network...',
          percentage: 75,
          step: ActivationStep.blockchainSync,
          info: {'stage': 'sync', 'type': 'tendermint'},
        );
      // Success and error cases are handled in the main loop
      default:
        return (
          status: 'Processing Tendermint activation...',
          percentage: 60,
          step: ActivationStep.processing,
          info: {'status': status.toString(), 'type': 'tendermint'},
        );
    }
  }
}
