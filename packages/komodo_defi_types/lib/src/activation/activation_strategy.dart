import 'dart:async';

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base interface for asset activation strategies
abstract class ActivationStrategy {
  const ActivationStrategy();

  /// Perform the activation and stream progress updates
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset asset, [
    List<Asset>? childAssets,
  ]);

  /// Check if asset type is supported by this strategy
  bool supportsAssetType(Asset asset);

  /// Whether strategy supports batch activation with children
  bool get supportsBatchActivation;
}

/// Base class for batch-capable strategies
abstract class BatchActivationStrategy extends ActivationStrategy {
  const BatchActivationStrategy();

  @override
  bool get supportsBatchActivation => true;
}

/// Base class for single-asset strategies
abstract class SingleAssetStrategy extends ActivationStrategy {
  const SingleAssetStrategy();

  @override
  bool get supportsBatchActivation => false;
}

class PlaceholderStrategy extends ActivationStrategy {
  const PlaceholderStrategy();

  @override
  Stream<ActivationProgress> activate(
    ApiClient client,
    Asset asset, [
    List<Asset>? childAssets,
  ]) async* {
    yield ActivationProgress(
      status: 'Placeholder strategy for ${asset.id.id}',
      isComplete: true,
    );
  }

  @override
  bool supportsAssetType(Asset asset) => true;

  @override
  bool get supportsBatchActivation => true;
}
