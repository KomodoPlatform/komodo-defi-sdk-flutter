import 'dart:async';
import 'dart:ui_web' show AssetManager;

import 'package:flutter/foundation.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_coins/src/repository/runtime_update_config_repository.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A high-level library that provides a simple way to access Komodo Platform
/// coin data and seed nodes.
///
/// NB: [init] must be called before accessing any assets.
typedef CoinConfigRepositoryBuilder = CoinConfigRepository Function(
  RuntimeUpdateConfig config,
  CoinConfigTransformer transformer,
);

typedef LocalProviderBuilder = CoinConfigProvider Function(
  RuntimeUpdateConfig config,
);

class KomodoCoins {
  KomodoCoins({
    RuntimeUpdateConfigRepository? configRepository,
    CoinConfigTransformer? transformer,
    CoinConfigRepositoryBuilder? repositoryBuilder,
    LocalProviderBuilder? localProviderBuilder,
  })  : _configRepository = configRepository ?? RuntimeUpdateConfigRepository(),
        _transformer = transformer ?? const CoinConfigTransformer(),
        _repositoryBuilder = repositoryBuilder ??
            ((config, transformer) => CoinConfigRepository.withDefaults(
                  config,
                  transformer: transformer,
                )),
        _localProviderBuilder =
            localProviderBuilder ?? LocalAssetCoinConfigProvider.fromConfig;

  /// Creates an instance of [KomodoCoins] and initializes it.
  static Future<KomodoCoins> create() async {
    final instance = KomodoCoins();
    await instance.init();
    return instance;
  }

  /// Fetches the list of coin configuration maps to be passed to mm2 on start.
  ///
  /// - Uses only read paths and does not attempt to update or persist assets.
  /// - If local storage already contains assets, returns those.
  /// - Otherwise, falls back to the bundled local asset provider.
  static Future<JsonList> fetchAndTransformCoinsList() async {
    // Load runtime config (from asset if available)
    final runtimeConfig = await RuntimeUpdateConfigRepository().tryLoad() ??
        RuntimeUpdateConfig.withDefaults();

    // Build repository and attempt to read stored assets only
    const transformer = CoinConfigTransformer();
    final repo = CoinConfigRepository.withDefaults(
      runtimeConfig,
      transformer: transformer,
    );

    List<Asset> assets;
    if (await repo.coinConfigExists()) {
      assets = await repo.getAssets() ?? const <Asset>[];
    } else {
      // Fall back to local bundled coins (no persistence)
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
    return JsonList.of(configs);
  }

  Map<AssetId, Asset>? _assets;
  final Map<String, Map<AssetId, Asset>> _filterCache = {};
  bool _bootstrappedFromLocal = false;

  final RuntimeUpdateConfigRepository _configRepository;
  final CoinConfigTransformer _transformer;
  final CoinConfigRepositoryBuilder _repositoryBuilder;
  final LocalProviderBuilder _localProviderBuilder;

  @mustCallSuper
  Future<void> init() async {
    await fetchAssets();
  }

  bool get isInitialized => _assets != null;

  Map<AssetId, Asset> get all {
    if (!isInitialized) {
      throw StateError('Assets have not been initialized. Call init() first.');
    }
    return _assets!;
  }

  Future<Map<AssetId, Asset>> fetchAssets() async {
    // Load runtime config (from asset if available)
    final runtimeConfig =
        await _configRepository.tryLoad() ?? RuntimeUpdateConfig.withDefaults();

    final repo = _repositoryBuilder(runtimeConfig, _transformer);

    if (_assets != null) {
      // If we previously bootstrapped from local and storage is now ready,
      // refresh memory from storage so subsequent calls use the persisted set.
      if (_bootstrappedFromLocal && await repo.coinConfigExists()) {
        final refreshed = await repo.getAssets();
        final mapped = <AssetId, Asset>{
          for (final asset in refreshed ?? const <Asset>[]) asset.id: asset,
        };
        _assets = mapped;
        _bootstrappedFromLocal = false;
      }
      return _assets!;
    }

    // Prefer returning cached storage if present
    if (await repo.coinConfigExists()) {
      final list = await repo.getAssets();
      // Trigger background update check (fire-and-forget)
      unawaited(_maybeUpdateFromRemote(repo));
      final mapped = <AssetId, Asset>{
        for (final asset in list ?? const <Asset>[]) asset.id: asset,
      };
      _assets = mapped;
      return mapped;
    }

    // Cold start: load from local asset then fetch and persist latest remote
    final localProvider = _localProviderBuilder(runtimeConfig);
    final localAssets = await localProvider.getAssets();
    final mapped = <AssetId, Asset>{
      for (final asset in localAssets) asset.id: asset,
    };
    _assets = mapped;
    _bootstrappedFromLocal = true;

    // Fetch remote latest and upsert for next call (do not block first load)
    unawaited(() async {
      try {
        final remoteAssets = await repo.coinConfigProvider.getAssets();
        final latestCommit = await repo.coinConfigProvider.getLatestCommit();
        await repo.upsertAssets(remoteAssets, latestCommit);
      } catch (_) {}
    }());

    return mapped;
  }

  Future<void> _maybeUpdateFromRemote(CoinConfigRepository repo) async {
    try {
      final isLatest = await repo.isLatestCommit();
      if (!isLatest) {
        await repo.updateCoinConfig();
      }
    } catch (_) {}
  }

  // Removed unused helper to satisfy lints after refactor

  /// Returns the assets filtered using the provided [strategy].
  ///
  /// This allows higher-level components, such as [AssetManager], to tailor
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
    return result;
  }

  // Helper methods
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
