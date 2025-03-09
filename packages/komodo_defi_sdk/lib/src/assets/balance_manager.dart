import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/assets/asset_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

/// Manages balance operations and balance streaming for assets
class BalanceManager {
  /// Creates a balance manager with the given client and managers
  BalanceManager(
    this._client,
    this._activationManager,
    this._assetManager,
    this._auth,
  );

  /// Constant duration values for various timing operations
  static const Duration _refreshIntervalWithBalance = Duration(seconds: 30);
  static const Duration _refreshIntervalNoBalance = Duration(seconds: 60);

  // Increased timeout from 10 to 30 seconds to accommodate slower servers
  static const Duration _waitingTimeout = Duration(seconds: 30);
  static const Duration _activationPollingInterval = Duration(seconds: 3);
  static const Duration _waitingPollInterval = Duration(milliseconds: 100);

  // Minimum time between staggered balance fetches
  static const Duration _minimumStaggeredFetchInterval = Duration(seconds: 1);
  // The maximum time before waiting to start the next staggered fetch
  static const Duration _maximumStaggeredFetchInterval = Duration(seconds: 5);

  // Maximum number of consecutive failures before temporarily disabling an asset's refresh
  static const int _maxConsecutiveFailures = 3;

  // Duration to wait before attempting to refresh a problematic asset again
  static const Duration _problematicAssetCooldown = Duration(minutes: 5);

  final ApiClient _client;
  final ActivationManager _activationManager;
  final AssetManager _assetManager;
  final KomodoDefiLocalAuth _auth;

  final Map<AssetId, StreamController<BalanceInfo>> _balanceStreams = {};
  final Map<AssetId, BalanceInfo> _lastKnownBalances = {};
  final Map<AssetId, Timer> _refreshTimers = {};
  final Map<AssetId, Mutex> _mutexes = {};

  // Track failed attempts to fetch balances
  final Map<AssetId, int> _consecutiveFailures = {};
  // Track when a problematic asset can be retried
  final Map<AssetId, DateTime> _cooldownUntil = {};

  // Add a random number generator for staggered refresh
  final _random = math.Random();

  // Keep track of the last refresh time for each asset
  final Map<AssetId, DateTime> _lastRefreshTimes = {};

  Future<bool?> _isHdWallet() => _auth.currentUser.then((user) => user?.isHd);

  /// Gets the current balance for an asset.
  /// Will ensure the asset is activated before querying.
  ///
  /// Throws an [AuthException] if the user is not signed in.
  /// Throws an [ArgumentError] if the asset is not found.
  /// May throw a [TimeoutException] if the balance fetch times out.
  Future<BalanceInfo> getBalance(AssetId assetId) async {
    final isHdWallet = await _isHdWallet();
    if (isHdWallet == null) {
      throw AuthException.notSignedIn();
    }

    // Check if the asset is in cooldown period after consecutive failures
    if (_isAssetInCooldown(assetId)) {
      final cooldownUntil = _cooldownUntil[assetId]!;
      final remainingTime = cooldownUntil.difference(DateTime.now());
      debugPrint(
        'Asset $assetId is in cooldown period. Will retry in ${remainingTime.inSeconds} seconds',
      );

      // Return last known balance if available
      if (_lastKnownBalances.containsKey(assetId)) {
        return _lastKnownBalances[assetId]!;
      }

      throw TimeoutException(
        'Asset $assetId temporarily unavailable due to connection issues. Retrying in ${remainingTime.inSeconds} seconds',
      );
    }

    final mutex = _mutexes.putIfAbsent(assetId, Mutex.new);

    // Prevent concurrent calls for the same asset
    if (mutex.isLocked) {
      debugPrint('Balance fetch already in progress for $assetId, waiting...');
      // Return last known balance or wait for current fetch to complete
      return _lastKnownBalances[assetId] ??
          await _waitForFetchCompletion(assetId);
    }

    try {
      await mutex.acquire();

      final asset = _assetManager.fromId(assetId);
      if (asset == null) {
        throw ArgumentError('Asset $assetId not found');
      }

      // Ensure asset is activated first
      try {
        await _activationManager.activateAsset(asset).last;
      } catch (e) {
        debugPrint('Failed to activate asset $assetId: $e');
        _incrementFailureCount(assetId);
        rethrow;
      }

      // Use the appropriate balance strategy based on wallet mode
      final balanceStrategy = BalanceStrategyFactory.createStrategy(
        isHdWallet: isHdWallet,
      );

      BalanceInfo balance;
      try {
        // Wrap the balance fetch with a timeout
        balance = await balanceStrategy
            .getBalance(assetId, _client)
            .timeout(
              _waitingTimeout,
              onTimeout: () {
                throw TimeoutException(
                  'Balance fetch operation timed out for $assetId',
                );
              },
            );

        debugPrint('Got balance for $assetId: ${balance.total}');

        // Reset failure counter on success
        _resetFailureCount(assetId);
      } catch (e) {
        debugPrint('Error fetching balance for $assetId: $e');
        _incrementFailureCount(assetId);
        rethrow;
      }

      // Update stream if value changed
      final lastBalance = _lastKnownBalances[assetId];
      if (lastBalance != balance) {
        _lastKnownBalances[assetId] = balance;
        _yieldBalance(assetId, balance);
      }

      return balance;
    } finally {
      _safeReleaseMutex(mutex);
    }
  }

