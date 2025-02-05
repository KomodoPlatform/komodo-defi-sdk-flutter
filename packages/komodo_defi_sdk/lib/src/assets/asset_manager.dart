// lib/src/assets/asset_manager.dart

import 'dart:async';
import 'dart:collection';

import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/sdk/komodo_defi_sdk_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

typedef AssetIdMap = SplayTreeMap<AssetId, Asset>;

/// Manages the lifecycle and state of crypto assets in the Komodo DeFi Framework.
///
/// The AssetManager is responsible for:
/// * Tracking available assets
/// * Managing asset activation state
/// * Handling automatic activation of assets
/// * Maintaining asset ordering and grouping
///
/// ## Usage
///
/// ```dart
/// final assetManager = sdk.assets;
///
/// // Find an asset
/// final btcAssets = assetManager.findAssetsByTicker('BTC');
///
/// // Activate an asset
/// await assetManager.activateAsset(btcAssets.first).last;
///
/// // Get all activated assets
/// final activeAssets = await assetManager.getActivatedAssets();
/// ```
class AssetManager implements IAssetProvider {
  /// Creates a new instance of AssetManager.
  ///
  /// This is typically created by the SDK and shouldn't need to be instantiated
  /// directly.
  AssetManager(
    this._client,
    this._auth,
    this._config,
  ) : _assetHistory = AssetHistoryStorage();

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final KomodoDefiSdkConfig _config;
  final AssetHistoryStorage _assetHistory;

  ActivationManager? _activationManager;

  /// Set the activation manager after construction to handle circular dependency
  void setActivationManager(ActivationManager manager) {
    if (_activationManager != null) {
      throw StateError('ActivationManager has already been set');
    }
    _activationManager = manager;
  }

  /// Gets the activation manager, throwing if not set
  ActivationManager get _activation {
    if (_activationManager == null) {
      throw StateError(
        'ActivationManager not set. Ensure setActivationManager() is called during initialization.',
      );
    }
    return _activationManager!;
  }

  final Map<AssetId, Completer<void>> _activationCompleters = {};
  final Set<AssetId> _activeAssetIds = {};
  final KomodoCoins _coins = KomodoCoins();

  StreamSubscription<KdfUser?>? _authSubscription;

  late final AssetIdMap _orderedCoins;

