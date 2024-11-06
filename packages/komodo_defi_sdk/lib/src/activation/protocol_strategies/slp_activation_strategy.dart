import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for activating single SLP tokens
class SlpSingleActivationStrategy extends SingleAssetStrategy {
  const SlpSingleActivationStrategy();

  @override
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (children != null) {
      throw StateError(
        'Single SLP activation does not support batch operations',
      );
    }

    yield ActivationProgress(
      status: 'Activating SLP token ${asset.id.id}...',
    );

    try {
      await client.rpc.slp.enableSlpToken(
        ticker: asset.id.id,
        params: SlpActivationParams(),
      );
      yield ActivationProgress.success();
    } catch (e) {
      yield ActivationProgress(
        status: 'Failed to activate SLP token',
        errorMessage: e.toString(),
        isComplete: true,
      );
    }
  }

  @override
  bool supportsAssetType(Asset asset) => asset.protocol is SlpProtocol;

  List<Map<String, dynamic>> _getElectrumServers(Asset asset) {
    final protocol = asset.protocol as SlpProtocol;
    return protocol.requiredServers
        .map((server) => {'url': server, 'protocol': 'TCP'})
        .toList();
  }

  List<String> _getBchdUrls(Asset asset) {
    final protocol = asset.protocol as SlpProtocol;
    return protocol.bchdUrls;
  }
}

/// Strategy for activating BCH with multiple SLP tokens
class SlpBatchActivationStrategy extends BatchActivationStrategy {
  const SlpBatchActivationStrategy();

  @override
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset parent, [
    List<Asset>? children = const [],
  ]) async* {
    final protocol = parent.protocol as SlpProtocol;

    yield ActivationProgress(
      status:
          'Activating ${parent.id.id} with ${children?.length ?? 0} SLP tokens...',
    );

    try {
      await client.rpc.slp.enableBchWithTokens(
        ticker: parent.id.id,
        params: BchActivationParams(
          electrumServers: _getElectrumServers(parent),
          bchdUrls: protocol.bchdUrls,
        ),
        slpTokensRequests: children
                ?.map(
                  (child) => TokensRequest(
                    ticker: child.id.id,
                  ),
                )
                .toList() ??
            [],
      );
      yield ActivationProgress.success();
    } catch (e) {
      yield ActivationProgress(
        status: 'Batch activation failed',
        errorMessage: e.toString(),
        isComplete: true,
      );
    }
  }

  @override
  bool supportsAssetType(Asset asset) =>
      asset.protocol is SlpProtocol && !asset.id.isChildAsset;

  List<Map<String, dynamic>> _getElectrumServers(Asset asset) {
    final protocol = asset.protocol as SlpProtocol;
    return protocol.requiredServers
        .map((server) => {'url': server, 'protocol': 'TCP'})
        .toList();
  }
}