  /// Check if the asset is in cooldown period
  bool _isAssetInCooldown(AssetId assetId) {
    final cooldownUntil = _cooldownUntil[assetId];
    if (cooldownUntil != null) {
      return DateTime.now().isBefore(cooldownUntil);
    }
    return false;
  }

  /// Increment failure counter for an asset and put it in cooldown if needed
  void _incrementFailureCount(AssetId assetId) {
    final failures = (_consecutiveFailures[assetId] ?? 0) + 1;
    _consecutiveFailures[assetId] = failures;

    if (failures >= _maxConsecutiveFailures) {
      debugPrint(
        'Asset $assetId has failed $failures times consecutively. Putting in cooldown',
      );
      _cooldownUntil[assetId] = DateTime.now().add(_problematicAssetCooldown);
    }
  }

  /// Reset failure counter for an asset
  void _resetFailureCount(AssetId assetId) {
    _consecutiveFailures.remove(assetId);
    _cooldownUntil.remove(assetId);
  }

  /// Safely releases a mutex if it's locked
  void _safeReleaseMutex(Mutex? mutex) {
    if (mutex != null && mutex.isLocked) {
      mutex.release();
    }
  }

  /// Waits for an in-progress fetch operation to complete
  Future<BalanceInfo> _waitForFetchCompletion(AssetId assetId) async {
    // Completes when the fetch lock is released and we have a balance
    final completer = Completer<BalanceInfo>();
    Timer? periodicTimer;

    periodicTimer = Timer.periodic(_waitingPollInterval, (timer) {
      // Check that the mutex exists before using it
      if (!_mutexes.containsKey(assetId)) {
        timer.cancel();
        if (!completer.isCompleted && _lastKnownBalances.containsKey(assetId)) {
          completer.complete(_lastKnownBalances[assetId]!);
        }
        return;
      }

      final mutex = _mutexes[assetId]!;
      if (!mutex.isLocked && _lastKnownBalances.containsKey(assetId)) {
        timer.cancel();
        completer.complete(_lastKnownBalances[assetId]!);
      }
    });

    return completer.future.timeout(
      _waitingTimeout,
      onTimeout: () {
        periodicTimer?.cancel();
        // Mark the asset as having failed once when timeout occurs
        _incrementFailureCount(assetId);
        throw TimeoutException(
          'Timed out waiting for balance fetch to complete for $assetId',
        );
      },
    );
  }

