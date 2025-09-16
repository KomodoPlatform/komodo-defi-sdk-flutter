// TODO: refactor to rely on komodo_coins cache instead of duplicating the
// splaytreemap cache here. This turns it into a thinner wrapper than it
// already is.
import 'dart:async' show StreamSubscription, unawaited;
import 'dart:collection';

import 'package:flutter/foundation.dart' show ValueGetter, debugPrint;
import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
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
/// Note: The actual asset activation is handled by the internal
/// [ActivationManager] which is not publicly exposed by design.
/// The [AssetManager] provides proxy methods for backward compatibility.
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
///
/// The manager listens to authentication changes to keep the available asset
/// list in sync with the active wallet's capabilities.
class AssetManager implements IAssetProvider, IAssetRefreshNotifier {
  /// Creates a new instance of AssetManager.
  ///
  /// This is typically created by the SDK and shouldn't need to be instantiated
  /// directly.
  AssetManager(
    this._client,
    this._auth,
    this._config,
    this._customAssetHistory,
    this._activationManager,
    this._coins,
  ) {
    _authSubscription = _auth.authStateChanges.listen(_handleAuthStateChange);
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final KomodoDefiSdkConfig _config;
  final CustomAssetHistoryStorage _customAssetHistory;
  final AssetsUpdateManager _coins;
  late final AssetIdMap _orderedCoins;
  StreamSubscription<KdfUser?>? _authSubscription;
  bool _isDisposed = false;
  AssetFilterStrategy? _currentFilterStrategy;

  /// NB: This cannot be used during initialization. This is a workaround
  /// to publicly expose the activation manager's activation methods.
  /// See [activateAsset] and [activateAssets] for more details.
  final ValueGetter<ActivationManager> _activationManager;

  /// Initializes the asset manager.
  ///
  /// This is called automatically by the SDK and shouldn't need to be called
  /// manually.
  Future<void> init() async {
    await _coins.init(defaultPriorityTickers: _config.defaultAssets);

    _orderedCoins = AssetIdMap((keyA, keyB) {
      final isDefaultA = _config.defaultAssets.contains(keyA.id);
      final isDefaultB = _config.defaultAssets.contains(keyB.id);

      if (isDefaultA != isDefaultB) {
        return isDefaultA ? -1 : 1;
      }

      return keyA.toString().compareTo(keyB.toString());
    });

    _refreshCoins(const NoAssetFilterStrategy());

    await _refreshCustomTokens();
  }

  /// Exposes the currently active commit hash for coins config.
  Future<String?> get currentCoinsCommit async => _coins.getCurrentCommitHash();

  /// Exposes the latest available commit hash for coins config.
  Future<String?> get latestCoinsCommit async => _coins.getLatestCommitHash();

  void _refreshCoins(AssetFilterStrategy strategy) {
    _orderedCoins
      ..clear()
      ..addAll(_coins.filteredAssets(strategy));
  }

  /// Applies a new [strategy] for filtering available assets.
  ///
  /// This is called whenever the authentication state changes so the
  /// visible asset list always matches the capabilities of the active wallet.
  void setFilterStrategy(AssetFilterStrategy strategy) {
    if (_currentFilterStrategy?.strategyId == strategy.strategyId) return;

    _currentFilterStrategy = strategy;
    if (_coins.isInitialized) {
      _refreshCoins(strategy);
      // Also refresh custom tokens to apply the new filter strategy
      unawaited(_refreshCustomTokens());
    }
  }

  Future<void> _refreshCustomTokens() async {
    final user = await _auth.currentUser;
    if (user == null) {
      debugPrint('No user signed in, skipping custom token refresh');
      return;
    }

    // Drop previously injected custom tokens to avoid stale entries
    final toRemove = <AssetId>[];
    _orderedCoins.forEach((id, asset) {
      if (asset.protocol.isCustomToken) toRemove.add(id);
    });
    for (final id in toRemove) {
      _orderedCoins.remove(id);
    }

    final customTokens = await _customAssetHistory.getWalletAssets(
      user.walletId,
      _orderedCoins.keys.toSet(),
    );

    final filteredCustomTokens = _filterCustomTokens(customTokens);

    for (final customToken in filteredCustomTokens) {
      _orderedCoins[customToken.id] = customToken;
    }
  }

  /// Reacts to authentication changes by updating the active asset filter.
  ///
  /// When a hardware wallet such as Trezor is connected we limit the list of
  /// available assets to only those explicitly supported by that wallet.
  void _handleAuthStateChange(KdfUser? user) {
    if (_isDisposed) return;

    final isTrezor =
        user?.walletId.authOptions.privKeyPolicy ==
        const PrivateKeyPolicy.trezor();

    // Trezor does not support all assets yet, so we apply a filter here
    // to only show assets that are compatible with Trezor.
    // WalletConnect and Metamask will require similar handling in the future.
    final strategy = isTrezor
        ? const TrezorAssetFilterStrategy(hiddenAssets: {'BCH'})
        : const NoAssetFilterStrategy();

    setFilterStrategy(strategy);
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
  Map<AssetId, Asset> get available => Map.unmodifiable(_orderedCoins);
  Map<AssetId, Asset> get availableOrdered => available;

  /// Returns currently activated assets for the signed-in user.
  ///
  /// Returns an empty list if no user is signed in.
  @override
  Future<List<Asset>> getActivatedAssets() async {
    final enabled = await getEnabledCoins();
    return enabled.expand(findAssetsByConfigId).toList();
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

  /// Finds all assets matching the given ID String (as is in the coins config).
  ///
  /// Example:
  /// ```dart
  /// final ethAssets = assetManager.findAssetsByTicker('ETH');
  /// for (final asset in ethAssets) {
  ///   print('${asset.id.name} on ${asset.protocol.subClass.formatted}');
  /// }
  /// ```
  @override
  Set<Asset> findAssetsByConfigId(String ticker) {
    // Create a defensive copy to prevent concurrent modification during iteration
    final assetsCopy = List<Asset>.of(_orderedCoins.values);
    return assetsCopy.where((asset) => asset.id.id == ticker).toSet();
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
    // Create a defensive copy to prevent concurrent modification during iteration
    final assetsCopy = List<Asset>.of(_orderedCoins.values);
    return assetsCopy
        .where(
          (asset) => asset.id.isChildAsset && asset.id.parentId == parentId,
        )
        .toSet();
  }

  /// Activates a single asset.
  ///
  /// This is a proxy method that delegates to the internal [ActivationManager]
  /// for backward compatibility. The [ActivationManager] is not publicly
  /// exposed by design.
  ///
  /// This method may be removed in the future, as the goal is to handle all
  /// activation logic internally and seamlessly.
  ///
  /// Returns a stream of [ActivationProgress] updates.
  Stream<ActivationProgress> activateAsset(Asset asset) =>
      _activationManager().activateAsset(asset);

  /// Activates multiple assets at once.
  ///
  /// This is a proxy method that delegates to the internal [ActivationManager]
  /// for backward compatibility. The [ActivationManager] is not publicly
  /// exposed by design.
  ///
  /// This method may be removed in the future, as the goal is to handle all
  /// activation logic internally and seamlessly.
  ///
  /// Returns a stream of [ActivationProgress] updates.
  Stream<ActivationProgress> activateAssets(List<Asset> assets) =>
      _activationManager().activateAssets(assets);

  @override
  void notifyCustomTokensChanged() {
    // Refresh custom tokens when notified by the activation manager
    unawaited(
      _refreshCustomTokens().catchError((Object e, StackTrace s) {
        debugPrint('Custom token refresh failed: $e');
      }),
    );
  }

  /// Filters custom tokens based on the current asset filtering strategy.
  ///
  /// Custom tokens don't have traditional coin configs, so we create a minimal
  /// config structure to support filtering decisions. This ensures custom tokens
  /// are properly filtered alongside regular assets.
  Set<Asset> _filterCustomTokens(Set<Asset> customTokens) {
    final strategy = _currentFilterStrategy;
    if (strategy == null) return customTokens;

    return customTokens.where((Asset token) {
      return strategy.shouldInclude(token, token.protocol.config);
    }).toSet();
  }

  /// Disposes of the asset manager, cleaning up resources.
  ///
  /// This is called automatically by the SDK when disposing.
  Future<void> dispose() async {
    _isDisposed = true;
    await _authSubscription?.cancel();
  }
}
