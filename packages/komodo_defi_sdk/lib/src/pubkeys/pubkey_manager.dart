import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager responsible for handling pubkey operations across different assets
class PubkeyManager {
  PubkeyManager(this._client, this._auth, this._activationManager);

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final ActivationManager _activationManager;

  /// Get pubkeys for a given asset, handling HD/non-HD differences internally
  Future<AssetPubkeys> getPubkeys(Asset asset) async {
    await retryWithBackoff(() => _activationManager.activateAsset(asset).last);
    final strategy = await _resolvePubkeyStrategy(asset);
    return strategy.getPubkeys(asset.id, _client);
  }

  /// Create a new pubkey for an asset if supported
  Future<PubkeyInfo> createNewPubkey(Asset asset) async {
    await retryWithBackoff(() => _activationManager.activateAsset(asset).last);
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
