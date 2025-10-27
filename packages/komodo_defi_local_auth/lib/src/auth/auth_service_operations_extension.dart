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
    // Reduce frequency to prevent excessive wallet name checks.
    // Health checks do not need sub-second responsiveness; 5 minutes is ample.
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkKdfHealth(),
    );
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
      _logger.warning(
        'Health check failed, will retry on next interval',
        e,
        s,
      );
      // Note: We intentionally do NOT emit null here to avoid false sign-outs
      // from transient errors. KDF may still be running and user authenticated.
    }
  }
}
