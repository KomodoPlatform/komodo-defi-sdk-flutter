import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// High level helper that handles sign in/register and Trezor device
/// initialization for the built in "My Trezor" wallet.
///
/// This service implements [IAuthService] and provides Trezor-specific
/// authentication logic while using composition with [KdfAuthService] to
/// avoid duplicating existing auth service functionality. The [signIn] and
/// [register] methods are customized for Trezor devices, automatically
/// handling passphrase requirements and ignoring PIN prompts. All other
/// [IAuthService] methods are delegated to the composed auth service.
class TrezorAuthService implements IAuthService {
  TrezorAuthService(this._authService, this._trezor);

  static const String trezorWalletName = 'My Trezor';
  static const String _passwordKey = 'trezor_wallet_password';

  final IAuthService _authService;
  final TrezorRepository _trezor;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> provideTrezorPin(int taskId, String pin) =>
      _trezor.providePin(taskId, pin);

  Future<void> provideTrezorPassphrase(int taskId, String passphrase) =>
      _trezor.providePassphrase(taskId, passphrase);

  Future<void> cancelTrezorInitialization(int taskId) =>
      _trezor.cancelInitialization(taskId);

  /// Handles Trezor sign-in with stream-based progress updates
  Stream<AuthenticationState> signInStreamed({
    required AuthOptions options,
  }) async* {
    try {
      // For Trezor, we need to use the built-in trezor wallet name
      // and let TrezorAuthService handle the credentials
      await for (final trezorState in _initializeTrezorAndAuthenticate(
        derivationMethod: options.derivationMethod,
      )) {
        if (trezorState.status == AuthenticationStatus.completed) {
          // TrezorAuthService already completed the sign-in process
          // Just get the current user
          final user = await _authService.getActiveUser();
          if (user != null) {
            yield AuthenticationState.completed(user);
          } else {
            yield AuthenticationState.error(
              'Failed to retrieve signed-in user',
            );
          }
          break;
        }

        yield trezorState.toAuthenticationState();

        if (trezorState.status == AuthenticationStatus.error ||
            trezorState.status == AuthenticationStatus.cancelled) {
          break;
        }
      }
    } catch (e) {
      yield AuthenticationState.error('Trezor sign-in failed: $e');
    }
  }

  /// Handles Trezor registration with stream-based progress updates
  Stream<AuthenticationState> registerStream({
    required AuthOptions options,
    Mnemonic? mnemonic,
  }) async* {
    try {
      // For Trezor, we need to use the built-in trezor wallet name
      // and let TrezorAuthService handle the credentials
      await for (final trezorState in _initializeTrezorAndAuthenticate(
        derivationMethod: options.derivationMethod,
        register: true,
      )) {
        yield trezorState.toAuthenticationState();

        if (trezorState.status == AuthenticationStatus.completed) {
          // TrezorAuthService already completed the registration process
          // Just get the current user
          final user = await _authService.getActiveUser();
          if (user != null) {
            yield AuthenticationState.completed(user);
          } else {
            yield AuthenticationState.error(
              'Failed to retrieve registered user',
            );
          }
          break;
        }

        if (trezorState.status == AuthenticationStatus.error ||
            trezorState.status == AuthenticationStatus.cancelled) {
          break;
        }
      }
    } catch (e) {
      yield AuthenticationState.error('Trezor registration failed: $e');
    }
  }

  // IAuthService implementation - delegate to composed auth service
  @override
  Future<List<KdfUser>> getUsers() => _authService.getUsers();

  @override
  Future<KdfUser?> getActiveUser() => _authService.getActiveUser();

  @override
  Future<bool> isSignedIn() => _authService.isSignedIn();

