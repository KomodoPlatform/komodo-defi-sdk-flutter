import 'dart:async';
import 'package:flutter/foundation.dart'; // Add this import for debugPrint
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Interface defining the contract for balance management operations
abstract class IBalanceManager {
  /// Gets the current balance for an asset.
  /// Will ensure the asset is activated before querying.
  ///
  /// Note: If the asset was recently activated through [ActivationManager],
  /// the balance will typically be pre-cached and return immediately. However,
  /// this should not be relied upon as a way to check activation status.
  ///
  /// Throws [AuthException] if user is not signed in.
  /// Throws [ArgumentError] if asset is not found.
  /// May throw [TimeoutException] if balance fetch times out.
  Future<BalanceInfo> getBalance(AssetId assetId);

  /// Gets a stream of balance updates for an asset.
  /// The stream will emit the current balance immediately if available,
  /// and then emit updates whenever the balance changes.
  ///
  /// If [activateIfNeeded] is false, will not trigger activation but will
  /// wait for the asset to be activated externally.
  Stream<BalanceInfo> watchBalance(
    AssetId assetId, {
    bool activateIfNeeded = true,
  });

  /// Gets the last known balance for an asset without triggering a refresh.
  /// Returns null if no balance has been fetched yet.
  BalanceInfo? lastKnown(AssetId assetId);

  /// Disposes of all resources and stops all balance watching
  Future<void> dispose();

  /// Pre-caches the balance for an asset.
  /// This is an internal method used during activation to optimize initial balance fetches.
  Future<void> preCacheBalance(Asset asset);
}

/// Implementation of the [IBalanceManager] interface for managing asset balances.
///
/// This class provides balance management operations with efficient caching
/// and update mechanisms using appropriate balance strategies based on asset type.
class BalanceManager implements IBalanceManager {
  /// Creates a new instance of [BalanceManager].
  ///
  /// Requires an [IAssetLookup] to find asset information and [KomodoDefiLocalAuth] for auth.
  /// The [activationManager] and [pubkeyManager] can be initialized as null and set later
  /// to break circular dependencies.
  BalanceManager({
    required IAssetLookup assetLookup,
    required KomodoDefiLocalAuth auth,
    required PubkeyManager? pubkeyManager,
    required ActivationManager? activationManager,
  }) : _activationManager = activationManager,
       _pubkeyManager = pubkeyManager,
       _assetLookup = assetLookup,
       _auth = auth {
    // Listen for auth state changes
    _authSubscription = _auth.authStateChanges.listen(_handleAuthStateChanged);
  }

  ActivationManager? _activationManager;
  PubkeyManager? _pubkeyManager;
  final IAssetLookup _assetLookup;
  final KomodoDefiLocalAuth _auth;
  StreamSubscription<KdfUser?>? _authSubscription;
  final Duration _defaultPollingInterval = const Duration(seconds: 30);

  /// Cache of the latest known balances for each asset
  final Map<AssetId, BalanceInfo> _balanceCache = {};

  /// Track active balance watch streams by asset ID
  final Map<AssetId, StreamSubscription<dynamic>> _activeWatchers = {};

  /// Stream controllers for each asset being watched
  final Map<AssetId, StreamController<BalanceInfo>> _balanceControllers = {};

  /// Track activation operations in progress to avoid duplicate activations
  final Map<AssetId, Completer<void>> _pendingActivations = {};

  /// Current wallet ID being tracked
  WalletId? _currentWalletId;

  /// Flag indicating if the manager has been disposed
  bool _isDisposed = false;

  /// Getter for activationManager to make it accessible
  ActivationManager? get activationManager => _activationManager;

  /// Getter for pubkeyManager to make it accessible
  PubkeyManager? get pubkeyManager => _pubkeyManager;

  /// Setter for activationManager to resolve circular dependencies
  void setActivationManager(ActivationManager manager) {
    _activationManager = manager;
  }

  /// Setter for pubkeyManager to resolve circular dependencies
  void setPubkeyManager(PubkeyManager manager) {
    _pubkeyManager = manager;
  }

  /// Handle authentication state changes
  Future<void> _handleAuthStateChanged(KdfUser? user) async {
    if (_isDisposed) return;
    final newWalletId = user?.walletId;
    // If the wallet ID has changed, reset all state
    if (_currentWalletId != newWalletId) {
      await _resetState();
      _currentWalletId = newWalletId;
    }
  }

