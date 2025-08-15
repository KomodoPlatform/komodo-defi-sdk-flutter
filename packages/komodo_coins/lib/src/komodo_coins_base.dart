import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// A high-level library that provides a simple way to access Komodo Platform
/// coin data and seed nodes.
class KomodoCoins {
  KomodoCoins({
    RuntimeUpdateConfigRepository? configRepository,
    CoinConfigTransformer? transformer,
    CoinConfigDataFactory? dataFactory,
  })  : _configRepository = configRepository ?? RuntimeUpdateConfigRepository(),
        _transformer = transformer ?? const CoinConfigTransformer(),
        _dataFactory = dataFactory ?? const DefaultCoinConfigDataFactory();

  static final Logger _log = Logger('KomodoCoins');

  /// Creates an instance of [KomodoCoins] and initializes it.
  static Future<KomodoCoins> create() async {
    _log.fine('Creating KomodoCoins');
    final instance = KomodoCoins();
    await instance.init();
    _log.fine('KomodoCoins initialized');
    return instance;
  }

  /// Fetches the list of coin configuration maps to be passed to mm2 on start.
  ///
  /// - Uses only read paths and does not attempt to update or persist assets.
  /// - If local storage already contains assets, returns those.
  /// - Otherwise, falls back to the bundled local asset provider.
  static Future<JsonList> fetchAndTransformCoinsList() async {
    _log.fine('fetchAndTransformCoinsList: start');
    // Load runtime config (from asset if available)
    final runtimeConfig = await RuntimeUpdateConfigRepository().tryLoad() ??
        const RuntimeUpdateConfig();

    // Build repository and attempt to read stored assets only
    const transformer = CoinConfigTransformer();
    final repo = CoinConfigRepository.withDefaults(
      runtimeConfig,
      transformer: transformer,
    );

    List<Asset> assets;
    if (await repo.coinConfigExists()) {
      _log.fine('Using stored assets from repository');
      assets = await repo.getAssets();
    } else {
      // Fall back to local bundled coins (no persistence)
      _log.info(
        'Stored assets not found; falling back to local bundled assets',
      );
      final localProvider = LocalAssetCoinConfigProvider.fromConfig(
        runtimeConfig,
        transformer: transformer,
      );
      assets = await localProvider.getAssets();
    }

    // Convert to raw coin config maps expected by mm2
    final configs = <JsonMap>[
      for (final asset in assets) asset.protocol.config,
    ];
    _log.fine('fetchAndTransformCoinsList: produced ${configs.length} configs');
    return JsonList.of(configs);
  }

  Map<AssetId, Asset>? _assets;
  final Map<String, Map<AssetId, Asset>> _filterCache = {};
  bool _bootstrappedFromLocal = false;
  RuntimeUpdateConfig? _runtimeConfig;

  final RuntimeUpdateConfigRepository _configRepository;
  final CoinConfigTransformer _transformer;
  final CoinConfigDataFactory _dataFactory;

  @mustCallSuper
  Future<void> init() async {
    _log.fine('init: fetching assets');
    await fetchAssets();
  }

  bool get isInitialized => _assets != null;

  Map<AssetId, Asset> get all {
    if (!isInitialized) {
      throw StateError('Assets have not been initialized. Call init() first.');
    }
    return _assets!;
  }

  Future<RuntimeUpdateConfig> _getRuntimeConfig() async {
    if (_runtimeConfig != null) return _runtimeConfig!;
    _log.fine('Loading runtime update config');
    _runtimeConfig =
        await _configRepository.tryLoad() ?? const RuntimeUpdateConfig();
    return _runtimeConfig!;
  }

  CoinConfigRepository _repoFor(RuntimeUpdateConfig config) =>
      _dataFactory.createRepository(config, _transformer);

  CoinConfigProvider _localProviderFor(RuntimeUpdateConfig config) =>
      _dataFactory.createLocalProvider(config);

  Map<AssetId, Asset> _mapAssets(List<Asset>? list) => <AssetId, Asset>{
        for (final asset in list ?? const <Asset>[]) asset.id: asset,
      };

