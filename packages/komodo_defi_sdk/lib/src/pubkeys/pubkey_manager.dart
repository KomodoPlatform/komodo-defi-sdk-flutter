import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Interface defining the contract for pubkey management operations
abstract class IPubkeyManager {
  /// Get pubkeys for a given asset, handling HD/non-HD differences internally
  Future<AssetPubkeys> getPubkeys(Asset asset);

  /// Watch pubkeys for a given asset, emitting the initial state if available
  /// and polling for updates at a fixed interval. Optionally activates asset.
  Stream<AssetPubkeys> watchPubkeys(
    Asset asset, {
    bool activateIfNeeded = true,
  });

  /// Get the last known pubkeys for an asset without triggering a refresh.
  /// Returns null if no pubkeys have been fetched yet.
  AssetPubkeys? lastKnown(AssetId assetId);

  /// Create a new pubkey for an asset if supported
  Future<PubkeyInfo> createNewPubkey(Asset asset);

  /// Streamed version of [createNewPubkey]
  Stream<NewAddressState> createNewPubkeyStream(Asset asset);

  /// Unban pubkeys according to [unbanBy] criteria
  Future<UnbanPubkeysResult> unbanPubkeys(UnbanBy unbanBy);

  /// Pre-caches pubkeys for an asset to warm the cache and notify listeners
  Future<void> preCachePubkeys(Asset asset);

  /// Dispose of any resources
  Future<void> dispose();
}

