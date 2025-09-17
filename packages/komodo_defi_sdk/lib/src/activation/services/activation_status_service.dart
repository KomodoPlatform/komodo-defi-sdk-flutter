import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';
import 'package:mutex/mutex.dart';

/// Service interface for activation status queries with concurrency protection.
abstract class IActivationStatusService {
  /// Whether the given `assetId` is currently active/available locally.
  ///
  /// Implementations may perform I/O and should be considered potentially slow.
  Future<bool> isAssetActive(AssetId assetId);

  /// Snapshot of all assets currently considered active.
  Future<Set<AssetId>> getActiveAssets();
}

/// Default implementation that deduplicates in-flight checks and uses
/// per-asset mutexes to serialize concurrent queries for the same asset.
class ActivationStatusService implements IActivationStatusService {
  /// Creates a new [ActivationStatusService] with the given activation manager.
  ActivationStatusService(this._activationManager);

  final ActivationManager _activationManager;
  final Logger _logger = Logger('ActivationStatusService');

  final Map<AssetId, Mutex> _locks = <AssetId, Mutex>{};
  final Map<AssetId, Future<bool>> _inflight = <AssetId, Future<bool>>{};

  Mutex _lockFor(AssetId id) => _locks.putIfAbsent(id, Mutex.new);

  /// See [IActivationStatusService.isAssetActive]. Deduplicates in-flight
  /// checks per asset and serializes them via a per-asset mutex.
  @override
  Future<bool> isAssetActive(AssetId assetId) {
    final existing = _inflight[assetId];
    if (existing != null) return existing;

    final future = _lockFor(assetId).protect(() async {
      try {
        return await _activationManager.isAssetActive(assetId);
      } catch (e, s) {
        _logger.fine('isAssetActive failed for ${assetId.id}', e, s);
        rethrow;
      } finally {
        await _inflight.remove(assetId);
      }
    });

    _inflight[assetId] = future;
    return future;
  }

  /// See [IActivationStatusService.getActiveAssets].
  @override
  Future<Set<AssetId>> getActiveAssets() {
    // TODO: consider protecting with a mutex
    return _activationManager.getActiveAssets();
  }
}
