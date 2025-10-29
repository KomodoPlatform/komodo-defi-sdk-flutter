part of 'auth_service.dart';

extension KdfAuthServiceOperationsExtension on KdfAuthService {
  Future<T> _runReadOperation<T>(Future<T> Function() operation) async {
    return _authMutex.protectRead(operation);
  }

  Future<T> _lockWriteOperation<T>(Future<T> Function() operation) async {
    return _authMutex.protectWrite(operation);
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    // With shutdown signal streaming in place, health checks serve primarily
    // as a backup for edge cases where the event stream might miss a shutdown.
    // Reduced from 5 minutes to 30 minutes to minimize RPC spam while
    // maintaining a safety net for detecting stale KDF instances.
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkKdfHealth(),
    );
  }

  /// Subscribes to shutdown signal events from KDF to immediately detect
  /// when KDF is shutting down, eliminating the need for frequent polling.
  ///
  /// This provides near-instant detection of KDF shutdown (< 1 second) compared
  /// to the periodic health check (up to 30 minutes delay).
  ///
  /// Note: This is called once during initialization. If KDF is not running at
  /// that time, [_enableShutdownStream] is retried after KDF successfully starts.
  void _subscribeToShutdownSignals() {
    _shutdownSubscription?.cancel();

    // Enable shutdown signal streaming via RPC and subscribe to events
    _shutdownSubscription = _kdfFramework.streaming.shutdownSignals.listen(
      _handleShutdownSignal,
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Error in shutdown signal stream, '
          'will rely on periodic health checks',
          error,
          stackTrace,
        );
      },
      cancelOnError: false,
    );

    // Enable the shutdown signal stream on KDF
    // Note: This is fire-and-forget; if it fails, we'll rely on health checks
    // and retry when KDF starts
    _enableShutdownStream().catchError((Object error) {
      _logger.warning(
        'Failed to enable shutdown signal stream, '
        'will rely on periodic health checks: $error',
      );
    });
  }

  /// Enables the shutdown signal stream on KDF.
  ///
  /// This is called once during service initialization and retried after KDF
  /// successfully starts to ensure the stream is enabled even if KDF was not
  /// running during initialization.
  Future<void> _enableShutdownStream() async {
    // TODO: Remove if/when shutdown signal stream is supported on Web
    // and Windows
    if (kIsWeb || Platform.isWindows) {
      _logger.info('Shutdown signal stream not supported on Web');
      return;
    }
    try {
      if (!await _kdfFramework.isRunning()) {
        return;
      }

      await _client.rpc.streaming.enableShutdownSignal();
      _logger.info(
        '[EVENT STREAM] Shutdown signal stream enabled successfully',
      );
    } catch (e) {
      // Log but don't throw - streaming is a nice-to-have optimization
      _logger.warning('Could not enable shutdown signal stream: $e');
    }
  }

  /// Handles shutdown signal events by immediately updating auth state.
  void _handleShutdownSignal(ShutdownSignalEvent event) {
    _logger.info(
      'Received shutdown signal (${event.signalName}), '
      'signing out user immediately',
    );

    // Immediately emit signed out state without waiting for health check
    if (_lastEmittedUser != null) {
      _emitAuthStateChange(null);
    }

    // On iOS, trigger app restart for shutdown signals
    // This handles cases where KDF receives an OS shutdown signal
    _handleShutdownSignalRestart(event);
  }

  /// Triggers an iOS app restart when a shutdown signal is received.
  void _handleShutdownSignalRestart(ShutdownSignalEvent event) {
    // The actual implementation is in KomodoDefiFramework
    // to avoid circular dependencies
    _kdfFramework.handleShutdownSignalForRestart(event);
  }

  Future<void> _checkKdfHealth() async {
    try {
      final isRunning = await _kdfFramework.isRunning();
      // Bypass cached user to detect external changes accurately
      final currentUser = await _getActiveUser();

      // If KDF is not running or we're in no-auth mode but previously had a user,
      // emit signed out state
      if ((!isRunning || currentUser == null) && _lastEmittedUser != null) {
        _emitAuthStateChange(null);
      } else if (currentUser != null &&
          currentUser.walletId != _lastEmittedUser?.walletId) {
        // User state changed
        _emitAuthStateChange(currentUser);
      }
    } catch (e, s) {
      // Log the error but don't immediately sign out on transient RPC failures.
      // The next health check (in 5 minutes) will verify if this is persistent.
      // This prevents false sign-outs during temporary network issues.
      _logger.warning('Health check failed, will retry on next interval', e, s);
      // Note: We intentionally do NOT emit null here to avoid false sign-outs
      // from transient errors. KDF may still be running and user authenticated.
    }
  }
}
