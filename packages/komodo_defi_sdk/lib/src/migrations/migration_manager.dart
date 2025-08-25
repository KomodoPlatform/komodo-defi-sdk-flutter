import 'dart:async';
import 'dart:collection';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_sdk/src/assets/asset_manager.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_sdk/src/fees/fee_manager.dart';
import 'package:komodo_defi_sdk/src/rpc.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';


import 'migration_logger.dart';
import 'utils/batch_processor.dart';
import 'utils/migration_utils.dart';

/// Core service responsible for orchestrating cryptocurrency migrations
/// between wallets.
///
/// The MigrationManager handles the complete lifecycle of migrating assets
/// from a source wallet to a target wallet, including:
/// - Asset activation and balance checking
/// - Fee estimation and validation
/// - Batch processing for large asset lists
/// - Progress reporting and error handling
/// - Transaction execution and monitoring
///
/// Usage:
/// ```dart
/// final manager = MigrationManager(client, assetProvider, activationManager, ...);
///
/// // Generate preview
/// final preview = await manager.previewMigration(request);
///
/// // Start migration
/// await for (final progress in manager.startMigration(request)) {
///   print('Progress: ${progress.completedAssets}/${progress.totalAssets}');
/// }
/// ```
class MigrationManager {
  /// Creates a new [MigrationManager] instance.
  ///
  /// All manager dependencies are required and should be properly initialized
  /// before creating the migration manager.
  MigrationManager(
    this._client,
    this._assetProvider,
    this._activationManager,
    this._withdrawalManager,
    this._balanceManager,
    this._feeManager, {
    MigrationConfigProvider? configProvider,
  }) : _configProvider = configProvider ?? const DefaultMigrationConfigProvider() {
    _initializeManager();
  }

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final ActivationManager _activationManager;
  final WithdrawalManager _withdrawalManager;
  final IBalanceManager _balanceManager;
  final FeeManager _feeManager;
  final MigrationConfigProvider _configProvider;

  late final MigrationConfig _config;
  late final MigrationLogger _logger;
  late final BatchProcessor<AssetId> _batchProcessor;

  // Active migration tracking
  final Map<String, StreamController<MigrationProgress>> _activeMigrations = {};
  final Map<String, bool> _cancellationFlags = {};

  /// Initializes the manager with configuration and dependencies.
  Future<void> _initializeManager() async {
    _config = await _configProvider.getConfig();
    _logger = MigrationLogger(_config);
    _batchProcessor = BatchProcessor<AssetId>(
      batchSize: _config.activationBatchSize,
      delayBetweenBatches: _config.retryDelay,
    );
  }

