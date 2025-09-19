import 'package:komodo_coin_updates/src/coins_config/custom_token_storage_interface.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A no-op implementation of [ICustomTokenStorage] that always returns empty results.
/// This is useful in scenarios where custom tokens should not be included,
/// such as in startup coin providers that need to provide a minimal coin list
/// to initialize the system without user-specific customizations.
class NoOpCustomTokenStorage implements ICustomTokenStorage {
  const NoOpCustomTokenStorage();

  @override
  Future<void> storeCustomToken(Asset asset) async {
    // No-op: doesn't store anything
  }

  @override
  Future<void> storeCustomTokens(List<Asset> assets) async {
    // No-op: doesn't store anything
  }

  @override
  Future<List<Asset>> getAllCustomTokens() async {
    // Always returns empty list
    return <Asset>[];
  }

  @override
  Future<Asset?> getCustomToken(AssetId assetId) async {
    // Always returns null (no custom tokens)
    return null;
  }

  @override
  Future<bool> hasCustomToken(AssetId assetId) async {
    // Never has any custom tokens
    return false;
  }

  @override
  Future<void> deleteCustomToken(AssetId assetId) async {
    // No-op: nothing to delete
  }

  @override
  Future<void> deleteCustomTokens(List<AssetId> assetIds) async {
    // No-op: nothing to delete
  }

  @override
  Future<void> deleteAllCustomTokens() async {
    // No-op: nothing to delete
  }

  @override
  Future<bool> hasCustomTokens() async {
    // Never has any custom tokens
    return false;
  }

  @override
  Future<bool> updateCustomToken(Asset asset) async {
    // No-op: doesn't update anything, returns false (not updated)
    return false;
  }

  @override
  Future<bool> addCustomTokenIfNotExists(Asset asset) async {
    // No-op: doesn't add anything, returns false (not added)
    return false;
  }

  @override
  Future<int> getCustomTokenCount() async {
    // Always has zero custom tokens
    return 0;
  }

  @override
  Future<void> dispose() async {
    // No-op: nothing to dispose
  }
}
