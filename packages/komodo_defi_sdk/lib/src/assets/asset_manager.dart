// lib/src/assets/asset_manager.dart

import 'dart:async';
import 'dart:collection';

import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/assets/asset_extensions.dart';
import 'package:komodo_defi_sdk/src/assets/asset_history_storage.dart';
import 'package:komodo_defi_sdk/src/sdk/sdk_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetManager {
  AssetManager(
    this._client,
    this._auth,
    this._config,
  )   : _assetHistory = AssetHistoryStorage(),
        _activationManager = ActivationManager(_client);

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final KomodoDefiSdkConfig _config;
  final AssetHistoryStorage _assetHistory;
  final ActivationManager _activationManager;

  final Map<AssetId, Completer<void>> _activationCompleters = {};
  final Set<AssetId> _activeAssetIds = {};
  final KomodoCoins _coins = KomodoCoins();

  StreamSubscription<KdfUser?>? _authSubscription;

  late final SplayTreeMap<AssetId, Asset> _orderedCoins;

  Future<void> init() async {
    await _coins.init();

    _orderedCoins = SplayTreeMap<AssetId, Asset>((keyA, keyB) {
      final isDefaultA = _config.defaultAssets.contains(keyA.id);
      final isDefaultB = _config.defaultAssets.contains(keyB.id);

      if (isDefaultA != isDefaultB) {
        return isDefaultA ? -1 : 1;
      }

      return keyA.toString().compareTo(keyB.toString());
    });

    _orderedCoins.addAll(_coins.all);

    final currentUser = await _auth.currentUser;
    await _onAuthStateChanged(currentUser);

    _authSubscription = _auth.authStateChanges.listen(_onAuthStateChanged);
  }

  Asset? fromId(AssetId id) => _coins.isInitialized
      ? available[id]
      : throw StateError(
          'Assets have not been initialized. Call init() first.',
        );

  Map<AssetId, Asset> get available => _orderedCoins;
  Map<AssetId, Asset> get availableOrdered => available;

  @Deprecated(
      'This method will be removed from the public interface in the future. '
      'It is intended for internal use only.')
  Stream<ActivationProgress> activateAsset(Asset asset) async* {
    if ((await getActivatedAssets()).contains(asset)) {
      yield ActivationProgress.success();
      return;
    }

    final isCompatible = await asset.isCompatible;
    if (!isCompatible) {
      throw UnsupportedError(
        'Asset ${asset.id.name} is not compatible with current wallet mode',
      );
    }

    final completer = _activationCompleters.putIfAbsent(
      asset.id,
      Completer<void>.new,
    );

    try {
      await for (final progress in _activationManager.activateAsset(asset)) {
        yield progress;

        if (progress.isComplete) {
          if (progress.isSuccess) {
            _activeAssetIds.add(asset.id);

            final user = await _auth.currentUser;
            if (user != null) {
              await _assetHistory.addAssetToWallet(user.walletId, asset.id.id);
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else {
            if (!completer.isCompleted) {
              completer.completeError(progress.errorMessage ?? 'Unknown error');
            }
          }
        }
      }

      yield ActivationProgress.success();
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    } finally {
      _activationCompleters.remove(asset.id);
    }
  }

  Future<List<Asset>> getActivatedAssets() async {
    if (!await _auth.isSignedIn()) return [];

    final enabledCoins = await _getEnabledCoins();
    return enabledCoins.expand(findAssetsByTicker).toList();
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
        in _activationManager.activateAssets(validAssets)) {
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

    final enabledCoins = await _getEnabledCoins();
    for (final ticker in enabledCoins) {
      _activeAssetIds.addAll(
        findAssetsByTicker(ticker).map((asset) => asset.id),
      );
    }

    await _handlePreActivation(user);
  }

  // bool isAssetActive(AssetId assetId) => _activeAssetIds.contains(assetId);

  Future<Set<String>> _getEnabledCoins() async {
    if (!await _auth.isSignedIn()) return {};

    final enabled = await _client.rpc.generalActivation.getEnabledCoins();
    return enabled.result.map((e) => e.ticker).toSet();
  }

  Set<Asset> findAssetsByTicker(String ticker) {
    return available.values.where((asset) => asset.id.id == ticker).toSet();
  }

  Set<Asset> childAssetsOf(AssetId parentId) {
    return available.values
        .where(
          (asset) => asset.id.isChildAsset && asset.id.parentId == parentId,
        )
        .toSet();
  }

  void dispose() {
    _activationCompleters.clear();
    _authSubscription?.cancel();
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
