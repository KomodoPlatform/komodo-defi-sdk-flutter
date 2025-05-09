import 'package:collection/collection.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Extension to add progress tracking to ActivationManager
extension ProgressTrackingActivationManager on ActivationManager {
  Stream<BatchActivationProgress> activateAssetsWithProgress(
    List<Asset> assets,
  ) async* {
    final tracker = BatchActivationProgress(assets);

    await for (final progress in activateAssets(assets)) {
      final asset = _findAssetForProgress(progress, assets);
      if (asset != null) {
        tracker.updateProgress(asset, progress);
        yield tracker;
      }
    }
  }

  Asset? _findAssetForProgress(
    ActivationProgress progress,
    List<Asset> assets,
  ) {
    final details = progress.progressDetails?.additionalInfo;
    if (details == null) return null;

    final assetName = details['activatedChain'] as String?;
    if (assetName == null) return null;

    return assets.firstWhereOrNull((a) => a.id.name == assetName);
  }
}
