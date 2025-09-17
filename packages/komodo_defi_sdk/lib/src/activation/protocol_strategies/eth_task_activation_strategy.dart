import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_sdk/src/transaction_history/strategies/etherscan_transaction_history_strategy.dart'
    show EtherscanProtocolHelper;
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Task-based activation strategy for ETH, specifically required for hardware
/// and external wallet support (e.g. MetaMask, WalletConnect, etc)
class EthTaskActivationStrategy extends ProtocolActivationStrategy {
  /// Creates a new [EthTaskActivationStrategy] with the given client and
  /// private key policy.
  const EthTaskActivationStrategy(super.client, this.privKeyPolicy);
  static final _logger = Logger('EthTaskActivationStrategy');

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

    _logger.fine(
      'Starting activation for asset: ${asset.id.name}, '
      'protocol: ${protocol.subClass.formatted}, privKeyPolicy: $privKeyPolicy',
    );
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
        params: EthWithTokensActivationParams.fromJson(asset.protocol.config)
            .copyWith(
              erc20Tokens:
                  children
                      ?.map((e) => TokensRequest(ticker: e.id.id))
                      .toList() ??
                  [],
              txHistory: const EtherscanProtocolHelper()
                  .shouldEnableTransactionHistory(asset),
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
            _logger.fine(
              'Activation completed successfully for asset: ${asset.id.name}',
            );
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
            _logger.warning(
              'Activation failed for asset: ${asset.id.name}, '
              'status: ${status.status}, details: ${status.details}',
            );
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
          // Only log unexpected/unknown status for debugging
          if (!_knownEthStatuses.contains(status.status)) {
            _logger.fine(
              'Unknown activation status for asset: ${asset.id.name}, '
              'status: ${status.status}',
            );
          }
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
      _logger.severe(
        'Exception during activation for asset: ${asset.id.name}',
        e,
        stack,
      );
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

  static const Set<String> _knownEthStatuses = {
    'ActivatingCoin',
    'RequestingWalletBalance',
    'ActivatingTokens',
    'Finishing',
    'WaitingForTrezorToConnect',
    'FollowHwDeviceInstructions',
  };

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
