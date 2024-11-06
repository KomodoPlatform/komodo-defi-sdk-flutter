import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for activating UTXO-based coins
class UtxoActivationStrategy extends SingleAssetStrategy {
  const UtxoActivationStrategy();

  @override
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset asset, [
    List<Asset>? childAssets,
  ]) async* {
    if (childAssets?.isNotEmpty ?? false) {
      throw StateError('UTXO activation does not support batch operations');
    }

    final protocol = asset.protocol as UtxoProtocol;

    yield ActivationProgress(
      status: 'Starting UTXO activation for ${asset.id.id}...',
    );

    try {
      final taskResponse = await client.rpc.utxo.enableUtxoInit(
        ticker: asset.id.id,
        params: protocol.defaultActivationParams(),
      );

      yield ActivationProgress(
        status: 'Checking activation status...',
      );

      var isComplete = false;
      while (!isComplete) {
        final status =
            await client.rpc.utxo.taskEnableStatus(taskResponse.taskId);

        if (status.isCompleted) {
          if (status.status == 'Ok') {
            yield ActivationProgress.success();
          } else {
            yield ActivationProgress(
              status: 'Activation failed: ${status.details}',
              errorMessage: status.details,
              isComplete: true,
            );
          }
          isComplete = true;
        } else {
          yield ActivationProgress(
            status: status.status,
            progressPercentage: _calculateProgress(status.status),
          );
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      yield ActivationProgress(
        status: 'Activation failed',
        errorMessage: e.toString(),
        isComplete: true,
      );
    }
  }

  double? _calculateProgress(String status) {
    // Implement progress calculation based on status messages
    // Return null if progress cannot be determined
    return null;
  }

  @override
  bool supportsAssetType(Asset asset) => asset.protocol is UtxoProtocol;
}