  /// Reset all internal state when wallet changes
  Future<void> _resetState() async {
    // Cancel all active watchers
    for (final subscription in _activeWatchers.values) {
      await subscription.cancel();
    }
    _activeWatchers.clear();

    // Add errors to existing controllers to signal disconnection
    for (final controller in _balanceControllers.values) {
      if (!controller.isClosed) {
        controller.addError(
          StateError('Wallet changed, reconnecting balance watchers'),
        );
      }
    }

    // Clear caches and pending operations
    _balanceCache.clear();
    _pendingActivations.clear();

    // Restart balance watchers for existing controllers with the new wallet
    final existingWatches = Map<AssetId, StreamController<BalanceInfo>>.from(
      _balanceControllers,
    );
    for (final entry in existingWatches.entries) {
      if (!entry.value.isClosed) {
        _startWatchingBalance(entry.key, true);
      }
    }
  }

  @override
  Future<BalanceInfo> getBalance(AssetId assetId) async {
    if (_isDisposed) {
      throw StateError('BalanceManager has been disposed');
    }

    // Check if dependencies are properly initialized
    if (_pubkeyManager == null) {
      throw StateError('PubkeyManager is not initialized');
    }

    // Check if user is authenticated
    final user = await _auth.currentUser;
    if (user == null) {
      throw AuthException.notSignedIn();
    }

    final asset = _assetLookup.fromId(assetId);
    if (asset == null) {
      throw ArgumentError('Asset not found for balance check: $assetId');
    }

    try {
      final balance = await _pubkeyManager!
          .getPubkeys(asset)
          .then((pubkeys) => pubkeys.balance);
      // Update cache with the latest balance
      _balanceCache[assetId] = balance;
      return balance;
    } catch (e) {
      // Rethrow with more context
      throw StateError('Failed to get balance for ${assetId.name}: $e');
    }
  }

  @override
  Stream<BalanceInfo> watchBalance(
    AssetId assetId, {
    bool activateIfNeeded = true,
  }) async* {
    if (_isDisposed) {
      throw StateError('BalanceManager has been disposed');
    }

    final lastKnownBalance = lastKnown(assetId);
    if (lastKnownBalance != null) {
      yield lastKnownBalance;
    }

    final controller = _balanceControllers.putIfAbsent(
      assetId,
      () => StreamController<BalanceInfo>.broadcast(
        onListen: () => _startWatchingBalance(assetId, activateIfNeeded),
        onCancel: () => _stopWatchingBalance(assetId),
      ),
    );

    yield* controller.stream;
  }

  /// Ensures an asset is activated, with protection against duplicate activations
  Future<bool> _ensureAssetActivated(Asset asset, bool activateIfNeeded) async {
    // Check if activationManager is initialized
    if (_activationManager == null) {
      debugPrint('ActivationManager not initialized, cannot activate asset');
      return false;
    }

    if (!activateIfNeeded) {
      return _activationManager!.isAssetActive(asset.id);
    }

    final isActive = await _activationManager!.isAssetActive(asset.id);
    if (isActive) {
      return true;
    }

    // Check if activation is already in progress
    if (_pendingActivations.containsKey(asset.id)) {
      try {
        // Wait for the existing activation to complete
        await _pendingActivations[asset.id]!.future;
        return await _activationManager!.isAssetActive(asset.id);
      } catch (e) {
        // If the activation fails, we'll try again
        return false;
      }
    }

    // Start a new activation
    final completer = Completer<void>();
    _pendingActivations[asset.id] = completer;

    try {
      // Activate the asset
      await _activationManager!.activateAsset(asset).last;
      completer.complete();
      return await _activationManager!.isAssetActive(asset.id);
    } catch (e) {
      completer.completeError(e);
      return false;
    } finally {
      _pendingActivations.remove(asset.id);
    }
  }

