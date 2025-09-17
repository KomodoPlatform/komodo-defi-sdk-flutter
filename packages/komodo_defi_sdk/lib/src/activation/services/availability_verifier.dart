import 'package:komodo_defi_sdk/src/activation/services/activation_status_service.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Verifies that an asset becomes available locally after activation.
abstract class IAvailabilityVerifier {
  /// Polls activation status with exponential backoff until the asset is
  /// reported available locally. Throws [StateError] if availability is not
  /// observed within the configured number of attempts.
  Future<void> waitUntilAvailable(AssetId assetId);

  /// Watches the availability of an asset and emits updates when it changes.
  /// The stream will emit the current availability immediately and then continue
  /// to emit updates whenever the availability changes.
  Stream<bool> watchAvailability(AssetId assetId);
}

/// Default availability verifier using exponential backoff.
class AvailabilityVerifier implements IAvailabilityVerifier {
  /// Creates a new [AvailabilityVerifier] with the given status service and
  /// configuration.
  AvailabilityVerifier(
    this._status, {
    this.maxRetries = 15,
    this.baseDelay = const Duration(milliseconds: 50),
    this.maxDelay = const Duration(milliseconds: 500),
  });

  final IActivationStatusService _status;

  /// Maximum number of polling attempts.
  final int maxRetries;

  /// Initial delay between attempts; doubles up to [maxDelay].
  final Duration baseDelay;

  /// Upper bound for the backoff delay.
  final Duration maxDelay;

  /// See [IAvailabilityVerifier.waitUntilAvailable].
  @override
  Future<void> waitUntilAvailable(AssetId assetId) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (await _status.isAssetActive(assetId)) return;
      final delayMs = (baseDelay.inMilliseconds * (1 << attempt)).clamp(
        baseDelay.inMilliseconds,
        maxDelay.inMilliseconds,
      );
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
    throw StateError(
      'Coin ${assetId.id} did not become available after activation '
      '(waited $maxRetries attempts)',
    );
  }

  @override
  Stream<bool> watchAvailability(AssetId assetId) {
    return _status
        .isAssetActive(assetId)
        .asStream()
        .map((isActive) => isActive);
  }
}
