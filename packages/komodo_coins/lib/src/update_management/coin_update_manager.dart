import 'dart:async';

import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/update_management/update_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:logging/logging.dart';

/// Interface defining the contract for coin configuration update operations
abstract class CoinUpdateManager {
  Future<void> init();

  /// Checks if an update is available
  Future<bool> isUpdateAvailable();

  /// Gets the current commit hash
  Future<String?> getCurrentCommitHash();

  /// Gets the latest available commit hash
  Future<String?> getLatestCommitHash();

  /// Performs an immediate update
  Future<UpdateResult> updateNow();

  /// Starts automatic background updates (if strategy supports it)
  void startBackgroundUpdates();

  /// Stops automatic background updates
  void stopBackgroundUpdates();

  /// Whether background updates are currently active
  bool get isBackgroundUpdatesActive;

  /// Stream of update results for monitoring
  Stream<UpdateResult> get updateStream;

  /// Disposes of all resources
  Future<void> dispose();
}

/// Implementation of [CoinUpdateManager] that uses strategy pattern for updates
class StrategicCoinUpdateManager implements CoinUpdateManager {
  StrategicCoinUpdateManager({
    required this.repository,
    UpdateStrategy? updateStrategy,
    this.fallbackProvider,
  }) : _updateStrategy = updateStrategy ?? const BackgroundUpdateStrategy();

  static final _logger = Logger('StrategicCoinUpdateManager');

  final CoinConfigRepository repository;
  final UpdateStrategy _updateStrategy;
  final CoinConfigProvider? fallbackProvider;

  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _backgroundUpdatesActive = false;
  Timer? _backgroundTimer;
  DateTime? _lastUpdateTime;

  final StreamController<UpdateResult> _updateStreamController =
      StreamController<UpdateResult>.broadcast();

  @override
  Stream<UpdateResult> get updateStream => _updateStreamController.stream;

  void _emitUpdateResult(UpdateResult result) {
    if (_isDisposed || _updateStreamController.isClosed) {
      return;
    }
    try {
      _updateStreamController.add(result);
    } catch (_) {
      // Ignore if the stream is already closed or cannot accept more events
    }
  }

  @override
  Future<void> init() async {
    _logger.fine('Initializing CoinUpdateManager');

    try {
      await repository.updatedAssetStorageExists();
      _logger.finer('Repository connectivity verified');
    } catch (e, s) {
      _logger.warning('Repository connectivity issue during init', e, s);
      // Don't throw - manager should still be usable
    }

    _isInitialized = true;
    _logger.fine('CoinUpdateManager initialized successfully');
  }

  /// Validates that the manager hasn't been disposed
  void _checkNotDisposed() {
    if (_isDisposed) {
      _logger.warning('Attempted to use manager after dispose');
      throw StateError('CoinUpdateManager has been disposed');
    }
  }

  /// Validates that the manager has been initialized
  void _assertInitialized() {
    if (!_isInitialized) {
      _logger.warning('Attempted to use manager before initialization');
      throw StateError('CoinUpdateManager must be initialized before use');
    }
  }

  @override
  Future<bool> isUpdateAvailable() async {
    _checkNotDisposed();
    _assertInitialized();

    try {
      return await _updateStrategy.shouldUpdate(
        requestType: UpdateRequestType.backgroundUpdate,
        repository: repository,
        lastUpdateTime: _lastUpdateTime,
      );
    } catch (e, s) {
      _logger.fine('Error checking update availability', e, s);
      return false;
    }
  }

  @override
  Future<String?> getCurrentCommitHash() async {
    _checkNotDisposed();
    _assertInitialized();

    try {
      // Try to get commit from repository first
      final repositoryCommit = await repository.getCurrentCommit();
      if (repositoryCommit != null && repositoryCommit.isNotEmpty) {
        return repositoryCommit;
      }

      // Fall back to local provider if repository has no commit
      if (fallbackProvider != null) {
        _logger.fine('Repository has no commit, using fallback provider');
        return await fallbackProvider!.getLatestCommit();
      }

      return null;
    } catch (e, s) {
      _logger.fine('Error getting current commit hash', e, s);

      // Try fallback provider on error
      if (fallbackProvider != null) {
        try {
          _logger.fine('Using fallback provider due to repository error');
          return await fallbackProvider!.getLatestCommit();
        } catch (fallbackError, fallbackStack) {
          _logger.fine(
            'Fallback provider also failed',
            fallbackError,
            fallbackStack,
          );
        }
      }

      return null;
    }
  }

