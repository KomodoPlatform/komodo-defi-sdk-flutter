import 'dart:async';

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Event bus for activation lifecycle state updates.
///
/// Exposes broadcast streams for tracking which assets are pending activation
/// and which have failed, and provides imperative emit methods.
abstract class IActivationEventBus {
  /// Broadcast stream of assets currently marked as failed.
  Stream<Set<AssetId>> watchFailed();

  /// Broadcast stream of assets currently pending activation.
  Stream<Set<AssetId>> watchPending();

  /// Emits a new snapshot of failed assets to listeners.
  void emitFailed(Set<AssetId> failed);

  /// Emits a new snapshot of pending assets to listeners.
  void emitPending(Set<AssetId> pending);

  /// Closes all streams and releases resources.
  Future<void> dispose();
}

/// Simple broadcast-based implementation of [IActivationEventBus].
///
/// Emits defensive copies to avoid accidental mutation by listeners.
class ActivationEventBus implements IActivationEventBus {
  final StreamController<Set<AssetId>> _failed =
      StreamController<Set<AssetId>>.broadcast();
  final StreamController<Set<AssetId>> _pending =
      StreamController<Set<AssetId>>.broadcast();

  /// See [IActivationEventBus.watchFailed].
  @override
  Stream<Set<AssetId>> watchFailed() => _failed.stream;

  /// See [IActivationEventBus.watchPending].
  @override
  Stream<Set<AssetId>> watchPending() => _pending.stream;

  /// See [IActivationEventBus.emitFailed].
  @override
  void emitFailed(Set<AssetId> failed) {
    if (!_failed.isClosed) _failed.add(Set<AssetId>.from(failed));
  }

  /// See [IActivationEventBus.emitPending].
  @override
  void emitPending(Set<AssetId> pending) {
    if (!_pending.isClosed) _pending.add(Set<AssetId>.from(pending));
  }

  /// See [IActivationEventBus.dispose].
  @override
  Future<void> dispose() async {
    if (!_failed.isClosed) await _failed.close();
    if (!_pending.isClosed) await _pending.close();
  }
}
