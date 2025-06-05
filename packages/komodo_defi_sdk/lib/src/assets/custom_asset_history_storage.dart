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
    final assetsJsonArray = assets.map((asset) => asset.toJson()).toList();
    await _storage.write(key: key, value: assetsJsonArray.toJsonString());
  }

  /// Add a single asset to wallet's history
  Future<void> addAssetToWallet(WalletId walletId, Asset asset) async {
    final assets = await getWalletAssets(walletId);
    // Equatable operators not working as expected, so we need to check manually
    if (assets.any((historicalAsset) => historicalAsset.id.id == asset.id.id)) {
      return;
    }
    assets.add(asset);
    await storeWalletAssets(walletId, assets);
  }

  /// Get all assets previously used by a wallet
  Future<Set<Asset>> getWalletAssets(WalletId walletId) async {
    final key = _getStorageKey(walletId);
    final value = await _storage.read(key: key);
    if (value == null || value.isEmpty) return {};
    final assetsJsonArray = jsonListFromString(value);
    return assetsJsonArray.map(Asset.fromJson).toSet();
  }

  /// Clear wallet's custom token history
  Future<void> clearWalletAssets(WalletId walletId) async {
    final key = _getStorageKey(walletId);
    await _storage.delete(key: key);
  }

  String _getStorageKey(WalletId walletId) =>
      '$_storagePrefix${walletId.pubkeyHash ?? walletId.name}';
}
