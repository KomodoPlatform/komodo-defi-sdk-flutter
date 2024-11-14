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

  /// Throws [AuthException] if user creation fails, the wallet already exists,
  /// or the seed phrase is not a valid BIP39 seed phrase.
  Future<KdfUser> register({
    required String walletName,
    required String password,
    required AuthOptions options,
    Mnemonic? mnemonic,
  });

  /// Signs the user out and clears the active user.
  /// If [force] is true, the KDF framework will be stopped immediately.
  /// Otherwise, the framework will be stopped after a short delay to allow
  /// for any pending operations to complete
  Future<void> signOut({bool force = false});
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
  KdfAuthService(this._kdfFramework, this._hostConfig) {
    _startHealthCheck();
  }

  final KomodoDefiFramework _kdfFramework;
  final IKdfHostConfig _hostConfig;
  final StreamController<KdfUser?> _authStateController =
      StreamController.broadcast();
  final SecureLocalStorage _secureStorage = SecureLocalStorage();
  final ReadWriteMutex _authMutex = ReadWriteMutex();

  KdfUser? _lastEmittedUser;
  Timer? _healthCheckTimer;

  ApiClient get _client => _kdfFramework.client;
  late final methods = KomodoDefiRpcMethods(_client);

  // read&write locks cannot coexist, so use frugally to avoid deadlocks
  // reads can continue while write lock waits, and there is no mention of the
  // order in which locks are processed in the docs.
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

    var currentUser = await getActiveUser();
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
    // ignore: omit_local_variable_types
    KdfUser currentUser = KdfUser(
      walletId: walletId,
      authOptions: authOptions,
      isBip39Seed: isBip39Seed,
    );
    await _secureStorage.saveUser(currentUser);
    _authStateController.add(currentUser);

    if (currentUser.isHd && !currentUser.isBip39Seed) {
      // Verify BIP39 compatibility for HD wallets after registration
      // if verification fails, the user can still log into the wallet in legacy
      // mode.
      currentUser = await _verifyBip39Compatibility(config, currentUser);
    }

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

  /// Requires a user to be signed into a valid wallet in order to verify the
  /// seed phrase and determine BIP39 compatibility.
  /// Updates the stored user with the verified BIP39 status before returning
  /// the modified [KdfUser].
  /// NOTE: this function does not contain any write/read protected sections,
  /// so any atomic requirements need to be handled by the calling function.
  /// Throws [AuthException] if the seed is not a valid BIP39 seed phrase.
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
        atomicProtected: false, // Protection is up to caller
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
    required AuthOptions options,
  }) async {
    final user = await _lockWriteOperation<KdfUser>(() async {
      // Check if already signed in first
      if (await _kdfFramework.isRunning()) {
        final activeUser = await getActiveUser();

        if (activeUser?.walletId.name == walletName) {
          return activeUser!;
        }
        // If running but wrong user, stop KDF
        await _stopKdf();
      }

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

      final user = await _authenticateUser(config);
      _emitAuthStateChange(user);
      return user;
    });

    return user;
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
    bool? isBip39;
    final walletExists = await _walletExists(walletName);
    if (walletExists) {
      throw AuthException(
        'Wallet already exists',
        type: AuthExceptionType.generalAuthError,
      );
    }

    if (await getActiveUser() != null) {
      await signOut(force: true);
    }

    final config = await _generateStartupConfig(
      walletName: walletName,
      walletPassword: password,
      allowRegistrations: true,
      plaintextMnemonic: mnemonic?.plaintextMnemonic,
      hdEnabled: options.derivationMethod == DerivationMethod.hdWallet,
    );

    // only lock modifications to the current state
    return _lockWriteOperation(() async {
      return _registerNewUser(config, options, isBip39 ?? false);
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

  @override
  Future<void> signOut({bool force = false}) async {
    if (force) {
      await _stopKdf();
      return _emitAuthStateChange(null);
    }

    await _lockWriteOperation(() async {
      await _stopKdf();
      _emitAuthStateChange(null);
    });
  }

  @override
  Future<bool> isSignedIn() async {
    return await getActiveUser() != null;
  }

  @override
  Future<KdfUser?> getActiveUser() async {
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
    bool atomicProtected = true,
  }) async {
    assert(
      encrypted || walletPassword != null,
      'walletPassword is required to retrieve plaintext mnemonic.',
    );

    if (!atomicProtected) {
      return _getMnemonicFromKdf(encrypted, walletPassword);
    }

    return _runReadOperation(() async {
      return _getMnemonicFromKdf(encrypted, walletPassword);
    });
  }

  Future<Mnemonic> _getMnemonicFromKdf(
    bool encrypted,
    String? walletPassword,
  ) async {
    if (await getActiveUser() == null) {
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
  }

  @override
  Stream<KdfUser?> get authStateChanges => _authStateController.stream;

  @override
  void dispose() {
    // Wait for running operations to complete before disposing. Write lock can
    // only be acquired once the active read/write operations complete.
    _lockWriteOperation(() async {
      _healthCheckTimer?.cancel();
      _stopKdf().ignore();
      await _authStateController.close();
      _lastEmittedUser = null;
    }).ignore();
  }

  Future<bool> _walletExists(String walletName) async {
    if (!await _kdfFramework.isRunning()) return false;

    final users = await getUsers();
    return users.any((user) => user.walletId.name == walletName);
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
