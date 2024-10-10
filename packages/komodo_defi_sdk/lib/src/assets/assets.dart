import 'dart:async';

import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Assets extends KomodoCoins {
  Assets(this._kdf);

  final KomodoDefiFramework _kdf;

  @override
  Future<void> init() async {
    await super.init();
    _kdfInstance = _kdf;
  }

  /// Yields a list of all enabled assets and then listens for any new assets
  Stream<List<Asset>> activeAssets() {
    // TODO: (Important) Refactor to use KDF streaming interface
    // if/when available because this method is expensive
    final controller = StreamController<List<Asset>>();
    final inactiveAssets = all.toList();

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
    return _kdf.rpc.generalActivation
        .getEnabledCoins()
        .then((r) => r.result.map((e) => e.ticker).toSet());
  }

  // ApiClient
}

extension ApiClientCoinActivation on ApiClient {
  Stream<ActivationProgress> activate(Asset coin) => (KomodoCoins.isInitialized)
      ? coin.activate()
      : throw Exception('Assets not initialized');
  // coin.protocol.activationStrategy.activate(this, coin);
}

// Asset activation extension
extension AssetActivation on Asset {
  Stream<ActivationProgress> activate() =>
      protocol.activationStrategy.activate(_kdfInstance, this);
}

// TODO: Refactor to avoid singleton use
late KomodoDefiFramework _kdfInstance;
