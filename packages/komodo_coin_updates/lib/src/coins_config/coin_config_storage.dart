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
  /// Reads all stored [Asset] items, excluding any whose ticker appears
  /// in [excludedAssets]. The ticker corresponds to `AssetId.id` (the
  /// `coin` field in the source JSON). Returns an empty list when storage
  /// is empty.
  Future<List<Asset>> getAssets({
    List<String> excludedAssets = const <String>[],
  });

  /// Reads a single [Asset] identified by [assetId]. Returns `null` if
  /// the asset is not present.
  Future<Asset?> getAsset(AssetId assetId);

  /// Returns `true` if the locally stored commit matches [latestCommit].
  /// Storage should not query remote providers.
  Future<bool> isLatestCommit({String? latestCommit});

  /// Returns the commit hash currently stored alongside the assets, or `null`
  /// if not present.
  Future<String?> getCurrentCommit();

  /// Returns `true` when storage boxes exist and contain data for the coin
  /// configuration. This is a lightweight readiness check, not a deep
  /// validation of contents.
  Future<bool> updatedAssetStorageExists();

  /// Creates or updates the stored assets and persists the associated
  /// repository [commit]. Implementations should upsert by `AssetId`
  /// (idempotent per asset). Where possible, persist the commit only
  /// after assets have been successfully written to storage to avoid
  /// inconsistent states on partial failures.
  Future<void> upsertAssets(List<Asset> assets, String commit);

  /// Creates or updates the stored assets from raw JSON entries keyed by
  /// ticker and persists the associated [commit]. Entries are keyed by
  /// the `coin` ticker. Implementations should parse entries into [Asset]
  /// and delegate to [upsertAssets]. See [upsertAssets] for guidance on
  /// idempotency and commit persistence ordering.
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
