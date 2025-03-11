import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Activation strategy for NFT assets using the [EnableNftRequest] RPC method.
class NftActivationStrategy extends ProtocolActivationStrategy {
  /// Activation strategy for NFT assets using the [EnableNftRequest] RPC method
  const NftActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {
    // NFT-related protocols (primarily EVM-based chains that support NFTs)
    CoinSubClass.erc20,
    CoinSubClass.matic,
    CoinSubClass.bep20,
    CoinSubClass.ftm20,
    CoinSubClass.avx20,
  };

  @override
  bool get supportsBatchActivation => true;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    yield ActivationProgress(
      status: 'Activating ${asset.id.name}...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 2,
        additionalInfo: {'protocol': asset.protocol.subClass.formatted},
      ),
    );

    try {
      await client.rpc.nft.enableNft(
        ticker: asset.id.id,
        activationParams: NftActivationParams.fromJson(asset.protocol.config),
      );

      yield ActivationProgress.success(
        details: ActivationProgressDetails(
          currentStep: 'complete',
          stepCount: 2,
          additionalInfo: {
            'activatedChain': asset.id.name,
            'activationType': 'NFT',
            'activationTime': DateTime.now().toIso8601String(),
          },
        ),
      );
    } catch (e, stack) {
      yield ActivationProgress(
        status: 'Activation failed',
        errorMessage: e.toString(),
        isComplete: true,
        progressDetails: ActivationProgressDetails(
          currentStep: 'error',
          stepCount: 2,
          errorCode: 'NFT_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }
}
