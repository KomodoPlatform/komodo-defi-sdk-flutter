import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Erc20ActivationStrategy extends ProtocolActivationStrategy {
  const Erc20ActivationStrategy(super.client, this.privKeyPolicy);

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
    CoinSubClass.base,
  };

  @override
  bool get supportsBatchActivation => false;

  @override
  bool canHandle(Asset asset) {
    // Use erc20 activation for token assets (not platform assets, not trezor)
    final isTokenAsset = asset.id.parentId != null;
    return isTokenAsset &&
        privKeyPolicy != const PrivateKeyPolicy.trezor() &&
        super.canHandle(asset);
  }

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children?.isNotEmpty == true) {
      throw StateError('Token assets cannot perform batch activation');
    }

    yield ActivationProgress(
      status: 'Activating ${asset.id.name} token...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.initialization,
        stepCount: 2,
        additionalInfo: {
          'assetType': 'token',
          'protocol': asset.protocol.subClass.formatted,
        },
      ),
    );

    try {
      await client.rpc.erc20.enableErc20(
        ticker: asset.id.id,
        activationParams: Erc20ActivationParams.fromJsonConfig(
          asset.protocol.config,
        ),
      );

      yield ActivationProgress.success(
        details: ActivationProgressDetails(
          currentStep: ActivationStep.complete,
          stepCount: 2,
          additionalInfo: {
            'activatedToken': asset.id.name,
            'activationTime': DateTime.now().toIso8601String(),
            'method': 'enableErc20',
          },
        ),
      );
    } catch (e, stack) {
      yield ActivationProgress(
        status: 'Activation failed',
        errorMessage: e.toString(),
        isComplete: true,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.error,
          stepCount: 2,
          errorCode: 'ERC20_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }
}
