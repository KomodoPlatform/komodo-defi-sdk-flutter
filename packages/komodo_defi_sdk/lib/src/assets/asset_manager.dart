// lib/src/assets/asset_manager.dart

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart' show ValueGetter;
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
class AssetManager implements IAssetProvider {
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
  );

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final KomodoDefiSdkConfig _config;
  final CustomAssetHistoryStorage _customAssetHistory;
  final KomodoCoins _coins = KomodoCoins();
  late final AssetIdMap _orderedCoins;

  /// NB: This cannot be used during initialization. This is a workaround
  /// to publicly expose the activation manager's activation methods.
  /// See [activateAsset] and [activateAssets] for more details.
  final ValueGetter<ActivationManager> _activationManager;

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

    await _initializeCustomTokens();
  }

  Future<void> _initializeCustomTokens() async {
    final user = await _auth.currentUser;
    if (user != null) {
      final customTokens = await _customAssetHistory.getWalletAssets(
        user.walletId,
      );
      for (final customToken in customTokens) {
        _orderedCoins[customToken.id] = customToken;
      }
    }
  }

  /// Returns an asset by its [AssetId], if available.
  ///
  /// Returns null if no matching asset is found.
  /// Throws [StateError] if called before initialization.
  @override
  Asset? fromId(AssetId id) =>
      _coins.isInitialized
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
    final enabled = await getEnabledCoins();
    return enabled.expand(findAssetsByTicker).toList();
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

  /// Disposes of the asset manager, cleaning up resources.
  ///
  /// This is called automatically by the SDK when disposing.
  Future<void> dispose() async {
    // No cleanup needed for now
  }
}
