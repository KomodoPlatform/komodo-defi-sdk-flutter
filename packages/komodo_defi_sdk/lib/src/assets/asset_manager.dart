// asset_manager.dart
import 'dart:async';
import 'dart:collection';
import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/assets/asset_extensions.dart';
import 'package:komodo_defi_sdk/src/assets/asset_history_storage.dart';
import 'package:komodo_defi_sdk/src/sdk/sdk_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetManager {
  AssetManager(
    this._client,
    this._auth,
    this._config,
  ) : _assetHistory = AssetHistoryStorage();

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final KomodoDefiSdkConfig _config;
  final AssetHistoryStorage _assetHistory;

  final Map<String, Completer<void>> _activationCompleters = {};
  final Set<String> _activeAssetIds = {};
  final KomodoCoins _coins = KomodoCoins();

  StreamSubscription<KdfUser?>? _authSubscription;

  // Replace direct KomodoCoins instance with SplayTreeMap wrapper
  late final SplayTreeMap<String, Asset> _orderedCoins;

  /// Initialize asset manager and handle pre-activation
  Future<void> init() async {
    // 1. Initialize coins first
    await _coins.init();

    // 2. Set up ordered coins structure
    _orderedCoins = SplayTreeMap<String, Asset>((keyA, keyB) {
      final assetA = _coins.all[keyA];
      final assetB = _coins.all[keyB];

      if (assetA == null || assetB == null) {
        return keyA.compareTo(keyB);
      }

      // Pre-activated/default assets first
      final isDefaultA = _config.defaultAssets.contains(keyA);
      final isDefaultB = _config.defaultAssets.contains(keyB);

      if (isDefaultA != isDefaultB) {
        return isDefaultA ? -1 : 1;
      }

      // Then alphabetically by name
      return assetA.id.name.compareTo(assetB.id.name);
    });

    // 3. Populate ordered map
    _orderedCoins.addAll(_coins.all);

    // 4. Get current user and handle initial state
    final currentUser = await _auth.currentUser;
    await _onAuthStateChanged(currentUser);

    // 5. Set up subscription for future changes
    _authSubscription = _auth.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(KdfUser? user) async {
    // Clear state on logout
    if (user == null) {
      _activeAssetIds.clear();
      return;
    }

    // Get enabled coins first to know current state
    final enabledCoins = await _getEnabledCoins();
    _activeAssetIds.addAll(enabledCoins);

    // Then handle pre-activation of missing coins
    await _handlePreActivation(user);
  }

  /// Handle pre-activation of assets
  Future<void> _handlePreActivation(KdfUser user) async {
    final assetsToActivate = <String>{};

    // Add default assets if configured and not already active
    if (_config.preActivateDefaultAssets) {
      assetsToActivate.addAll(
        _config.defaultAssets.where((id) => !_activeAssetIds.contains(id)),
      );
    }

    // Add historical assets if configured and not already active
    if (_config.preActivateHistoricalAssets) {
      final historical = await _assetHistory.getWalletAssets(user.walletId);
      assetsToActivate.addAll(
        historical.where((id) => !_activeAssetIds.contains(id)),
      );
    }

    // Filter for available and compatible assets
    final validAssets = assetsToActivate
        .where(
          (id) =>
              available[id]?.isCompatibleWith(options: user.authOptions) ??
              false,
        )
        .toList();

    // Attempt activation with retries
    for (final assetString in validAssets) {
      final asset = available[assetString] ??
          (throw ArgumentError('Asset not found for ID: $assetString'));

      var attempts = 0;
      while (attempts < _config.maxPreActivationAttempts) {
        try {
          await activateAsset(asset).last; // Wait for stream completion
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

  /// Get all available assets in ordered form
  /// Assets are ordered by:
  /// 1. Pre-activated/default assets first
  /// 2. Alphabetically within each group
  Map<String, Asset> get available => _orderedCoins;

  // Update the getter to be more explicit about ordering
  Map<String, Asset> get availableOrdered => available;

  //  // Replace the old getFilteredAssets method
  // @Deprecated('Use getFilteredOrderedAssets() instead')
  // Future<Map<String, Asset>> getFilteredAssets() async {
  //   return getFilteredOrderedAssets();
  // }

  /// Get assets sorted with default assets first
  // Future<Map<String, Asset>> getFilteredAssets() async {
  //   final filteredAssets = <String, Asset>{};

  //   Future<bool> shouldIncludeAsset(Asset asset) async {
  //     return !await asset.shouldBeFiltered;
  //   }

  //   // Add default assets first if they pass filtering
  //   for (final id in _config.defaultAssets) {
  //     final asset = available[id];
  //     if (asset != null && await shouldIncludeAsset(asset)) {
  //       filteredAssets[id] = asset;
  //     }
  //   }

  //   // Add remaining filtered assets
  //   for (final entry in available.entries) {
  //     if (!filteredAssets.containsKey(entry.key) &&
  //         await shouldIncludeAsset(entry.value)) {
  //       filteredAssets[entry.key] = entry.value;
  //     }
  //   }

  //   return filteredAssets;
  // }

  /// Get list of currently activated assets
  Future<Set<Asset>> getActivatedAssets() async {
    if (!await _auth.isSignedIn()) return {};

    final enabled = await _getEnabledCoins();
    return enabled.map((id) => available[id]).whereType<Asset>().toSet();
  }

  /// Activate an asset and return a stream of activation progress
  /// The stream will complete after the asset is fully activated. If an error
  /// occurs, the stream will emit an error event and complete.
  /// Activate an asset and return a stream of activation progress
  /// The stream will complete after the asset is fully activated. If an error
  /// occurs, the stream will emit an error event and complete.
  Stream<ActivationProgress> activateAsset(Asset asset) async* {
    if (_activeAssetIds.contains(asset.id.id) ||
        (await getActivatedAssets()).contains(asset)) {
      yield ActivationProgress.success();
      return;
    }

    // Check compatibility
    final isCompatible = await asset.isCompatible;
    if (isCompatible == false) {
      throw UnsupportedError(
        'Asset ${asset.id.name} is not compatible with current wallet mode',
      );
    }

    final completer = _activationCompleters.putIfAbsent(
      asset.id.id,
      Completer<void>.new,
    );

    try {
      await for (final progress in _activateAssetStream(asset)) {
        yield progress;

        if (progress.isComplete) {
          if (progress.isSuccess) {
            _activeAssetIds.add(asset.id.id);

            // Record successful activation in history
            final user = await _auth.currentUser;
            if (user != null) {
              await _assetHistory.addAssetToWallet(user.walletId, asset.id.id);
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else {
            // Don't throw here - just complete the completer with error
            completer.completeError(progress.errorMessage ?? 'Unknown error');
          }
        }
      }
    } catch (e) {
      // Complete with error if not already completed
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    } finally {
      _activationCompleters.remove(asset.id.id);
    }
  }

  Stream<ActivationProgress> _activateAssetStream(Asset asset) async* {
    final strategy = ActivationStrategyFactory.fromJsonConfig(
      asset.protocol.subClass,
      asset.protocol.toJson(),
    );

    yield* strategy.activate(_client, asset);
  }

  /// Check if an asset is currently activated
  bool isAssetActive(Asset asset) => _activeAssetIds.contains(asset.id.id);

  /// Get list of enabled coins from API
  Future<Set<String>> _getEnabledCoins() async {
    if (!await _auth.isSignedIn()) return {};

    final enabled = await _client.rpc.generalActivation.getEnabledCoins();
    return enabled.result.map((e) => e.ticker).toSet();
  }

  void dispose() {
    _activationCompleters.clear();
    _authSubscription?.cancel();
  }
}

// /// Manages assets and their activation states
// class AssetManager {
//   AssetManager(this._client, this._auth);

//   final ApiClient _client;
//   final KomodoDefiLocalAuth _auth;

//   // Track activation state
//   final Map<String, Completer<void>> _activationCompleters = {};
//   final Set<String> _activeAssetIds = {};

//   // Coin configuration
//   final KomodoCoins _coins = KomodoCoins();

//   StreamSubscription<AuthOptions?>? _authSubscription;
//   AuthOptions? _currentAuthOptions;

//   /// Initialize asset manager
//   Future<void> init() async {
//     await _coins.init();
//     final enabledCoins = await _getEnabledCoins();
//     _activeAssetIds.addAll(enabledCoins);

//     _authSubscription = _auth.authStateChanges
//         .map((user) => user?.authOptions)
//         .listen((options) {
//       _currentAuthOptions = options;
//     });
//   }

//   /// Get all available assets
//   Map<String, Asset> get all => _filterAssets(_coins.all, _currentAuthOptions);

//   /// Get all currently activated assets
//   Future<Set<Asset>> getActivatedAssets() async {
//     final enabled = await _getEnabledCoins();
//     return enabled.map((id) => _coins.all[id]).whereType<Asset>().toSet();
//   }

//   /// Filter assets based on current auth state
//   Map<String, Asset> _filterAssets(
//     Map<String, Asset> assets,
//     AuthOptions? options,
//   ) {
//     return Map.fromEntries(
//       assets.entries.where((entry) {
//         // Get current HD wallet status

//         final isHdWallet =
//             options?.derivationMethod == DerivationMethod.hdWallet;

//         return !entry.value.isFilteredOut(isHdWallet: isHdWallet);
//       }),
//     );
//   }

//   /// Activate an asset if not already active
//   Future<void> activateAsset(Asset asset) async {
//     if (_activeAssetIds.contains(asset.id.id)) return;

//     final completer = _activationCompleters.putIfAbsent(
//       asset.id.id,
//       () => Completer<void>(),
//     );

//     final activationStream = asset.activation(isHdWallet: true).preActivate(asset, _client);

//     try {
//       await for (final progress in activationStream) {
//         if (progress.isComplete) {
//           if (progress.isSuccess) {
//             _activeAssetIds.add(asset.id.id);
//             completer.complete();
//           } else {
//             completer.completeError(progress.errorMessage ?? 'Unknown error');
//           }
//           break;
//         }
//       }
//     } catch (e) {
//       completer.completeError(e);
//       rethrow;
//     } finally {
//       _activationCompleters.remove(asset.id.id);
//     }
//   }

//   /// Deactivate an asset
//   Future<void> deactivateAsset(Asset asset) async {
//     // TODO: Implement deactivation when API supports it
//     throw UnimplementedError();
//   }

//   /// Get list of enabled coins
//   Future<Set<String>> _getEnabledCoins() async {
//     if (!await _auth.isSignedIn()) return {};

//     final enabled = await _client.rpc.generalActivation.getEnabledCoins();
//     return enabled.result.map((e) => e.ticker).toSet();
//   }

//   /// Check if an asset is currently activated
//   bool isAssetActive(Asset asset) => _activeAssetIds.contains(asset.id.id);
// }