  Future<Map<AssetId, Asset>> fetchAssets() async {
    _log.fine('fetchAssets: start');
    final runtimeConfig = await _getRuntimeConfig();
    final repo = _repoFor(runtimeConfig);

    if (_assets != null) {
      // If we previously bootstrapped from local and storage is now ready,
      // refresh memory from storage so subsequent calls use the persisted set.
      if (_bootstrappedFromLocal && await repo.coinConfigExists()) {
        _log.fine(
          'Refreshing cached assets from storage after local bootstrap',
        );
        _assets = _mapAssets(await repo.getAssets());
        _bootstrappedFromLocal = false;
      }
      _log.finer('Returning cached assets: ${_assets!.length}');
      return _assets!;
    }

    // Prefer returning cached storage if present
    if (await repo.coinConfigExists()) {
      _log.info('Storage exists; loading assets from repository');
      final mapped = _mapAssets(await repo.getAssets());
      // Trigger background update check (fire-and-forget)
      unawaited(_maybeUpdateFromRemote(repo));
      _assets = mapped;
      return mapped;
    }

    // Cold start: load from local asset then fetch and persist latest remote
    _log.info('Cold start: loading assets from local asset bundle');
    final localProvider = _localProviderFor(runtimeConfig);
    final localAssets = await localProvider.getAssets();
    final mapped = _mapAssets(localAssets);
    _assets = mapped;
    _bootstrappedFromLocal = true;

    // Fetch remote latest and upsert for next call (do not block first load)
    unawaited(() async {
      try {
        _log.fine(
          'Background refresh: fetching remote assets and latest commit',
        );
        final remoteAssets = await repo.coinConfigProvider.getAssets();
        final latestCommit = await repo.coinConfigProvider.getLatestCommit();
        await repo.upsertAssets(remoteAssets, latestCommit);
        _log.info(
          'Background refresh: updated ${remoteAssets.length} assets at commit $latestCommit',
        );
      } catch (e, s) {
        _log.warning('Background refresh failed', e, s);
      }
    }());

    return mapped;
  }

  Future<void> _maybeUpdateFromRemote(CoinConfigRepository repo) async {
    try {
      final isLatest = await repo.isLatestCommit();
      if (!isLatest) {
        _log.info('Remote commit is newer; updating coin config');
        await repo.updateCoinConfig();
        _log.fine('Coin config updated');
      } else {
        _log.fine('Already at latest commit; no update performed');
      }
    } catch (e, s) {
      _log.warning('Failed to check/update remote coin config', e, s);
    }
  }

  /// Returns the currently active coins commit hash.
  ///
  /// If storage exists, returns the stored commit. Otherwise returns the
  /// bundled coins commit from the runtime config asset, when available.
  Future<String?> getCurrentCommitHash() async {
    final runtimeConfig = await _getRuntimeConfig();
    final repo = _repoFor(runtimeConfig);

    if (await repo.coinConfigExists()) {
      final commit = await repo.getCurrentCommit();
      _log.fine('Current stored commit: $commit');
      return commit;
    }
    _log.fine(
      'No stored commit; returning bundled commit: ${runtimeConfig.bundledCoinsRepoCommit}',
    );
    return runtimeConfig.bundledCoinsRepoCommit;
  }

  /// Returns the latest commit hash available from the configured remote.
  Future<String?> getLatestCommitHash() async {
    final runtimeConfig = await _getRuntimeConfig();
    final repo = _repoFor(runtimeConfig);
    try {
      final latest = await repo.coinConfigProvider.getLatestCommit();
      _log.fine('Latest remote commit: $latest');
      return latest;
    } catch (e, s) {
      _log.warning('Failed to fetch latest commit', e, s);
      return null;
    }
  }

  /// Returns the assets filtered using the provided [strategy].
  ///
  /// This allows higher-level components, such as AssetManager to tailor
  /// the visible asset list to the active authentication context. For example,
  /// a hardware wallet may only support a subset of coins, which can be
  /// enforced by supplying an appropriate [AssetFilterStrategy].
  Map<AssetId, Asset> filteredAssets(AssetFilterStrategy strategy) {
    if (!isInitialized) {
      throw StateError('Assets have not been initialized. Call init() first.');
    }
    final cacheKey = strategy.strategyId;
    final cached = _filterCache[cacheKey];
    if (cached != null) return cached;

    final result = <AssetId, Asset>{};
    for (final entry in _assets!.entries) {
      final config = entry.value.protocol.config;
      if (strategy.shouldInclude(entry.value, config)) {
        result[entry.key] = entry.value;
      }
    }
    _filterCache[cacheKey] = result;
    _log.finer(
      'filteredAssets(${strategy.strategyId}): ${result.length} assets',
    );
    return result;
  }

  Asset? findByTicker(String ticker, CoinSubClass subClass) {
    return all.entries
        .where((e) => e.key.id == ticker && e.key.subClass == subClass)
        .map((e) => e.value)
        .firstOrNull;
  }

  Set<Asset> findVariantsOfCoin(String ticker) {
    return all.entries
        .where((e) => e.key.id == ticker)
        .map((e) => e.value)
        .toSet();
  }

  Set<Asset> findChildAssets(AssetId parentId) {
    return all.entries
        .where((e) => e.key.isChildAsset && e.key.parentId == parentId)
        .map((e) => e.value)
        .toSet();
  }
}