  /// Start watching the balance for a specific asset
  Future<void> _startWatchingBalance(
    AssetId assetId,
    bool activateIfNeeded,
  ) async {
    final controller = _balanceControllers[assetId];
    if (controller == null || _isDisposed) return;

    // Check if dependencies are initialized
    if (_activationManager == null || _pubkeyManager == null) {
      if (!controller.isClosed) {
        controller.addError(
          StateError('Dependencies not fully initialized yet'),
        );
      }
      return;
    }

    // Cancel any existing watcher for this asset
    await _activeWatchers[assetId]?.cancel();
    _activeWatchers.remove(assetId);

    final asset = _assetLookup.fromId(assetId);
    if (asset == null) {
      controller.addError(
        ArgumentError('Asset not found for balance watch: $assetId'),
      );
      return;
    }

    // Check if user is authenticated
    final user = await _auth.currentUser;
    if (user == null) {
      // Don't throw an error, just wait for authentication
      return;
    }

    // Keep track of the wallet ID this balance is for
    _currentWalletId = user.walletId;

    // Emit the last known balance immediately if available
    final maybeKnownBalance = lastKnown(assetId);
    if (maybeKnownBalance != null) {
      controller.add(maybeKnownBalance);
    }

    try {
      // Ensure asset is activated if needed
      final isActive = await _ensureAssetActivated(asset, activateIfNeeded);

      // If active, get the first balance
      if (isActive) {
        final balance = await getBalance(assetId);
        if (!controller.isClosed) controller.add(balance);
      }

      // Set up periodic polling for balance updates
      final periodicStream = Stream<void>.periodic(_defaultPollingInterval);
      _activeWatchers[assetId] = periodicStream
          .asyncMap<BalanceInfo?>((void _) async {
            if (_isDisposed) return null;

            // Check if dependencies are still initialized
            if (_activationManager == null || _pubkeyManager == null) {
              return null;
            }

            // Check if user is still authenticated
            final currentUser = await _auth.currentUser;
            if (currentUser == null ||
                currentUser.walletId != _currentWalletId) {
              return null; // Don't fetch balance if user changed or logged out
            }

            try {
              // Ensure asset is activated if needed
              final isActive = await _ensureAssetActivated(
                asset,
                activateIfNeeded,
              );

              // Only fetch balance if asset is active
              if (isActive) {
                final balance = await getBalance(assetId);
                return balance;
              }
            } catch (e) {
              // Just log the error and continue with the last known balance
              // This prevents the stream from terminating on transient errors
            }

            // Return the last known balance if we can't fetch a new one
            return lastKnown(assetId);
          })
          .listen(
            (BalanceInfo? balance) {
              if (balance != null && !controller.isClosed) {
                controller.add(balance);
              }
            },
            onError: (Object error) {
              if (!controller.isClosed) controller.addError(error);
            },
            onDone: () {
              _stopWatchingBalance(assetId);
            },
            cancelOnError: false,
          );
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  /// Stop watching the balance for a specific asset
  void _stopWatchingBalance(AssetId assetId) {
    final watcher = _activeWatchers[assetId];
    if (watcher != null) {
      watcher.cancel();
      _activeWatchers.remove(assetId);
    }
    // Don't close the controller here, just remove the watcher
    // The controller will be closed when all listeners are gone
  }

  @override
  BalanceInfo? lastKnown(AssetId assetId) {
    if (_isDisposed) {
      throw StateError('BalanceManager has been disposed');
    }
    return _balanceCache[assetId];
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    // Cancel auth subscription
    await _authSubscription?.cancel();
    _authSubscription = null;

    // Cancel all active watchers
    for (final subscription in _activeWatchers.values) {
      await subscription.cancel();
    }
    _activeWatchers.clear();

    // Close all stream controllers
    for (final controller in _balanceControllers.values) {
      await controller.close();
    }
    _balanceControllers.clear();

    // Clear all other resources
    _pendingActivations.clear();
    _balanceCache.clear();
    _currentWalletId = null;
  }

  @override
  Future<void> preCacheBalance(Asset asset) async {
    if (_isDisposed) return;

    // Check if pubkeyManager is initialized
    if (_pubkeyManager == null) {
      debugPrint('Cannot pre-cache balance: PubkeyManager not initialized');
      return;
    }

    final user = await _auth.currentUser;
    if (user == null) return;

    try {
      final balance = await _pubkeyManager!
          .getPubkeys(asset)
          .then((pubkeys) => pubkeys.balance);
      _balanceCache[asset.id] = balance;

      // If there's an active stream controller for this asset, emit the balance
      final controller = _balanceControllers[asset.id];
      if (controller != null && !controller.isClosed) {
        controller.add(balance);
      }
    } catch (e) {
      // Silently fail pre-caching - this is just an optimization
      debugPrint('Failed to pre-cache balance for ${asset.id.name}: $e');
    }
  }
}
