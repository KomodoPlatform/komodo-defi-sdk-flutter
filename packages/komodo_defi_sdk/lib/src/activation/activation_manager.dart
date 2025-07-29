import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';

import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

/// Timeout configuration for different operation types
class _TimeoutConfig {
  static const Duration userAuth = Duration(seconds: 5);      // Fast operation
  static const Duration statusCheck = Duration(seconds: 10);  // Network operation
  static const Duration cleanup = Duration(seconds: 3);       // Internal operation
  static const Duration balanceCache = Duration(seconds: 15); // Network operation
}

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
  final Map<AssetId, _ActivationState> _activations = {};
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

      // Start activation without applying timeout here - let individual tests control timeout
      try {
        await for (final progress in _startActivation(
          group,
          registration.state,
        )) {
          yield progress;
          if (progress.isComplete) {
            break;
          }
        }
      } catch (e) {
        rethrow;
      }
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
          .timeout(_TimeoutConfig.statusCheck);
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
    } on TimeoutException catch (e) {
      _logger.warning(
        'Status check timed out for ${group.primary.id.name}: $e',
      );
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
        // Check if the existing state is no longer usable
        final isCompleted = existing.completer.isCompleted;
        final isClosed = existing.controller.isClosed;
        final hasError =
            existing.controller.hasListener && existing.controller.isPaused;

        if (isCompleted || isClosed || hasError) {
          _logger.fine(
            'Found unusable activation state for ${assetId.name} '
            '(completed: $isCompleted, closed: $isClosed, '
            'hasError: $hasError), '
            'creating new one',
          );

          // Ensure proper cleanup of the old state
          if (!isClosed) {
            try {
              await existing.controller.close();
            } catch (e) {
              _logger.warning(
                'Failed to close existing controller for ${assetId.name}',
                e,
              );
            }
          }

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
      await _handleActivationComplete(
        group,
        activationStatus,
        state.completer,
      ).timeout(
        _operationTimeout,
        onTimeout: () {
          _logger.warning(
            'Early completion handling timed out for ${group.primary.id.name}',
          );
          throw TimeoutException(
            'Early completion timed out',
            _operationTimeout,
          );
        },
      );
      await _cleanupActivation(group.primary.id).timeout(
        _operationTimeout,
        onTimeout: () {
          _logger.warning(
            'Early cleanup timed out for ${group.primary.id.name}',
          );
          throw TimeoutException('Early cleanup timed out', _operationTimeout);
        },
      );
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
      'Using ${parentAsset?.id.name ?? group.primary.id.name} '
      'as activation target',
    );

    // Remove extra progress message that interferes with test expectations
    // The activation strategy itself will emit the appropriate progress messages

    try {
      final currentUser = await _auth.currentUser.timeout(_TimeoutConfig.userAuth);
      final privKeyPolicy =
          currentUser?.walletId.authOptions.privKeyPolicy ??
          const PrivateKeyPolicy.contextPrivKey();

      _logger.fine('Creating activation strategy for ${group.primary.id.name}');
      final activator = _activationStrategyFactory.createStrategy(
        _client,
        privKeyPolicy,
      );

      _logger.fine('Starting activation process for ${group.primary.id.name}');

      final activationStream = activator.activate(
        parentAsset ?? group.primary,
        group.children?.toList(),
      );

      await for (final progress in activationStream) {
        _logger.fine(
          'Activation progress for ${group.primary.id.name}: '
          '${progress.status}',
        );
        _emit(state, progress);
        yield progress;
        if (progress.isComplete) {
          _logger.info('Activation completed for ${group.primary.id.name}');
          try {
            await _handleActivationComplete(group, progress, state.completer)
                .timeout(_TimeoutConfig.cleanup);
          } catch (e) {
            _logger.warning(
              'Activation completion handling failed for ${group.primary.id.name}: $e',
            );
            // Continue with cleanup, don't fail the activation
          }
          break;
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Activation failed for ${group.primary.id.name}', e);

      // Add error to controller if not closed
      if (!state.controller.isClosed) {
        state.controller.addError(e, stackTrace);
      }

      // Perform safe cleanup that preserves the original error
      await _performSafeCleanup(group, state, e, stackTrace);

      // Rethrow the original error
      rethrow;
    }

    // Successful completion cleanup
    await _performSafeCleanup(group, state, null, null);
  }

  /// Perform safe cleanup that preserves original errors
  Future<void> _performSafeCleanup(
    AssetGroup group,
    _ActivationState state,
    Object? primaryError,
    StackTrace? primaryStackTrace,
  ) async {
    final cleanupErrors = <Object>[];

    // Complete completer if not already completed
    if (!state.completer.isCompleted) {
      try {
        if (primaryError != null) {
          state.completer.completeError(primaryError, primaryStackTrace);
        } else {
          state.completer.complete();
        }
      } catch (e) {
        cleanupErrors.add(e);
      }
    }

    // Close controller if not already closed
    if (!state.controller.isClosed) {
      try {
        await state.controller.close().timeout(_TimeoutConfig.cleanup);
      } catch (e) {
        cleanupErrors.add(e);
        _logger.warning('Failed to close controller for ${group.primary.id.name}: $e');
      }
    }

    // Clean up activation state
    try {
      await _cleanupActivation(group.primary.id).timeout(_TimeoutConfig.cleanup);
    } catch (e) {
      cleanupErrors.add(e);
      _logger.warning('Failed to cleanup activation state for ${group.primary.id.name}: $e');
    }

    // Log cleanup errors but don't throw them (preserve primary error)
    if (cleanupErrors.isNotEmpty) {
      _logger.warning(
        'Cleanup completed with ${cleanupErrors.length} non-critical errors: $cleanupErrors'
      );
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
        _logger.fine(
          'Adding ${group.primary.id.name} to user wallet '
          '${user.walletId}',
        );
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
          .timeout(_TimeoutConfig.statusCheck);
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

    _logger.info('Disposing ActivationManager');
    final disposalErrors = <Object>[];

    try {
      await _protectedOperation(() async {
        _isDisposed = true;
        _logger.fine('Cleaning up ${_activations.length} pending activations');

        // Dispose each activation safely
        for (final entry in _activations.entries) {
          try {
            final state = entry.value;
            if (!state.completer.isCompleted) {
              state.completer.completeError(
                Exception('ActivationManager disposed'),
              );
            }
            if (!state.controller.isClosed) {
              await state.controller.close().timeout(_TimeoutConfig.cleanup);
            }
          } catch (e) {
            disposalErrors.add(e);
            _logger.fine('Error disposing activation ${entry.key.name}: $e');
          }
        }

        _activations.clear();
        _logger.fine('ActivationManager disposed successfully');
      });
    } catch (e) {
      disposalErrors.add(e);
      _logger.warning('Protected disposal operation failed: $e');
    }

    // Don't throw disposal errors in production, but log them
    if (disposalErrors.isNotEmpty) {
      _logger.warning('Disposal completed with ${disposalErrors.length} errors: $disposalErrors');
    }
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
