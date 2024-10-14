import 'dart:async';

import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetManager {
  AssetManager(this._kdf, this._auth);

  final ApiClient _kdf;
  final KomodoDefiLocalAuth _auth;

  final Map<String, Completer<void>> _activationCompleters = {};
  final Set<String> _activeAssetIds = {};

  late final _Assets _assets = _Assets(_kdf, _auth);

  Future<void> init() async {
    await _assets.init();
    // Initialize with currently enabled coins
    final enabledCoins = await _enabledCoins();
    _activeAssetIds.addAll(enabledCoins);
  }

  Map<String, Asset> get all => _assets.all;

  Future<T> _ensureActivated<T>(
    AssetId assetId,
    Future<T> Function() action,
  ) async {
    if (!_activeAssetIds.contains(assetId.id)) {
      if (!_activationCompleters.containsKey(assetId.id)) {
        _activationCompleters[assetId.id] = Completer<void>();
        _activateAsset(assetId);
      }
      await _activationCompleters[assetId.id]!.future;
    }
    return action();
  }

  Future<void> _activateAsset(AssetId assetId) async {
    try {
      final asset = _assets.all[assetId.id]!;
      await for (final progress in asset.preActivate()) {
        if (progress.isComplete) {
          _activeAssetIds.add(assetId.id);
          _activationCompleters[assetId.id]!.complete();
          break;
        }
      }
    } catch (e) {
      _activationCompleters[assetId.id]!.completeError(e);
    } finally {
      _activationCompleters.remove(assetId.id);
    }
  }

  Future<Set<String>> _enabledCoins() async {
    final isAuthed = await _auth.isSignedIn();

    // TODO: Throw or return empty?

    return !isAuthed
        ? {}
        : _kdf.rpc.generalActivation
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
      return 100;
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

class _Assets extends KomodoCoins {
  _Assets(this._kdf, this._auth);

  final ApiClient _kdf;
  final KomodoDefiLocalAuth _auth;

  @override
  Future<void> init() async {
    await super.init();
    _kdfClientInstance = _kdf;
  }

  /// Yields a list of all enabled assets and then listens for any new assets
  Stream<List<Asset>> activeAssets() {
    // TODO: (Important) Refactor to use KDF streaming interface
    // if/when available because this method is expensive
    final controller = StreamController<List<Asset>>();
    final inactiveAssets = all.values.toList();

    scheduleMicrotask(() async {
      // Poll for new assets as long as the stream is active and emit only new assets
      while (!controller.isClosed) {
        final enabledAssetIds = await _enabledCoins();

        controller.add(
          inactiveAssets
              .where((a) => enabledAssetIds.contains(a.id.id))
              .toList(),
        );

        // remove enabled assets from the inactive list
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

  // ApiClient
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