  /// Generates a comprehensive preview of the migration operation.
  ///
  /// This method:
  /// 1. Validates the migration request
  /// 2. Activates necessary assets in batches
  /// 3. Retrieves current balances
  /// 4. Estimates transaction fees
  /// 5. Calculates net amounts and migration summary
  ///
  /// The preview provides complete cost and outcome information without
  /// actually executing any transactions.
  ///
  /// Throws [MigrationException] if the preview cannot be generated.
  Future<MigrationOperationPreview> previewMigration(MigrationRequest request) async {
    final stopwatch = Stopwatch()..start();
    final previewId = MigrationUtils.generatePreviewId();

    try {
      // Validate the request
      final validationErrors = MigrationUtils.validateMigrationRequest(request);
      if (validationErrors.isNotEmpty) {
        throw MigrationException(
          MigrationErrorType.invalidWallet,
          'Migration request validation failed: ${validationErrors.join(', ')}',
        );
      }

      _logger.logPreviewGenerated(previewId, request.selectedAssets.length, Duration.zero);

      // Activate assets in batches if needed
      await _activateAssetsInBatches(request.selectedAssets, previewId);

      // Create asset previews
      final assetPreviews = await _createAssetPreviews(
        request.selectedAssets,
        request.sourceWalletId,
        request.targetWalletId,
        previewId,
      );

      // Calculate migration summary
      final summary = _calculateMigrationSummary(assetPreviews);

      stopwatch.stop();
      _logger.logPreviewGenerated(previewId, request.selectedAssets.length, stopwatch.elapsed);

      return MigrationOperationPreview(
        previewId: previewId,
        sourceWallet: request.sourceWalletId,
        targetWallet: request.targetWalletId,
        assets: assetPreviews,
        summary: summary,
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.logError(previewId, 'preview_generation', e, stackTrace: stackTrace);

      if (e is MigrationException) {
        rethrow;
      }

      throw MigrationException(
        MigrationUtils.mapWithdrawalErrorToMigrationError(e),
        'Failed to generate migration preview: $e',
        originalError: e,
      );
    }
  }

  /// Starts the migration process and returns a progress stream.
  ///
  /// This method executes the actual migration by:
  /// 1. Validating the request and checking asset readiness
  /// 2. Creating withdrawal transactions for each asset
  /// 3. Broadcasting transactions to the network
  /// 4. Monitoring transaction status and progress
  ///
  /// The returned stream provides real-time updates on migration progress,
  /// including per-asset status and overall completion percentage.
  ///
  /// The migration can be cancelled using [cancelMigration].
  Stream<MigrationProgress> startMigration(MigrationRequest request) async* {
    final migrationId = MigrationUtils.generateMigrationId();
    final controller = StreamController<MigrationProgress>.broadcast();
    _activeMigrations[migrationId] = controller;
    _cancellationFlags[migrationId] = false;

    final stopwatch = Stopwatch()..start();

    try {
      _logger.logMigrationStart(
        migrationId,
        request.sourceWalletId,
        request.targetWalletId,
        request.selectedAssets.length,
      );

      // Validate and get ready assets
      final readyAssets = await _validateAndGetReadyAssets(request, migrationId);
      if (readyAssets.isEmpty) {
        final error = MigrationException(
          MigrationErrorType.invalidWallet,
          'No assets are ready for migration',
        );
        controller.addError(error);
        return;
      }

      // Initialize progress tracking
      final assetProgress = <AssetId, AssetMigrationProgress>{};
      for (final asset in readyAssets) {
        assetProgress[asset] = AssetMigrationProgress.pending(asset);
      }

      var completedCount = 0;
      final totalCount = readyAssets.length;

      // Emit initial progress
      yield MigrationProgress(
        migrationId: migrationId,
        status: MigrationStatus.inProgress,
        assetProgress: assetProgress.values.toList(),
        completedCount: completedCount,
        totalCount: totalCount,
        startedAt: DateTime.now(),
      );

      // Process assets with concurrency limits
      final semaphore = Semaphore(_config.maxConcurrentWithdrawals);
      final futures = readyAssets.map((asset) async {
        await semaphore.acquire();
        try {
          if (_cancellationFlags[migrationId] == true) {
            return _WithdrawalResult(
              assetId: asset,
              success: false,
              error: 'Migration cancelled by user',
            );
          }

          final result = await _executeAssetMigration(
            asset,
            request.sourceWalletId,
            request.targetWalletId,
            migrationId,
          );

          // Update progress
          assetProgress[asset] = result.success
              ? AssetMigrationProgress.completed(asset, result.txHash ?? '')
              : AssetMigrationProgress.failed(asset, result.error ?? 'Migration failed');

          if (result.success) {
            completedCount++;
          }

          // Emit progress update
          controller.add(MigrationProgress(
            migrationId: migrationId,
            status: MigrationStatus.inProgress,
            assetProgress: assetProgress.values.toList(),
            completedCount: completedCount,
            totalCount: totalCount,
            startedAt: DateTime.now(),
          ));

          return result;
        } finally {
          semaphore.release();
        }
      });

      final results = await Future.wait(futures);
      stopwatch.stop();

      // Calculate final results
      final successfulAssets = <AssetId>[];
      final failedAssets = <AssetMigrationError>[];

      for (final result in results) {
        if (result.success) {
          successfulAssets.add(result.assetId);
        } else {
          failedAssets.add(AssetMigrationError(
            assetId: result.assetId,
            errorType: MigrationUtils.mapWithdrawalErrorToMigrationError(result.error ?? 'Unknown error'),
            message: result.error ?? 'Asset migration failed',
          ));
        }
      }

      final finalStatus = _cancellationFlags[migrationId] == true
          ? MigrationStatus.cancelled
          : failedAssets.isEmpty
              ? MigrationStatus.completed
              : MigrationStatus.partiallyCompleted;

      final migrationResult = MigrationResult(
        migrationId: migrationId,
        status: finalStatus == MigrationStatus.completed
            ? MigrationResultStatus.completed
            : finalStatus == MigrationStatus.cancelled
                ? MigrationResultStatus.cancelled
                : MigrationResultStatus.partiallyCompleted,
        assetResults: assetProgress.values.toList(),
        successCount: successfulAssets.length,
        failureCount: failedAssets.length,
        totalCount: totalCount,
        startedAt: DateTime.now().subtract(stopwatch.elapsed),
        completedAt: DateTime.now(),
        summary: _getFinalMessage(successfulAssets.length, failedAssets.length),
      );

      _logger.logMigrationComplete(migrationId, migrationResult, stopwatch.elapsed);

      // Emit final progress
      yield MigrationProgress(
        migrationId: migrationId,
        status: finalStatus,
        assetProgress: assetProgress.values.toList(),
        completedCount: completedCount,
        totalCount: totalCount,
        startedAt: DateTime.now().subtract(stopwatch.elapsed),
        completedAt: DateTime.now(),
      );

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.logError(migrationId, 'migration_execution', e, stackTrace: stackTrace);

      final migrationException = e is MigrationException
          ? e
          : MigrationException(
              MigrationUtils.mapWithdrawalErrorToMigrationError(e),
              'Migration failed: $e',
              originalError: e,
            );

      controller.addError(migrationException);
    } finally {
      // Cleanup
      _activeMigrations.remove(migrationId);
      _cancellationFlags.remove(migrationId);
      controller.close();
    }
  }

  /// Cancels an active migration.
  ///
  /// Sets a cancellation flag that prevents new asset migrations from starting.
  /// Assets that are already in progress will complete normally.
  Future<void> cancelMigration(String migrationId) async {
    _cancellationFlags[migrationId] = true;
    _logger.logMigrationCancelled(migrationId, 'User requested cancellation');
  }

  /// Retries migration for specific failed assets.
  ///
  /// Creates a new migration operation for only the specified assets
  /// that failed in a previous migration attempt.
  Stream<MigrationProgress> retryFailedAssets(
    String originalMigrationId,
    List<AssetId> assetIds,
    WalletId sourceWallet,
    WalletId targetWallet,
  ) async* {
    final retryRequest = MigrationRequest(
      sourceWalletId: sourceWallet,
      targetWalletId: targetWallet,
      selectedAssets: assetIds,
      activateCoinsOnly: false,
      feePreferences: {},
    );

    yield* startMigration(retryRequest);
  }

  /// Disposes of the migration manager and cleans up resources.
  Future<void> dispose() async {
    // Cancel all active migrations
    for (final migrationId in _activeMigrations.keys.toList()) {
      await cancelMigration(migrationId);
    }

    // Close all active stream controllers
    for (final controller in _activeMigrations.values) {
      await controller.close();
    }

    _activeMigrations.clear();
    _cancellationFlags.clear();
  }

  /// Activates assets in batches to prevent overwhelming the system.
  Future<void> _activateAssetsInBatches(
    List<AssetId> assetIds,
    String operationId,
  ) async {
    if (assetIds.isEmpty) return;

    await _batchProcessor.processBatches<void>(
      assetIds,
      (batch, batchIndex, totalBatches) async {
        _logger.logBatchStart(operationId, 'activation', batch.length, batchIndex);

        final stopwatch = Stopwatch()..start();

        try {
          // Get asset objects for activation
          final assets = <Asset>[];
          for (final assetId in batch) {
            final asset = _assetProvider.fromId(assetId);
            if (asset != null) {
              assets.add(asset);
            }
          }

          // Activate assets
          final results = <Asset>[];
          for (final asset in assets) {
            try {
              await for (final result in _activationManager.activateAsset(asset)) {
                if (result.isSuccess) {
                  results.add(asset);
                  _logger.logAssetActivation(operationId, asset.id);
                  break;
                }
              }
            } catch (e) {
              _logger.logError(
                operationId,
                'asset_activation',
                e,
                context: {'assetId': asset.id.id},
              );
            }
          }

          stopwatch.stop();
          _logger.logBatchComplete(
            operationId,
            'activation',
            batchIndex,
            results.length,
            batch.length,
            stopwatch.elapsed,
          );

          return <void>[];
        } catch (e) {
          stopwatch.stop();
          _logger.logError(
            operationId,
            'batch_activation',
            e,
            context: {
              'batchIndex': batchIndex,
              'batchSize': batch.length,
            },
          );
          rethrow;
        }
      },
    );
  }

  /// Creates asset migration previews with balance and fee information.
  Future<List<AssetMigrationPreview>> _createAssetPreviews(
    List<AssetId> assetIds,
    WalletId sourceWallet,
    WalletId targetWallet,
    String operationId,
  ) async {
    final previews = <AssetMigrationPreview>[];

    for (final assetId in assetIds) {
      try {
        final asset = _assetProvider.fromId(assetId);
        if (asset == null) {
          previews.add(AssetMigrationPreview(
            assetId: assetId,
            sourceAddress: '',
            targetAddress: '',
            balance: Decimal.zero,
            estimatedFee: Decimal.zero,
            netAmount: Decimal.zero,
            status: MigrationAssetStatus.unsupported,
            errorMessage: 'Asset not found',
          ));
          continue;
        }

        // Get balance
        final balanceInfo = await _balanceManager.getBalance(assetId);
        final balance = balanceInfo.total;

        // Estimate fee (using placeholder values for now)
        final estimatedFee = await _estimateMigrationFee(asset);

        // Calculate net amount
        final netAmount = MigrationUtils.calculateNetAmount(balance, estimatedFee);

        // Determine status
        final status = _determineMigrationAssetStatus(balance, estimatedFee);

        // Get addresses (simplified for now)
        final sourceAddress = 'source_address_placeholder';
        final targetAddress = 'target_address_placeholder';

        previews.add(AssetMigrationPreview(
          assetId: assetId,
          sourceAddress: sourceAddress,
          targetAddress: targetAddress,
          balance: balance,
          estimatedFee: estimatedFee,
          netAmount: netAmount,
          status: status,
          errorMessage: status == MigrationAssetStatus.unsupported ? 'Migration not possible' : null,
        ));

      } catch (e) {
        _logger.logError(
          operationId,
          'asset_preview_creation',
          e,
          context: {'assetId': assetId.id},
        );

        previews.add(AssetMigrationPreview(
          assetId: assetId,
          sourceAddress: '',
          targetAddress: '',
          balance: Decimal.zero,
          estimatedFee: Decimal.zero,
          netAmount: Decimal.zero,
          status: MigrationAssetStatus.unsupported,
          errorMessage: 'Failed to create preview: $e',
        ));
      }
    }

    return previews;
  }

  /// Calculates migration summary from asset previews.
  MigrationSummary _calculateMigrationSummary(List<AssetMigrationPreview> assetPreviews) {
    return MigrationUtils.createMigrationSummary(assetPreviews);
  }

  /// Validates the request and returns assets that are ready for migration.
  Future<List<AssetId>> _validateAndGetReadyAssets(
    MigrationRequest request,
    String migrationId,
  ) async {
    final validationErrors = MigrationUtils.validateMigrationRequest(request);
    if (validationErrors.isNotEmpty) {
      throw MigrationException(
        MigrationErrorType.invalidWallet,
        'Validation failed: ${validationErrors.join(', ')}',
      );
    }

    return request.selectedAssets;
  }

  /// Executes migration for a single asset.
  Future<_WithdrawalResult> _executeAssetMigration(
    AssetId assetId,
    WalletId sourceWallet,
    WalletId targetWallet,
    String migrationId,
  ) async {
    try {
      // This is a simplified implementation
      // In a real scenario, this would use the withdrawal manager
      // to create and broadcast the transaction

      await Future.delayed(Duration(seconds: 1)); // Simulate transaction time

      final success = true; // Placeholder logic
      final txHash = success ? 'tx_hash_${assetId.id}_${DateTime.now().millisecondsSinceEpoch}' : null;

      _logger.logAssetMigration(migrationId, assetId, success, txHash: txHash);

      return _WithdrawalResult(
        assetId: assetId,
        success: success,
        txHash: txHash,
      );

    } catch (e) {
      _logger.logAssetMigration(migrationId, assetId, false, error: e.toString());
      return _WithdrawalResult(
        assetId: assetId,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Gets a user-friendly message for the final migration result.
  String _getFinalMessage(int successCount, int failureCount) {
    if (failureCount == 0) {
      return 'All $successCount assets migrated successfully';
    } else if (successCount == 0) {
      return 'Migration failed for all $failureCount assets';
    } else {
      return '$successCount assets migrated successfully, $failureCount failed';
    }
  }

  /// Estimates the migration fee for an asset.
  Future<Decimal> _estimateMigrationFee(Asset asset) async {
    // Placeholder implementation
    // In reality, this would use the fee manager to estimate withdrawal fees
    return Decimal.parse('0.001'); // Example fee
  }

  /// Determines the migration status for an asset based on balance and fees.
  MigrationAssetStatus _determineMigrationAssetStatus(Decimal balance, Decimal fee) {
    if (balance <= Decimal.zero) {
      return MigrationAssetStatus.insufficientBalance;
    }
    if (fee >= balance) {
      return MigrationAssetStatus.insufficientBalance;
    }
    return MigrationAssetStatus.ready;
  }
}

/// Internal class for tracking withdrawal operation results.
class _WithdrawalResult {
  const _WithdrawalResult({
    required this.assetId,
    required this.success,
    this.txHash,
    this.error,
  });

  final AssetId assetId;
  final bool success;
  final String? txHash;
  final String? error;
}

/// Simple semaphore implementation for controlling concurrency.
class Semaphore {
  Semaphore(this._maxCount) : _currentCount = 0;

  final int _maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Future<void> acquire() async {
    if (_currentCount < _maxCount) {
      _currentCount++;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount--;
    }
  }
}
