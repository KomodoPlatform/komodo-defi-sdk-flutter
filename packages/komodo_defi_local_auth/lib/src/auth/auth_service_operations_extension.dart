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
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkKdfHealth(),
    );
  }

  Future<void> _checkKdfHealth() async {
    try {
      final isRunning = await _kdfFramework.isRunning();
      if (!isRunning) {
        await _handleKdfDown();
        return;
      }

      final currentUser = await _getActiveUser();
      if (currentUser == null) {
        if (_lastEmittedUser != null) {
          _emitAuthStateChange(null);
        }
        if (_activeSession != null) {
          await _attemptRecovery(restartWallet: true);
        }
        return;
      }

      if (_lastEmittedUser?.walletId != currentUser.walletId) {
        _emitAuthStateChange(currentUser);
      }
    } catch (e, stack) {
      developer.log(
        'KDF health check failed: $e',
        name: 'KdfAuthService',
        stackTrace: stack,
      );
      if (_lastEmittedUser != null) {
        _emitAuthStateChange(null);
      }
      await _handleKdfDown();
    }
  }

  Future<void> _handleKdfDown() async {
    if (_lastEmittedUser != null) {
      _emitAuthStateChange(null);
    }
    await _attemptRecovery(restartWallet: true);
  }

  Future<void> _attemptRecovery({required bool restartWallet}) async {
    final existingTask = _recoveryTask;
    if (existingTask != null) {
      await existingTask;
      return;
    }

    final task = _lockWriteOperation(() async {
      try {
        final isRunning = await _kdfFramework.isRunning();
        if (!isRunning) {
          final walletRecovered =
              restartWallet && await _tryRecoverWalletSession();
          if (walletRecovered) {
            return;
          }
          await _startNoAuthMode();
          if (restartWallet) {
            await _tryRecoverWalletSession();
          }
          return;
        }

        if (restartWallet) {
          await _tryRecoverWalletSession();
        }
      } finally {
        _recoveryTask = null;
      }
    });

    _recoveryTask = task;
    await task;
  }

  Future<bool> _tryRecoverWalletSession() async {
    final session = await _ensureCachedSession();
    if (session == null) {
      return false;
    }

    if (_recoveryAttempts >= KdfAuthService._maxRecoveryAttempts) {
      developer.log(
        'Skipping automatic recovery for ${session.walletName}: attempt limit reached.',
        name: 'KdfAuthService',
      );
      return false;
    }

    _recoveryAttempts++;
    developer.log(
      'Attempting automatic recovery for wallet ${session.walletName} '
      '(attempt $_recoveryAttempts of ${KdfAuthService._maxRecoveryAttempts}).',
      name: 'KdfAuthService',
    );

    try {
      final config = await session.buildStartupConfig(this);
      await _restartKdf(config);
      await _waitUntilKdfRpcIsUp();
      final recoveredUser = await _getActiveUser();
      if (recoveredUser != null) {
        _emitAuthStateChange(recoveredUser);
        _recoveryAttempts = 0;
        developer.log(
          'Wallet ${session.walletName} recovered automatically.',
          name: 'KdfAuthService',
        );
        return true;
      }

      developer.log(
        'Automatic recovery completed but no active user detected for '
        '${session.walletName}.',
        name: 'KdfAuthService',
      );
    } catch (e, stack) {
      developer.log(
        'Automatic wallet recovery failed for ${session.walletName}: $e',
        name: 'KdfAuthService',
        stackTrace: stack,
      );
    }

    return false;
  }

  Future<void> _startNoAuthMode() async {
    try {
      developer.log('Starting KDF in no-auth mode.', name: 'KdfAuthService');
      final result = await _kdfFramework.startKdf(await _noAuthConfig);
      if (!result.isStartingOrAlreadyRunning()) {
        developer.log(
          'No-auth restart returned status ${result.name}.',
          name: 'KdfAuthService',
        );
      }
      await _waitUntilKdfRpcIsUp();
    } catch (e, stack) {
      developer.log(
        'Failed to start KDF in no-auth mode: $e',
        name: 'KdfAuthService',
        stackTrace: stack,
      );
    }
  }
}
