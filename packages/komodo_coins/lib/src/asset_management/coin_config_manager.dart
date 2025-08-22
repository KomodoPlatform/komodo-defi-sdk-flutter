import 'dart:async';
import 'dart:collection';

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
  /// Subsequent calls are ignored if already initialized.
  Future<void> init();

  /// Gets all available assets.
  ///
  /// This method returns a map of all available assets.
  /// The map is keyed by the asset id.
  Map<AssetId, Asset> get all;

  /// Gets the current commit hash for the loaded coin configuration.
  /// This represents the commit hash of the currently active coin list.
  Future<String?> getCurrentCommitHash();

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
  factory StrategicCoinConfigManager({
    required List<CoinConfigSource> configSources,
    LoadingStrategy? loadingStrategy,
    Set<String> defaultPriorityTickers = const {},
  }) {
    return StrategicCoinConfigManager._internal(
      configSources: configSources,
      loadingStrategy: loadingStrategy ?? StorageFirstLoadingStrategy(),
      defaultPriorityTickers: defaultPriorityTickers,
    );
  }

  StrategicCoinConfigManager._internal({
    required List<CoinConfigSource> configSources,
    required LoadingStrategy loadingStrategy,
    required Set<String> defaultPriorityTickers,
  }) : _configSources = configSources,
       _loadingStrategy = loadingStrategy,
       _defaultPriorityTickers = Set.unmodifiable(defaultPriorityTickers);

  static final _logger = Logger('StrategicCoinConfigManager');

  final List<CoinConfigSource> _configSources;
  final LoadingStrategy _loadingStrategy;
  final Set<String> _defaultPriorityTickers;

  // Required by CoinConfigFallbackMixin
  @override
  List<CoinConfigSource> get configSources => _configSources;

  @override
  LoadingStrategy get loadingStrategy => _loadingStrategy;

  SplayTreeMap<AssetId, Asset>? _assets;
  final Map<String, SplayTreeMap<AssetId, Asset>> _filterCache = {};
  bool _isDisposed = false;
  bool _isInitialized = false;

  // Cache for commit hash to prevent unnecessary queries
  String? _cachedCommitHash;

  @override
  Future<void> init() async {
    _logger.fine('Initializing CoinConfigManager');

    await _validateConfigSources();

    await _loadAssets();
    // Populate commit hash cache before the manager is marked initialized
    await _populateCommitHashCacheFromSources();
    _isInitialized = true;
    _logger.fine('CoinConfigManager initialized successfully');
  }

  Future<void> _validateConfigSources() async {
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

  /// Comparator for ordering assets deterministically by their key.
  int _assetIdComparator(AssetId a, AssetId b) {
    final aIsDefault = _defaultPriorityTickers.contains(a.id);
    final bIsDefault = _defaultPriorityTickers.contains(b.id);
    if (aIsDefault != bIsDefault) {
      // Default-priority assets come first
      return aIsDefault ? -1 : 1;
    }
    return a.toString().compareTo(b.toString());
  }

  /// Maps a list of assets to an ordered SplayTreeMap keyed by AssetId
  SplayTreeMap<AssetId, Asset> _mapAssets(List<Asset> assets) {
    final map = SplayTreeMap<AssetId, Asset>(_assetIdComparator);
    for (final asset in assets) {
      map[asset.id] = asset;
    }
    return map;
  }

  /// Loads assets using the fallback mechanism
  Future<void> _loadAssets() async {
    _checkNotDisposed();

    final assets = await trySourcesInOrder(
      LoadingRequestType.initialLoad,
      (source) => source.loadAssets(),
      operationName: 'loadAssets',
    );

    _assets = _mapAssets(assets);
    _logger.info('Loaded ${assets.length} assets');
  }

  /// Populates the commit hash cache by querying available sources.
  ///
  /// This variant is safe to call during initialization, before the manager
  /// is marked as initialized. It does not assert initialization state.
  Future<void> _populateCommitHashCacheFromSources() async {
    if (_cachedCommitHash != null && _cachedCommitHash!.isNotEmpty) {
      _logger.finer('Commit hash already cached: $_cachedCommitHash');
      return;
    }

    for (final source in _configSources) {
      try {
        final commit = await source.getCurrentCommitHash();
        if (commit != null && commit.isNotEmpty) {
          _cachedCommitHash = commit;
          _logger.fine(
            'Cached commit hash from ${source.displayName}: $_cachedCommitHash',
          );
          return;
        }
      } catch (e, s) {
        _logger.fine(
          'Failed to get commit hash from ${source.displayName}',
          e,
          s,
        );
        continue;
      }
    }

    _logger.fine('No commit hash available from any source during init');
  }

  /// Refreshes assets from sources
  @override
  Future<void> refreshAssets() async {
    _checkNotDisposed();
    _assertInitialized();

    final assets = await trySourcesInOrder(
      LoadingRequestType.refreshLoad,
      (source) => source.loadAssets(),
      operationName: 'refreshAssets',
    );

    _assets = _mapAssets(assets);
    _filterCache.clear(); // Clear cache after refresh

    // Refresh commit hash cache when assets are refreshed
    _cachedCommitHash = null;

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
  Future<String?> getCurrentCommitHash() async {
    _checkNotDisposed();
    _assertInitialized();

    // Return cached commit hash if available
    if (_cachedCommitHash != null && _cachedCommitHash!.isNotEmpty) {
      _logger.finer('Returning cached commit hash: $_cachedCommitHash');
      return _cachedCommitHash;
    }

    await _populateCommitHashCacheFromSources();

    return _cachedCommitHash;
  }

  @override
  Map<AssetId, Asset> filteredAssets(AssetFilterStrategy strategy) {
    _checkNotDisposed();
    _assertInitialized();

    final cacheKey = strategy.strategyId;
    final cached = _filterCache[cacheKey];
    if (cached != null) return cached;

    final result = SplayTreeMap<AssetId, Asset>(_assetIdComparator);
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
    _cachedCommitHash = null; // Clear commit hash cache
    clearSourceHealthData(); // Clear mixin data
    _logger.fine('Disposed StrategicCoinConfigManager');
  }
}
