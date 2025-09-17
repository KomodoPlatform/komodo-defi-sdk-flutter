import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/activation/activation_policy.dart';
import 'package:komodo_defi_sdk/src/activation/activation_result.dart';
import 'package:komodo_defi_sdk/src/activation/activation_state_store.dart';
import 'package:komodo_defi_sdk/src/activation/services/activation_event_bus.dart';
import 'package:komodo_defi_sdk/src/activation/services/activation_status_service.dart';
import 'package:komodo_defi_sdk/src/activation/services/availability_verifier.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart'
    show BufferedEventRetryStrategy, RetryConfig, RetryStrategy;
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';
import 'package:mutex/mutex.dart' show ReadWriteMutex;

/// Timeout configuration for different operation types
class _TimeoutConfig {
  static const Duration statusCheck = Duration(
    seconds: 10,
  ); // Network operation
  static const Duration cleanup = Duration(seconds: 3); // Internal operation
}

/// Shared coordinator for asset activations across all managers.
/// Prevents race conditions by ensuring only one activation per asset at a time
/// and sharing the result with all requesting managers.
///
/// **CONCURRENCY PROTECTION:**
/// All state access is protected by the [IActivationStateStore] implementation which
/// uses an internal [ReadWriteMutex] to ensure thread safety:
/// - Read operations (status checks, getters) use read locks for concurrency
/// - Write operations (state modifications, stream creation) use write locks for exclusivity
/// - Multiple concurrent calls to [activateAsset] or [activateAssetStream] for the same
///   asset will result in one activation being started, with subsequent calls joining
///   the existing operation and receiving the same result/stream.
///
/// **CRITICAL TIMING ISSUE HANDLING:**
/// This coordinator addresses a race condition where activation RPC can complete
/// successfully, but the coin may not immediately appear in the enabled coins list.
/// This can cause subsequent operations (balance fetching, address generation) to
/// fail with "No such coin" errors. The coordinator waits for coin availability
/// verification before declaring activation successful.
class SharedActivationCoordinator {
  /// Creates a new [SharedActivationCoordinator] with the given dependencies.
  ///
  /// [retryConfig] optional, defaults to [RetryConfig.defaultConfig]
  /// [retryStrategy] optional, defaults to [RetryStrategy.defaultStrategy]
  /// [ActivationManager] handles asset activation lifecycle reporting.
  /// [KomodoDefiLocalAuth] required to listen for auth state changes.
  /// [IActivationStatusService] optional, defaults to [ActivationStatusService]
  /// [IAvailabilityVerifier] optional, defaults to [AvailabilityVerifier]
  /// [IActivationEventBus] optional, defaults to [ActivationEventBus]
  /// [IActivationStateStore] optional, defaults to [ActivationStateStore]
  SharedActivationCoordinator(
    this._activationManager,
    this._auth, {
    RetryConfig? retryConfig,
    RetryStrategy? retryStrategy,
    IActivationStatusService? statusService,
    IAvailabilityVerifier? availabilityVerifier,
    IActivationEventBus? eventBus,
    IActivationStateStore? stateStore,
  }) : _policy = ActivationPolicy(
         retryConfig ?? RetryConfig.minuteTimeout(),
         retryStrategy ?? const BufferedEventRetryStrategy(),
       ),
       _state = stateStore ?? ActivationStateStore(),
       _events = eventBus ?? ActivationEventBus() {
    _status = statusService ?? ActivationStatusService(_activationManager);
    _availability = availabilityVerifier ?? AvailabilityVerifier(_status);
    _authSubscription = _auth.authStateChanges.listen(_handleAuthStateChanged);
  }

  final ActivationManager _activationManager;
  final KomodoDefiLocalAuth _auth;

  late final StreamSubscription<KdfUser?>? _authSubscription;
  late final IActivationStatusService _status;
  late final IAvailabilityVerifier _availability;

  /// Central policy and mutable state/event store
  final ActivationPolicy _policy;
  final IActivationStateStore _state;
  final IActivationEventBus _events;

  /// Current wallet ID being tracked
  WalletId? _currentWalletId;

  bool _isDisposed = false;

  final Logger _logger = Logger('SharedActivationCoordinator');

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
    _logger.info(
      'Resetting SharedActivationCoordinator state due to wallet change',
    );

