import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Enum for the type of loading request
enum LoadingRequestType { initialLoad, refreshLoad, fallbackLoad }

/// Strategy interface for selecting the appropriate coin configuration source
abstract class LoadingStrategy {
  /// Selects the best source for loading coin configurations
  ///
  /// Returns a list of sources in priority order for fallback handling
  Future<List<CoinConfigSource>> selectSources({
    required LoadingRequestType requestType,
    required List<CoinConfigSource> availableSources,
    required bool storageExists,
    required bool enableAutoUpdate,
  });
}

/// Represents a source for coin configuration data
abstract class CoinConfigSource {
  /// Unique identifier for this source type
  String get sourceId;

  /// Human-readable name for this source
  String get displayName;

  /// Whether this source supports the given request type
  bool supports(LoadingRequestType requestType);

  /// Load assets from this source
  Future<List<Asset>> loadAssets();

  /// Check if this source has data available
  Future<bool> isAvailable();

  /// Get the current commit hash for this source
  Future<String?> getCurrentCommitHash();
}

/// Source that loads from local storage (Hive)
class StorageCoinConfigSource implements CoinConfigSource {
  StorageCoinConfigSource({required this.repository});

  final CoinConfigRepository repository;

  @override
  String get sourceId => 'storage';

  @override
  String get displayName => 'Local Storage';

  @override
  bool supports(LoadingRequestType requestType) => true;

  @override
  Future<List<Asset>> loadAssets() => repository.getAssets();

  @override
  Future<bool> isAvailable() => repository.updatedAssetStorageExists();

  @override
  Future<String?> getCurrentCommitHash() => repository.getCurrentCommit();
}

/// Source that loads from bundled asset files
class AssetBundleCoinConfigSource implements CoinConfigSource {
  AssetBundleCoinConfigSource({required this.provider});

  final CoinConfigProvider provider;

  @override
  String get sourceId => 'asset_bundle';

  @override
  String get displayName => 'Asset Bundle';

  @override
  bool supports(LoadingRequestType requestType) {
    // Asset bundle can support all types but is typically used as fallback
    return true;
  }

  @override
  Future<List<Asset>> loadAssets() => provider.getAssets();

  @override
  Future<bool> isAvailable() async {
    try {
      await provider.getAssets();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getCurrentCommitHash() => provider.getLatestCommit();
}

/// Default strategy that prefers storage but falls back to asset bundle
class StorageFirstLoadingStrategy implements LoadingStrategy {
  @override
  Future<List<CoinConfigSource>> selectSources({
    required LoadingRequestType requestType,
    required List<CoinConfigSource> availableSources,
    required bool storageExists,
    required bool enableAutoUpdate,
  }) async {
    final sources = <CoinConfigSource>[];

    // Find storage and asset bundle sources
    final storageSource =
        availableSources.whereType<StorageCoinConfigSource>().firstOrNull;
    final assetBundleSource =
        availableSources.whereType<AssetBundleCoinConfigSource>().firstOrNull;

    switch (requestType) {
      case LoadingRequestType.initialLoad:
        // Prefer storage if it exists, otherwise use asset bundle
        if (storageExists && storageSource != null) {
          sources.add(storageSource);
        }
        if (assetBundleSource != null) {
          sources.add(assetBundleSource);
        }

      case LoadingRequestType.refreshLoad:
        // For refresh, always try storage first if available
        if (storageSource != null) {
          sources.add(storageSource);
        }
        if (assetBundleSource != null) {
          sources.add(assetBundleSource);
        }

      case LoadingRequestType.fallbackLoad:
        // For fallback, prefer asset bundle as it's more reliable
        if (assetBundleSource != null) {
          sources.add(assetBundleSource);
        }
        if (storageSource != null) {
          sources.add(storageSource);
        }
    }

    return sources;
  }
}

/// Strategy that prefers asset bundle over storage (useful for testing)
class AssetBundleFirstLoadingStrategy implements LoadingStrategy {
  @override
  Future<List<CoinConfigSource>> selectSources({
    required LoadingRequestType requestType,
    required List<CoinConfigSource> availableSources,
    required bool storageExists,
    required bool enableAutoUpdate,
  }) async {
    final sources = <CoinConfigSource>[];

    // Find sources
    final storageSource =
        availableSources.whereType<StorageCoinConfigSource>().firstOrNull;
    final assetBundleSource =
        availableSources.whereType<AssetBundleCoinConfigSource>().firstOrNull;

    // Always prefer asset bundle first
    if (assetBundleSource != null) {
      sources.add(assetBundleSource);
    }
    if (storageSource != null) {
      sources.add(storageSource);
    }

    return sources;
  }
}