/// Manager responsible for handling pubkey operations across different assets
class PubkeyManager implements IPubkeyManager {
  PubkeyManager(this._client, this._auth, this._activationCoordinator) {
    _authSubscription = _auth.authStateChanges.listen(_handleAuthStateChanged);
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final SharedActivationCoordinator _activationCoordinator;

  // Internal state for watching pubkeys per asset
  final Map<AssetId, AssetPubkeys> _pubkeysCache = {};
  final Map<AssetId, StreamSubscription<dynamic>> _activeWatchers = {};
  final Map<AssetId, StreamController<AssetPubkeys>> _pubkeysControllers = {};
  // Track the Asset for each AssetId that has an associated controller so that
  // we can restart watchers after auth changes without requiring new listeners
  final Map<AssetId, Asset> _watchedAssets = {};

  StreamSubscription<KdfUser?>? _authSubscription;
  WalletId? _currentWalletId;
  bool _isDisposed = false;
  final Duration _defaultPollingInterval = const Duration(seconds: 30);

  /// Get pubkeys for a given asset, handling HD/non-HD differences internally
  @override
  Future<AssetPubkeys> getPubkeys(Asset asset) async {
    await retry(() => _activationCoordinator.activateAsset(asset));
    final strategy = await _resolvePubkeyStrategy(asset);
    return strategy.getPubkeys(asset.id, _client);
  }

  /// Create a new pubkey for an asset if supported
  @override
  Future<PubkeyInfo> createNewPubkey(Asset asset) async {
    await retry(() => _activationCoordinator.activateAsset(asset));
    final strategy = await _resolvePubkeyStrategy(asset);
    if (!strategy.supportsMultipleAddresses) {
      throw UnsupportedError(
        'Asset ${asset.id.name} does not support multiple addresses',
      );
    }
    return strategy.getNewAddress(asset.id, _client);
  }

  /// Streamed version of [createNewPubkey]
  @override
  Stream<NewAddressState> createNewPubkeyStream(Asset asset) async* {
    await retry(() => _activationCoordinator.activateAsset(asset));
    final strategy = await _resolvePubkeyStrategy(asset);
    if (!strategy.supportsMultipleAddresses) {
      yield NewAddressState.error(
        'Asset ${asset.id.name} does not support multiple addresses',
      );
      return;
    }
    yield* strategy.getNewAddressStream(asset.id, _client);
  }

  /// Unban pubkeys according to [unbanBy] criteria
  @override
  Future<UnbanPubkeysResult> unbanPubkeys(UnbanBy unbanBy) async {
    final response = await _client.rpc.wallet.unbanPubkeys(unbanBy: unbanBy);
    return response.result;
  }

  Future<PubkeyStrategy> _resolvePubkeyStrategy(Asset asset) async {
    final currentUser = await _auth.currentUser;
    if (currentUser == null) {
      throw AuthException.notSignedIn();
    }
    return asset.pubkeyStrategy(kdfUser: currentUser);
  }

  /// Stream of pubkeys per asset. Polls pubkeys (not balances) and emits updates.
  /// Emits the initial known state if available.
  @override
  Stream<AssetPubkeys> watchPubkeys(
    Asset asset, {
    bool activateIfNeeded = true,
  }) async* {
    if (_isDisposed) {
      throw StateError('PubkeyManager has been disposed');
    }

    // Emit last known pubkeys immediately if available
    final lastKnown = _pubkeysCache[asset.id];
    if (lastKnown != null) {
      yield lastKnown;
    }

    final controller = _pubkeysControllers.putIfAbsent(
      asset.id,
      () => StreamController<AssetPubkeys>.broadcast(
        onListen: () => _startWatchingPubkeys(asset, activateIfNeeded),
        onCancel: () {
          _stopWatchingPubkeys(asset.id);
          _watchedAssets.remove(asset.id);
        },
      ),
    );
    // Remember the Asset so we can restart the watcher after a reset
    _watchedAssets[asset.id] = asset;

    yield* controller.stream;
  }

  @override
  AssetPubkeys? lastKnown(AssetId assetId) {
    if (_isDisposed) {
      throw StateError('PubkeyManager has been disposed');
    }
    return _pubkeysCache[assetId];
  }

  Future<void> _startWatchingPubkeys(Asset asset, bool activateIfNeeded) async {
    final controller = _pubkeysControllers[asset.id];
    if (controller == null || _isDisposed) return;

    // Cancel any existing watcher for this asset
    await _activeWatchers[asset.id]?.cancel();
    _activeWatchers.remove(asset.id);

    // Ensure user is authenticated
    final user = await _auth.currentUser;
    if (user == null) {
      // Do not emit an error; wait for authentication changes
      return;
    }
    _currentWalletId = user.walletId;

    // Emit last known immediately if available
    final maybeKnown = _pubkeysCache[asset.id];
    if (maybeKnown != null && !controller.isClosed) {
      controller.add(maybeKnown);
    }

    try {
      // Ensure activation if requested, otherwise only proceed if already active
      bool isActive = await _activationCoordinator.isAssetActive(asset.id);
      if (!isActive && activateIfNeeded) {
        final activationResult = await _activationCoordinator.activateAsset(
          asset,
        );
        isActive = activationResult.isSuccess;
      }

      if (isActive) {
        final first = await getPubkeys(asset);
        _pubkeysCache[asset.id] = first;
        if (!controller.isClosed) controller.add(first);
      }

      // Periodic polling for pubkeys updates
      final periodicStream = Stream<void>.periodic(_defaultPollingInterval);
      _activeWatchers[asset.id] = periodicStream
          .asyncMap<AssetPubkeys?>((_) async {
            if (_isDisposed) return null;

            // Check that user is still authenticated and wallet hasn't changed
            final currentUser = await _auth.currentUser;
            if (currentUser == null ||
                currentUser.walletId != _currentWalletId) {
              return null;
            }

            try {
              bool active = await _activationCoordinator.isAssetActive(
                asset.id,
              );
              if (!active && activateIfNeeded) {
                final activationResult = await _activationCoordinator
                    .activateAsset(asset);
                active = activationResult.isSuccess;
              }
              if (active) {
                final pubkeys = await getPubkeys(asset);
                _pubkeysCache[asset.id] = pubkeys;
                return pubkeys;
              }
            } catch (_) {
              // Swallow transient errors; continue with last known state
            }
            return _pubkeysCache[asset.id];
          })
          .listen(
            (AssetPubkeys? pubkeys) {
              if (pubkeys != null && !controller.isClosed) {
                controller.add(pubkeys);
              }
            },
            onError: (Object error) {
              if (!controller.isClosed) controller.addError(error);
            },
            onDone: () => _stopWatchingPubkeys(asset.id),
            cancelOnError: false,
          );
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  void _stopWatchingPubkeys(AssetId assetId) {
    final watcher = _activeWatchers[assetId];
    if (watcher != null) {
      watcher.cancel();
      _activeWatchers.remove(assetId);
    }
  }

  @override
  Future<void> preCachePubkeys(Asset asset) async {
    if (_isDisposed) return;

    final user = await _auth.currentUser;
    if (user == null) return;

    try {
      final pubkeys = await getPubkeys(asset);
      _pubkeysCache[asset.id] = pubkeys;

      final controller = _pubkeysControllers[asset.id];
      if (controller != null && !controller.isClosed) {
        controller.add(pubkeys);
      }
    } catch (_) {
      // Fail silently; this is a best-effort cache warm-up
    }
  }

  Future<void> _handleAuthStateChanged(KdfUser? user) async {
    if (_isDisposed) return;
    final newWalletId = user?.walletId;
    if (_currentWalletId != newWalletId) {
      await _resetState();
      _currentWalletId = newWalletId;
    }
  }

  /// Called when authentication state changes to do the following:
  /// - clear active watchers
  /// - indicate disconnection with state error to controllers
  /// - restart the pubkey watchers for the active controllers
  Future<void> _resetState() async {
    // Cancel all active watchers
    for (final subscription in _activeWatchers.values) {
      await subscription.cancel();
    }
    _activeWatchers.clear();

    // Notify existing controllers with an error to signal reconnection
    for (final controller in _pubkeysControllers.values) {
      if (!controller.isClosed) {
        controller.addError(
          StateError('Wallet changed, reconnecting pubkey watchers'),
        );
      }
    }

    // Clear caches
    _pubkeysCache.clear();

    // Restart pubkey watchers for controllers that remain open
    final existingControllers =
        Map<AssetId, StreamController<AssetPubkeys>>.from(_pubkeysControllers);
    for (final entry in existingControllers.entries) {
      final controller = entry.value;
      if (controller.isClosed) continue;
      final assetId = entry.key;
      final asset = _watchedAssets[assetId];
      if (asset != null) {
        await _startWatchingPubkeys(asset, true);
      }
    }
  }

  /// Dispose of any resources
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _authSubscription?.cancel();
    _authSubscription = null;

    for (final subscription in _activeWatchers.values) {
      await subscription.cancel();
    }
    _activeWatchers.clear();

    for (final controller in _pubkeysControllers.values) {
      await controller.close();
    }
    _pubkeysControllers.clear();

    _pubkeysCache.clear();
    _watchedAssets.clear();
    _currentWalletId = null;
  }
}
