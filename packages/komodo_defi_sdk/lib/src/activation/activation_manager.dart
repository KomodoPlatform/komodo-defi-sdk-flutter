import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart' show retryStream;
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

import 'base_strategies/activation_strategy_factory.dart';

/// Manager responsible for handling asset activation lifecycle
class ActivationManager {
  /// Manager responsible for handling asset activation lifecycle
  ActivationManager(
    this._client,
    this._auth,
    this._assetHistory,
    this._customTokenHistory,
    this._assetLookup,
    this._balanceManager, {
    required IAssetRefreshNotifier assetRefreshNotifier,
    IActivationStrategyFactory? activationStrategyFactory,
    Duration? operationTimeout,
  }) : _activationStrategyFactory =
           activationStrategyFactory ??
           const DefaultActivationStrategyFactory(),
       _operationTimeout = operationTimeout ?? const Duration(seconds: 30);
  }) : _assetRefreshNotifier = assetRefreshNotifier;

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final AssetHistoryStorage _assetHistory;
  final CustomAssetHistoryStorage _customTokenHistory;
  final IAssetLookup _assetLookup;
  final IAssetRefreshNotifier _assetRefreshNotifier;
  final IBalanceManager _balanceManager;
  final IActivationStrategyFactory _activationStrategyFactory;
  final Duration _operationTimeout;
  final _activationMutex = Mutex();
  static final _logger = Logger('ActivationManager');

  final Map<AssetId, Completer<void>> _activationCompleters = {};
  bool _isDisposed = false;

  /// Helper for mutex-protected operations with timeout
  Future<T> _protectedOperation<T>(Future<T> Function() operation) {
    return _activationMutex
        .protect(operation)
        .timeout(
          _operationTimeout,
          onTimeout: () =>
              throw TimeoutException('Operation timed out', _operationTimeout),
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
    final groups = AssetGroup.groupByPrimary(assets, _assetLookup);
    _logger.fine('Created ${groups.length} asset groups for activation');

    for (final group in groups) {
      // Check activation status atomically
      final activationStatus = await _checkActivationStatus(group);
      if (activationStatus.isComplete) {
        yield activationStatus;
        continue;
      }

      final registration = await _registerActivation(group.primary.id);
      if (!registration.isNew) {
        _logger.fine(
          'Joining existing activation for ${group.primary.id.name}',
          'Yielding state history and existing state to new subscribers',
        );

        // Yield the full history and current state to new subscribers
        // This allows new listeners to catch up on the activation progress
        yield* Stream.fromIterable(registration.state.history);
        yield* registration.state.controller.stream;
      }

      _logger.info('Starting new activation for  ${group.primary.id.name}');
      yield* retryStream(
        () => _startActivation(group, registration.state),
        // ignore: avoid_redundant_argument_values
        maxAttempts: 3,
        perAttemptTimeout: _operationTimeout,
        shouldRetry: (e) => e is TimeoutException || e is Exception,
        onRetry:
            (attempt, error) => _logger.warning(
              'Retry attempt #$attempt for ${group.primary.id.name} due to:'
              '$error',
            ),
      );
    }
  }

  /// Check if asset and its children are already activated
  Future<ActivationProgress> _checkActivationStatus(AssetGroup group) async {
    _logger.fine(
      'Checking activation status for group ${group.primary.id.name}',
    );
    try {
      final enabledCoins = await _client.rpc.generalActivation
          .getEnabledCoins()
          .timeout(
            _operationTimeout,
            onTimeout:
                () =>
                    throw TimeoutException(
                      'getEnabledCoins timed out',
                      _operationTimeout,
                    ),
          );
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
      debugPrint('Failed to check activation status: $e');
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
    _logger.fine('Registering activation for ${assetId.name}');
    var isNew = false;
    late final _ActivationState state;
    await _protectedOperation(() async {
      final existing = _activations[assetId];
      if (existing != null) {
        if (existing.completer.isCompleted || existing.controller.isClosed) {
          _logger.fine(
            'Found completed activation state for ${assetId.name}, '
            'creating new one',
          );
          _activations.remove(assetId);
          state = _ActivationState(
            controller: StreamController<ActivationProgress>.broadcast(),
            completer: Completer<void>(),
          );
          _activations[assetId] = state;
          isNew = true;
        } else {
          _logger.fine(
            'Found existing active activation state for ${assetId.name}',
          );
          state = existing;
        }
        return;
      }

      final completer = Completer<void>();
      _activationCompleters[assetId] = completer;
      return completer;
    });
  }

  /// Start activation for the given group and stream state to the controller
  Stream<ActivationProgress> _startActivation(
    AssetGroup group,
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
      final activator = _activationStrategyFactory.createStrategy(
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
    AssetGroup group,
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
          await _balanceManager.precacheBalance(asset);
        }

        // Notify asset manager to refresh custom tokens if any were activated
        if (allAssets.any((asset) => asset.protocol.isCustomToken)) {
          _assetRefreshNotifier.notifyCustomTokensChanged();
        }
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    } else {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception(progress.errorMessage ?? 'Unknown error'),
        );
      }
    }
  }

  /// Cleanup after activation attempt
  Future<void> _cleanupActivation(AssetId assetId) async {
    await _protectedOperation(() async {
      _activationCompleters.remove(assetId);
    });
  }

  /// Get currently activated assets
  Future<Set<AssetId>> getActiveAssets() async {
    if (_isDisposed) {
      throw StateError('ActivationManager has been disposed');
    }

    try {
      final enabledCoins = await _client.rpc.generalActivation
          .getEnabledCoins()
          .timeout(
            _operationTimeout,
            onTimeout:
                () =>
                    throw TimeoutException(
                      'getEnabledCoins timed out',
                      _operationTimeout,
                    ),
          );
      final activeAssets =
          enabledCoins.result
              .map((coin) => _assetLookup.findAssetsByConfigId(coin.ticker))
              .expand((assets) => assets)
              .map((asset) => asset.id)
              .toSet();

      _logger.fine('Found ${activeAssets.length} active assets');
      return activeAssets;
    } catch (e) {
      debugPrint('Failed to get active assets: $e');
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
      debugPrint('Failed to check if asset is active: $e');
      return false;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    await _protectedOperation(() async {
      _isDisposed = true;
      _logger.fine('Cleaning up ${_activations.length} pending activations');
      for (final state in _activations.values) {
        if (!state.completer.isCompleted) {
          state.completer.completeError(
            Exception('ActivationManager disposed'),
          );
        }
      }

      _activationCompleters.clear();
    });
  }
}

/// Internal class for grouping related assets
class AssetGroup {
  AssetGroup({required this.primary, this.children})
    : assert(
        children == null ||
            children.every((asset) => asset.id.parentId == primary.id),
        'All child assets must have the parent asset as their parent '
        'primary  ${primary.id}, child assets: $children',
      );

  final Asset primary;
  final Set<Asset>? children;

  AssetId? get parentId =>
      children?.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

  static List<AssetGroup> groupByPrimary(
    List<Asset> assets,
    IAssetLookup assetLookup,
  ) {
    _logger.fine('Grouping ${assets.length} assets by primary');
    final groups = <AssetId, AssetGroup>{};

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
        groups[asset.id] = AssetGroup(
          primary: asset,
          children: existing?.children,
        );
        group.children?.add(asset);
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
          groups[parentId] = AssetGroup(
            primary: parentAsset,
            children: {asset},
          );
        } else if (existing.children == null) {
          _logger.fine(
            'Adding first child ${asset.id.name} to existing group '
            'for ${existing.primary.id.name}',
          );
          groups[parentId] = AssetGroup(
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

    return groups.values.toList();
  }
}
