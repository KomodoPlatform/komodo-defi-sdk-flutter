import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Custom token asset history storage for tokens not present in the live coins
/// configuration.
class CustomAssetHistoryStorage {
  static const _storagePrefix = 'wallet_custom_assets_';
  final _storage = const FlutterSecureStorage();

  /// Store custom tokens used by a wallet
  Future<void> storeWalletAssets(WalletId walletId, Set<Asset> assets) async {
    final key = _getStorageKey(walletId);
    // Use the protocol config instead of asset toJson due to missing fields
    // from the incomplete Asset.toJson implementation. Similar to the
    // komodo_coin_updates/hive/hive_adapters.dart issue.
    final assetsJsonArray = assets
        .map((asset) => asset.protocol.config)
        .toList();
    await _storage.write(key: key, value: assetsJsonArray.toJsonString());
  }

  /// Add a single asset to wallet's history
  ///
  /// [walletId] is the wallet to add the asset to.
  /// [asset] is the asset to add to the wallet.
  /// [knownAssets] is used to find the parent asset for child assets.
  Future<void> addAssetToWallet(
    WalletId walletId,
    Asset asset,
    Set<AssetId> knownAssets,
  ) async {
    final assets = await getWalletAssets(walletId, knownAssets);
    if (assets.any((historicalAsset) => historicalAsset.id.id == asset.id.id)) {
      return;
    }
    assets.add(asset);
    await storeWalletAssets(walletId, assets);
  }

  /// Get all assets previously used by a wallet
  ///
  /// [walletId] is the wallet to get the assets from.
  /// [knownAssets] is used to find the parent asset for child assets.
  Future<Set<Asset>> getWalletAssets(
    WalletId walletId,
    Set<AssetId> knownAssets,
  ) async {
    final key = _getStorageKey(walletId);
    final value = await _storage.read(key: key);
    if (value == null || value.isEmpty) return {};
    final assetsJsonArray = jsonListFromString(value);
    return assetsJsonArray
        .map((json) => Asset.fromJson(json, knownIds: knownAssets))
        .toSet();
  }

  /// Clear wallet's custom token history
  ///
  /// [walletId] is the wallet to clear the assets from.
  Future<void> clearWalletAssets(WalletId walletId) async {
    final key = _getStorageKey(walletId);
    await _storage.delete(key: key);
  }

  String _getStorageKey(WalletId walletId) =>
      '$_storagePrefix${walletId.pubkeyHash ?? walletId.name}';
}