  /// Initializes the asset manager.
  ///
  /// This is called automatically by the SDK and shouldn't need to be called
  /// manually.
  Future<void> init() async {
    await _coins.init();

    _orderedCoins = AssetIdMap((keyA, keyB) {
      final isDefaultA = _config.defaultAssets.contains(keyA.id);
      final isDefaultB = _config.defaultAssets.contains(keyB.id);

      if (isDefaultA != isDefaultB) {
        return isDefaultA ? -1 : 1;
      }

      return keyA.toString().compareTo(keyB.toString());
    });

    _orderedCoins.addAll(_coins.all);

    await initTickerIndex();

    final currentUser = await _auth.currentUser;
    await _onAuthStateChanged(currentUser);

    _authSubscription = _auth.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Activates a specific asset, making it available for use.
  ///
  /// Returns a stream of [ActivationProgress] updates during the activation process.
  ///
  /// Example:
  /// ```dart
  /// final asset = assetManager.findAssetsByTicker('BTC').first;
  /// await for (final progress in assetManager.activateAsset(asset)) {
  ///   print('Activation progress: ${progress.status}');
  /// }
  /// ```
  Stream<ActivationProgress> activateAsset(Asset asset) {
    return _activation.activateAsset(asset);
  }

  /// Returns an asset by its [AssetId], if available.
  ///
  /// Returns null if no matching asset is found.
  /// Throws [StateError] if called before initialization.
  @override
  Asset? fromId(AssetId id) => _coins.isInitialized
      ? available[id]
      : throw StateError(
          'Assets have not been initialized. Call init() first.',
        );

  /// Returns all available assets, ordered by priority.
  ///
  /// Default assets (configured in [KomodoDefiSdkConfig]) appear first,
  /// followed by other assets in alphabetical order.
  @override
  Map<AssetId, Asset> get available => _orderedCoins;
  Map<AssetId, Asset> get availableOrdered => available;

  /// Returns currently activated assets for the signed-in user.
  ///
  /// Returns an empty list if no user is signed in.
  @override
  Future<List<Asset>> getActivatedAssets() async {
    if (!await _auth.isSignedIn()) return [];

    final enabledCoins = await getEnabledCoins();
    return enabledCoins.expand(findAssetsByTicker).toList();
  }

  /// Returns the set of enabled coin tickers for the current user.
  ///
  /// Returns an empty set if no user is signed in.
  @override
  Future<Set<String>> getEnabledCoins() async {
    if (!await _auth.isSignedIn()) return {};

    final enabled = await _client.rpc.generalActivation.getEnabledCoins();
    return enabled.result.map((e) => e.ticker).toSet();
  }

  Future<void> _handlePreActivation(KdfUser user) async {
    final assetsToActivate = <Asset>{};

    if (_config.preActivateDefaultAssets) {
      for (final ticker in _config.defaultAssets) {
        final assets = findAssetsByTicker(ticker)
            .where((asset) => !_activeAssetIds.contains(asset.id));
        assetsToActivate.addAll(assets);
      }
    }

    if (_config.preActivateHistoricalAssets) {
      final historical = await _assetHistory.getWalletAssets(user.walletId);
      for (final ticker in historical) {
        final assets = findAssetsByTicker(ticker)
            .where((asset) => !_activeAssetIds.contains(asset.id));
        assetsToActivate.addAll(assets);
      }
    }

    final validAssets = assetsToActivate
        .where((asset) => asset.isCompatibleWith(user.authOptions))
        .toList();

    await for (final progress
        in _activationManager!.activateAssets(validAssets)) {
      if (progress.isComplete && !progress.isSuccess) {
        final assetToRetry = validAssets.firstWhere(
          (asset) => !_activeAssetIds.contains(asset.id),
          orElse: () => throw StateError('No asset found for retry'),
        );

        var attempts = 0;
        while (attempts < _config.maxPreActivationAttempts) {
          try {
            await activateAsset(assetToRetry).last;
            break;
          } catch (e) {
            attempts++;
            if (attempts < _config.maxPreActivationAttempts) {
              await Future<void>.delayed(_config.activationRetryDelay);
            }
          }
        }
      }
    }
  }

  Future<void> _onAuthStateChanged(KdfUser? user) async {
    if (user == null) {
      _activeAssetIds.clear();
      return;
    }

    final enabledCoins = await getEnabledCoins();
    for (final ticker in enabledCoins) {
      _activeAssetIds.addAll(
        findAssetsByTicker(ticker).map((asset) => asset.id),
      );
    }

    await _handlePreActivation(user);
  }

  /// Finds all assets matching the given ticker symbol.
  ///
  /// Example:
  /// ```dart
  /// final ethAssets = assetManager.findAssetsByTicker('ETH');
  /// for (final asset in ethAssets) {
  ///   print('${asset.id.name} on ${asset.protocol.subClass.formatted}');
  /// }
  /// ```
  @override
  Set<Asset> findAssetsByTicker(String ticker) {
    return available.values.where((asset) => asset.id.id == ticker).toSet();
  }

  /// Returns child assets for the given parent asset ID.
  ///
  /// For example, this can be used to find all tokens on a particular chain.
  ///
  /// Example:
  /// ```dart
  /// final ethId = assetManager.findAssetsByTicker('ETH').first.id;
  /// final erc20Tokens = assetManager.childAssetsOf(ethId);
  /// ```
  @override
  Set<Asset> childAssetsOf(AssetId parentId) {
    return available.values
        .where(
          (asset) => asset.id.isChildAsset && asset.id.parentId == parentId,
        )
        .toSet();
  }

  /// Disposes of the asset manager, cleaning up resources.
  ///
  /// This is called automatically by the SDK when disposing.
  Future<void> dispose() async {
    _activationCompleters.clear();
    await _authSubscription?.cancel();
  }
}

class _AssetGroup {
  _AssetGroup({
    required this.primary,
    required this.children,
  });

  final Asset primary;
  final List<Asset> children;
}
