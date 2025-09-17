import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Result of an asset activation operation.
///
/// This class encapsulates the outcome of attempting to activate an asset,
/// providing both success and failure states with appropriate context.
///
/// Example usage:
/// ```dart
/// final result = await activationManager.activateAsset(asset);
/// if (result.isSuccess) {
///   print('Asset ${result.assetId.id} activated successfully');
/// } else {
///   print('Failed to activate ${result.assetId.id}: ${result.errorMessage}');
/// }
/// ```
class ActivationResult {
  /// Private constructor for creating activation results.
  ///
  /// Use [ActivationResult.success] or [ActivationResult.failure] factory
  /// constructors instead of calling this directly.
  const ActivationResult._(this.assetId, this.isSuccess, this.errorMessage);

  /// Creates a successful activation result.
  ///
  /// [assetId] - The ID of the asset that was successfully activated.
  ///
  /// Returns an [ActivationResult] indicating successful activation.
  factory ActivationResult.success(AssetId assetId) {
    return ActivationResult._(assetId, true, null);
  }

  /// Creates a failed activation result.
  ///
  /// [assetId] - The ID of the asset that failed to activate.
  /// [errorMessage] - A descriptive error message explaining why activation failed.
  ///
  /// Returns an [ActivationResult] indicating failed activation with error details.
  factory ActivationResult.failure(AssetId assetId, String errorMessage) {
    return ActivationResult._(assetId, false, errorMessage);
  }

  /// The ID of the asset this result pertains to.
  final AssetId assetId;

  /// Whether the activation was successful.
  ///
  /// `true` if activation completed successfully, `false` otherwise.
  final bool isSuccess;

  /// Error message if activation failed.
  ///
  /// This will be `null` for successful activations and contain a descriptive
  /// error message for failed activations.
  final String? errorMessage;

  /// Whether the activation failed.
  ///
  /// This is the inverse of [isSuccess] for convenience.
  bool get isFailure => !isSuccess;

  /// Returns a string representation of the activation result.
  ///
  /// For successful activations: `ActivationResult.success(ASSET_ID)`
  /// For failed activations: `ActivationResult.failure(ASSET_ID, ERROR_MESSAGE)`
  @override
  String toString() {
    return isSuccess
        ? 'ActivationResult.success(${assetId.id})'
        : 'ActivationResult.failure(${assetId.id}, $errorMessage)';
  }
}
