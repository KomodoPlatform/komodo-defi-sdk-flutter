import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_types/src/utils/retry_config.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

import 'base_strategies/activation_strategy_factory.dart';

/// A retryable wrapper around ActivationManager that adds retry logic using composition.
///
/// This class wraps the original ActivationManager and adds configurable retry
/// behavior without modifying the core activation logic. It uses the decorator
/// pattern to enhance the base manager with retry capabilities.
class RetryableActivationManager {
  /// Creates a retryable activation manager.
  ///
  /// [retryConfig] - Configuration for retry behavior (defaults to production config)
  /// [retryStrategy] - Strategy for implementing retry logic (defaults to DefaultRetryStrategy)
  /// [operationTimeout] - Timeout for individual operations (defaults to 30 seconds)
  /// Other parameters are passed through to the underlying ActivationManager
  RetryableActivationManager(
    ApiClient client,
    KomodoDefiLocalAuth auth,
    AssetHistoryStorage assetHistory,
    CustomAssetHistoryStorage customTokenHistory,
    IAssetLookup assetLookup,
    IBalanceManager balanceManager, {
    IActivationStrategyFactory? activationStrategyFactory,
    RetryConfig? retryConfig,
    RetryStrategy? retryStrategy,
    Duration? operationTimeout,
  }) : _retryConfig = retryConfig ?? RetryConfig.production,
       _retryStrategy = retryStrategy ?? const DefaultRetryStrategy(),
       _baseManager = ActivationManager(
         client,
         auth,
         assetHistory,
         customTokenHistory,
         assetLookup,
         balanceManager,
         activationStrategyFactory: activationStrategyFactory,
         operationTimeout: operationTimeout,
       );

  static final _logger = Logger('RetryableActivationManager');

  final RetryConfig _retryConfig;
  final RetryStrategy _retryStrategy;
  final ActivationManager _baseManager;

  /// Get the retry configuration being used.
  RetryConfig get retryConfig => _retryConfig;

  /// Get the retry strategy being used.
  RetryStrategy get retryStrategy => _retryStrategy;

  /// Activate a single asset with retry logic.
  ///
  /// This method wraps the base manager's activateAsset method with
  /// retry logic based on the configured retry policy.
  Stream<ActivationProgress> activateAsset(Asset asset) {
    _logger.info('Starting retryable activation for asset: ${asset.id.name}');
    _logger.fine('Using retry config: $_retryConfig');

    return _retryStrategy.executeWithRetry(
      () {
        _logger.fine('Executing activation attempt for ${asset.id.name}');
        return _baseManager.activateAsset(asset);
      },
      _retryConfig.copyWith(
        onRetry: (attempt, error) {
          _logger.warning(
            'Retry attempt #$attempt for ${asset.id.name} due to: $error',
          );
          _retryConfig.onRetry?.call(attempt, error);
        },
      ),
    );
  }

  /// Activate multiple assets with retry logic.
  ///
  /// This method wraps the base manager's activateAssets method with
  /// retry logic. Each asset group will be retried independently
  /// according to the retry configuration.
  Stream<ActivationProgress> activateAssets(List<Asset> assets) {
    _logger.info(
      'Starting retryable activation for ${assets.length} assets: '
      '${assets.map((a) => a.id.name).join(', ')}',
    );
    _logger.fine('Using retry config: $_retryConfig');

    return _retryStrategy.executeWithRetry(
      () {
        _logger.fine(
          'Executing activation attempt for ${assets.length} assets',
        );
        return _baseManager.activateAssets(assets);
      },
      _retryConfig.copyWith(
        onRetry: (attempt, error) {
          _logger.warning(
            'Retry attempt #$attempt for asset group due to: $error',
          );
          _retryConfig.onRetry?.call(attempt, error);
        },
      ),
    );
  }

  /// Get currently activated assets.
  ///
  /// This method delegates directly to the base manager without retry logic
  /// as it's a read operation that typically doesn't need retrying.
  Future<Set<AssetId>> getActiveAssets() {
    _logger.fine('Getting active assets from base manager');
    return _baseManager.getActiveAssets();
  }

