// NB! This should be moved to a separate package for wallet persistence
// which will cache wallet data to return

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetHistoryStorage {
  static const _storagePrefix = 'wallet_assets_';
  final _storage = const FlutterSecureStorage();

  /// Store assets used by a wallet
  Future<void> storeWalletAssets(
    WalletId walletId,
    Set<String> assetIds,
  ) async {
    final key = _getStorageKey(walletId);
    await _storage.write(
      key: key,
      value: assetIds.join(','),
    );
  }

  /// Add a single asset to wallet's history
  Future<void> addAssetToWallet(WalletId walletId, String assetId) async {
    final assets = await getWalletAssets(walletId);
    assets.add(assetId);
    await storeWalletAssets(walletId, assets);
  }

  /// Get all assets previously used by a wallet
  Future<Set<String>> getWalletAssets(WalletId walletId) async {
    final key = _getStorageKey(walletId);
    final value = await _storage.read(key: key);
    if (value == null || value.isEmpty) return {};
    return value.split(',').toSet();
  }

  /// Clear wallet's asset history
  Future<void> clearWalletAssets(WalletId walletId) async {
    final key = _getStorageKey(walletId);
    await _storage.delete(key: key);
  }

  String _getStorageKey(WalletId walletId) =>
      '$_storagePrefix${walletId.pubkeyHash ?? walletId.name}';
}
