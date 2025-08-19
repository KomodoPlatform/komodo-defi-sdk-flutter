import 'dart:async';

import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_coins/src/asset_management/coin_config_fallback_mixin.dart';
import 'package:komodo_coins/src/asset_management/loading_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Interface defining the contract for coin configuration management operations
abstract class CoinConfigManager {
  /// Initializes the coin config manager.
  ///
  /// This method should be called before any other methods are called.
  /// It is responsible for loading the initial assets and setting up the
  /// manager.
  ///
  /// Performs the following steps:
  /// 1. Validates the sources
  /// 2. Loads the initial assets
  /// 3. Sets the manager to initialized
  ///
  /// Throws a [StateError] if the manager is already initialized.
  Future<void> init();

  /// Gets all available assets.
  ///
  /// This method returns a map of all available assets.
  /// The map is keyed by the asset id.
  Map<AssetId, Asset> get all;

  /// Refreshes assets from sources
  Future<void> refreshAssets();

  /// Returns filtered assets using the provided strategy
  Map<AssetId, Asset> filteredAssets(AssetFilterStrategy strategy);

  /// Finds an asset by ticker and subclass
  Asset? findByTicker(String ticker, CoinSubClass subClass);

  /// Finds all variants of a coin by ticker
  Set<Asset> findVariantsOfCoin(String ticker);

  /// Finds child assets of a parent asset
  Set<Asset> findChildAssets(AssetId parentId);

  /// Checks if the manager is initialized
  bool get isInitialized;

  /// Disposes of all resources
  Future<void> dispose();
}

/// Implementation of [CoinConfigManager] that uses strategy pattern for loading
class StrategicCoinConfigManager
    with CoinConfigFallbackMixin
    implements CoinConfigManager {
  StrategicCoinConfigManager({
    required List<CoinConfigSource> configSources,
    LoadingStrategy? loadingStrategy,
    this.enableAutoUpdate = true,
  })  : _configSources = configSources,
        _loadingStrategy = loadingStrategy ?? StorageFirstLoadingStrategy();

  static final _logger = Logger('StrategicCoinConfigManager');

  final List<CoinConfigSource> _configSources;
  final LoadingStrategy _loadingStrategy;
  final bool enableAutoUpdate;

  // Required by CoinConfigFallbackMixin
  @override
  List<CoinConfigSource> get configSources => _configSources;

  @override
  LoadingStrategy get loadingStrategy => _loadingStrategy;

  Map<AssetId, Asset>? _assets;
  final Map<String, Map<AssetId, Asset>> _filterCache = {};
  bool _isDisposed = false;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    _logger.fine('Initializing CoinConfigManager');

    // Validate sources
    for (final source in _configSources) {
      try {
        final isAvailable = await source.isAvailable();
        _logger.finer(
          'Source ${source.displayName} availability: $isAvailable',
        );
      } catch (e, s) {
        _logger.warning(
          'Failed to check availability for source ${source.displayName}',
          e,
          s,
        );
      }
    }

    // Load initial assets
    await _loadAssets();
    _isInitialized = true;
    _logger.fine('CoinConfigManager initialized successfully');
  }

  /// Validates that the manager hasn't been disposed
  void _checkNotDisposed() {
    if (_isDisposed) {
      _logger.warning('Attempted to use manager after dispose');
      throw StateError('CoinConfigManager has been disposed');
    }
  }

  /// Validates that the manager has been initialized
  void _assertInitialized() {
    if (!_isInitialized) {
      _logger.warning('Attempted to use manager before initialization');
      throw StateError('CoinConfigManager must be initialized before use');
    }
  }

  /// Maps a list of assets to a map keyed by AssetId
  Map<AssetId, Asset> _mapAssets(List<Asset> assets) => <AssetId, Asset>{
        for (final asset in assets) asset.id: asset,
      };

  /// Determines if storage exists by checking storage sources
  Future<bool> _storageExists() async {
    for (final source in _configSources) {
      if (source is StorageCoinConfigSource) {
        try {
          return await source.isAvailable();
        } catch (_) {
          continue;
        }
      }
    }
    return false;
  }

  /// Loads assets using the fallback mechanism
  Future<void> _loadAssets() async {
    _checkNotDisposed();

    final storageExists = await _storageExists();

    final assets = await trySourcesInOrder(
      LoadingRequestType.initialLoad,
      (source) => source.loadAssets(),
      operationName: 'loadAssets',
      storageExists: storageExists,
      enableAutoUpdate: enableAutoUpdate,
    );

    _assets = _mapAssets(assets);
    _logger.info('Loaded ${assets.length} assets');
  }

  /// Refreshes assets from sources
  @override
  Future<void> refreshAssets() async {
    _checkNotDisposed();
    _assertInitialized();

    final storageExists = await _storageExists();

    final assets = await trySourcesInOrder(
      LoadingRequestType.refreshLoad,
      (source) => source.loadAssets(),
      operationName: 'refreshAssets',
      storageExists: storageExists,
      enableAutoUpdate: enableAutoUpdate,
    );

    _assets = _mapAssets(assets);
    _filterCache.clear(); // Clear cache after refresh
    _logger.info('Refreshed ${assets.length} assets');
  }

  @override
  bool get isInitialized => _isInitialized && _assets != null;

  @override
  Map<AssetId, Asset> get all {
    _checkNotDisposed();
    _assertInitialized();
    return _assets!;
  }

  @override
  Map<AssetId, Asset> filteredAssets(AssetFilterStrategy strategy) {
    _checkNotDisposed();
    _assertInitialized();

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
    _logger.finer(
      'filteredAssets(${strategy.strategyId}): ${result.length} assets',
    );
    return result;
  }

  @override
  Asset? findByTicker(String ticker, CoinSubClass subClass) {
    _checkNotDisposed();
    _assertInitialized();

    return all.entries
        .where((e) => e.key.id == ticker && e.key.subClass == subClass)
        .map((e) => e.value)
        .firstOrNull;
  }

  @override
  Set<Asset> findVariantsOfCoin(String ticker) {
    _checkNotDisposed();
    _assertInitialized();

    return all.entries
        .where((e) => e.key.id == ticker)
        .map((e) => e.value)
        .toSet();
  }

  @override
  Set<Asset> findChildAssets(AssetId parentId) {
    _checkNotDisposed();
    _assertInitialized();

    return all.entries
        .where((e) => e.key.isChildAsset && e.key.parentId == parentId)
        .map((e) => e.value)
        .toSet();
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _isInitialized = false;
    _assets = null;
    _filterCache.clear();
    clearSourceHealthData(); // Clear mixin data
    _logger.fine('Disposed StrategicCoinConfigManager');
  }
}