  @override
  Future<Mnemonic> getMnemonic({
    required bool encrypted,
    required String? walletPassword,
  }) => _authService.getMnemonic(
    encrypted: encrypted,
    walletPassword: walletPassword,
  );

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) => _authService.updatePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> setActiveUserMetadata(JsonMap metadata) =>
      _authService.setActiveUserMetadata(metadata);

  @override
  Future<void> restoreSession(KdfUser user) =>
      _authService.restoreSession(user);

  @override
  Stream<KdfUser?> get authStateChanges => _authService.authStateChanges;

  @override
  void dispose() => _authService.dispose();

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> deleteWallet({
    required String walletName,
    required String password,
  }) => _authService.deleteWallet(walletName: walletName, password: password);

  @override
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
    required AuthOptions options,
  }) async {
    // Throw exception if PrivateKeyPolicy is NOT trezor
    if (options.privKeyPolicy != const PrivateKeyPolicy.trezor()) {
      throw AuthException(
        'TrezorAuthService only supports Trezor private key policy',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      // Copy over contents from the streamed function
      await for (final trezorState in _initializeTrezorAndAuthenticate(
        derivationMethod: options.derivationMethod,
      )) {
        // If status is passphrase required, use the provided password
        if (trezorState.status == AuthenticationStatus.passphraseRequired) {
          await _trezor.providePassphrase(trezorState.taskId!, password);
        }
        // Ignore pin required user action - user has to enter PIN on the device

        // Wait for task to finish and return result
        if (trezorState.status == AuthenticationStatus.completed) {
          final user = await _authService.getActiveUser();
          if (user != null) {
            return user;
          } else {
            throw AuthException(
              'Failed to retrieve signed-in user',
              type: AuthExceptionType.generalAuthError,
            );
          }
        }

        if (trezorState.status == AuthenticationStatus.error) {
          throw AuthException(
            trezorState.message ?? 'Trezor sign-in failed',
            type: AuthExceptionType.generalAuthError,
          );
        }

        if (trezorState.status == AuthenticationStatus.cancelled) {
          throw AuthException(
            'Trezor sign-in was cancelled',
            type: AuthExceptionType.generalAuthError,
          );
        }
      }

      throw AuthException(
        'Trezor sign-in did not complete',
        type: AuthExceptionType.generalAuthError,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Trezor sign-in failed: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<KdfUser> register({
    required String walletName,
    required String password,
    required AuthOptions options,
    Mnemonic? mnemonic,
  }) async {
    // Throw exception if PrivateKeyPolicy is NOT trezor
    if (options.privKeyPolicy != const PrivateKeyPolicy.trezor()) {
      throw AuthException(
        'TrezorAuthService only supports Trezor private key policy',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      // Copy over contents from the streamed function
      await for (final trezorState in _initializeTrezorAndAuthenticate(
        derivationMethod: options.derivationMethod,
        register: true,
      )) {
        // If status is passphrase required, use the provided password
        if (trezorState.status == AuthenticationStatus.passphraseRequired) {
          await _trezor.providePassphrase(trezorState.taskId!, password);
        }
        // Ignore pin required user action - user has to enter PIN on the device

        // Wait for task to finish and return result
        if (trezorState.status == AuthenticationStatus.completed) {
          final user = await _authService.getActiveUser();
          if (user != null) {
            return user;
          } else {
            throw AuthException(
              'Failed to retrieve registered user',
              type: AuthExceptionType.generalAuthError,
            );
          }
        }

        if (trezorState.status == AuthenticationStatus.error) {
          throw AuthException(
            trezorState.message ?? 'Trezor registration failed',
            type: AuthExceptionType.generalAuthError,
          );
        }

        if (trezorState.status == AuthenticationStatus.cancelled) {
          throw AuthException(
            'Trezor registration was cancelled',
            type: AuthExceptionType.generalAuthError,
          );
        }
      }

      throw AuthException(
        'Trezor registration did not complete',
        type: AuthExceptionType.generalAuthError,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Trezor registration failed: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  Future<String> _getPassword({required bool isNewUser}) async {
    final existing = await _secureStorage.read(key: _passwordKey);
    if (!isNewUser) {
      if (existing == null) {
        throw AuthException(
          'Authentication failed for Trezor wallet',
          type: AuthExceptionType.generalAuthError,
        );
      }
      return existing;
    }

    if (existing != null) return existing;

    final newPassword = SecurityUtils.generatePasswordSecure(16);
    await _secureStorage.write(key: _passwordKey, value: newPassword);
    return newPassword;
  }

  /// Clears the stored password for the Trezor wallet.
  Future<void> clearTrezorPassword() =>
      _secureStorage.delete(key: _passwordKey);

  /// Signs out the current user if they are using the Trezor wallet
  Future<void> _signOutCurrentTrezorUser() async {
    final current = await _authService.getActiveUser();
    if (current?.walletId.name == trezorWalletName) {
      try {
        await _authService.signOut();
      } catch (_) {
        // ignore sign out errors
      }
    }
  }

  /// Finds an existing Trezor user in the user list
  Future<KdfUser?> _findExistingTrezorUser() async {
    final users = await _authService.getUsers();
    return users.firstWhereOrNull(
      (u) =>
          u.walletId.name == trezorWalletName &&
          u.authOptions.privKeyPolicy == const PrivateKeyPolicy.trezor(),
    );
  }

  /// Authenticates with the Trezor wallet (sign in or register)
  Future<void> _authenticateWithTrezorWallet({
    required KdfUser? existingUser,
    required String password,
    required DerivationMethod derivationMethod,
    required bool register,
  }) async {
    final authOptions = AuthOptions(
      derivationMethod: derivationMethod,
      privKeyPolicy: const PrivateKeyPolicy.trezor(),
    );

    if (existingUser != null && !register) {
      await _authService.signIn(
        walletName: trezorWalletName,
        password: password,
        options: authOptions,
      );
    } else {
      await _authService.register(
        walletName: trezorWalletName,
        password: password,
        options: authOptions,
      );
    }
  }

  /// Initializes the Trezor device and yields state updates
  Stream<TrezorInitializationState> _initializeTrezorDevice() async* {
    await for (final state in _trezor.initializeDevice()) {
      yield state;
      if (state.status == AuthenticationStatus.completed ||
          state.status == AuthenticationStatus.error ||
          state.status == AuthenticationStatus.cancelled) {
        break;
      }
    }
  }

  /// Registers or signs in to the "My Trezor" wallet and initializes the device
  ///
  /// Emits [TrezorInitializationState] updates while the device is initializing
  Stream<TrezorInitializationState> _initializeTrezorAndAuthenticate({
    required DerivationMethod derivationMethod,
    bool register = false,
  }) async* {
    await _signOutCurrentTrezorUser();

    final existingUser = await _findExistingTrezorUser();
    final isNewUser = existingUser == null || register;
    final password = await _getPassword(isNewUser: isNewUser);

    await _authenticateWithTrezorWallet(
      existingUser: existingUser,
      password: password,
      derivationMethod: derivationMethod,
      register: register,
    );

    yield* _initializeTrezorDevice();
  }
}
