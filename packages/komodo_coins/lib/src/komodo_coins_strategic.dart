import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_coins/src/asset_management/_asset_management_index.dart';
import 'package:komodo_coins/src/update_management/_update_management_index.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Modern implementation of KomodoCoins using strategy pattern for separation of concerns
class StrategicKomodoCoins {
  StrategicKomodoCoins({
    RuntimeUpdateConfigRepository? configRepository,
    CoinConfigTransformer? transformer,
    CoinConfigDataFactory? dataFactory,
    LoadingStrategy? loadingStrategy,
    UpdateStrategy? updateStrategy,
    this.enableAutoUpdate = true,
  })  : _configRepository = configRepository ?? RuntimeUpdateConfigRepository(),
        _transformer = transformer ?? const CoinConfigTransformer(),
        _dataFactory = dataFactory ?? const DefaultCoinConfigDataFactory(),
        _loadingStrategy = loadingStrategy ?? StorageFirstLoadingStrategy(),
        _updateStrategy = updateStrategy ?? const BackgroundUpdateStrategy();

  static final Logger _log = Logger('StrategicKomodoCoins');

  /// Whether to automatically update coin configurations from remote sources.
  final bool enableAutoUpdate;

  final RuntimeUpdateConfigRepository _configRepository;
  final CoinConfigTransformer _transformer;
  final CoinConfigDataFactory _dataFactory;
  final LoadingStrategy _loadingStrategy;
  final UpdateStrategy _updateStrategy;

  RuntimeUpdateConfig? _runtimeConfig;
  CoinConfigManager? _assetsManager;
  CoinUpdateManager? _updatesManager;

  /// Asset management operations (fetching, caching, filtering)
  CoinConfigManager get assets {
    if (_assetsManager == null) {
      throw StateError(
        'KomodoCoins has not been initialized. Call init() first.',
      );
    }
    return _assetsManager!;
  }

  /// Update management operations (checking for updates, syncing)
  CoinUpdateManager get updates {
    if (_updatesManager == null) {
      throw StateError(
        'KomodoCoins has not been initialized. Call init() first.',
      );
    }
    return _updatesManager!;
  }

  bool get isInitialized => _assetsManager != null && _updatesManager != null;

  /// Fetches the list of coin configuration maps to be passed to mm2 on start.
  ///
  /// Static method that maintains compatibility with the original API.
  /// Uses only read paths and does not attempt to update or persist assets.
  static Future<JsonList> fetchAndTransformCoinsList() async {
    return retry(
      _fetchAndTransformCoinsListInternal,
      maxAttempts: 3,
      onRetry: (attempt, error, delay) {
        _log.warning(
          'fetchAndTransformCoinsList attempt $attempt failed, retrying after $delay: $error',
        );
      },
      shouldRetry: (error) {
        // Retry on most errors except for critical state errors
        if (error is StateError || error is ArgumentError) {
          return false;
        }
        return true;
      },
    );
  }

  static Future<JsonList> _fetchAndTransformCoinsListInternal() async {
    _log.fine('_fetchAndTransformCoinsListInternal: start');

    try {
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
      _log.fine(
        '_fetchAndTransformCoinsListInternal: produced ${configs.length} configs',
      );
      return JsonList.of(configs);
    } catch (e, s) {
      _log.warning('_fetchAndTransformCoinsListInternal failed', e, s);

      // Clear storage before rethrowing for retry
      try {
        final runtimeConfig = await RuntimeUpdateConfigRepository().tryLoad() ??
            const RuntimeUpdateConfig();
        const transformer = CoinConfigTransformer();
        final repo = CoinConfigRepository.withDefaults(
          runtimeConfig,
          transformer: transformer,
        );
        await repo.deleteAllAssets();
        _log.fine('Cleared persisted storage for static method retry');
      } catch (clearError, clearStack) {
        _log.warning(
          'Failed to clear persisted storage for static method retry',
          clearError,
          clearStack,
        );
        // Don't rethrow - we still want to attempt the retry
      }

      rethrow;
    }
  }

