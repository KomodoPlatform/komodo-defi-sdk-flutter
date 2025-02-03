import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager responsible for handling pubkey operations across different assets
class PubkeyManager {
  PubkeyManager(
    this._client,
    this._auth,
    this._assetManager,
  );

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final AssetManager _assetManager;

  /// Get pubkeys for a given asset, handling HD/non-HD differences internally
  Future<AssetPubkeys> getPubkeys(Asset asset) async {
    final finalStatus = await _assetManager.activateAsset(asset).last;

    if (finalStatus.isComplete && !finalStatus.isSuccess) {
      throw StateError(
        'Failed to activate asset ${asset.id.name}. ${finalStatus.toJson()}',
      );
    }

    final strategy = await _resolvePubkeyStrategy(asset);
    return strategy.getPubkeys(asset.id, _client);
  }

  /// Create a new pubkey for an asset if supported
  Future<PubkeyInfo> createNewPubkey(Asset asset) async {
    // ignore: deprecated_member_use_from_same_package
    await _assetManager.activateAsset(asset).last;

    final strategy = await _resolvePubkeyStrategy(asset);
    if (!strategy.supportsMultipleAddresses) {
      throw UnsupportedError(
        'Asset ${asset.id.name} does not support multiple addresses',
      );
    }

    return strategy.getNewAddress(asset.id, _client);
  }

  Future<PubkeyStrategy> _resolvePubkeyStrategy(Asset asset) async {
    final authOptions = await _auth.currentUsersAuthOptions();
    final isHdWallet =
        authOptions?.derivationMethod == DerivationMethod.hdWallet;

    return asset.pubkeyStrategy(isHdWallet: isHdWallet);
  }

  /// Dispose of any resources
  Future<void> dispose() async {
    // Add any cleanup if needed
  }
}
