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
/// Manager responsible for handling asset activation lifecycle
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

    _logger.info(
      'Activating ${assets.length} assets: '
      '${assets.map((a) => a.id.name).join(', ')}',
    );
    final groups = _AssetGroup._groupByPrimary(assets, _assetLookup);
    _logger.fine('Created ${groups.length} asset groups for activation');

    for (final group in groups) {
      _logger.fine(
        'Processing group for ${group.primary.id.name} with '
        '${group.children?.length ?? 0} children',
      );
      final activationStatus = await _checkActivationStatus(group);
      if (activationStatus.isComplete) {
        _logger.fine(
          'Group ${group.primary.id.id} is already active, skipping',
        );
        yield activationStatus;
        continue;
      }

      final registration = await _registerActivation(group.primary.id);

      if (registration.isNew) {
        _logger.info('Starting new activation for ${group.primary.id.name}');
        yield* _startActivation(group, registration.state);
      } else {
        _logger.fine(
          'Joining existing activation for ${group.primary.id.name}',
        );
        yield* Stream.fromIterable(registration.state.history);
        yield* registration.state.controller.stream;
      }
    }
  }

  /// Check if asset and its children are already activated
  Future<ActivationProgress> _checkActivationStatus(_AssetGroup group) async {
    _logger.fine(
      'Checking activation status for group ${group.primary.id.name}',
    );
    try {
      final enabledCoins =
          await _client.rpc.generalActivation.getEnabledCoins();
      final enabledAssetIds =
          enabledCoins.result
              .map((coin) => _assetLookup.findAssetsByConfigId(coin.ticker))
              .expand((assets) => assets)
              .map((asset) => asset.id)
              .toSet();

      _logger.fine('Found ${enabledAssetIds.length} enabled assets');
      final isActive = enabledAssetIds.contains(group.primary.id);
      final childrenActive =
          group.children?.every(
            (child) => enabledAssetIds.contains(child.id),
          ) ??
          true;

      _logger.fine(
        'Primary ${group.primary.id.name} active: $isActive, '
        'children active: $childrenActive',
      );
      if (isActive && childrenActive) {
        _logger.fine(
          'Group ${group.primary.id.name} is already fully activated',
        );
        return ActivationProgress.alreadyActiveSuccess(
          assetName: group.primary.id.name,
          childCount: group.children?.length ?? 0,
        );
      }
    } catch (e) {
      _logger.warning(
        'Failed to check activation status for ${group.primary.id.name}',
        e,
      );
    }

    _logger.fine('Group ${group.primary.id.name} needs activation');
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
    _logger.fine('Registering activation for ${assetId.name}');
    var isNew = false;
    late final _ActivationState state;
    await _protectedOperation(() async {
      final existing = _activations[assetId];
      if (existing != null) {
        _logger.fine('Found existing activation state for ${assetId.name}');
        state = existing;
        return;
      }

      _logger.fine('Creating new activation state for ${assetId.name}');
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
    _logger.fine('Starting activation for group ${group.primary.id.name}');

    // Verify activation status again in case it changed after the initial check
    final activationStatus = await _checkActivationStatus(group);
    if (activationStatus.isComplete) {
      _logger.fine(
        'Group ${group.primary.id.name} became active after re-check, completing',
      );
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

    _logger.fine(
      'Using ${parentAsset?.id.name ?? group.primary.id.name} as activation target',
    );

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
          const PrivateKeyPolicy.contextPrivKey();

      _logger.fine('Creating activation strategy for ${group.primary.id.name}');
      final activator = ActivationStrategyFactory.createStrategy(
        _client,
        privKeyPolicy,
      );

      _logger.fine('Starting activation process for ${group.primary.id.name}');
      await for (final progress in activator.activate(
        parentAsset ?? group.primary,
        group.children?.toList(),
      )) {
        _logger.fine(
          'Activation progress for ${group.primary.id.name}: ${progress.status}',
        );
        _emit(state, progress);
        yield progress;
        if (progress.isComplete) {
          _logger.info('Activation completed for ${group.primary.id.name}');
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
    _logger.fine('Emitting progress: ${progress.status}');
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
    _logger.fine(
      'Handling activation completion for ${group.primary.id.name}, success: ${progress.isSuccess}',
    );

    if (progress.isSuccess) {
      final user = await _auth.currentUser;
      if (user != null) {
        _logger.fine(
          'Adding ${group.primary.id.name} to user wallet ${user.walletId}',
        );
        await _assetHistory.addAssetToWallet(
          user.walletId,
          group.primary.id.id,
        );

        final allAssets = [group.primary, ...(group.children?.toList() ?? [])];
        _logger.fine(
          'Processing ${allAssets.length} assets for post-activation tasks',
        );

        for (final asset in allAssets) {
          if (asset.protocol.isCustomToken) {
            _logger.fine(
              'Adding custom token ${asset.id.name} to wallet history',
            );
            await _customTokenHistory.addAssetToWallet(user.walletId, asset);
          }
          // Pre-cache balance for the activated asset
          _logger.fine('Pre-caching balance for ${asset.id.name}');
          await _balanceManager.preCacheBalance(asset);
        }
      } else {
        _logger.warning('No current user found during activation completion');
      }

      if (!completer.isCompleted) {
        _logger.fine(
          'Completing activation future for ${group.primary.id.name}',
        );
        completer.complete();
      }
    } else {
      _logger.warning(
        'Activation failed for ${group.primary.id.name}: ${progress.errorMessage}',
      );
      if (!completer.isCompleted) {
        completer.completeError(progress.errorMessage ?? 'Unknown error');
      }
    }
  }

  /// Cleanup after activation attempt
  Future<void> _cleanupActivation(AssetId assetId) async {
    _logger.fine('Cleaning up activation state for ${assetId.name}');
    await _protectedOperation(() async {
      _activations.remove(assetId);
      _logger.fine('Removed activation state for ${assetId.name}');
    });
  }

  /// Get currently activated assets
  Future<Set<AssetId>> getActiveAssets() async {
    if (_isDisposed) {
      throw StateError('ActivationManager has been disposed');
    }

    _logger.fine('Getting currently active assets');
    try {
      final enabledCoins =
          await _client.rpc.generalActivation.getEnabledCoins();
      final activeAssets =
          enabledCoins.result
              .map((coin) => _assetLookup.findAssetsByConfigId(coin.ticker))
              .expand((assets) => assets)
              .map((asset) => asset.id)
              .toSet();

      _logger.fine('Found ${activeAssets.length} active assets');
      return activeAssets;
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

    _logger.fine('Checking if asset ${assetId.name} is active');
    try {
      final activeAssets = await getActiveAssets();
      final isActive = activeAssets.contains(assetId);
      _logger.fine(
        'Asset ${assetId.name} is ${isActive ? 'active' : 'inactive'}',
      );
      return isActive;
    } catch (e) {
      _logger.warning('Failed to check if asset ${assetId.name} is active', e);
      return false;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    _logger.info('Disposing ActivationManager');
    await _protectedOperation(() async {
      _isDisposed = true;
      _logger.fine('Cleaning up ${_activations.length} pending activations');
      for (final state in _activations.values) {
        if (!state.completer.isCompleted) {
          state.completer.completeError('ActivationManager disposed');
        }
        if (!state.controller.isClosed) {
          await state.controller.close();
        }
      }
      _activations.clear();
      _logger.fine('ActivationManager disposed successfully');
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
        'All child assets must have the parent asset as their parent '
        'primary ${primary.id}, child assets: $children',
      );

  final Asset primary;
  final Set<Asset>? children;
  static final _logger = Logger('_AssetGroup');

  AssetId? get parentId =>
      children?.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

  static List<_AssetGroup> _groupByPrimary(
    List<Asset> assets,
    IAssetLookup assetLookup,
  ) {
    _logger.fine('Grouping ${assets.length} assets by primary');
    final groups = <AssetId, _AssetGroup>{};

    for (final asset in assets) {
      if (asset.id.parentId == null) {
        // Primary asset. Preserve any previously added children.
        _logger.fine('Processing primary asset: ${asset.id.name}');
        final existing = groups[asset.id];
        if (existing != null) {
          _logger.fine(
            'Found existing group for ${asset.id.name}, '
            'preserving ${existing.children?.length ?? 0} children',
          );
        }
        groups[asset.id] = _AssetGroup(
          primary: asset,
          children: existing?.children,
        );
      } else {
        // Child asset - look up the parent using asset lookup
        final parentId = asset.id.parentId!;
        _logger.fine(
          'Processing child asset: ${asset.id.name} with parent: '
          '${parentId.name}',
        );
        final existing = groups[parentId];

        if (existing == null) {
          _logger.fine(
            'Parent ${parentId.name} not yet seen, looking up via asset lookup',
          );
          final parentAsset = assetLookup.fromId(parentId);
          if (parentAsset == null) {
            _logger.warning(
              'Parent asset ${parentId.name} not found in asset lookup, '
              'skipping child ${asset.id.name}',
            );
            continue;
          }

          _logger.fine(
            'Found parent asset ${parentAsset.id.name}, '
            'creating new group with child ${asset.id.name}',
          );
          // Create new group with the looked-up parent as primary
          groups[parentId] = _AssetGroup(
            primary: parentAsset,
            children: {asset},
          );
        } else if (existing.children == null) {
          _logger.fine(
            'Adding first child ${asset.id.name} to existing group '
            'for ${existing.primary.id.name}',
          );
          groups[parentId] = _AssetGroup(
            primary: existing.primary,
            children: {asset},
          );
        } else {
          _logger.fine(
            'Adding child ${asset.id.name} to existing group for '
            '${existing.primary.id.name} (${existing.children!.length} '
            'existing children)',
          );
          existing.children!.add(asset);
        }
      }
    }

    final result = groups.values.toList();
    _logger.fine('Grouped assets into ${result.length} groups');
    for (final group in result) {
      _logger.fine(
        'Group: ${group.primary.id.name} with '
        '${group.children?.length ?? 0} children',
      );
    }

    return result;
  }
}
