import 'dart:async' show Completer, StreamController, TimeoutException;

import 'package:collection/collection.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart'
    show KomodoDefiLocalAuth;
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    show PrivateKeyPolicy;
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';
import 'package:mutex/mutex.dart';

/// Manager responsible for handling asset activation lifecycle
class ActivationManager {
  ActivationManager(
    this._client,
    this._auth,
    this._assetHistory,
    this._customTokenHistory,
    this._assetLookup,
    this._balanceManager,
  );

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final AssetHistoryStorage _assetHistory;
  final CustomAssetHistoryStorage _customTokenHistory;
  final IAssetLookup _assetLookup;
  final IBalanceManager _balanceManager;
  final _activationMutex = Mutex();
  static const _operationTimeout = Duration(seconds: 30);
  static final _logger = Logger('ActivationManager');

  final Map<AssetId, _ActivationState> _activations = {};
  bool _isDisposed = false;

  /// Helper for mutex-protected operations with timeout
  Future<T> _protectedOperation<T>(Future<T> Function() operation) {
    return _activationMutex
        .protect(operation)
        .timeout(
          _operationTimeout,
          onTimeout:
              () =>
                  throw TimeoutException(
                    'Operation timed out',
                    _operationTimeout,
                  ),
        );
  }

  /// Activate a single asset
  Stream<ActivationProgress> activateAsset(Asset asset) =>
      activateAssets([asset]);

  /// Activate multiple assets
  Stream<ActivationProgress> activateAssets(List<Asset> assets) async* {
    if (_isDisposed) {
      throw StateError('ActivationManager has been disposed');
    }

    final groups = _AssetGroup._groupByPrimary(assets);

    for (final group in groups) {
      final activationStatus = await _checkActivationStatus(group);
      if (activationStatus.isComplete) {
        yield activationStatus;
        continue;
      }

      final registration = await _registerActivation(group.primary.id);

      if (registration.isNew) {
        yield* _startActivation(group, registration.state);
      } else {
        yield* Stream.fromIterable(registration.state.history);
        yield* registration.state.controller.stream;
      }
    }
  }

  /// Check if asset and its children are already activated
  Future<ActivationProgress> _checkActivationStatus(_AssetGroup group) async {
    try {
      final enabledCoins =
          await _client.rpc.generalActivation.getEnabledCoins();
      final enabledAssetIds =
          enabledCoins.result
              .map((coin) => _assetLookup.findAssetsByConfigId(coin.ticker))
              .expand((assets) => assets)
              .map((asset) => asset.id)
              .toSet();

      final isActive = enabledAssetIds.contains(group.primary.id);
      final childrenActive =
          group.children?.every(
            (child) => enabledAssetIds.contains(child.id),
          ) ??
          true;

      if (isActive && childrenActive) {
        return ActivationProgress.alreadyActiveSuccess(
          assetName: group.primary.id.name,
          childCount: group.children?.length ?? 0,
        );
      }
    } catch (e) {
      _logger.warning('Failed to check activation status', e);
    }

    return const ActivationProgress(
      status: 'Needs activation',
      progressDetails: ActivationProgressDetails(
        currentStep: 'init',
        stepCount: 1,
      ),
    );
  }

  /// Register new activation attempt and return the activation state
  Future<_ActivationRegistration> _registerActivation(AssetId assetId) async {
    var isNew = false;
    late final _ActivationState state;
    await _protectedOperation(() async {
      final existing = _activations[assetId];
      if (existing != null) {
        state = existing;
        return;
      }

      state = _ActivationState(
        controller: StreamController<ActivationProgress>.broadcast(),
        completer: Completer<void>(),
      );
      _activations[assetId] = state;
      isNew = true;
    });

    return _ActivationRegistration(state, isNew: isNew);
  }

  /// Start activation for the given group and stream state to the controller
  Stream<ActivationProgress> _startActivation(
    _AssetGroup group,
    _ActivationState state,
  ) async* {
    // Verify activation status again in case it changed after the initial check
    final activationStatus = await _checkActivationStatus(group);
    if (activationStatus.isComplete) {
      _emit(state, activationStatus);
      await _handleActivationComplete(group, activationStatus, state.completer);
      await _cleanupActivation(group.primary.id);
      if (!state.controller.isClosed) {
        await state.controller.close();
      }
      yield activationStatus;
      return;
    }

    final parentAsset =
        group.parentId == null
            ? null
            : _assetLookup.fromId(group.parentId!) ??
                (throw StateError('Parent asset ${group.parentId} not found'));

    final startProgress = ActivationProgress(
      status: 'Starting activation for ${group.primary.id.name}...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'group_start',
        stepCount: 1,
        additionalInfo: {
          'primaryAsset': group.primary.id.name,
          'childCount': group.children?.length ?? 0,
        },
      ),
    );
    _emit(state, startProgress);
    yield startProgress;

