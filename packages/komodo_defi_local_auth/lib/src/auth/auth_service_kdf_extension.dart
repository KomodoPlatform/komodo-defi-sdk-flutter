part of 'auth_service.dart';

extension KdfExtensions on KdfAuthService {
  Future<bool> _walletExists(String walletName) async {
    if (!await _kdfFramework.isRunning()) return false;

    final users = await getUsers();
    return users.any((user) => user.walletId.name == walletName);
  }

  Future<KdfUser?> _getActiveUser() async {
    if (!await _kdfFramework.isRunning()) {
      return null;
    }

    final activeWallet =
        (await _client.rpc.wallet.getWalletNames()).activatedWallet;
    if (activeWallet == null) {
      return null;
    }

    return _secureStorage.getUser(activeWallet);
  }

  /// Returns the mnenomic for the active wallet in the requested format, if
  /// it exists and KDF is running, otherwise throws [AuthException].
  /// NOTE: this function does not check if there is an active user, so only
  /// use it if you know there is one.
  /// There are no read/write locks used internally by this function, so it is
  /// safe to call within mutex locks.
  Future<Mnemonic> _getMnemonic({
    required bool encrypted,
    required String? walletPassword,
  }) async {
    if (!await _kdfFramework.isRunning()) {
      throw AuthException(
        'KDF is not running',
        type: AuthExceptionType.generalAuthError,
      );
    }

    final response = await _kdfFramework.client.executeRpc({
      'mmrpc': '2.0',
      'method': 'get_mnemonic',
      'params': {
        'format': encrypted ? 'encrypted' : 'plaintext',
        if (!encrypted) 'password': walletPassword,
      },
    });

    if (response is JsonRpcErrorResponse) {
      throw AuthException(
        response.error,
        type: AuthExceptionType.generalAuthError,
      );
    }

    return Mnemonic.fromRpcJson(response.value<JsonMap>('result'));
  }

  Future<void> _stopKdf() async {
    await _kdfFramework.kdfStop();
    _authStateController.add(null);
  }

  /// Ensures that KDF is running with a write lock.
  /// NOTE: do not use within a read or write lock.
  Future<void> _ensureKdfRunning() async {
    assert(
      !_authMutex.isReadLocked,
      'Starting KDF is a write-protected operation, '
      'so it should not be called within a read lock.',
    );

    if (!await _kdfFramework.isRunning()) {
      _lockWriteOperation(
        () async => await _kdfFramework.startKdf(await _noAuthConfig),
      );
    }
  }

  // consider moving to kdf api
  Future<void> _restartKdf(KdfStartupConfig config) async {
    final foundAuthExceptions = <AuthException>[];
    late StreamSubscription<String> sub;

    sub = _kdfFramework.logStream.listen((log) {
      final exceptions = AuthException.findExceptionsInLog(log);
      if (exceptions.isNotEmpty) {
        foundAuthExceptions.addAll(exceptions);
      }
    });

    try {
      await _stopKdf();
      final kdfResult = await _kdfFramework.startKdf(config);

      if (!kdfResult.isStartingOrAlreadyRunning()) {
        throw AuthException(
          'Failed to start KDF: ${kdfResult.name}',
          type: AuthExceptionType.generalAuthError,
        );
      }

      await _waitUntilKdfRpcIsUp();

      if (foundAuthExceptions.isNotEmpty) {
        throw foundAuthExceptions.first;
      }
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _waitUntilKdfRpcIsUp({
    Duration timeout = const Duration(seconds: 5),
    bool throwOnTimeout = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final status = await _kdfFramework.kdfMainStatus();
      if (status == MainStatus.rpcIsUp) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (throwOnTimeout) {
      throw AuthException(
        'Timeout waiting for KDF RPC to start',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<KdfStartupConfig> _generateStartupConfig({
    required String walletName,
    required String walletPassword,
    required bool allowRegistrations,
    required bool hdEnabled,
    String? plaintextMnemonic,
    String? encryptedMnemonic,
  }) async {
    if (plaintextMnemonic != null && encryptedMnemonic != null) {
      throw AuthException(
        'Both plaintext and encrypted mnemonics provided.',
        type: AuthExceptionType.generalAuthError,
      );
    }

    return KdfStartupConfig.generateWithDefaults(
      walletName: walletName,
      walletPassword: walletPassword,
      seed: plaintextMnemonic ?? encryptedMnemonic,
      rpcPassword: _hostConfig.rpcPassword,
      allowRegistrations: allowRegistrations,
      enableHd: hdEnabled,
    );
  }
}
