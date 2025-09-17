import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/activation/asset_group.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Manager responsible for invoking activation strategies and emitting progress
class ActivationManager {
  /// Manager responsible for invoking activation strategies and emitting progress
  ActivationManager(
    this._client,
    this._auth,
    this._assetHistory,
    this._customTokenHistory,
    this._assetLookup,
    this._balanceManager, {
    required IAssetRefreshNotifier assetRefreshNotifier,
    IActivationStrategyFactory? activationStrategyFactory,
  }) : _activationStrategyFactory =
           activationStrategyFactory ??
           const DefaultActivationStrategyFactory(),
       _assetRefreshNotifier = assetRefreshNotifier;

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final AssetHistoryStorage _assetHistory;
  final CustomAssetHistoryStorage _customTokenHistory;
  final IAssetLookup _assetLookup;
  final IAssetRefreshNotifier _assetRefreshNotifier;
  final IBalanceManager _balanceManager;
  final IActivationStrategyFactory _activationStrategyFactory;
  static final _logger = Logger('ActivationManager');
  bool _isDisposed = false;

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
      // Check activation status
      final activationStatus = await _checkActivationStatus(group);
      if (activationStatus.isComplete) {
        yield activationStatus;
        continue;
      }

      final parentAsset = group.parentId == null
          ? null
          : _assetLookup.fromId(group.parentId!) ??
                (throw StateError('Parent asset ${group.parentId} not found'));

      try {
        final currentUser = await _auth.currentUser;
        final privKeyPolicy =
            currentUser?.walletId.authOptions.privKeyPolicy ??
            const PrivateKeyPolicy.contextPrivKey();

        _logger.fine(
          'Creating activation strategy for ${group.primary.id.name}',
        );
        final activator = _activationStrategyFactory.createStrategy(
          _client,
          privKeyPolicy,
        );

        _logger.fine(
          'Starting activation process for ${group.primary.id.name}',
        );

        final activationStream = activator.activate(
          parentAsset ?? group.primary,
          group.children?.toList(),
        );

        await for (final progress in activationStream) {
          _logger.fine(
            'Activation progress for ${group.primary.id.name}: '
            '${progress.status}',
          );
          yield progress;
          if (progress.isComplete) {
            if (progress.isSuccess) {
              try {
                await _handleActivationComplete(group, progress);
              } catch (e) {
                _logger.warning(
                  'Activation completion handling failed for '
                  '${group.primary.id.name}: $e',
                );
              }
            }
            break;
          }
        }
      } catch (e, s) {
        _logger.severe('Activation failed for ${group.primary.id.name}', e, s);
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
          .getEnabledCoins();
      final enabledAssetIds = enabledCoins.result
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
    } catch (e, s) {
      _logger.severe('Failed to check activation status', e, s);
    }

    return const ActivationProgress(
      status: 'Needs activation',
      progressDetails: ActivationProgressDetails(
        currentStep: 'init',
        stepCount: 1,
      ),
    );
  }

  /// Handle completion of activation
  Future<void> _handleActivationComplete(
    AssetGroup group,
    ActivationProgress progress,
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
    } else {
      // No-op for errors here; callers observe the stream error/state
    }
  }

  /// Get currently activated assets
  Future<Set<AssetId>> getActiveAssets() async {
    if (_isDisposed) {
      throw StateError('ActivationManager has been disposed');
    }

    try {
      final enabledCoins = await _client.rpc.generalActivation
          .getEnabledCoins();
      final activeAssets = enabledCoins.result
          .map((coin) => _assetLookup.findAssetsByConfigId(coin.ticker))
          .expand((assets) => assets)
          .map((asset) => asset.id)
          .toSet();

      _logger.fine('Found ${activeAssets.length} active assets');
      return activeAssets;
    } catch (e, s) {
      _logger.severe('Failed to get active assets', e, s);
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
    } catch (e, s) {
      _logger.severe('Failed to check if asset is active', e, s);
      return false;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    _logger.info('Disposing ActivationManager');
    _isDisposed = true;
  }
}
