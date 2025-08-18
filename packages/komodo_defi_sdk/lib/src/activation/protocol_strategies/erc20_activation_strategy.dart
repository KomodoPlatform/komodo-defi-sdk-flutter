import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Erc20ActivationStrategy extends ProtocolActivationStrategy {
  const Erc20ActivationStrategy(super.client);

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
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    final isPlatformAsset = asset.id.parentId == null;
    if (!isPlatformAsset && children?.isNotEmpty == true) {
      throw StateError('Child assets cannot perform batch activation');
    }

    yield ActivationProgress(
      status: 'Activating ${asset.id.name}...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.initialization,
        stepCount: 2,
        additionalInfo: {
          'assetType': isPlatformAsset ? 'platform' : 'token',
          'protocol': asset.protocol.subClass.formatted,
        },
      ),
    );

    try {
      if (isPlatformAsset) {
        await client.rpc.erc20.enableEthWithTokens(
          ticker: asset.id.id,
          params: EthWithTokensActivationParams.fromJson(asset.protocol.config)
              .copyWith(
            erc20Tokens:
                children?.map((e) => TokensRequest(ticker: e.id.id)).toList() ??
                    [],
            txHistory: true,
          ),
        );
      } else {
        await client.rpc.erc20.enableErc20(
          ticker: asset.id.id,
          activationParams: Erc20ActivationParams.fromJsonConfig(
            asset.protocol.config,
          ),
        );
      }

      yield ActivationProgress.success(
        details: ActivationProgressDetails(
          currentStep: ActivationStep.complete,
          stepCount: 2,
          additionalInfo: {
            'activatedChain': asset.id.name,
            'activationTime': DateTime.now().toIso8601String(),
            'childCount': children?.length ?? 0,
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