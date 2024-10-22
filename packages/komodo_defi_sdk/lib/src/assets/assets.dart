import 'dart:async';

import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetManager extends _Assets {
  AssetManager(super._kdf, super._auth);

  // final ApiClient _kdf;
  // final KomodoDefiLocalAuth _auth;

  final Map<String, Completer<void>> _activationCompleters = {};
  final Set<String> _activeAssetIds = {};

  // late final _Assets _assets = _Assets(_kdf, _auth);

  @override

  /// Initializes the asset manager by fetching assets and checking enabled coins.
  Future<void> init() async {
    await super.init();
    final enabledCoins = await _enabledCoins();
    _activeAssetIds.addAll(enabledCoins);
  }

  /// Returns all assets.
  Map<String, Asset> get all => _assets.all;

  /// Ensures that an asset is activated before performing any actions on it.
  Future<T> _ensureActivated<T>(
    AssetId assetId,
    Future<T> Function() action,
  ) async {
    if (!_activeAssetIds.contains(assetId.id)) {
      if (!_activationCompleters.containsKey(assetId.id)) {
        _activationCompleters[assetId.id] = Completer<void>();
        await _activateAsset(assetId);
      }

      // Wait for asset activation to complete
      await _activationCompleters[assetId.id]!.future;
    }
    return action();
  }

  /// Activates an asset if not already activated.
  Future<void> _activateAsset(AssetId assetId) async {
    try {
      final asset = _assets.all[assetId.id];
      if (asset == null) {
        throw ArgumentError('Asset not found for ID: ${assetId.id}');
      }

      await for (final progress in asset.preActivate()) {
        if (progress.isComplete) {
          _activeAssetIds.add(assetId.id);
          _activationCompleters[assetId.id]?.complete();
          break;
        }
      }
    } catch (e) {
      _activationCompleters[assetId.id]?.completeError(e);
      rethrow;
    } finally {
      _activationCompleters.remove(assetId.id);
    }
  }

  /// Retrieves the enabled coins from the API, checking the user's authentication status.
  Future<Set<String>> _enabledCoins() async {
    final isAuthed = await _auth.isSignedIn();
    if (!isAuthed) {
      return {};
    }
    return _kdf.rpc.generalActivation
        .getEnabledCoins()
        .then((r) => r.result.map((e) => e.ticker).toSet());
  }

  // Example methods that ensure asset activation before performing actions
  Future<String> getAddress(AssetId assetId) {
    return _ensureActivated(assetId, () async {
      // Implement address retrieval logic here
      return 'sample_address';
    });
  }

  Future<double> getBalance(AssetId assetId) {
    return _ensureActivated(assetId, () async {
      // Implement balance retrieval logic here
      return 100.0;
    });
  }

  Stream<List<Transaction>> getTransactions(AssetId assetId) {
    return Stream.fromFuture(
      _ensureActivated(assetId, () async {
        // Implement transaction retrieval logic here
        return [Transaction()];
      }),
    ).asyncExpand(Stream.value);
  }

  Future<String> send(AssetId assetId, String toAddress, double amount) {
    return _ensureActivated(assetId, () async {
      // Implement send logic here
      return 'transaction_hash';
    });
  }
}

abstract class _Assets {
  _Assets(this._kdf, this._auth);

  final ApiClient _kdf;
  final KomodoDefiLocalAuth _auth;
  final KomodoCoins _assets = KomodoCoins();

  Future<void> init() async {
    await _assets.init();
    _kdfClientInstance = _kdf;
  }

  /// Streams a list of active assets, updating as more are enabled.
  Stream<List<Asset>> activeAssets() {
    final controller = StreamController<List<Asset>>();
    final inactiveAssets = _assets.all.values.toList();

    scheduleMicrotask(() async {
      while (!controller.isClosed) {
        final enabledAssetIds = await _enabledCoins();

        controller.add(
          inactiveAssets
              .where((a) => enabledAssetIds.contains(a.id.id))
              .toList(),
        );

        // Remove enabled assets from inactive list
        inactiveAssets.removeWhere((a) => enabledAssetIds.contains(a.id.id));

        await Future<void>.delayed(const Duration(seconds: 5));
      }
    });

    return controller.stream;
  }

  Future<Set<String>> _enabledCoins() async {
    final isSignedIn = await _auth.isSignedIn();
    return _kdf.rpc.generalActivation
        .getEnabledCoins()
        .then((r) => r.result.map((e) => e.ticker).toSet());
  }
}

// extension ApiClientCoinActivation on ApiClient {
//   Stream<ActivationProgress> activate(Asset coin) => (_assets.isInitialized)
//       ? coin.activate()
//       : throw Exception('Assets not initialized');
//   // coin.protocol.activationStrategy.activate(this, coin);
// }

/// Asset activation extension
// TODO: consider making this private since we want to abstract the activation
// process away from the user/developer.
extension AssetActivation on Asset {
  /// Forces the activation of the asset.
  /// NB: This is not necessary for most cases as the activation process is
  /// handled internally when performing operations on the asset that
  /// require activation.
  Stream<ActivationProgress> preActivate() =>
      protocol.activationStrategy.activate(_kdfClientInstance, this);
}

// TODO: Refactor to avoid singleton use
late ApiClient _kdfClientInstance;
