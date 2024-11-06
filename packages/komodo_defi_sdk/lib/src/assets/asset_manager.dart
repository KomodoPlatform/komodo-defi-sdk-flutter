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

  final Map<String, Completer<void>> _activationCompleters = {};
  final Set<String> _activeAssetIds = {};
  final KomodoCoins _coins = KomodoCoins();

  StreamSubscription<KdfUser?>? _authSubscription;

  // Replace direct KomodoCoins instance with SplayTreeMap wrapper
  late final SplayTreeMap<String, Asset> _orderedCoins;

  Future<void> init() async {
    await _coins.init();

    _orderedCoins = SplayTreeMap<String, Asset>((keyA, keyB) {
      final isDefaultA = _config.defaultAssets.contains(keyA);
      final isDefaultB = _config.defaultAssets.contains(keyB);

      if (isDefaultA != isDefaultB) {
        return isDefaultA ? -1 : 1;
      }

      return keyA.compareTo(keyB);
    });

    _orderedCoins.addAll(_coins.all);

    final currentUser = await _auth.currentUser;
    await _onAuthStateChanged(currentUser);

    _authSubscription = _auth.authStateChanges.listen(_onAuthStateChanged);
  }

  Asset? fromId(AssetId id) => _coins.isInitialized
      ? available[id.id]
      : throw StateError(
          'Assets have not been initialized. Call init() first.',
        );

  Map<String, Asset> get available => _orderedCoins;
  Map<String, Asset> get availableOrdered => available;

  @Deprecated('This logic is handled internally.')
  Future<List<Asset>> getActivatedAssets() async {
    if (!await _auth.isSignedIn()) return [];

    final enabled = await _getEnabledCoins();
    return enabled.map((id) => available[id]).whereType<Asset>().toList();
  }

  Stream<ActivationProgress> activateAsset(Asset asset) async* {
    if (_activeAssetIds.contains(asset.id.id) ||
        (await getActivatedAssets()).contains(asset)) {
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
      asset.id.id,
      Completer<void>.new,
    );

    try {
      await for (final progress in _activationManager.activateAsset(asset)) {
        yield progress;

        if (progress.isComplete) {
          if (progress.isSuccess) {
            _activeAssetIds.add(asset.id.id);

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
      _activationCompleters.remove(asset.id.id);
    }
  }

  Future<void> _handlePreActivation(KdfUser user) async {
    final assetsToActivate = <String>{};

    if (_config.preActivateDefaultAssets) {
      assetsToActivate.addAll(
        _config.defaultAssets.where((id) => !_activeAssetIds.contains(id)),
      );
    }

    if (_config.preActivateHistoricalAssets) {
      final historical = await _assetHistory.getWalletAssets(user.walletId);
      assetsToActivate.addAll(
        historical.where((id) => !_activeAssetIds.contains(id)),
      );
    }

    final validAssets = assetsToActivate
        .where(
          (id) => available[id]?.isCompatibleWith(user.authOptions) ?? false,
        )
        .map((id) => available[id]!)
        .toSet();

    await for (final progress
        in _activationManager.activateAssets(validAssets.toList())) {
      if (progress.isComplete && !progress.isSuccess) {
        final assetId = validAssets.firstWhere(
          (id) => !_activeAssetIds.contains(id.id.id),
          orElse: () => throw StateError('No asset found for retry'),
        );

        var attempts = 0;
        while (attempts < _config.maxPreActivationAttempts) {
          try {
            final asset = available[assetId.id.id]!;
            await activateAsset(asset).last;
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
    _activeAssetIds.addAll(enabledCoins);

    await _handlePreActivation(user);
  }

  bool isAssetActive(AssetId assetId) => _activeAssetIds.contains(assetId.id);

  Future<Set<String>> _getEnabledCoins() async {
    if (!await _auth.isSignedIn()) return {};

    final enabled = await _client.rpc.generalActivation.getEnabledCoins();
    return enabled.result.map((e) => e.ticker).toSet();
  }

  Set<AssetId> childIdsOf(AssetId parentId) {
    return available.values
        .where((asset) => asset.id.parentId == parentId)
        .map((asset) => asset.id)
        .toSet();
  }

  Map<AssetId, Asset> childAssetsOf(AssetId parentId) {
    return Map.fromEntries(
      available.values
          .where((asset) => asset.id.parentId == parentId)
          .map((asset) => MapEntry(asset.id, asset)),
    );
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
