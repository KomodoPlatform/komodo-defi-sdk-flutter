import 'dart:async';

import 'package:komodo_defi_sdk/src/activation/activation_result.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

/// Mutable store for activation coordination state and related helpers.
///
/// Tracks per-asset pending operations, progress streams (with history),
/// and the last known failures and reasons. All operations are internally
/// protected by a [ReadWriteMutex] for thread safety.
abstract class IActivationStateStore {
  // Pending operations
  /// Get pending activation completer for an asset.
  Future<Completer<ActivationResult>?> getPendingActivation(AssetId assetId);

  /// Register a new pending activation.
  Future<Completer<ActivationResult>?> registerPendingActivation(
    AssetId assetId,
    Completer<ActivationResult> completer,
  );

  /// Remove pending activation and return whether it existed.
  Future<bool> removePendingActivation(AssetId assetId);

  /// Get all pending asset IDs.
  Future<Set<AssetId>> getPendingAssetIds();

  /// Clear all pending activations.
  Future<void> clearPendingActivations();

  // Stream management
  /// Whether a non-closed progress stream exists for the given asset.
  Future<bool> hasActiveStream(AssetId assetId);

  /// Get active stream controller for an asset.
  Future<StreamController<ActivationProgress>?> getActiveStream(
    AssetId assetId,
  );

  /// Register a new active stream controller.
  Future<void> registerActiveStream(
    AssetId assetId,
    StreamController<ActivationProgress> controller,
  );

  /// Remove active stream controller.
  Future<StreamController<ActivationProgress>?> removeActiveStream(
    AssetId assetId,
  );

  /// Add progress to history and notify active stream if present.
  Future<void> addProgressToHistory(
    AssetId assetId,
    ActivationProgress progress,
  );

  /// Returns a stream that first replays known history for the asset, then
  /// continues with live progress events if a stream is currently active.
  Future<Stream<ActivationProgress>?> existingStreamWithHistory(
    AssetId assetId,
  );

  // Failure tracking
  /// Check if an asset has failed activation.
  Future<bool> isAssetFailed(AssetId assetId);

  /// Mark an asset as failed with optional reason.
  Future<void> markAssetFailed(AssetId assetId, [String? reason]);

  /// Clear failed status for an asset.
  Future<bool> clearFailedAsset(AssetId assetId);

  /// Get all failed asset IDs.
  Future<Set<AssetId>> getFailedAssetIds();

  /// Clear all failed assets.
  Future<int> clearAllFailedAssets();

  /// Clears all in-memory state, closing any open streams.
  Future<void> reset();
}

/// Default in-memory implementation of [IActivationStateStore] with internal
/// [ReadWriteMutex] protection for thread safety.
class ActivationStateStore implements IActivationStateStore {
  /// Creates a new [ActivationStateStore].
  ActivationStateStore();

  final ReadWriteMutex _mutex = ReadWriteMutex();
  final Map<AssetId, Completer<ActivationResult>> _pending = {};
  final Map<AssetId, StreamController<ActivationProgress>> _activeStreams = {};
  final Map<AssetId, List<ActivationProgress>> _progressHistory = {};
  final Set<AssetId> _failed = <AssetId>{};
  final Map<AssetId, String> _lastFailureReasons = {};

  // Pending operations
  @override
  Future<Completer<ActivationResult>?> getPendingActivation(AssetId assetId) {
    return _mutex.protectRead(() async => _pending[assetId]);
  }

  @override
  Future<Completer<ActivationResult>?> registerPendingActivation(
    AssetId assetId,
    Completer<ActivationResult> completer,
  ) {
    return _mutex.protectWrite(() async {
      final existing = _pending[assetId];
      if (existing != null) {
        return existing; // Return existing if already registered
      }
      _pending[assetId] = completer;
      return null; // Indicate new registration
    });
  }