  @override
  Future<String?> getLatestCommitHash() async {
    _checkNotDisposed();
    _assertInitialized();

    try {
      // Try to get latest commit from repository's provider first
      return await repository.coinConfigProvider.getLatestCommit();
    } catch (e, s) {
      _logger.fine('Error getting latest commit hash from repository', e, s);

      // Fall back to local provider if repository provider fails
      if (fallbackProvider != null) {
        try {
          _logger.fine('Using fallback provider for latest commit hash');
          return await fallbackProvider!.getLatestCommit();
        } catch (fallbackError, fallbackStack) {
          _logger.fine(
            'Fallback provider also failed for latest commit',
            fallbackError,
            fallbackStack,
          );
        }
      }

      return null;
    }
  }

  @override
  Future<UpdateResult> updateNow() async {
    _checkNotDisposed();
    _assertInitialized();

    _logger.info('Performing immediate update');

    final result = await retry(
      () => _performUpdate(UpdateRequestType.immediateUpdate),
      maxAttempts: 3,
      onRetry: (attempt, error, delay) {
        _logger.warning(
          'Update attempt $attempt failed, retrying after $delay: $error',
        );
      },
      shouldRetry: (error) {
        // Retry on most errors except for critical state errors
        if (error is StateError || error is ArgumentError) {
          return false;
        }
        return true;
      },
    );

    _emitUpdateResult(result);
    return result;
  }

  /// Performs the actual update using the strategy
  Future<UpdateResult> _performUpdate(UpdateRequestType requestType) async {
    try {
      final shouldUpdate = await _updateStrategy.shouldUpdate(
        requestType: requestType,
        repository: repository,
        lastUpdateTime: _lastUpdateTime,
      );

      if (!shouldUpdate) {
        _logger.fine('Strategy determined no update is needed');
        return const UpdateResult(
          success: true,
          updatedAssetCount: 0,
        );
      }

      final result = await _updateStrategy.executeUpdate(
        requestType: requestType,
        repository: repository,
      );

      if (result.success) {
        _lastUpdateTime = DateTime.now();
        _logger.info(
          'Update completed successfully: ${result.updatedAssetCount} assets, '
          'commit: ${result.newCommitHash}',
        );
      } else {
        _logger.warning('Update failed: ${result.error}');
      }

      return result;
    } catch (e, s) {
      _logger.warning('Update operation failed', e, s);
      return UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  void startBackgroundUpdates() {
    _checkNotDisposed();
    _assertInitialized();

    if (_backgroundUpdatesActive) {
      _logger.fine('Background updates already active');
      return;
    }

    _logger.info(
      'Starting background updates with interval ${_updateStrategy.updateInterval}',
    );

    _backgroundTimer = Timer.periodic(
      _updateStrategy.updateInterval,
      (_) => _performBackgroundUpdate(),
    );

    _backgroundUpdatesActive = true;

    // Perform initial background check
    unawaited(_performBackgroundUpdate());
  }

  /// Performs a background update check
  Future<void> _performBackgroundUpdate() async {
    if (_isDisposed || !_backgroundUpdatesActive) return;

    try {
      _logger.finer('Performing background update check');

      final result = await _performUpdate(UpdateRequestType.backgroundUpdate);

      if (result.success && result.hasNewCommit) {
        _logger.info(
          'Background update completed with new commit: ${result.newCommitHash}',
        );
      }

      _emitUpdateResult(result);
    } catch (e, s) {
      _logger.fine('Background update check failed', e, s);

      final result = UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: e is Exception ? e : Exception(e.toString()),
      );

      _emitUpdateResult(result);
    }
  }

  @override
  void stopBackgroundUpdates() {
    // Allow calling stop even after dispose; just ensure timer is stopped.
    if (!_backgroundUpdatesActive) {
      _logger.fine('Background updates not active');
      return;
    }

    _logger.info('Stopping background updates');
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    _backgroundUpdatesActive = false;
  }

  @override
  bool get isBackgroundUpdatesActive => _backgroundUpdatesActive;

  @override
  Future<void> dispose() async {
    // Make dispose idempotent and safe to call multiple times.
    if (_isDisposed) {
      return;
    }
    // Stop background updates before marking as disposed to avoid race issues.
    stopBackgroundUpdates();

    _isDisposed = true;
    _isInitialized = false;

    if (!_updateStreamController.isClosed) {
      await _updateStreamController.close();
    }

    _logger.fine('Disposed StrategicCoinUpdateManager');
  }
}
