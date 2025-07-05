import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class EthTaskActivationStrategy extends ProtocolActivationStrategy {
  const EthTaskActivationStrategy(super.client, this.privKeyPolicy);

  /// The private key management policy to use for this strategy.
  /// Used for external wallet support.
  final PrivateKeyPolicy privKeyPolicy;

  @override
  Set<CoinSubClass> get supportedProtocols => {
    CoinSubClass.erc20,
    CoinSubClass.bep20,
    CoinSubClass.ftm20,
    CoinSubClass.matic,
    CoinSubClass.avx20,
    CoinSubClass.hrc20,
    CoinSubClass.moonbeam,
    CoinSubClass.moonriver,
    CoinSubClass.ethereumClassic,
    CoinSubClass.ubiq,
    CoinSubClass.krc20,
    CoinSubClass.ewt,
    CoinSubClass.hecoChain,
    CoinSubClass.rskSmartBitcoin,
    CoinSubClass.arbitrum,
  };

  @override
  bool get supportsBatchActivation => true;

  @override
  bool canHandle(Asset asset) {
    // Use task-based activation for Trezor private key policy
    return privKeyPolicy == const PrivateKeyPolicy.trezor() &&
        super.canHandle(asset);
  }

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    final protocol = asset.protocol as Erc20Protocol;

    yield ActivationProgress(
      status: 'Starting ${asset.id.name} activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 5,
        additionalInfo: {
          'chainType': protocol.subClass.formatted,
          'contractAddress': protocol.contractAddress,
          'nodes': protocol.nodes.length,
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

      final taskResponse = await client.rpc.erc20.enableEthInit(
        ticker: asset.id.id,
        params: EthWithTokensActivationParams.fromJson(
          asset.protocol.config,
        ).copyWith(
          erc20Tokens:
              children?.map((e) => TokensRequest(ticker: e.id.id)).toList() ??
              [],
          txHistory: true,
          privKeyPolicy: privKeyPolicy,
        ),
      );

      yield ActivationProgress(
        status: 'Establishing network connections...',
        progressPercentage: 40,
        progressDetails: ActivationProgressDetails(
          currentStep: 'connection',
          stepCount: 5,
          additionalInfo: {
            'nodes': protocol.requiredServers.toJsonRequest(),
            'protocolType': protocol.subClass.formatted,
            'tokenCount': children?.length ?? 0,
          },
        ),
      );

      var isComplete = false;
      while (!isComplete) {
        final status = await client.rpc.erc20.taskEthStatus(
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
                  'childCount': children?.length ?? 0,
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
                errorCode: 'ETH_TASK_ACTIVATION_ERROR',
                errorDetails: status.details,
              ),
            );
          }
          isComplete = true;
        } else {
          final progress = _parseEthStatus(status.status);
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
          errorCode: 'ETH_TASK_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }

  ({String status, double percentage, String step, Map<String, dynamic> info})
  _parseEthStatus(String status) {
    switch (status) {
      case 'ActivatingCoin':
        return (
          status: 'Activating platform coin...',
          percentage: 60,
          step: 'coin_activation',
          info: {'activationType': 'platform'},
        );
      case 'RequestingWalletBalance':
        return (
          status: 'Requesting wallet balance...',
          percentage: 70,
          step: 'balance_request',
          info: {'dataType': 'balance'},
        );
      case 'ActivatingTokens':
        return (
          status: 'Activating ERC20 tokens...',
          percentage: 80,
          step: 'token_activation',
          info: {'activationType': 'tokens'},
        );
      case 'Finishing':
        return (
          status: 'Finalizing activation...',
          percentage: 90,
          step: 'finalization',
          info: {'stage': 'completion'},
        );
      case 'WaitingForTrezorToConnect':
        return (
          status: 'Waiting for Trezor device...',
          percentage: 50,
          step: 'trezor_connection',
          info: {'deviceType': 'Trezor', 'action': 'connect'},
        );
      case 'FollowHwDeviceInstructions':
        return (
          status: 'Follow instructions on hardware device',
          percentage: 55,
          step: 'hardware_interaction',
          info: {'deviceType': 'Hardware', 'action': 'follow_instructions'},
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
