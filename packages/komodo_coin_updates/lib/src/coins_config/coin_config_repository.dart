import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_storage.dart';
import 'package:komodo_coin_updates/src/coins_config/config_transform.dart';
import 'package:komodo_coin_updates/src/coins_config/github_coin_config_provider.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Repository that orchestrates fetching coin configuration from a
/// [CoinConfigProvider] and performing CRUD operations against local
/// Hive storage. Parsed [Asset] models are persisted along with the
/// source repository commit hash for traceability.
class CoinConfigRepository implements CoinConfigStorage {
  /// Creates a coin config repository.
  /// [coinConfigProvider] is the provider that fetches the coins and coin configs.
  /// (i.e. current commit hash).
  CoinConfigRepository({
    required this.coinConfigProvider,
    this.assetsBoxName = 'assets',
    this.settingsBoxName = 'coins_settings',
    this.coinsCommitKey = 'coins_commit',
  });

  /// Convenience factory that derives a provider from a runtime config and
  /// uses default Hive boxes (`assets`, `coins_settings`).
  CoinConfigRepository.withDefaults(
    RuntimeUpdateConfig config, {
    String? githubToken,
    CoinConfigTransformer? transformer,
    this.assetsBoxName = 'assets',
    this.settingsBoxName = 'coins_settings',
    this.coinsCommitKey = 'coins_commit',
  }) : coinConfigProvider = GithubCoinConfigProvider.fromConfig(
         config,
         githubToken: githubToken,
         transformer: transformer,
       );
  static final Logger _log = Logger('CoinConfigRepository');

  /// The provider that fetches the coins and coin configs.
  final CoinConfigProvider coinConfigProvider;

  LazyBox<Asset>? _assetsBox;
  Box<String>? _settingsBox;

  /// Configurable Hive box names and settings key.
  final String assetsBoxName;

  /// The name of the Hive box for the coins settings.
  final String settingsBoxName;

  /// The key for the coins commit. The value is the commit hash.
  final String coinsCommitKey;

  /// Fetches the latest commit from the provider, downloads assets for that
  /// commit, and upserts them in local storage along with the commit hash.
  /// Throws an [Exception] if the request fails at any step.
  Future<void> updateCoinConfig({
    List<String> excludedAssets = const <String>[],
  }) async {
    _log.fine('Updating coin config: fetching latest commit');
    final latestCommit = await coinConfigProvider.getLatestCommit();
    _log.fine('Fetched latest commit: $latestCommit; fetching assets');
    final assets = await coinConfigProvider.getAssetsForCommit(latestCommit);
    _log.fine(
      'Fetched ${assets.length} assets for commit $latestCommit; upserting',
    );
    await upsertAssets(assets, latestCommit);
    _log.fine('Update complete for commit $latestCommit');
  }

  @override
  /// Returns whether the currently stored commit matches the latest
  /// commit on the configured branch. Also caches the latest commit hash
  /// in memory for subsequent calls.
  Future<bool> isLatestCommit({String? latestCommit}) async {
    _log.fine('Checking if stored commit is latest');
    final commit = latestCommit ?? await getCurrentCommit();
    if (commit != null) {
      final latestCommit = await coinConfigProvider.getLatestCommit();
      final isLatest = commit == latestCommit;
      _log.fine('Stored commit=$commit latest=$latestCommit result=$isLatest');
      return isLatest;
    }
    _log.fine('No stored commit found');
    return false;
  }

  @override
  /// Retrieves all assets from storage, excluding any whose symbol appears
  /// in [excludedAssets]. Returns an empty list if storage is empty.
  Future<List<Asset>> getAssets({
    List<String> excludedAssets = const <String>[],
  }) async {
    _log.fine(
      'Retrieving all assets (excluding ${excludedAssets.length} symbols)',
    );
    final box = await _openAssetsBox();
    final keys = box.keys;
    final values = await Future.wait(
      keys.map((dynamic key) => box.get(key as String)),
    );
    final result =
        values
            .whereType<Asset>()
            .where((a) => !excludedAssets.contains(a.id.id))
            .toList();
    _log.fine('Retrieved ${result.length} assets');
    return result;
  }

