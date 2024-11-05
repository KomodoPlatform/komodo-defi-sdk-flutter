import 'dart:async';

import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/src/auth/storage/secure_storage.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

abstract interface class IAuthService {
  Future<List<KdfUser>> getUsers();

  Future<KdfUser> signIn({
    required String walletName,
    required String password,
    required AuthOptions options,
  });

  Future<KdfUser> register({
    required String walletName,
    required String password,
    required AuthOptions options,
    Mnemonic? mnemonic,
  });

  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<KdfUser?> getActiveUser();
  Future<Mnemonic> getMnemonic({
    required bool encrypted,
    required String? walletPassword,
  });

  Stream<KdfUser?> get authStateChanges;
  void dispose();
}

class KdfAuthService implements IAuthService {
  KdfAuthService(this._kdfFramework, this._hostConfig);

  final KomodoDefiFramework _kdfFramework;
  final IKdfHostConfig _hostConfig;
  final StreamController<KdfUser?> _authStateController =
      StreamController.broadcast();
  final SecureLocalStorage _secureStorage = SecureLocalStorage();
  final ReadWriteMutex _authMutex = ReadWriteMutex();

  ApiClient get _client => _kdfFramework.client;
  late final methods = KomodoDefiRpcMethods(_client);

  Future<T> _runReadOperation<T>(Future<T> Function() operation) async {
    return _authMutex.protectRead(operation);
  }

  Future<T> _lockWriteOperation<T>(Future<T> Function() operation) async {
    return _authMutex.protectWrite(operation);
  }

  Future<KdfUser> _authenticateUser(KdfStartupConfig config) async {
    await _restartKdf(config);
    final status = await _kdfFramework.kdfMainStatus();
    if (status != MainStatus.rpcIsUp) {
      throw AuthException(
        'KDF framework is not running properly: ${status.name}',
        type: AuthExceptionType.generalAuthError,
      );
    }

    var currentUser = await _getActiveUserInternal();
    if (currentUser == null) {
      throw AuthException(
        'No user signed in',
        type: AuthExceptionType.unauthorized,
      );
    }

    // For HD wallets, verify BIP39 compatibility if not already verified
    if (currentUser.isHd && !currentUser.isBip39Seed) {
      currentUser = await _verifyBip39Compatibility(config, currentUser);
    }

    _authStateController.add(currentUser);
    return currentUser;
  }

