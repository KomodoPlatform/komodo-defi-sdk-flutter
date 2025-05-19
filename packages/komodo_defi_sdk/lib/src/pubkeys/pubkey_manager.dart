import 'dart:async';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Retry utility with exponential backoff.
/// If [shouldRetry] returns true, the attempt counter is incremented.
/// If [shouldRetryNoIncrement] returns true, the attempt counter is NOT
/// incremented. Use with caution. The intended application is for 
/// false positives, where the error is not a failure of the function 
/// E.g. PlatformIsAlreadyActivated
Future<T> retryWithBackoff<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
  bool Function(Object error)? shouldRetry,
  bool Function(Object error)? shouldRetryNoIncrement,
}) async {
  var attempt = 0;
  var delay = initialDelay;

  while (true) {
    try {
      return await fn();
    } catch (e) {
      if (shouldRetryNoIncrement != null && shouldRetryNoIncrement(e)) {
        await Future<void>.delayed(delay);
        delay *= 2;
        continue;
      }
      attempt++;
      if (attempt >= maxAttempts || (shouldRetry != null && !shouldRetry(e))) {
        rethrow;
      }
      await Future<void>.delayed(delay);
      delay *= 2;
    }
  }
}

/// Manager responsible for handling pubkey operations across different assets
class PubkeyManager {
  PubkeyManager(this._client, this._auth, this._activationManager);

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final ActivationManager _activationManager;

  /// Get pubkeys for a given asset, handling HD/non-HD differences internally
  Future<AssetPubkeys> getPubkeys(Asset asset) async {
    await retryWithBackoff(
      () => _activationManager.activateAsset(asset).last,
      shouldRetry: (e) =>
        // Always retry unless maxAttempts reached, except for positive errors
        true,
      shouldRetryNoIncrement: (e) {
        // Handle GeneralErrorResponse with PlatformIsAlreadyActivated as a positive error
        if (e is GeneralErrorResponse && e.errorType == 'PlatformIsAlreadyActivated') {
          return true;
        }
        // Also handle legacy StateError with "AlreadyActivated"
        if (e is StateError && e.toString().contains('AlreadyActivated')) {
          return true;
        }
        return false;
      },
    );
    final strategy = await _resolvePubkeyStrategy(asset);
    return strategy.getPubkeys(asset.id, _client);
  }

  /// Create a new pubkey for an asset if supported
  Future<PubkeyInfo> createNewPubkey(Asset asset) async {
    await retryWithBackoff(
      () => _activationManager.activateAsset(asset).last,
      shouldRetry: (e) =>
        true,
      shouldRetryNoIncrement: (e) {
        if (e is GeneralErrorResponse && e.errorType == 'PlatformIsAlreadyActivated') {
          return true;
        }
        if (e is StateError && e.toString().contains('AlreadyActivated')) {
          return true;
        }
        return false;
      },
    );
    final strategy = await _resolvePubkeyStrategy(asset);
    if (!strategy.supportsMultipleAddresses) {
      throw UnsupportedError(
        'Asset ${asset.id.name} does not support multiple addresses',
      );
    }
    return strategy.getNewAddress(asset.id, _client);
  }

  Future<PubkeyStrategy> _resolvePubkeyStrategy(Asset asset) async {
    final isHdWallet =
        await _auth.currentUser.then((u) => u?.isHd) ??
        (throw AuthException.notSignedIn());
    return asset.pubkeyStrategy(isHdWallet: isHdWallet);
  }

  /// Dispose of any resources
  Future<void> dispose() async {
    // No cleanup needed currently
  }
}
