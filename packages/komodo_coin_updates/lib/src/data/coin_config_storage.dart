import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Storage abstraction for CRUD operations on the locally persisted
/// coin configuration using Hive. Implementations are responsible for
/// persisting and retrieving parsed [Asset] models as well as tracking
/// the repository commit hash they were sourced from.
///
/// This interface intentionally focuses on storage concerns; fetching
/// fresh coin configuration from a remote source is handled by a
/// corresponding provider (see `coin_config_provider.dart`).
abstract class CoinConfigStorage {
  /// Reads all stored [Asset] items, excluding any whose symbol appears
  /// in [excludedAssets]. Returns `null` when storage is empty.
  Future<List<Asset>?> getAssets({
    List<String> excludedAssets = const <String>[],
  });

  /// Reads a single [Asset] identified by [assetId]. Returns `null` if
  /// the asset is not present.
  Future<Asset?> getAsset(AssetId assetId);

  /// Returns `true` if the locally stored commit matches the latest commit
  /// reported by the configured provider. Implementations may cache the
  /// latest commit value in memory.
  Future<bool> isLatestCommit();

  /// Returns the commit hash currently stored alongside the assets, or `null`
  /// if not present.
  Future<String?> getCurrentCommit();

  /// Returns `true` when storage boxes exist and contain data for the coin
  /// configuration. This is a lightweight readiness check, not a deep
  /// validation of contents.
  Future<bool> coinConfigExists();

  /// Creates or updates the stored assets and persists the associated
  /// repository [commit]. Implementations should upsert by `AssetId`.
  Future<void> upsertAssets(List<Asset> assets, String commit);

  /// Creates or updates the stored assets from raw JSON entries keyed by
  /// ticker symbol and persists the associated [commit]. Implementations
  /// should parse entries into [Asset] and delegate to [upsertAssets].
  Future<void> upsertRawAssets(
    Map<String, dynamic> coinConfigsBySymbol,
    String commit,
  );

  /// Deletes a single stored [Asset] identified by [assetId].
  Future<void> deleteAsset(AssetId assetId);

  /// Deletes all stored assets and clears any associated metadata
  /// (such as the stored commit hash).
  Future<void> deleteAllAssets();
}
