import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A manager for security-sensitive wallet operations.
///
/// This manager handles operations that involve private keys or other
/// sensitive cryptographic material. All operations require proper
/// authentication and should be used with caution.
///
/// **Security Note**: Private key operations are extremely sensitive.
/// Ensure proper authentication before calling these methods and
/// handle returned private keys securely.
class SecurityManager {
  /// Creates a new [SecurityManager] instance.
  SecurityManager(this._client, this._auth, this._assetProvider);

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final IAssetProvider _assetProvider;

  /// Gets private keys for the specified assets.
  ///
  /// This method exports private keys for assets, supporting both HD wallet
  /// and Iguana (standard) modes. The exported keys can be used to recover
  /// funds or import into other wallets.
  ///
  /// **⚠️ SECURITY WARNING**: This method exposes private keys which provide
  /// full control over the associated funds. Use with extreme caution:
  /// - Only call this method when absolutely necessary
  /// - Ensure secure handling of returned private keys
  /// - Never log or store private keys in plain text
  /// - Clear private key data from memory when no longer needed
  ///
  /// Parameters:
  /// - [assets]: List of asset IDs to export keys for. If null, will use all
  ///   currently activated assets
  /// - [mode]: Export mode (HD or Iguana). If null, defaults based on wallet
  ///   type
  /// - [startIndex]: Starting address index for HD mode (default: 0)
  /// - [endIndex]: Ending address index for HD mode (default: startIndex + 10)
  /// - [accountIndex]: Account index for HD mode (default: 0)
  ///
  /// Returns a [GetPrivateKeysResponse] containing either standard keys or
  /// HD keys based on the export mode.
  ///
  /// Throws:
  /// - [StateError] if user is not authenticated
  /// - [GeneralErrorResponse] if the RPC call fails
  /// - [ArgumentError] if invalid parameters are provided
  ///
  /// Example:
  /// ```dart
  /// // Check if authenticated first
  /// if (await securityManager.isAuthenticated) {
  ///   // Get private keys for all activated assets
  ///   final response = await securityManager.getPrivateKeys();
  ///
  ///   // Get private keys for specific assets
  ///   final btcAsset = assetManager.findAssetsByTicker('BTC').first;
  ///   final response = await securityManager.getPrivateKeys(
  ///     assets: [btcAsset.id],
  ///     mode: KeyExportMode.iguana,
  ///   );
  ///
  ///   if (response.isStandardResponse) {
  ///     for (final keyInfo in response.standardKeys!) {
  ///       print('${keyInfo.coin}: ${keyInfo.address}');
  ///       // Handle private key securely: keyInfo.privKey
  ///     }
  ///   }
  ///
  ///   // Get HD keys with custom range
  ///   final ethAsset = assetManager.findAssetsByTicker('ETH').first;
  ///   final hdResponse = await securityManager.getPrivateKeys(
  ///     assets: [ethAsset.id],
  ///     mode: KeyExportMode.hd,
  ///     startIndex: 0,
  ///     endIndex: 5,
  ///     accountIndex: 0,
  ///   );
  ///
  ///   if (hdResponse.isHdResponse) {
  ///     for (final coinInfo in hdResponse.hdKeys!) {
  ///       for (final addressInfo in coinInfo.addresses) {
  ///         print('${addressInfo.derivationPath}: ${addressInfo.address}');
  ///         // Handle private key securely: addressInfo.privKey
  ///       }
  ///     }
  ///   }
  /// }
  /// ```
  Future<GetPrivateKeysResponse> getPrivateKeys({
    List<AssetId>? assets,
    KeyExportMode? mode,
    int? startIndex,
    int? endIndex,
    int? accountIndex,
  }) async {
    // Ensure user is authenticated before proceeding with sensitive operation
    final currentUser = await _auth.currentUser;
    if (currentUser == null) {
      throw AuthException.notSignedIn();
    }

    // If no assets specified, use all activated assets
    List<AssetId> targetAssets;
    if (assets == null) {
      final activatedAssets = await _assetProvider.getActivatedAssets();
      targetAssets = activatedAssets.map((Asset asset) => asset.id).toList();
    } else {
      targetAssets = assets;
    }

    // Validate parameters
    if (targetAssets.isEmpty) {
      throw ArgumentError('At least one asset must be available or specified');
    }

    // Convert AssetId objects to coin ticker strings for the RPC call
    final coinTickers = targetAssets.map((assetId) => assetId.id).toList();

    // If HD mode parameters are provided, ensure they're valid
    if (mode == KeyExportMode.hd) {
      final start = startIndex ?? 0;
      final end = endIndex ?? (start + 10);

      if (start < 0) {
        throw ArgumentError('startIndex must be non-negative');
      }

      if (end < start) {
        throw ArgumentError(
          'endIndex must be greater than or equal to startIndex',
        );
      }

      if (end - start > 100) {
        throw ArgumentError('Index range cannot exceed 100 addresses');
      }

      if (accountIndex != null && accountIndex < 0) {
        throw ArgumentError('accountIndex must be non-negative');
      }
    } else if (mode == KeyExportMode.iguana) {
      // Validate that HD-specific parameters are not provided for Iguana mode
      if (startIndex != null || endIndex != null || accountIndex != null) {
        throw ArgumentError(
          'startIndex, endIndex, and accountIndex are only valid for HD mode',
        );
      }
    }

    return _client.rpc.wallet.getPrivateKeys(
      coins: coinTickers,
      mode: mode,
      startIndex: startIndex,
      endIndex: endIndex,
      accountIndex: accountIndex,
    );
  }

  /// Convenience method to get private keys for a single asset.
  ///
  /// This is a wrapper around [getPrivateKeys] for the common case of
  /// exporting keys for a single asset.
  ///
  /// **⚠️ SECURITY WARNING**: Same security considerations as [getPrivateKeys]
  /// apply.
  ///
  /// Parameters:
  /// - [asset]: The asset ID to export keys for
  /// - [mode]: Export mode (HD or Iguana). If null, defaults based on
  ///   authenticated wallet type.
  /// - [startIndex]: Starting address index for HD mode (default: 0)
  /// - [endIndex]: Ending address index for HD mode (default: startIndex + 10)
  /// - [accountIndex]: Account index for HD mode (default: 0)
  ///
  /// Returns a [GetPrivateKeysResponse] containing the private key information.
  Future<GetPrivateKeysResponse> getPrivateKey(
    AssetId asset, {
    KeyExportMode? mode,
    int? startIndex,
    int? endIndex,
    int? accountIndex,
  }) {
    return getPrivateKeys(
      assets: [asset],
      mode: mode,
      startIndex: startIndex,
      endIndex: endIndex,
      accountIndex: accountIndex,
    );
  }

  /// Dispose of any resources
  Future<void> dispose() async {
    // No cleanup needed currently
  }
}
