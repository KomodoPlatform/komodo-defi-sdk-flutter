part of 'auth_service.dart';

extension KdfAuthServiceAuthExtension on KdfAuthService {
  Future<KdfUser> _authenticateUser(KdfStartupConfig config) async {
    await _restartKdf(config);
    final status = await _kdfFramework.kdfMainStatus();
    if (status != MainStatus.rpcIsUp) {
      throw AuthException(
        'KDF framework is not running properly: ${status.name}',
        type: AuthExceptionType.generalAuthError,
      );
    }

    // use the internal function here, which isn't read-protected, to avoid
    // deadlocks if used within a write-lock
    var currentUser = await _getActiveUser();
    if (currentUser == null) {
      throw AuthException(
        'No user signed in',
        type: AuthExceptionType.unauthorized,
      );
    }

    // For HD wallets, verify BIP39 compatibility if not already verified
    if (currentUser.isHd && !currentUser.isBip39Seed) {
      currentUser = await _verifyBip39Compatibility(
        walletPassword: config.walletPassword,
        currentUser,
      );
    }

    return currentUser;
  }

  void _emitAuthStateChange(KdfUser? user) {
    if (!_authStateController.isClosed && user != _lastEmittedUser) {
      _lastEmittedUser = user;
      _authStateController.add(user);
    }
  }

  /// Creates, stores, and verifies the bip39 compatibility of a new user, if
  /// HD wallet is enabled for the user.
  Future<KdfUser> _registerNewUser(
    KdfStartupConfig config,
    AuthOptions authOptions,
  ) async {
    await _restartKdf(config);
    final status = await _kdfFramework.kdfMainStatus();
    if (status != MainStatus.rpcIsUp) {
      throw AuthException(
        'KDF framework is not running properly: ${status.name}',
        type: AuthExceptionType.generalAuthError,
      );
    }

    final walletId = WalletId.fromName(config.walletName!, authOptions);
    final isBip39Seed = await _isSeedBip39Compatible(config);
    final currentUser = KdfUser(walletId: walletId, isBip39Seed: isBip39Seed);
    await _secureStorage.saveUser(currentUser);

    // Do not allow authentication to proceed for HD wallets if the seed is not
    // BIP39 compatible.
    if (currentUser.isHd) {
      return _verifyBip39Compatibility(
        currentUser,
        walletPassword: config.walletPassword,
      );
    }

    return currentUser;
  }

  /// Checks if the seed is a valid BIP39 seed phrase.
  /// Throws [AuthException] if the seed could not be obtained from KDF.
  Future<bool> _isSeedBip39Compatible(KdfStartupConfig config) async {
    final plaintext = await _getMnemonic(
      encrypted: false,
      walletPassword: config.walletPassword,
    );

    if (plaintext.plaintextMnemonic == null) {
      throw AuthException(
        'Failed to decrypt seed for verification',
        type: AuthExceptionType.generalAuthError,
      );
    }

    final validator = MnemonicValidator();
    await validator.init();
    final isBip39 = validator.validateBip39(plaintext.plaintextMnemonic!);
    return isBip39;
  }

  /// Requires a user to be signed into a valid wallet in order to verify the
  /// seed phrase and determine BIP39 compatibility.
  /// Updates the stored user with the verified BIP39 status before returning
  /// the modified [KdfUser].
  /// NOTE: this function does not contain any write/read protected sections,
  /// so any atomic requirements need to be handled by the calling function.
  /// Throws [AuthException] if the seed is not a valid BIP39 seed phrase.
  Future<KdfUser> _verifyBip39Compatibility(
    KdfUser currentUser, {
    required String? walletPassword,
  }) async {
    var updatedUser = currentUser.copyWith();
    bool isBip39;

    try {
      // Use the password from the config to verify the seed
      // Use the private method here, since it does not call the read-protected
      // [getActiveUser] function (or any others). It simply
      final plaintext = await _getMnemonic(
        encrypted: false,
        walletPassword: walletPassword,
      );

      if (plaintext.plaintextMnemonic == null) {
        throw AuthException(
          'Failed to decrypt seed for verification',
          type: AuthExceptionType.generalAuthError,
        );
      }

      await MnemonicValidator().init();
      isBip39 = MnemonicValidator().validateBip39(plaintext.plaintextMnemonic!);

      if (!isBip39) {
        await _stopKdf();
        throw AuthException(
          'HD wallets require a valid BIP39 seed phrase',
          type: AuthExceptionType.invalidBip39Mnemonic,
        );
      }

      // Update stored user with verified BIP39 status
      updatedUser = currentUser.copyWith(isBip39Seed: true);
      await _secureStorage.saveUser(updatedUser);
    } catch (e) {
      await _stopKdf();
      throw AuthException(
        'Failed to verify seed compatibility: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }

    return updatedUser;
  }
}
