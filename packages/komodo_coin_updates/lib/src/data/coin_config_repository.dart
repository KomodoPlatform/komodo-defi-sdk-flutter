import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/data/coin_config_storage.dart';
import 'package:komodo_coin_updates/src/models/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A repository that fetches the coins and coin configs from the provider and
/// stores them in the storage provider.
class CoinConfigRepository implements CoinConfigStorage {
  /// Creates a coin config repository.
  /// [coinConfigProvider] is the provider that fetches the coins and coin configs.
  /// (i.e. current commit hash).
  CoinConfigRepository({required this.coinConfigProvider});

  /// Creates a coin config storage provider with default databases.
  /// The default databases are HiveLazyBoxProvider.
  /// The default databases are named 'coins' and 'coins_settings'.
  CoinConfigRepository.withDefaults(
    RuntimeUpdateConfig config, {
    String? githubToken,
  }) : coinConfigProvider = CoinConfigProvider.fromConfig(
         config,
         githubToken: githubToken,
       );

  /// The provider that fetches the coins and coin configs.
  final CoinConfigProvider coinConfigProvider;

  LazyBox<Asset>? _assetsBox;
  Box<String>? _settingsBox;

  /// The key for the coins commit. The value is the commit hash.
  final String coinsCommitKey = 'coins_commit';

  String? _latestCommit;

  /// Updates the assets from the provider and stores them in the storage provider.
  /// Throws an [Exception] if the request fails.
  Future<void> updateCoinConfig({
    List<String> excludedAssets = const <String>[],
  }) async {
    final assets = await coinConfigProvider.getLatestAssets();
    await saveAssetData(assets, _latestCommit ?? '');
  }

  @override
  /// Returns whether the currently stored commit matches the latest
  /// commit on the configured branch. Also caches the latest commit hash
  /// in memory for subsequent calls.
  Future<bool> isLatestCommit() async {
    final commit = await getCurrentCommit();
    if (commit != null) {
      _latestCommit = await coinConfigProvider.getLatestCommit();
      return commit == _latestCommit;
    }
    return false;
  }

  @override
  /// Retrieves all assets from storage, excluding any whose symbol appears
  /// in [excludedAssets]. Returns `null` if storage is empty.
  Future<List<Asset>?> getAssets({
    List<String> excludedAssets = const <String>[],
  }) async {
    final box = await _openAssetsBox();
    final keys = box.keys;
    final values = await Future.wait(
      keys.map((dynamic key) => box.get(key as String)),
    );
    return values
        .whereType<Asset>()
        .where((a) => !excludedAssets.contains(a.id.id))
        .toList();
  }

  @override
  /// Retrieves a single [Asset] by its [assetId] from storage.
  Future<Asset?> getAsset(AssetId assetId) async {
    final a = await (await _openAssetsBox()).get(assetId.id);
    return a;
  }

  @override
  // Explicit coin configs are no longer stored; callers should use [Asset].
  @override
  // Explicit coin config retrieval removed; derive from [Asset] if needed.
  @override
  /// Returns the commit hash currently persisted in the settings storage
  /// for the coin data, or `null` if not present.
  Future<String?> getCurrentCommit() async {
    final box = await _openSettingsBox();
    return box.get(coinsCommitKey);
  }

  @override
  /// Persists asset list to storage and records the
  /// associated repository [commit]. Also updates the in-memory cached
  /// latest commit if it has not yet been set.
  Future<void> saveAssetData(List<Asset> assets, String commit) async {
    final assetsBox = await _openAssetsBox();
    final putMap = <String, Asset>{for (final a in assets) a.id.id: a};
    await assetsBox.putAll(putMap);

    final settings = await _openSettingsBox();
    await settings.put(coinsCommitKey, commit);
    _latestCommit = _latestCommit ?? await coinConfigProvider.getLatestCommit();
  }

  @override
  /// Returns `true` when both the assets database and the settings
  /// database have been initialized and contain data.
  Future<bool> coinConfigExists() async {
    return await Hive.boxExists('assets') &&
        await Hive.boxExists('coins_settings');
  }

  @override
  /// Persists raw JSON coin config map to storage by parsing to [Asset].
  Future<void> saveRawAssetData(
    Map<String, dynamic> coinConfigsBySymbol,
    String commit,
  ) async {
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
    await saveAssetData(assets, commit);
  }

  Future<LazyBox<Asset>> _openAssetsBox() async {
    _assetsBox ??= await Hive.openLazyBox<Asset>('assets');
    return _assetsBox!;
  }

  Future<Box<String>> _openSettingsBox() async {
    _settingsBox ??= await Hive.openBox<String>('coins_settings');
    return _settingsBox!;
  }
}