  Future<KdfUser> _registerNewUser(
    KdfStartupConfig config,
    AuthOptions authOptions,
    bool isBip39Seed,
  ) async {
    await _restartKdf(config);
    final status = await _kdfFramework.kdfMainStatus();
    if (status != MainStatus.rpcIsUp) {
      throw AuthException(
        'KDF framework is not running properly: ${status.name}',
        type: AuthExceptionType.generalAuthError,
      );
    }

    final walletId = WalletId.fromName(config.walletName!);
    var currentUser = KdfUser(
      walletId: walletId,
      authOptions: authOptions,
      isBip39Seed: isBip39Seed,
    );

    if (currentUser.isHd && !currentUser.isBip39Seed) {
      currentUser = await _verifyBip39Compatibility(config, currentUser);
    }

    _authStateController.add(currentUser);
    return currentUser;
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

  Future<KdfUser> _verifyBip39Compatibility(
    KdfStartupConfig config,
    KdfUser currentUser,
  ) async {
    var updatedUser = currentUser.copyWith();
    bool isBip39;

    try {
      // Use the password from the config to verify the seed
      final plaintext = await getMnemonic(
        encrypted: false,
        walletPassword: config.walletPassword,
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
          type: AuthExceptionType.invalidWalletPassword,
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

  @override
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  }) async {
    final walletStatus =
        await _runReadOperation(() => _getWalletStatus(walletName));

    if (walletStatus) {
      final activeUser = await _runReadOperation(_getActiveUserInternal);
      return activeUser!;
    }

    return _lockWriteOperation(() async {
      final storedUser = await _secureStorage.getUser(walletName);

      // If we know this is not a BIP39 seed, don't allow HD mode
      if (storedUser?.isBip39Seed == false &&
          options.derivationMethod == DerivationMethod.hdWallet) {
        throw AuthException(
          'Cannot use HD mode with non-BIP39 seed',
          type: AuthExceptionType.generalAuthError,
        );
      }

      final config = await _generateStartupConfig(
        walletName: walletName,
        walletPassword: password,
        allowRegistrations: false,
        hdEnabled: options.derivationMethod == DerivationMethod.hdWallet,
      );

      // _authenticateUser will handle BIP39 verification for HD wallets
      return _authenticateUser(config);
    });
  }

  @override
  Future<KdfUser> register({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
    Mnemonic? mnemonic,
  }) async {
    final walletExists =
        await _runReadOperation(() => _assertWalletOrStop(walletName));
    if (walletExists ?? false) {
      throw AuthException(
        'Wallet already exists',
        type: AuthExceptionType.generalAuthError,
      );
    }

    return _lockWriteOperation(() async {
      bool? isBip39;

      // Verify BIP39 status for plaintext mnemonics
      if (mnemonic?.plaintextMnemonic != null) {
        await MnemonicValidator().init();
        isBip39 =
            MnemonicValidator().validateBip39(mnemonic!.plaintextMnemonic!);

        if (!isBip39 && options.derivationMethod == DerivationMethod.hdWallet) {
          throw AuthException(
            'HD wallets require a valid BIP39 seed phrase',
            type: AuthExceptionType.generalAuthError,
          );
        }
      }

      final config = await _generateStartupConfig(
        walletName: walletName,
        walletPassword: password,
        allowRegistrations: true,
        plaintextMnemonic: mnemonic?.plaintextMnemonic,
        hdEnabled: options.derivationMethod == DerivationMethod.hdWallet,
      );

      final user = await _registerNewUser(config, options, isBip39 ?? false);

      // Store initial user with BIP39 status if known
      if (isBip39 != null) {
        final userWithBip39 = user.copyWith(isBip39Seed: isBip39);
        await _secureStorage.saveUser(userWithBip39);
        return userWithBip39;
      }

      await _secureStorage.saveUser(user);
      return user;
    });
  }

  @override
  Future<List<KdfUser>> getUsers() async {
    return _runReadOperation(() async {
      await _ensureKdfRunning();
      final walletNames = await _client.rpc.wallet.getWalletNames();

      return Future.wait(
        walletNames.walletNames.map((name) async {
          final user = await _secureStorage.getUser(name);
          if (user != null) return user;

          // Create new user record if none exists
          final newUser = KdfUser(
            walletId: WalletId.fromName(name),
            authOptions: _fallbackAuthOptions,
            isBip39Seed: true, // Default to true until verified otherwise
          );
          await _secureStorage.saveUser(newUser);
          return newUser;
        }),
      );
    });
  }

  Future<void> updateUserBip39Status(String walletName, bool isBip39) async {
    final existingUser = await _secureStorage.getUser(walletName);
    if (existingUser == null) return;

    // Don't allow switching to HD if not BIP39
    if (!isBip39 && existingUser.isHd) {
      throw AuthException(
        'Cannot use non-BIP39 seed with HD wallet',
        type: AuthExceptionType.generalAuthError,
      );
    }

    final updatedUser = existingUser.copyWith(isBip39Seed: isBip39);
    await _secureStorage.saveUser(updatedUser);
  }

  Future<String?> _getPubkeyHash() async {
    try {
      final response = await _client.rpc.wallet.getPublicKeyHash();
      return response.publicKeyHash;
    } catch (_) {
      // If we can't get the pubkey hash, return null and continue with partial ID
      return null;
    }
  }

  Future<bool> _getWalletStatus(String walletName) async {
    return await _assertWalletOrStop(walletName) ?? false;
  }

  @override
  Future<void> signOut() async {
    await _lockWriteOperation(_stopKdf);
  }

  @override
  Future<bool> isSignedIn() async {
    return _runReadOperation(() async {
      return await _getActiveUserInternal() != null;
    });
  }

  @override
  Future<KdfUser?> getActiveUser() async {
    return _runReadOperation(_getActiveUserInternal);
  }

  Future<KdfUser?> _getActiveUserInternal() async {
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

  AuthOptions get _fallbackAuthOptions => const AuthOptions(
        derivationMethod: DerivationMethod.hdWallet,
      );

  @override
  Future<Mnemonic> getMnemonic({
    required bool encrypted,
    required String? walletPassword,
  }) async {
    return _runReadOperation(() async {
      assert(
        encrypted || walletPassword != null,
        'walletPassword is required to retrieve plaintext mnemonic.',
      );

      if (await _getActiveUserInternal() == null) {
        throw AuthException(
          'No user signed in',
          type: AuthExceptionType.unauthorized,
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
    });
  }

  @override
  Stream<KdfUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> dispose() async {
    return _lockWriteOperation(() async {
      await _stopKdf();
      await _authStateController.close();
    });
  }

  Future<bool?> _assertWalletOrStop(String walletName) async {
    if (!await _kdfFramework.isRunning()) return null;

    final activeUser = await getActiveUser();
    if (activeUser == null) {
      await _stopKdf();
      return false;
    }

    if (activeUser.walletId.name != walletName) {
      await _stopKdf();
      return false;
    }

    return true;
  }

  Future<void> _stopKdf() async {
    await _kdfFramework.kdfStop();
    _authStateController.add(null);
  }

  Future<void> _ensureKdfRunning() async {
    if (!await _kdfFramework.isRunning()) {
      await _kdfFramework.startKdf(await _noAuthConfig);
    }
  }

  late final Future<KdfStartupConfig> _noAuthConfig =
      KdfStartupConfig.noAuthStartup(rpcPassword: _hostConfig.rpcPassword);

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

  Future<bool> verifyEncryptedSeedBip39Compatibility(
    String password,
  ) async {
    final mnemonic = await getMnemonic(
      encrypted: false,
      walletPassword: password,
    );

    if (mnemonic.plaintextMnemonic == null) {
      throw AuthException(
        'Failed to decrypt seed for verification',
        type: AuthExceptionType.generalAuthError,
      );
    }

    return MnemonicValidator().init().then((_) {
      final result = MnemonicValidator().validateMnemonic(
        mnemonic.plaintextMnemonic!,
        isHd: false,
        allowCustomSeed: true,
      );

      return result == null;
    });
  }
}