  @override
  Future<bool> removePendingActivation(AssetId assetId) {
    return _mutex.protectWrite(() async {
      return _pending.remove(assetId) != null;
    });
  }

  @override
  Future<Set<AssetId>> getPendingAssetIds() {
    return _mutex.protectRead(() async => _pending.keys.toSet());
  }

  @override
  Future<void> clearPendingActivations() {
    return _mutex.protectWrite(() async {
      _pending.clear();
    });
  }

  // Stream management
  @override
  Future<bool> hasActiveStream(AssetId assetId) {
    return _mutex.protectRead(() async {
      final c = _activeStreams[assetId];
      return c != null && !c.isClosed;
    });
  }

  @override
  Future<StreamController<ActivationProgress>?> getActiveStream(
    AssetId assetId,
  ) {
    return _mutex.protectRead(() async => _activeStreams[assetId]);
  }

  @override
  Future<void> registerActiveStream(
    AssetId assetId,
    StreamController<ActivationProgress> controller,
  ) {
    return _mutex.protectWrite(() async {
      _activeStreams[assetId] = controller;
    });
  }

  @override
  Future<StreamController<ActivationProgress>?> removeActiveStream(
    AssetId assetId,
  ) {
    return _mutex.protectWrite(() async {
      return _activeStreams.remove(assetId);
    });
  }

  @override
  Future<void> addProgressToHistory(
    AssetId assetId,
    ActivationProgress progress,
  ) {
    return _mutex.protectWrite(() async {
      _progressHistory
          .putIfAbsent(assetId, () => <ActivationProgress>[])
          .add(progress);

      // Notify active stream if present
      final current = _activeStreams[assetId];
      if (current != null && !current.isClosed) {
        current.add(progress);
      }
    });
  }

  @override
  Future<Stream<ActivationProgress>?> existingStreamWithHistory(
    AssetId assetId,
  ) {
    return _mutex.protectRead(() async {
      final controller = _activeStreams[assetId];
      if (controller == null || controller.isClosed) {
        return null;
      }

      Stream<ActivationProgress> historyThenLive() async* {
        // Re-acquire read lock for history access
        final history = await _mutex.protectRead(
          () async => _progressHistory[assetId],
        );
        if (history != null && history.isNotEmpty) {
          for (final p in history) {
            yield p;
          }
        }

        // Re-acquire read lock for current stream access
        final current = await _mutex.protectRead(
          () async => _activeStreams[assetId],
        );
        if (current != null) {
          yield* current.stream;
        }
      }

      return historyThenLive();
    });
  }

  // Failure tracking
  @override
  Future<bool> isAssetFailed(AssetId assetId) {
    return _mutex.protectRead(() async => _failed.contains(assetId));
  }

  @override
  Future<void> markAssetFailed(AssetId assetId, [String? reason]) {
    return _mutex.protectWrite(() async {
      _failed.add(assetId);
      if (reason != null) {
        _lastFailureReasons[assetId] = reason;
      }
    });
  }

  @override
  Future<bool> clearFailedAsset(AssetId assetId) {
    return _mutex.protectWrite(() async {
      final removed = _failed.remove(assetId);
      _lastFailureReasons.remove(assetId);
      return removed;
    });
  }

  @override
  Future<Set<AssetId>> getFailedAssetIds() {
    return _mutex.protectRead(() async => Set<AssetId>.from(_failed));
  }

  @override
  Future<int> clearAllFailedAssets() {
    return _mutex.protectWrite(() async {
      final count = _failed.length;
      _failed.clear();
      _lastFailureReasons.clear();
      return count;
    });
  }

  @override
  Future<void> reset() async {
    await _mutex.protectWrite(() async {
      for (final controller in _activeStreams.values) {
        if (!controller.isClosed) {
          await controller.close();
        }
      }
      _activeStreams.clear();
      _progressHistory.clear();
      _pending.clear();
      _failed.clear();
      _lastFailureReasons.clear();
    });
  }
}