  @mustCallSuper
  Future<void> init() async {
    _log.fine('Initializing StrategicKomodoCoins');

    final runtimeConfig = await _getRuntimeConfig();

    // Create sources for the config manager
    final sources = await _createConfigSources(runtimeConfig);

    // Initialize asset manager
    _assetsManager = StrategicCoinConfigManager(
      configSources: sources,
      loadingStrategy: _loadingStrategy,
      enableAutoUpdate: enableAutoUpdate,
    );

    // Initialize update manager
    final repository =
        _dataFactory.createRepository(runtimeConfig, _transformer);
    final localProvider = _dataFactory.createLocalProvider(runtimeConfig);
    _updatesManager = StrategicCoinUpdateManager(
      repository: repository,
      updateStrategy: enableAutoUpdate ? _updateStrategy : NoUpdateStrategy(),
      fallbackProvider: localProvider,
    );

    // Initialize both managers
    await Future.wait([
      _assetsManager!.init(),
      _updatesManager!.init(),
    ]);

    // Start background updates if enabled
    if (enableAutoUpdate) {
      _updatesManager!.startBackgroundUpdates();
    }

    _log.fine('StrategicKomodoCoins initialized successfully');
  }

  Future<RuntimeUpdateConfig> _getRuntimeConfig() async {
    if (_runtimeConfig != null) return _runtimeConfig!;
    _log.fine('Loading runtime update config');
    _runtimeConfig =
        await _configRepository.tryLoad() ?? const RuntimeUpdateConfig();
    return _runtimeConfig!;
  }

  /// Creates configuration sources based on the runtime config
  Future<List<CoinConfigSource>> _createConfigSources(
    RuntimeUpdateConfig config,
  ) async {
    final sources = <CoinConfigSource>[];

    // Add storage source
    final repository = _dataFactory.createRepository(config, _transformer);
    sources.add(StorageCoinConfigSource(repository: repository));

    // Add local asset bundle source
    final localProvider = _dataFactory.createLocalProvider(config);
    sources.add(AssetBundleCoinConfigSource(provider: localProvider));

    return sources;
  }

  /// Convenience method to get all assets (for backward compatibility)
  Map<AssetId, Asset> get all => assets.all;

  /// Convenience method for filtered assets (for backward compatibility)
  Map<AssetId, Asset> filteredAssets(AssetFilterStrategy strategy) =>
      assets.filteredAssets(strategy);

  /// Convenience method to find by ticker (for backward compatibility)
  Asset? findByTicker(String ticker, CoinSubClass subClass) =>
      assets.findByTicker(ticker, subClass);

  /// Convenience method to find variants (for backward compatibility)
  Set<Asset> findVariantsOfCoin(String ticker) =>
      assets.findVariantsOfCoin(ticker);

  /// Convenience method to find child assets (for backward compatibility)
  Set<Asset> findChildAssets(AssetId parentId) =>
      assets.findChildAssets(parentId);

  /// Returns the currently active coins commit hash.
  Future<String?> getCurrentCommitHash() => updates.getCurrentCommitHash();

  /// Returns the latest commit hash available from the configured remote.
  Future<String?> getLatestCommitHash() => updates.getLatestCommitHash();

  /// Checks if an update is available
  Future<bool> isUpdateAvailable() => updates.isUpdateAvailable();

  /// Performs an immediate update
  Future<UpdateResult> updateNow() => updates.updateNow();

  /// Stream of update results for monitoring
  Stream<UpdateResult> get updateStream => updates.updateStream;

  /// Disposes of all resources
  Future<void> dispose() async {
    await Future.wait([
      if (_assetsManager != null) _assetsManager!.dispose(),
      if (_updatesManager != null) _updatesManager!.dispose(),
    ]);

    _assetsManager = null;
    _updatesManager = null;
    _runtimeConfig = null;

    _log.fine('Disposed StrategicKomodoCoins');
  }
}
