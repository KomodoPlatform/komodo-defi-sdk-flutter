import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A storage provider that fetches the coins and coin configs from the storage.
/// The storage provider is responsible for fetching the coins and coin configs
/// from the storage and saving the coins and coin configs to the storage.
abstract class CoinConfigStorage {
  /// Fetches the assets from the storage provider.
  /// Returns a list of [Asset] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Asset>?> getAssets({
    List<String> excludedAssets = const <String>[],
  });

  /// Fetches the specified asset from the storage provider.
  /// [assetId] identifies the asset (its `id.id` is used as box key).
  /// Returns an [Asset] object.
  /// Throws an [Exception] if the request fails.
  Future<Asset?> getAsset(AssetId assetId);

  /// Checks if the latest commit is the same as the current commit.
  /// Returns `true` if the latest commit is the same as the current commit,
  /// otherwise `false`.
  /// Throws an [Exception] if the request fails.
  Future<bool> isLatestCommit();

  /// Fetches the current commit hash.
  /// Returns the commit hash as a [String].
  /// Throws an [Exception] if the request fails.
  Future<String?> getCurrentCommit();

  /// Checks if the assets are saved in the storage provider.
  /// Returns `true` if the assets are saved, otherwise `false`.
  /// Throws an [Exception] if the request fails.
  Future<bool> coinConfigExists();

  /// Saves the assets data to the storage provider.
  /// [assets] is a list of [Asset] objects.
  /// [commit] is the commit hash.
  /// Throws an [Exception] if the request fails.
  Future<void> saveAssetData(List<Asset> assets, String commit);

  /// Saves the raw asset data to the storage provider.
  /// [coinConfigsBySymbol] is a map of raw JSON `dynamic` coin configs keyed by ticker.
  /// [commit] is the commit hash.
  /// Throws an [Exception] if the request fails.
  Future<void> saveRawAssetData(
    Map<String, dynamic> coinConfigsBySymbol,
    String commit,
  );
}