  /// Check if specific asset is active.
  ///
  /// This method delegates directly to the base manager without retry logic
  /// as it's a read operation that typically doesn't need retrying.
  Future<bool> isAssetActive(AssetId assetId) {
    _logger.fine('Checking if asset ${assetId.name} is active');
    return _baseManager.isAssetActive(assetId);
  }

  /// Dispose of resources.
  ///
  /// This method disposes the underlying base manager and cleans up
  /// any resources used by the retry wrapper.
  Future<void> dispose() async {
    _logger.info('Disposing RetryableActivationManager');
    await _baseManager.dispose();
    _logger.fine('RetryableActivationManager disposed successfully');
  }

  /// Create a copy of this manager with different retry configuration.
  ///
  /// This is useful for testing or temporarily changing retry behavior
  /// without creating a completely new manager instance.
  RetryableActivationManager withRetryConfig(RetryConfig newConfig) {
    _logger.fine('Creating copy with new retry config: $newConfig');
    // Note: This method is primarily for testing purposes.
    // In practice, create a new instance with the desired configuration.
    throw UnimplementedError(
      'withRetryConfig requires access to base manager parameters. '
      'Create a new RetryableActivationManager instance instead.',
    );
  }

  /// Create a copy of this manager with different retry strategy.
  ///
  /// This is useful for testing or changing retry behavior implementation
  /// without creating a completely new manager instance.
  RetryableActivationManager withRetryStrategy(RetryStrategy newStrategy) {
    _logger.fine('Creating copy with new retry strategy: $newStrategy');
    // Note: This method is primarily for testing purposes.
    // In practice, create a new instance with the desired strategy.
    throw UnimplementedError(
      'withRetryStrategy requires access to base manager parameters. '
      'Create a new RetryableActivationManager instance instead.',
    );
  }

  /// Create a manager optimized for testing.
  ///
  /// This factory method creates a RetryableActivationManager with
  /// test-friendly configurations that avoid timing issues and
  /// provide predictable behavior.
  static RetryableActivationManager forTesting(
    ApiClient client,
    KomodoDefiLocalAuth auth,
    AssetHistoryStorage assetHistory,
    CustomAssetHistoryStorage customTokenHistory,
    IAssetLookup assetLookup,
    IBalanceManager balanceManager, {
    IActivationStrategyFactory? activationStrategyFactory,
    RetryConfig? testRetryConfig,
    RetryStrategy? testRetryStrategy,
    Duration? operationTimeout,
  }) {
    _logger.fine('Creating RetryableActivationManager for testing');
    return RetryableActivationManager(
      client,
      auth,
      assetHistory,
      customTokenHistory,
      assetLookup,
      balanceManager,
      activationStrategyFactory: activationStrategyFactory,
      retryConfig: testRetryConfig ?? RetryConfig.testing,
      retryStrategy: testRetryStrategy ?? const NoRetryStrategy(),
      operationTimeout: operationTimeout ?? const Duration(milliseconds: 500),
    );
  }

  /// Create a manager optimized for production.
  ///
  /// This factory method creates a RetryableActivationManager with
  /// production-ready configurations that provide resilience and
  /// proper error handling.
  static RetryableActivationManager forProduction(
    ApiClient client,
    KomodoDefiLocalAuth auth,
    AssetHistoryStorage assetHistory,
    CustomAssetHistoryStorage customTokenHistory,
    IAssetLookup assetLookup,
    IBalanceManager balanceManager, {
    IActivationStrategyFactory? activationStrategyFactory,
    RetryConfig? productionRetryConfig,
    Duration? operationTimeout,
  }) {
    _logger.fine('Creating RetryableActivationManager for production');
    return RetryableActivationManager(
      client,
      auth,
      assetHistory,
      customTokenHistory,
      assetLookup,
      balanceManager,
      activationStrategyFactory: activationStrategyFactory,
      retryConfig: productionRetryConfig ?? RetryConfig.production,
      retryStrategy: const DefaultRetryStrategy(),
      operationTimeout: operationTimeout,
    );
  }
}
