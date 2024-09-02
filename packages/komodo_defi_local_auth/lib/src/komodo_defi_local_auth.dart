import 'dart:async';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/storage/secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoDefiLocalAuth {
  KomodoDefiLocalAuth({
    required KomodoDefiFramework kdf,
    required IKdfHostConfig hostConfig,
    bool allowRegistrations = true,
  }) : _allowRegistrations = allowRegistrations {
    // ignore: unused_local_variable
    final secureStorage = IFlutterSecureStorage();
    _authService = KdfAuthService(kdf, hostConfig);
  }

  final bool _allowRegistrations;
  late final IAuthService _authService;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _authService.getActiveUser();
    _initialized = true;
  }

  void _checkInitializedSync() {
    if (!_initialized) {
      throw StateError(
        'KomodoDefiLocalAuth has not been initialized. Call initialize() first.',
      );
    }
  }

  Stream<KdfUser?> get authStateChanges async* {
    await ensureInitialized();
    yield* _authService.authStateChanges;
  }

  Future<KdfUser?> get currentUser async {
    await ensureInitialized();
    return _authService.getActiveUser();
  }

  Future<KdfUser> signIn({
    required String walletName,
    required String password,
  }) async {
    await ensureInitialized();
    await _assertAuthState(false);

    try {
      return await _authService.signIn(
        walletName: walletName,
        password: password,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<KdfUser> register({
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  }) async {
    await ensureInitialized();
    await _assertAuthState(false);

    if (!_allowRegistrations) {
      throw AuthException(
        'Registration is not allowed.',
        type: AuthExceptionType.registrationNotAllowed,
      );
    }

    try {
      return await _authService.register(
        walletName: walletName,
        password: password,
        mnemonic: mnemonic,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<List<KdfUser>> getUsers() async {
    await ensureInitialized();

    return _authService.getUsers();
  }

  Future<void> signOut() async {
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      await _authService.signOut();
    } on AuthException {
      rethrow;
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

  Future<Mnemonic> getMnemonicEncrypted() async {
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      return await _authService.getMnemonic(
        encrypted: true,
        walletPassword: null,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred while retrieving the mnemonic: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<Mnemonic> getMnemonicPlainText(String walletPassword) async {
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      return _authService.getMnemonic(
        encrypted: false,
        walletPassword: walletPassword,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred while retrieving the mnemonic: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<void> _assertAuthState(bool expected) async {
    await ensureInitialized();
    final signedIn = await isSignedIn();
    if (signedIn != expected) {
      throw AuthException(
        'User is ${signedIn ? 'signed in' : 'not signed in'}.',
        type: signedIn
            ? AuthExceptionType.alreadySignedIn
            : AuthExceptionType.unauthorized,
      );
    }
  }

  void dispose() {
    _authService.dispose();
  }
}