    try {
      final currentUser = await _auth.currentUser;
      final privKeyPolicy =
          currentUser?.walletId.authOptions.privKeyPolicy ??
          PrivateKeyPolicy.contextPrivKey;

      final activator = ActivationStrategyFactory.createStrategy(
        _client,
        privKeyPolicy,
      );

      await for (final progress in activator.activate(
        parentAsset ?? group.primary,
        group.children?.toList(),
      )) {
        _emit(state, progress);
        yield progress;
        if (progress.isComplete) {
          await _handleActivationComplete(group, progress, state.completer);
        }
      }
    } catch (e) {
      _logger.severe('Activation failed for ${group.primary.id.name}', e);
      if (!state.completer.isCompleted) {
        state.completer.completeError(e);
      }
      if (!state.controller.isClosed) {
        state.controller.addError(e);
      }
      final failure = ActivationProgress.error(message: e.toString());
      _emit(state, failure);
      yield failure;
    } finally {
      try {
        await _cleanupActivation(group.primary.id);
      } catch (e) {
        _logger.warning(
          'Failed to cleanup activation for ${group.primary.id.name}',
          e,
        );
      }
      if (!state.controller.isClosed) {
        await state.controller.close();
      }
    }
  }

  void _emit(_ActivationState state, ActivationProgress progress) {
    state.history.add(progress);
    if (!state.controller.isClosed) {
      state.controller.add(progress);
    }
  }

  /// Handle completion of activation
  Future<void> _handleActivationComplete(
    _AssetGroup group,
    ActivationProgress progress,
    Completer<void> completer,
  ) async {
    if (progress.isSuccess) {
      final user = await _auth.currentUser;
      if (user != null) {
        await _assetHistory.addAssetToWallet(
          user.walletId,
          group.primary.id.id,
        );

        final allAssets = [group.primary, ...(group.children?.toList() ?? [])];
        for (final asset in allAssets) {
          if (asset.protocol.isCustomToken) {
            await _customTokenHistory.addAssetToWallet(user.walletId, asset);
          }
          // Pre-cache balance for the activated asset
          await _balanceManager.preCacheBalance(asset);
        }
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

  /// Cleanup after activation attempt
  Future<void> _cleanupActivation(AssetId assetId) async {
    await _protectedOperation(() async {
      _activations.remove(assetId);
    });
  }

  /// Get currently activated assets
  Future<Set<AssetId>> getActiveAssets() async {
    if (_isDisposed) {
      throw StateError('ActivationManager has been disposed');
    }

    try {
      final enabledCoins =
          await _client.rpc.generalActivation.getEnabledCoins();
      return enabledCoins.result
          .map((coin) => _assetLookup.findAssetsByConfigId(coin.ticker))
          .expand((assets) => assets)
          .map((asset) => asset.id)
          .toSet();
    } catch (e) {
      _logger.warning('Failed to get active assets', e);
      return {};
    }
  }

  /// Check if specific asset is active
  Future<bool> isAssetActive(AssetId assetId) async {
    if (_isDisposed) {
      throw StateError('ActivationManager has been disposed');
    }

    try {
      final activeAssets = await getActiveAssets();
      return activeAssets.contains(assetId);
    } catch (e) {
      _logger.warning('Failed to check if asset ${assetId.name} is active', e);
      return false;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    await _protectedOperation(() async {
      _isDisposed = true;
      for (final state in _activations.values) {
        if (!state.completer.isCompleted) {
          state.completer.completeError('ActivationManager disposed');
        }
        if (!state.controller.isClosed) {
          await state.controller.close();
        }
      }
      _activations.clear();
    });
  }
}

class _ActivationState {
  _ActivationState({required this.controller, required this.completer});

  final StreamController<ActivationProgress> controller;
  final Completer<void> completer;
  final List<ActivationProgress> history = [];
}

class _ActivationRegistration {
  _ActivationRegistration(this.state, {required this.isNew});

  final _ActivationState state;
  final bool isNew;
}

/// Internal class for grouping related assets
class _AssetGroup {
  _AssetGroup({required this.primary, this.children})
    : assert(
        children == null ||
            children.every((asset) => asset.id.parentId == primary.id),
        'All child assets must have the parent asset as their parent',
      );

  final Asset primary;
  final Set<Asset>? children;

  AssetId? get parentId =>
      children?.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

  static List<_AssetGroup> _groupByPrimary(List<Asset> assets) {
    final groups = <AssetId, _AssetGroup>{};

    for (final asset in assets) {
      if (asset.id.parentId == null) {
        // Primary asset. Preserve any previously added children.
        final existing = groups[asset.id];
        groups[asset.id] = _AssetGroup(
          primary: asset,
          children: existing?.children,
        );
      } else {
        // Child asset
        final parentId = asset.id.parentId!;
        final existing = groups[parentId];

        if (existing == null) {
          // Parent not seen yet. Use child as temporary primary.
          groups[parentId] = _AssetGroup(primary: asset, children: {asset});
        } else if (existing.children == null) {
          groups[parentId] = _AssetGroup(
            primary: existing.primary,
            children: {asset},
          );
        } else {
          existing.children!.add(asset);
        }
      }
    }

    return groups.values.toList();
  }
}