  /// Gets a stream of balance updates for an asset.
  /// The stream will emit the current balance immediately and then periodically refresh.
  /// The refresh interval is 30 seconds for assets with a balance, 60 seconds for those without.
  ///
  /// If [activateIfNeeded] is false and the asset is not activated, the method will not
  /// trigger activation but will poll every 3 seconds to check if the asset becomes activated,
  /// either externally or by another call.
  ///
  /// Throws an [ArgumentError] if the asset is not found.
  Stream<BalanceInfo> watchBalance(
    AssetId assetId, {
    bool activateIfNeeded = true,
  }) {
    final mutex = _mutexes.putIfAbsent(assetId, Mutex.new);

    return Stream.fromFuture(
      mutex.protect<Stream<BalanceInfo>>(() async {
        // Get or create stream controller atomically
        final controller = _getOrCreateStreamController(assetId);

        // Emit current balance immediately if available
        final currentBalance = _lastKnownBalances[assetId];
        if (currentBalance != null) {
          controller.add(currentBalance);
        }

        final asset = _assetManager.fromId(assetId);
        if (asset == null) {
          throw ArgumentError('Asset $assetId not found');
        }

        // Handle non-activated assets
        if (!activateIfNeeded) {
          final isActive = await _activationManager.isAssetActive(asset.id);
          if (!isActive) {
            debugPrint(
              'Asset $assetId not activated and activateIfNeeded=false',
            );
            _startActivationPolling(assetId, asset);
            // _safeReleaseMutex(mutex);
            return controller.stream;
          }
        }

        // Get initial balance if we don't have one yet
        if (currentBalance == null) {
          try {
            final initialBalance = await getBalance(assetId);
            if (!controller.isClosed) {
              _yieldBalance(assetId, initialBalance);
            }
          } catch (e) {
            debugPrint('Error getting initial balance for $assetId: $e');
            scheduleMicrotask(() {
              // _safeAddErrorToController(controller, e);
            });
          }
        }

        // // Ensure we release the mutex before returning the stream
        // _safeReleaseMutex(mutex);
        return controller.stream;
      }),
    ).asyncExpand((stream) => stream);
  }

  /// Creates or returns an existing broadcast stream controller for the given asset
  StreamController<BalanceInfo> _getOrCreateStreamController(AssetId assetId) {
    return _balanceStreams.putIfAbsent(assetId, () {
      debugPrint('Creating new balance stream for $assetId');
      return StreamController<BalanceInfo>.broadcast(
        onCancel: () {
          debugPrint('No more listeners for $assetId, pausing updates');
          final timer = _refreshTimers[assetId];
          if (timer != null) {
            timer.cancel();
          }
        },
        onListen: () {
          final lastKnownBalance = _lastKnownBalances[assetId];
          if (lastKnownBalance != null) {
            final timer = _refreshTimers[assetId];
            if (timer == null || !timer.isActive) {
              debugPrint('Restarting timer for $assetId');
              _startRefreshTimer(assetId, lastKnownBalance.hasValue);
            }
          }
        },
      );
    });
  }

  /// Start polling for asset activation and fetch balance when activated
  void _startActivationPolling(AssetId assetId, Asset asset) {
    _refreshTimers[assetId]?.cancel();

    final poller = Timer.periodic(_activationPollingInterval, (timer) async {
      final controller = _balanceStreams[assetId];
      if (controller == null || controller.isClosed) {
        timer.cancel();
        return;
      }

      try {
        final isActivated = await _activationManager.isAssetActive(asset.id);
        if (isActivated) {
          debugPrint('Asset $assetId is now activated, fetching balance');
          timer.cancel();

          try {
            final balance = await getBalance(assetId);
            if (!controller.isClosed) {
              _yieldBalance(assetId, balance);
            }
          } catch (error) {
            debugPrint(
              'Error getting balance for newly activated asset $assetId: $error',
            );
            _safeAddErrorToController(controller, error);
          }
        }
      } catch (error) {
        debugPrint('Error checking activation status for $assetId: $error');
        _safeAddErrorToController(controller, error);
      }
    });

    _refreshTimers[assetId] = poller;
  }

  /// Safely add an error to a stream controller if it's not closed
  void _safeAddErrorToController(
    StreamController<BalanceInfo> controller,
    Object error, [ // Added explicit Object type to fix inference warning
    StackTrace? stackTrace,
  ]) {
    if (!controller.isClosed) {
      if (stackTrace != null) {
        controller.addError(error, stackTrace);
      } else {
        controller.addError(error);
      }
    }
  }

  /// Start a timer to periodically refresh the balance
  void _startRefreshTimer(AssetId assetId, bool hasBalance) {
    _refreshTimers[assetId]?.cancel();

    final interval =
        hasBalance ? _refreshIntervalWithBalance : _refreshIntervalNoBalance;

    // Calculate the staggered delay for this asset
    final staggeredDelay = _calculateStaggeredDelay(assetId);

    debugPrint(
      'Starting balance refresh timer for $assetId with interval ${interval.inSeconds}s '
      'and initial delay of ${staggeredDelay.inMilliseconds}ms',
    );

    // Use a one-time timer for the initial staggered delay
    Timer(staggeredDelay, () {
      // Set the last refresh time when we first start the timer
      _lastRefreshTimes[assetId] = DateTime.now();

      // Refresh immediately after the staggered delay
      _refreshBalance(assetId);

      // Then set up the periodic timer with the regular interval
      _refreshTimers[assetId] = Timer.periodic(interval, (timer) async {
        final controller = _balanceStreams[assetId];
        if (controller == null || !controller.hasListener) {
          debugPrint('No listeners for $assetId, cancelling timer');
          timer.cancel();
          return;
        }

        // Update the last refresh time
        _lastRefreshTimes[assetId] = DateTime.now();

        // Perform the balance refresh
        _refreshBalance(assetId);
      });
    });
  }

