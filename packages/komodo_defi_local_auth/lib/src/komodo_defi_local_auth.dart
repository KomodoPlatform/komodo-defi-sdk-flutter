import 'dart:async';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/storage/secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoDefiLocalAuth {
  /// Creates a new instance of [KomodoDefiLocalAuth].
  /// Defaults to a local instance unless [kdf] is provided.
  KomodoDefiLocalAuth({
    required KomodoDefiFramework kdf,
  }) {
    final secureStorage = IFlutterSecureStorage();
    _authService = KdfAuthService(kdf);
  }

  late final IAuthService _authService;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _authService.getCurrentUser();
    _initialized = true;
  }

  void _checkInitializedSync() {
    if (!_initialized) {
      throw StateError(
        'KomodoDefiLocalAuth has not been initialized. Call initialize() first.',
      );
    }
  }

  Stream<KdfUser?> get authStateChanges {
    unawaited(ensureInitialized());
    return _authService.authStateChanges;
  }

  Future<KdfUser?> get currentUser async {
    await ensureInitialized();
    return _authService.getCurrentUser();
  }

  Future<KdfUser> signIn({
    required String walletName,
    required String password,
  }) async {
    await ensureInitialized();
    try {
      final user = await _authService.signInOrRegister(
        walletName: walletName,
        password: password,
      );
      // if (user == null) {
      //   throw AuthException('Failed to sign in',
      //       type: AuthExceptionType.generalAuthError);
      // }
      return user;
    } on AuthException {
      rethrow; // Rethrow the AuthException to be handled by the caller
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<void> importWallet({
    required String walletName,
    required String password,
    required String encryptedMnemonic,
  }) async {
    await ensureInitialized();
    try {
      await _authService.importWalletEncrypted(
        walletName: walletName,
        password: password,
        encryptedMnemonic: encryptedMnemonic,
      );
    } on AuthException {
      rethrow; // Rethrow the AuthException to be handled by the caller
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<void> signOut() async {
    await ensureInitialized();
    try {
      await _authService.signOut();
    } on AuthException {
      rethrow; // Rethrow the AuthException to be handled by the caller
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred while signing out: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<bool> isSignedIn() async {
    await ensureInitialized();
    return _authService.isSignedIn();
  }

  Future<String> getMnemonic({
    required bool encrypted,
    required String walletPassword,
  }) async {
    await ensureInitialized();
    try {
      return await _authService.getMnemonic(
        encrypted: encrypted,
        walletPassword: walletPassword,
      );
    } on AuthException {
      rethrow; // Rethrow the AuthException to be handled by the caller
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred while retrieving the mnemonic: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  void dispose() {
    _authService.dispose();
  }
}
