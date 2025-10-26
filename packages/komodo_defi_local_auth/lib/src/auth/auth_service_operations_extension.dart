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
      final currentUser = await getActiveUser();

      // If KDF is not running or we're in no-auth mode but previously had a user,
      // emit signed out state
      if ((!isRunning || currentUser == null) && _lastEmittedUser != null) {
        _emitAuthStateChange(null);
      } else if (currentUser != null &&
          currentUser.walletId != _lastEmittedUser?.walletId) {
        // User state changed
        _emitAuthStateChange(currentUser);
      }
    } catch (e) {
      // If we can't check status, assume KDF is not running properly
      if (_lastEmittedUser != null) {
        _emitAuthStateChange(null);
      }
    }
  }
}