  /// Calculate a staggered delay for an asset
  Duration _calculateStaggeredDelay(AssetId assetId) {
    // If this is the first balance being monitored, start immediately
    if (_refreshTimers.isEmpty) {
      return Duration.zero;
    }

    // Calculate a random staggered delay between min and max values
    final milliseconds =
        _minimumStaggeredFetchInterval.inMilliseconds +
        _random.nextInt(
          _maximumStaggeredFetchInterval.inMilliseconds -
              _minimumStaggeredFetchInterval.inMilliseconds,
        );

    return Duration(milliseconds: milliseconds);
  }

  /// Perform the balance refresh operation
  Future<void> _refreshBalance(AssetId assetId) async {
    final controller = _balanceStreams[assetId];
    if (controller == null || !controller.hasListener) {
      return;
    }

    // Skip refresh if asset is in cooldown period
    if (_isAssetInCooldown(assetId)) {
      final cooldownUntil = _cooldownUntil[assetId]!;
      final remainingTime = cooldownUntil.difference(DateTime.now());
      debugPrint(
        'Skipping refresh for $assetId. In cooldown for ${remainingTime.inSeconds} seconds',
      );
      return;
    }

    try {
      debugPrint('Refreshing balance for $assetId');
      await getBalance(assetId);
    } catch (e) {
      debugPrint('Error refreshing balance for $assetId: $e');
      _safeAddErrorToController(controller, e);
    }
  }

  /// Stops balance streaming for an asset
  void stopStreaming(AssetId assetId) {
    // Remove explicit null check since AssetId should be non-nullable
    debugPrint('Stopping balance streaming for $assetId');

    // Cancel and remove timer
    _refreshTimers[assetId]?.cancel();
    _refreshTimers.remove(assetId);

    // Close and remove stream controller
    final controller = _balanceStreams[assetId];
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
    _balanceStreams.remove(assetId);

    // Clean up other resources
    _lastKnownBalances.remove(assetId);
    _mutexes.remove(assetId);
  }

  /// Stops all balance streams and cleans up resources
  Future<void> dispose() async {
    debugPrint('Disposing BalanceManager');

    // Cancel all timers
    for (final timer in _refreshTimers.values) {
      timer.cancel();
    }
    _refreshTimers.clear();

    // Close all stream controllers
    await Future.wait(
      _balanceStreams.values
          .where((controller) => !controller.isClosed)
          .map((controller) => controller.close().catchError((_) {})),
    );
    _balanceStreams.clear();

    // Clear all caches
    _lastKnownBalances.clear();
    _lastRefreshTimes.clear();
    _consecutiveFailures.clear();
    _cooldownUntil.clear();

    // Release all mutexes
    for (final mutex in _mutexes.values) {
      _safeReleaseMutex(mutex);
    }
    _mutexes.clear();
  }

  /// Add a balance to the appropriate stream and start refresh timer if needed
  void _yieldBalance(AssetId assetId, BalanceInfo? balance) {
    if (balance == null) return;

    // Get or create the controller
    final controller = _getOrCreateStreamController(assetId);

    // Cache the balance
    _lastKnownBalances[assetId] = balance;

    // Start refresh timer with appropriate interval if not already running
    if (_refreshTimers[assetId] == null || !_refreshTimers[assetId]!.isActive) {
      _startRefreshTimer(assetId, balance.hasValue);
    }

    // Only add to stream if the controller is still active
    if (!controller.isClosed) {
      controller.add(balance);
    }
  }

  /// Gets the last known balance for an asset without triggering a refresh.
  /// Returns null if no balance has been fetched yet.
  BalanceInfo? getLastKnownBalance(AssetId assetId) {
    return _lastKnownBalances[assetId];
  }
}
