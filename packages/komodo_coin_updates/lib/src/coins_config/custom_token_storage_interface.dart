import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Interface for custom token storage operations
abstract class ICustomTokenStorage {
  /// Stores a single custom token.
  /// If a token with the same AssetId already exists, it will be overwritten.
  Future<void> storeCustomToken(Asset asset);

  /// Stores multiple custom tokens.
  /// Existing tokens with the same AssetIds will be overwritten.
  Future<void> storeCustomTokens(List<Asset> assets);

  /// Retrieves all custom tokens from storage.
  /// Returns an empty list if no custom tokens are stored.
  Future<List<Asset>> getAllCustomTokens();

  /// Retrieves a single custom token by its AssetId.
  /// Returns null if the token is not found.
  Future<Asset?> getCustomToken(AssetId assetId);

  /// Checks if a custom token exists in storage.
  Future<bool> hasCustomToken(AssetId assetId);

  /// Deletes a single custom token by its AssetId.
  Future<void> deleteCustomToken(AssetId assetId);

  /// Deletes multiple custom tokens by their AssetIds.
  Future<void> deleteCustomTokens(List<AssetId> assetIds);

  /// Deletes all custom tokens from storage.
  Future<void> deleteAllCustomTokens();

  /// Returns true if the custom tokens box exists and is not empty.
  Future<bool> hasCustomTokens();

  /// Updates an existing custom token if it exists, otherwise stores it as new.
  /// Returns true if the token was updated, false if it was newly created.
  Future<bool> updateCustomToken(Asset asset);

  /// Adds a custom token to storage if it doesn't already exist.
  /// Returns true if the token was added, false if it already existed.
  Future<bool> addCustomTokenIfNotExists(Asset asset);

  /// Returns the number of custom tokens in storage.
  Future<int> getCustomTokenCount();

  /// Closes the storage and releases resources.
  /// This should be called when the storage is no longer needed.
  Future<void> dispose();
}