    // Cancel all pending activations before clearing
    final pendingAssetIds = await _state.getPendingAssetIds();
    for (final assetId in pendingAssetIds) {
      final completer = await _state.getPendingActivation(assetId);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(
          StateError('Wallet changed, activation cancelled'),
        );
      }
    }

    await _state.reset();
    await _broadcastPendingActivations();
    await _broadcastFailedActivations();
  }

  /// Activate an asset with coordination across all managers.
  /// Returns a Future that completes when activation is finished.
  /// Multiple concurrent calls for the same asset will share the same result.
  Future<ActivationResult> activateAsset(Asset asset) async {
    if (_isDisposed) {
      throw StateError('SharedActivationCoordinator has been disposed');
    }

    _logger.info('Activation requested for asset: ${asset.id.id}');

    final existingActivation = await _state.getPendingActivation(asset.id);
    if (existingActivation != null) {
      _logger.info('Joining existing activation for ${asset.id.id}');
      return existingActivation.future;
    }

    final isActive = await _status
        .isAssetActive(asset.id)
        .timeout(_TimeoutConfig.statusCheck);
    if (isActive) {
      _logger.info('Asset ${asset.id.id} is already active, returning success');
      return ActivationResult.success(asset.id);
    }

    // Create completer and register activation
    final newCompleter = Completer<ActivationResult>();
    final existingCompleter = await _state.registerPendingActivation(
      asset.id,
      newCompleter,
    );

    // If another activation was already registered, join it
    if (existingCompleter != null) {
      _logger.info(
        'Joining activation that started while registering: ${asset.id.id}',
      );
      return existingCompleter.future;
    }

    // Clear any previous failed status for this asset
    final wasCleared = await _state.clearFailedAsset(asset.id);
    if (wasCleared) {
      _logger.info(
        'Cleared previous failed activation status for ${asset.id.id}',
      );
    }

    // Broadcast that this asset is now pending
    _logger.info('Starting activation for ${asset.id.id}');
    await _broadcastPendingActivations();
    await _broadcastFailedActivations();

    try {
      // If a stream activation is already in progress, join it and wait for completion
      final existingStream = await _state.existingStreamWithHistory(asset.id);
      if (existingStream != null) {
        await _watchExistingStream(asset, existingStream, newCompleter);
      } else {
        // Execute activation using injected executor
        final activationStream = _policy.retryStrategy
            .executeWithRetry<ActivationProgress>(
              () => _activationManager.activateAssets([asset]),
              _policy.retryConfig,
            );
        await for (final progress in activationStream) {
          if (progress.isComplete) {
            if (progress.isSuccess) {
              try {
                await _availability.waitUntilAvailable(asset.id);
                _logger.info('Successfully activated asset: ${asset.id.id}');
                final result = ActivationResult.success(asset.id);
                if (!newCompleter.isCompleted) {
                  newCompleter.complete(result);
                }
              } catch (e) {
                _logger.warning(
                  'Activation completed but coin ${asset.id.id} did not become available: $e',
                );
                await _state.markAssetFailed(
                  asset.id,
                  'Activation completed but coin did not become available: $e',
                );
                await _broadcastFailedActivations();
                final result = ActivationResult.failure(
                  asset.id,
                  'Activation completed but coin did not become available: $e',
                );
                if (!newCompleter.isCompleted) {
                  newCompleter.complete(result);
                }
              }
            } else {
              final errorMsg =
                  progress.errorMessage ?? 'Unknown activation error';
              _logger.warning(
                'Activation failed for ${asset.id.id}: $errorMsg',
              );
              await _state.markAssetFailed(asset.id, errorMsg);
              await _broadcastFailedActivations();
              final result = ActivationResult.failure(asset.id, errorMsg);
              if (!newCompleter.isCompleted) {
                newCompleter.complete(result);
              }
            }
            break;
          }
        }
      }
    } on TimeoutException catch (e) {
      if (!newCompleter.isCompleted) {
        await _state.markAssetFailed(asset.id);
        await _broadcastFailedActivations();
        _logger.severe('Activation timed out for ${asset.id.id}: $e', e);
        newCompleter.complete(
          ActivationResult.failure(
            asset.id,
            'Activation timed out: ${e.message}',
          ),
        );
      }
    } catch (e, stackTrace) {
      if (!newCompleter.isCompleted) {
        await _state.markAssetFailed(asset.id);
        await _broadcastFailedActivations();
        _logger.severe(
          'Activation failed for ${asset.id.id}: $e',
          e,
          stackTrace,
        );
        newCompleter.complete(ActivationResult.failure(asset.id, e.toString()));
      }
    } finally {
      await _state.removePendingActivation(asset.id);
      _logger.info('Completed activation attempt for ${asset.id.id}');
      await _broadcastPendingActivations();
    }

    return newCompleter.future;
  }

  Future<void> _watchExistingStream(
    Asset asset,
    Stream<ActivationProgress> existingStream,
    Completer<ActivationResult> newCompleter,
  ) async {
    _logger.info(
      'Activation stream already running for ${asset.id.id}, waiting for completion',
    );
    await for (final progress in existingStream) {
      if (progress.isComplete) {
        if (progress.isSuccess) {
          try {
            await _availability.waitUntilAvailable(asset.id);
            _logger.info(
              'Successfully activated asset (joined): ${asset.id.id}',
            );
            final result = ActivationResult.success(asset.id);
            if (!newCompleter.isCompleted) {
              newCompleter.complete(result);
            }
          } catch (e) {
            _logger.warning(
              'Activation completed (joined) but coin ${asset.id.id} did not become available: $e',
            );
            await _state.markAssetFailed(
              asset.id,
              'Activation completed but coin did not become available: $e',
            );
            await _broadcastFailedActivations();
            final result = ActivationResult.failure(
              asset.id,
              'Activation completed but coin did not become available: $e',
            );
            if (!newCompleter.isCompleted) {
              newCompleter.complete(result);
            }
          }
        } else {
          final errorMsg = progress.errorMessage ?? 'Unknown activation error';
          _logger.warning('Activation failed for ${asset.id.id}: $errorMsg');
          await _state.markAssetFailed(asset.id, errorMsg);
          await _broadcastFailedActivations();
          final result = ActivationResult.failure(asset.id, errorMsg);
          if (!newCompleter.isCompleted) {
            newCompleter.complete(result);
          }
        }
        break;
      }
    }
  }

  /// Get activation progress stream for an asset.
  /// Multiple subscribers will share the same stream.
  Stream<ActivationProgress> activateAssetStream(Asset asset) {
    if (_isDisposed) {
      throw StateError('SharedActivationCoordinator has been disposed');
    }

    _logger.info('Activation stream requested for asset: ${asset.id.id}');

    return _createStreamWithMutexProtection(asset);
  }

  Stream<ActivationProgress> _createStreamWithMutexProtection(
    Asset asset,
  ) async* {
    // Check for existing stream
    final existing = await _state.existingStreamWithHistory(asset.id);
    if (existing != null) {
      _logger.info('Joining existing activation stream for ${asset.id.id}');
      yield* existing;
      return;
    }

    // Create new stream controller
    _logger.info('Creating new activation stream for ${asset.id.id}');
    late final StreamController<ActivationProgress> controller;
    controller = StreamController<ActivationProgress>.broadcast(
      onCancel: () async {
        if (controller.hasListener == false) {
          await _state.removeActiveStream(asset.id);
          await controller.close();
        }
      },
    );

    await _state.registerActiveStream(asset.id, controller);

    // Check again if another stream was created while we were setting up
    final doubleCheck = await _state.existingStreamWithHistory(asset.id);
    if (doubleCheck != null && doubleCheck != controller.stream) {
      _logger.info('Joining stream created while setting up: ${asset.id.id}');
      await controller.close();
      yield* doubleCheck;
      return;
    }

    _activationManager
        .activateAsset(asset)
        .listen(
          (progress) async {
            // Add progress to history and notify stream
            await _state.addProgressToHistory(asset.id, progress);

            if (progress.isComplete) {
              _logger.info(
                'Stream activation '
                '${progress.isSuccess ? 'completed' : 'failed'} '
                'for ${asset.id.id}',
              );
              if (!progress.isSuccess) {
                await _state.markAssetFailed(
                  asset.id,
                  progress.errorMessage ?? 'Unknown activation error',
                );
                await _broadcastFailedActivations();
              }
              Timer.run(() async {
                final toClose = await _state.removeActiveStream(asset.id);
                if (toClose != null && !toClose.isClosed) {
                  await toClose.close();
                }
              });
            }
          },
          onError: (Object error, StackTrace stackTrace) async {
            _logger.severe(
              'Error in activation stream for ${asset.id.id}: $error',
              error,
              stackTrace,
            );
            await _state.markAssetFailed(asset.id, error.toString());
            await _broadcastFailedActivations();

            final current = await _state.getActiveStream(asset.id);
            if (current != null && !current.isClosed) {
              current.addError(error, stackTrace);
              await _state.removeActiveStream(asset.id);
              await current.close();
            }
          },
          onDone: () async {
            final toClose = await _state.removeActiveStream(asset.id);
            if (toClose != null && !toClose.isClosed) {
              await toClose.close();
            }
          },
        );

    // Return the stream with history that's already created by the state store
    final streamWithHistory = await _state.existingStreamWithHistory(asset.id);
    if (streamWithHistory != null) {
      yield* streamWithHistory;
    }
  }

  /// Check if an asset is currently being activated
  Future<bool> isActivationInProgress(AssetId assetId) async {
    final hasPending = await _state.getPendingActivation(assetId) != null;
    final hasStream = await _state.hasActiveStream(assetId);
    return hasPending || hasStream;
  }

  /// Check if an asset is active (delegated to ActivationManager)
  Future<bool> isAssetActive(AssetId assetId) async {
    try {
      return await _status
          .isAssetActive(assetId)
          .timeout(_TimeoutConfig.statusCheck);
    } on TimeoutException catch (e) {
      _logger.warning(
        'Status check timed out for ${assetId.id}: $e, returning false',
      );
      return false;
    }
  }

  /// Watch failed activations.
  /// Returns a stream that emits the current set of failed asset IDs
  /// whenever it changes.
  Stream<Set<AssetId>> watchFailedActivations() {
    if (_isDisposed) {
      throw StateError('SharedActivationCoordinator has been disposed');
    }
    return _events.watchFailed();
  }

  /// Watch pending activations.
  /// Returns a stream that emits the current set of pending asset IDs
  /// whenever it changes.
  Stream<Set<AssetId>> watchPendingActivations() {
    if (_isDisposed) {
      throw StateError('SharedActivationCoordinator has been disposed');
    }
    return _events.watchPending();
  }

  /// Get current set of failed activations
  Future<Set<AssetId>> get failedActivations async {
    return _state.getFailedAssetIds();
  }

  /// Get current set of pending activations
  Future<Set<AssetId>> get pendingActivations async {
    return _state.getPendingAssetIds();
  }

  /// Clear failed activation status for an asset
  Future<void> clearFailedActivation(AssetId assetId) async {
    final wasRemoved = await _state.clearFailedAsset(assetId);
    if (wasRemoved) {
      _logger.info('Cleared failed activation status for ${assetId.id}');
      await _broadcastFailedActivations();
    }
  }

  /// Clear all failed activations
  Future<void> clearAllFailedActivations() async {
    final count = await _state.clearAllFailedAssets();
    if (count > 0) {
      _logger.info('Cleared all failed activations ($count assets)');
      await _broadcastFailedActivations();
    }
  }

  // Unused: internal retry/availability helpers now live in dedicated classes.

  /// Broadcast current failed activations to stream listeners
  Future<void> _broadcastFailedActivations() async {
    final failed = await _state.getFailedAssetIds();
    _events.emitFailed(failed);
  }

  /// Broadcast current pending activations to stream listeners
  Future<void> _broadcastPendingActivations() async {
    final pending = await _state.getPendingAssetIds();
    _events.emitPending(pending);
  }

  /// Dispose of the coordinator and clean up resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _logger.info('Disposing SharedActivationCoordinator');

    // Cancel auth subscription
    await _authSubscription?.cancel();

    // Cancel all pending activations before clearing
    final pendingAssetIds = await _state.getPendingAssetIds();
    for (final assetId in pendingAssetIds) {
      final completer = await _state.getPendingActivation(assetId);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(
          StateError('SharedActivationCoordinator disposed'),
        );
      }
    }

    await _state.reset();

    // Close event bus
    try {
      await _events.dispose().timeout(_TimeoutConfig.cleanup);
    } catch (e, s) {
      _logger.warning('Failed to close activation event bus', e, s);
    }
  }
}