  @override
  /// Retrieves a single [Asset] by its [assetId] from storage.
  Future<Asset?> getAsset(AssetId assetId) async {
    _log.fine('Retrieving asset ${assetId.id}');
    final a = await (await _openAssetsBox()).get(assetId.id);
    return a;
  }

  // Explicit coin config retrieval removed; derive from [Asset] if needed.
  @override
  /// Returns the commit hash currently persisted in the settings storage
  /// for the coin data, or `null` if not present.
  Future<String?> getCurrentCommit() async {
    _log.fine('Reading current commit');
    final box = await _openSettingsBox();
    return box.get(coinsCommitKey);
  }

  @override
  /// Creates or updates stored assets keyed by `AssetId.id`, and records the
  /// associated repository [commit]. Also refreshes the in-memory cached
  /// latest commit when not yet initialized.
  Future<void> upsertAssets(List<Asset> assets, String commit) async {
    _log.fine('Upserting ${assets.length} assets for commit $commit');
    final assetsBox = await _openAssetsBox();
    final putMap = <String, Asset>{for (final a in assets) a.id.id: a};
    await assetsBox.putAll(putMap);

    final settings = await _openSettingsBox();
    await settings.put(coinsCommitKey, commit);
    _log.fine(
      'Upserted ${assets.length} assets; commit stored under "$coinsCommitKey"',
    );
  }

  @override
  /// Returns `true` when both the assets database and the settings
  /// database have been initialized and contain data.
  Future<bool> coinConfigExists() async {
    final assetsExists = await Hive.boxExists(assetsBoxName);
    final settingsExists = await Hive.boxExists(settingsBoxName);
    _log.fine(
      'Box existence check: $assetsBoxName=$assetsExists $settingsBoxName=$settingsExists',
    );
    return assetsExists && settingsExists;
  }

  @override
  /// Parses raw JSON coin config map to [Asset]s and delegates to [upsertAssets].
  Future<void> upsertRawAssets(
    Map<String, dynamic> coinConfigsBySymbol,
    String commit,
  ) async {
    _log.fine('Parsing and upserting raw assets for commit $commit');
    // First pass: known ids
    final knownIds = <AssetId>{
      for (final e in coinConfigsBySymbol.entries)
        AssetId.parse(e.value as Map<String, dynamic>, knownIds: const {}),
    };
    // Second pass: assets
    final assets = <Asset>[
      for (final e in coinConfigsBySymbol.entries)
        Asset.fromJsonWithId(
          e.value as Map<String, dynamic>,
          assetId: AssetId.parse(
            e.value as Map<String, dynamic>,
            knownIds: knownIds,
          ),
        ),
    ];
    _log.fine('Parsed ${assets.length} assets from raw; delegating to upsert');
    await upsertAssets(assets, commit);
  }

  @override
  Future<void> deleteAsset(AssetId assetId) async {
    _log.fine('Deleting asset ${assetId.id}');
    final assetsBox = await _openAssetsBox();
    await assetsBox.delete(assetId.id);
  }

  @override
  Future<void> deleteAllAssets() async {
    _log.fine('Clearing all assets and removing commit key "$coinsCommitKey"');
    final assetsBox = await _openAssetsBox();
    await assetsBox.clear();
    final settings = await _openSettingsBox();
    await settings.delete(coinsCommitKey);
  }

  // ---- end CRUD ----

  Future<LazyBox<Asset>> _openAssetsBox() async {
    if (_assetsBox == null) {
      _log.fine('Opening assets box "$assetsBoxName"');
      _assetsBox = await Hive.openLazyBox<Asset>(assetsBoxName);
    }
    return _assetsBox!;
  }

  Future<Box<String>> _openSettingsBox() async {
    if (_settingsBox == null) {
      _log.fine('Opening settings box "$settingsBoxName"');
      _settingsBox = await Hive.openBox<String>(settingsBoxName);
    }
    return _settingsBox!;
  }
}
