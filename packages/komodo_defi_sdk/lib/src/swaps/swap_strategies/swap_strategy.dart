import 'dart:async';

import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base class for swap execution strategies
abstract class SwapStrategy {
  /// Creates a new swap strategy
  const SwapStrategy();

  /// Executes the swap using this strategy
  Stream<SwapProgress> execute(
    SwapParameters parameters,
    ApiClient client,
    IAssetProvider assetProvider,
    ActivationManager activationManager,
    Map<String, StreamController<SwapProgress>> activeSwaps,
  );

  /// Returns a human-readable name for this strategy
  String get name;

  /// Returns a description of what this strategy does
  String get description;
}

/// Base class for swap strategies that need asset activation
abstract class BaseSwapStrategy extends SwapStrategy {
  /// Creates a new base swap strategy
  const BaseSwapStrategy();

  /// Ensures the required assets are activated before proceeding
  Future<void> ensureAssetsActivated(
    List<AssetId> assetIds,
    IAssetProvider assetProvider,
    ActivationManager activationManager,
  ) async {
    for (final assetId in assetIds) {
      final assets = assetProvider.findAssetsByConfigId(assetId.id);
      if (assets.isEmpty) {
        throw SwapException(
          'Asset ${assetId.id} not found',
          SwapErrorCode.assetNotActivated,
        );
      }

      final asset = assets.first;
      final activationStatus =
          await activationManager.activateAsset(asset).last;

      if (activationStatus.isComplete && !activationStatus.isSuccess) {
        throw SwapException(
          'Failed to activate asset ${assetId.id}',
          SwapErrorCode.assetNotActivated,
        );
      }
    }
  }

  /// Handles common error cases and converts them to SwapExceptions
  Stream<SwapProgress> handleError(Object error) async* {
    yield* Stream.error(
      error is SwapException
          ? error
          : SwapException(
              'Swap failed: $error',
              SwapException.mapErrorToCode(error.toString()),
            ),
    );
  }
}
