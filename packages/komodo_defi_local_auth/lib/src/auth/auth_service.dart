import 'dart:async';

import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/src/auth/storage/secure_storage.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

part 'auth_service_auth_extension.dart';
part 'auth_service_kdf_extension.dart';
part 'auth_service_operations_extension.dart';

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

  /// Waits for active operations to complete before signin the user out.
  Future<void> signOut();

  /// Returns true if KDF is running and the active wallet is registered with
  /// the auth service. Otherwise, returns false.
  Future<bool> isSignedIn();

  /// Returns the [KdfUser] associated with the active wallet if KDF is running,
  /// otherwise null.
  /// NOTE: this function does not start/stop KDF or modify the active user,
  /// so atomic read/write protection is not used within and not required when
  /// calling this function.
  Future<KdfUser?> getActiveUser();

  /// Returns the [Mnemonic] for the active wallet, throws an [AuthException]
  /// otherwise.
  ///
  /// If [encrypted] is true, the encrypted mnemonic is returned. Otherwise,
  /// the plaintext mnemonic is returned, which requires the [walletPassword]
  /// to be provided.
  ///
  /// NOTE: this function does not start/stop KDF or modify the active user,
  /// so atomic read/write protection is not used within and not required when
  /// calling this function.
  Future<Mnemonic> getMnemonic({
    required bool encrypted,
    required String? walletPassword,
  });

  /// Changes the password for the current user.
  ///
  /// Throws [AuthException] if the current password is incorrect or if no user
  /// is signed in.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Method to store custom metadata for the user.
  ///
  /// Overwrites any existing metadata.
  ///
  /// This does not emit an auth state change event.
  ///
  /// NB: This is intended to only be a short-term solution until the SDK
  /// is fully integrated with KW. This may be deprecated in the future.
  Future<void> setActiveUserMetadata(JsonMap metadata);

  /// Attempts to restore a user session without requiring password authentication
  /// Only works if the KDF API is running and the wallet exists
  Future<void> restoreSession(KdfUser user);

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

  @override
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
    required AuthOptions options,
  }) async {
    // [getActiveUser] performs a read lock, which should happen outside of
    // the write lock to prevent deadlocks. If kdf is not running, null is
    // returned, so we can safely call it here without any checks.
    final activeUser = await getActiveUser();

    final user = await _lockWriteOperation<KdfUser>(() async {
      // Check if already signed in first
      if (await _kdfFramework.isRunning()) {
        if (activeUser?.walletId.name == walletName) {
          return activeUser!;
        }
        // If running but wrong user, stop KDF
        await _stopKdf();
      }

      final storedUser = await _secureStorage.getUser(walletName);
      if (storedUser == null) {
        throw AuthException.notFound();
      }

      // If we know this is not a BIP39 seed, don't allow HD mode
      if (!storedUser.isBip39Seed &&
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
        allowWeakPassword: options.allowWeakPassword,
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
    await _ensureKdfRunning();

    await _runReadOperation(() async {
      final walletExists = await _walletExists(walletName);
      if (walletExists) {
        throw AuthException(
          'Wallet already exists',
          type: AuthExceptionType.generalAuthError,
        );
      }
    });

    // replaces the __assertWalletOrStop method - wait for read/write locks to
    // be released here.
    // can be used outside of a lock, since both functions are public-facing
    // and manage their own read/write locks
    if (await isSignedIn()) {
      await signOut();
    }

    final config = await _generateStartupConfig(
      walletName: walletName,
      walletPassword: password,
      allowRegistrations: true,
      plaintextMnemonic: mnemonic?.plaintextMnemonic,
      hdEnabled: options.derivationMethod == DerivationMethod.hdWallet,
      allowWeakPassword: options.allowWeakPassword,
    );

    return _lockWriteOperation(() async {
      final currentUser = await _registerNewUser(config, options);
      _emitAuthStateChange(currentUser);
      return currentUser;
    });
  }

  @override
  Future<List<KdfUser>> getUsers() async {
    await _ensureKdfRunning();

    return _runReadOperation(() async {
      final walletNames = await _client.rpc.wallet.getWalletNames();

      return Future.wait(
        walletNames.walletNames.map((name) async {
          final user = await _secureStorage.getUser(name);
          if (user != null) return user;

          // Create new user record if none exists
          final newUser = KdfUser(
            walletId: WalletId.fromName(name, _fallbackAuthOptions),
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
  Future<void> signOut() async {
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
    return _runReadOperation(_getActiveUser);
  }

  AuthOptions get _fallbackAuthOptions =>
      const AuthOptions(derivationMethod: DerivationMethod.hdWallet);

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

      if (await getActiveUser() == null) {
        throw AuthException(
          'No user signed in',
          type: AuthExceptionType.unauthorized,
        );
      }

      return _getMnemonic(encrypted: encrypted, walletPassword: walletPassword);
    });
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _runReadOperation(() async {
      if (await getActiveUser() == null) {
        throw AuthException(
          'No user signed in',
          type: AuthExceptionType.unauthorized,
        );
      }

      try {
        await _client.rpc.wallet.changeMnemonicPassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      } on ChangeMnemonicIncorrectPasswordErrorResponse catch (e) {
        throw AuthException(
          'Incorrect current password',
          type: AuthExceptionType.incorrectPassword,
          details: {'error': e.error, 'errorType': e.errorType},
        );
      } catch (e) {
        final knownExceptions = AuthException.findExceptionsInLog(
          e.toString().toLowerCase(),
        );
        if (knownExceptions.isNotEmpty) {
          throw knownExceptions.first;
        }

        throw AuthException(
          'Failed to change password: $e',
          type: AuthExceptionType.generalAuthError,
        );
      }
    });
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

  late final Future<KdfStartupConfig> _noAuthConfig =
      KdfStartupConfig.noAuthStartup(
        rpcPassword: _hostConfig.rpcPassword,
      );

  Future<bool> verifyEncryptedSeedBip39Compatibility(String password) async {
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

  /// Returns the [KdfUser] associated with the active wallet if authenticated,
  /// otherwise throws an [AuthException].
  Future<KdfUser> _activeUserOrThrow() async {
    final activeUser = await getActiveUser();
    if (activeUser == null) {
      throw AuthException.notSignedIn();
    }
    return activeUser;
  }

  @override
  Future<void> setActiveUserMetadata(Map<String, dynamic> metadata) async {
    final activeUser = await _activeUserOrThrow();
    // TODO: Implement locks for this to avoid this method interfering with
    // more sensitive operations.
    final user = await _secureStorage.getUser(activeUser.walletId.name);
    if (user == null) throw AuthException.notFound();

    final updatedUser = user.copyWith(metadata: metadata);
    await _secureStorage.saveUser(updatedUser);
  }

  @override
  Future<void> restoreSession(KdfUser user) async {
    // Only attempt to restore the session if KDF is running
    return _runReadOperation(() async {
      try {
        // Check if KDF is running
        if (!await _kdfFramework.isRunning()) {
          throw AuthException(
            'KDF API is not running, cannot restore session',
            type: AuthExceptionType.apiConnectionError,
          );
        }

        // Verify the wallet exists in KDF
        final wallets = await getUsers();
        final walletExists = wallets.any(
          (w) => w.walletId.name == user.walletId.name,
        );

        if (!walletExists) {
          throw AuthException(
            'Wallet not found: ${user.walletId.name}',
            type: AuthExceptionType.walletNotFound,
          );
        }

        // Update internal state and emit auth state change
        _lastEmittedUser = user;
        _emitAuthStateChange(user);
      } catch (e) {
        throw AuthException(
          'Failed to restore session: $e',
          type: AuthExceptionType.generalAuthError,
        );
      }
    });
  }
}
