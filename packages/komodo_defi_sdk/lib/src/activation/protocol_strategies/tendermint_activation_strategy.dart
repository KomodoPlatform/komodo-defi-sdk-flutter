import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class TendermintActivationStrategy extends ProtocolActivationStrategy {
  const TendermintActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {
        CoinSubClass.tendermint,
        CoinSubClass.tendermintToken,
      };

  @override
  bool get supportsBatchActivation => true;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    final isPlatformAsset = asset.id.parentId == null;
    if (!isPlatformAsset && children?.isNotEmpty == true) {
      throw StateError('Child assets cannot perform batch activation');
    }

    yield ActivationProgress(
      status: 'Starting Tendermint activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.initialization,
        stepCount: 4,
        additionalInfo: {
          'assetType': isPlatformAsset ? 'platform' : 'token',
          'protocol': asset.protocol.subClass.formatted,
        },
      ),
    );

    try {
      final protocol = asset.protocol as TendermintProtocol;

      yield ActivationProgress(
        status: 'Validating RPC endpoints...',
        progressPercentage: 25,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.validation,
          stepCount: 4,
          additionalInfo: {
            'rpcEndpoints': protocol.rpcUrlsMap.length,
            if (protocol.chainId != null) 'chainId': protocol.chainId,
          },
        ),
      );

      if (isPlatformAsset) {
        yield const ActivationProgress(
          status: 'Activating platform chain...',
          progressPercentage: 50,
          progressDetails: ActivationProgressDetails(
            currentStep: ActivationStep.platformActivation,
            stepCount: 4,
          ),
        );

        await client.rpc.tendermint.enableTendermintWithAssets(
          ticker: asset.id.id,
          params: TendermintActivationParams.fromJson(protocol.config).copyWith(
            tokensParams: children
                    ?.map(
                      (child) => TokensRequest(ticker: child.id.id),
                    )
                    .toList() ??
                [],
            getBalances: true,
            txHistory: true,
          ),
        );
      } else {
        yield const ActivationProgress(
          status: 'Activating Tendermint token...',
          progressPercentage: 75,
          progressDetails: ActivationProgressDetails(
            currentStep: ActivationStep.tokenActivation,
            stepCount: 4,
          ),
        );

        await client.rpc.tendermint.enableTendermintToken(
          ticker: asset.id.id,
          params: TendermintTokenActivationParams(),
        );
      }

      yield ActivationProgress.success(
        details: ActivationProgressDetails(
          currentStep: ActivationStep.complete,
          stepCount: 4,
          additionalInfo: {
            'activatedChain': asset.id.name,
            'activationTime': DateTime.now().toIso8601String(),
            if (protocol.chainId != null) 'chainId': protocol.chainId,
            'accountPrefix': protocol.accountPrefix,
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
          stepCount: 4,
          errorCode: 'TENDERMINT_ACTIVATION_ERROR',
          errorDetails: e.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }
}
