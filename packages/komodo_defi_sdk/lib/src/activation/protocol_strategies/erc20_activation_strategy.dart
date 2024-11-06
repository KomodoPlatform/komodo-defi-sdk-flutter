// import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
// import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for activating single ERC20 tokens
class Erc20SingleActivationStrategy extends SingleAssetStrategy {
  const Erc20SingleActivationStrategy();

  @override
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children != null) {
      throw StateError('Single activation strategy does not support children');
    }

    final isPlatformAsset = asset.id.parentId == null;

    if (isPlatformAsset) {
      yield* const Erc20BatchActivationStrategy().activate(client, asset);
      return;
    }

    final protocol = asset.protocol as Erc20Protocol;

    yield ActivationProgress(
      status: 'Activating ERC20 token ${asset.id.id}...',
    );

    try {
      await client.rpc.erc20.enableErc20(
        ticker: asset.id.id,
        nodes: protocol.nodes,
        swapContractAddress: protocol.swapContractAddress,
        fallbackSwapContract: protocol.fallbackSwapContract,
      );

      yield ActivationProgress.success();
    } catch (e) {
      yield ActivationProgress(
        status: 'Failed to activate token: $e',
        isComplete: true,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  bool supportsAssetType(Asset asset) => asset.protocol is Erc20Protocol;
}

/// Strategy for activating ETH with multiple ERC20 tokens
class Erc20BatchActivationStrategy extends BatchActivationStrategy {
  const Erc20BatchActivationStrategy();

  @override
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset parent, [
    List<Asset>? children = const [],
  ]) async* {
    final protocol = parent.protocol as Erc20Protocol;

    yield ActivationProgress(
      status:
          'Activating ${parent.id.id} with ${children?.length ?? 0} tokens...',
    );

    try {
      await client.rpc.erc20.enableEthWithTokens(
        ticker: parent.id.id,
        params: protocol.defaultActivationParams(children)
            as EthWithTokensActivationParams,
      );

      yield ActivationProgress.success();
    } catch (e) {
      yield ActivationProgress(
        status: 'Batch activation failed: $e',
        isComplete: true,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  bool supportsAssetType(Asset asset) =>
      asset.protocol is Erc20Protocol && !asset.id.isChildAsset;
}

/// Example concrete implementation
