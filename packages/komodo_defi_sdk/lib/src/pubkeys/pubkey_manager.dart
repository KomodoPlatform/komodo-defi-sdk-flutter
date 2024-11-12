import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager responsible for handling pubkey operations across different assets
class PubkeyManager {
  PubkeyManager(this._client);

  final ApiClient _client;

  /// Get pubkeys for a given asset, handling HD/non-HD differences internally
  Future<AssetPubkeys> getPubkeys(Asset asset) async {
    final finalStatus =
        await KomodoDefiSdk.global.assets.activateAsset(asset).last;

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
    await KomodoDefiSdk.global.assets.activateAsset(asset).last;

    final strategy = await _resolvePubkeyStrategy(asset);
    if (!strategy.supportsMultipleAddresses) {
      throw UnsupportedError(
        'Asset ${asset.id.name} does not support multiple addresses',
      );
    }

    return strategy.getNewAddress(asset.id, _client);
  }

  Future<PubkeyStrategy> _resolvePubkeyStrategy(Asset asset) async {
    // Get auth status from global SDK instance
    final authOptions = await KomodoDefiSdk().auth.currentUsersAuthOptions();
    final isHdWallet =
        authOptions?.derivationMethod == DerivationMethod.hdWallet;

    return asset.pubkeyStrategy(isHdWallet: isHdWallet);
  }
}
