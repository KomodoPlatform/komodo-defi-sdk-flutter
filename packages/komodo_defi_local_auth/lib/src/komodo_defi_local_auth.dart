import 'dart:async';

import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/namespaces/trezor_auth_namespace.dart';
import 'package:komodo_defi_local_auth/src/auth/namespaces/walletconnect_auth_namespace.dart';
import 'package:komodo_defi_local_auth/src/auth/storage/secure_storage.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/auth_strategy_factory.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_local_auth/src/komodo_defi_auth.dart';
import 'package:komodo_defi_local_auth/src/trezor/_trezor_index.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

class KomodoDefiLocalAuth implements KomodoDefiAuth {
  static final Logger _log = Logger('KomodoDefiLocalAuth');

  KomodoDefiLocalAuth({
    required KomodoDefiFramework kdf,
    required IKdfHostConfig hostConfig,
    required KomodoDefiRpcMethods rpcMethods,
    bool allowRegistrations = true,
  }) : _allowRegistrations = allowRegistrations,
       _authService = KdfAuthService(kdf, hostConfig),
       _rpcMethods = rpcMethods,
       _kdf = kdf {
    _log.info(
      'Initializing KomodoDefiLocalAuth with allowRegistrations: $allowRegistrations',
    );
    _trezorAuthService = TrezorAuthService(_authService, TrezorRepository(kdf));

    // Initialize namespaces
    _trezorNamespace = TrezorAuthNamespace(
      _trezorAuthService,
      ensureInitialized,
    );
    _walletConnectNamespace = WalletConnectAuthNamespace(
      _rpcMethods,
      () => _currentStrategy,
      ensureInitialized,
    );
    _log.fine('KomodoDefiLocalAuth initialization completed');
  }

  final SecureLocalStorage _secureStorage = SecureLocalStorage();
  final bool _allowRegistrations;
  late final IAuthService _authService;
  late final TrezorAuthService _trezorAuthService;
  final KomodoDefiRpcMethods _rpcMethods;
  final KomodoDefiFramework _kdf;
  bool _initialized = false;
  AuthenticationStrategy? _currentStrategy;

  // Namespaces
  late final TrezorAuthNamespace _trezorNamespace;
  late final WalletConnectAuthNamespace _walletConnectNamespace;

  @override
  TrezorAuthNamespace get trezor => _trezorNamespace;

  @override
  WalletConnectAuthNamespace get walletConnect => _walletConnectNamespace;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _log.fine('Initializing auth service');
    try {
      await _authService.getActiveUser();
      _initialized = true;
      _log.info('Auth service initialized successfully');
    } catch (e, stackTrace) {
      _log.severe('Failed to initialize auth service', e, stackTrace);
      rethrow;
    }
  }

  // Save AuthOptions when registering or signing in
  @override
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  }) async {
    _log.info('Attempting to sign in wallet: $walletName');
    await ensureInitialized();
    await _assertAuthState(false);

    // Trezor is not supported in non-stream functions
    if (options.privKeyPolicy == const PrivateKeyPolicy.trezor()) {
      _log.warning('Trezor authentication attempted with non-stream method');
      throw AuthException(
        'Trezor authentication requires using signInStream() method '
        'to handle device interactions (PIN, passphrase) asynchronously',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      final user = await _findUser(walletName);
      final updatedUser = user.copyWith(
        walletId: user.walletId.copyWith(authOptions: options),
      );

      // Save AuthOptions to secure storage by wallet name
      await _secureStorage.saveUser(updatedUser);

      final result = await _authService.signIn(
        walletName: walletName,
        password: password,
        options: options,
      );
      _log.info('Successfully signed in wallet: $walletName');
      return result;
    } catch (e, stackTrace) {
      _log.severe('Failed to sign in wallet: $walletName', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<AuthenticationState> signInStream({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  }) async* {
    _log.info('Attempting to sign in wallet via stream: $walletName');
    await ensureInitialized();
    await _assertAuthState(false);

    try {
      final strategy = await _createAuthStrategy(options.privKeyPolicy);
      _log.fine('Created authentication strategy for wallet: $walletName');
      yield* strategy.signInStream(
        options: options,
        walletName: walletName,
        password: password,
      );
      _log.info(
        'Successfully completed sign in stream for wallet: $walletName',
      );
    } catch (e, stackTrace) {
      _log.severe(
        'Authentication failed for wallet: $walletName',
        e,
        stackTrace,
      );
      yield AuthenticationState.error('Authentication failed: $e');
    }
  }

  Future<KdfUser> _findUser(String walletName) async {
    _log.fine('Searching for user with wallet name: $walletName');
    try {
      final matchedUsers = (await _authService.getUsers()).where(
        (user) => user.walletId.name == walletName,
      );

      if (matchedUsers.isEmpty) {
        _log.warning('No user found with wallet name: $walletName');
        throw AuthException(
          'No user found with the specified wallet name.',
          type: AuthExceptionType.walletNotFound,
        );
      }

      if (matchedUsers.length > 1) {
        _log.severe('Multiple users found with wallet name: $walletName');
        throw AuthException(
          'Multiple users found with the specified wallet name.',
          type: AuthExceptionType.internalError,
        );
      }

      _log.fine('Found user with wallet name: $walletName');
      return matchedUsers.first;
    } catch (e, stackTrace) {
      _log.severe(
        'Error finding user with wallet name: $walletName',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static Future<AuthOptions?> storedAuthOptions(String walletName) async {
    _log.fine('Retrieving stored auth options for wallet: $walletName');
    try {
      final result = await SecureLocalStorage()
          .getUser(walletName)
          .then((user) => user?.authOptions);
      _log.fine('Retrieved auth options for wallet: $walletName');
      return result;
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to retrieve stored auth options for wallet: $walletName',
        e,
        stackTrace,
      );
      rethrow;
    }
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
    _log.info('Attempting to register wallet: $walletName');
    await ensureInitialized();
    await _assertAuthState(false);

    if (!_allowRegistrations) {
      _log.warning('Registration attempt denied - registrations not allowed');
      throw AuthException(
        'Registration is not allowed.',
        type: AuthExceptionType.registrationNotAllowed,
      );
    }

    // Trezor is not supported in non-stream functions
    if (options.privKeyPolicy == const PrivateKeyPolicy.trezor()) {
      _log.warning('Trezor registration attempted with non-stream method');
      throw AuthException(
        'Trezor registration requires using registerStream() method '
        'to handle device interactions (PIN, passphrase) asynchronously',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      final user = await _authService.register(
        walletName: walletName,
        password: password,
        options: options,
        mnemonic: mnemonic,
      );

      await _secureStorage.saveUser(user);
      _log.info('Successfully registered wallet: $walletName');
      return user;
    } catch (e, stackTrace) {
      _log.severe('Failed to register wallet: $walletName', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<AuthenticationState> registerStream({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Attempting to register wallet via stream: $walletName');
    await ensureInitialized();
    await _assertAuthState(false);

    if (!_allowRegistrations) {
      _log.warning('Registration stream denied - registrations not allowed');
      yield AuthenticationState.error('Registration is not allowed');
      return;
    }

    try {
      // Create strategy based on private key policy
      final strategy = await _createAuthStrategy(options.privKeyPolicy);
      _log.fine(
        'Created authentication strategy for registration: $walletName',
      );

      // Use strategy to handle registration
      yield* strategy.registerStream(
        options: options,
        walletName: walletName,
        password: password,
        mnemonic: mnemonic,
      );
      _log.info(
        'Successfully completed registration stream for wallet: $walletName',
      );
    } catch (e, stackTrace) {
      _log.severe('Registration failed for wallet: $walletName', e, stackTrace);
      yield AuthenticationState.error('Registration failed: $e');
    }
  }

  @override
  Stream<KdfUser?> get authStateChanges async* {
    _log.fine('Starting auth state changes stream');
    await ensureInitialized();
    yield* _authService.authStateChanges;
  }

  @override
  Stream<KdfUser?> watchCurrentUser() async* {
    _log.fine('Starting watch current user stream');
    await ensureInitialized();

    try {
      // Emit the current user state as the initial value
      yield await _authService.getActiveUser();

      // Then emit subsequent changes
      yield* _authService.authStateChanges;
    } catch (e, stackTrace) {
      _log.severe('Error in watch current user stream', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<KdfUser?> get currentUser async {
    _log.fine('Getting current user');
    await ensureInitialized();
    try {
      final user = await _authService.getActiveUser();
      _log.fine('Retrieved current user: ${user?.walletId.name}');
      return user;
    } catch (e, stackTrace) {
      _log.severe('Failed to get current user', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<KdfUser>> getUsers() async {
    _log.fine('Getting all users');
    await ensureInitialized();

    try {
      final users = await _authService.getUsers();
      _log.fine('Retrieved ${users.length} users');
      return users;
    } catch (e, stackTrace) {
      _log.severe('Failed to get users', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    _log.info('Attempting to sign out');
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      await _authService.signOut();
      _log.info('Successfully signed out');
    } on AuthException {
      _log.warning('Auth exception during sign out');
      rethrow;
    } catch (e, stackTrace) {
      _log.severe('Unexpected error during sign out', e, stackTrace);
      throw AuthException(
        'An unexpected error occurred while signing out: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<bool> isSignedIn() async {
    _log.finest('Checking if user is signed in');
    await ensureInitialized();
    try {
      final signedIn = await _authService.isSignedIn();
      _log.finest('User signed in status: $signedIn');
      return signedIn;
    } catch (e, stackTrace) {
      _log.severe('Failed to check sign in status', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Mnemonic> getMnemonicEncrypted() async {
    _log.info('Getting encrypted mnemonic');
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      final mnemonic = await _authService.getMnemonic(
        encrypted: true,
        walletPassword: null,
      );
      _log.info('Successfully retrieved encrypted mnemonic');
      return mnemonic;
    } on AuthException {
      _log.warning('Auth exception while getting encrypted mnemonic');
      rethrow;
    } catch (e, stackTrace) {
      _log.severe(
        'Unexpected error while retrieving encrypted mnemonic',
        e,
        stackTrace,
      );
      throw AuthException(
        'An unexpected error occurred while retrieving the mnemonic: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<Mnemonic> getMnemonicPlainText(String walletPassword) async {
    _log.info('Getting plain text mnemonic');
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      final mnemonic = await _authService.getMnemonic(
        encrypted: false,
        walletPassword: walletPassword,
      );
      _log.info('Successfully retrieved plain text mnemonic');
      return mnemonic;
    } on AuthException {
      _log.warning('Auth exception while getting plain text mnemonic');
      rethrow;
    } catch (e, stackTrace) {
      _log.severe(
        'Unexpected error while retrieving plain text mnemonic',
        e,
        stackTrace,
      );
      throw AuthException(
        'An unexpected error occurred while retrieving the mnemonic: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _log.info('Updating password');
    await ensureInitialized();
    await _assertAuthState(true);

    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _log.info('Successfully updated password');
    } on AuthException {
      _log.warning('Auth exception while updating password');
      rethrow;
    } catch (e, stackTrace) {
      _log.severe('Unexpected error while updating password', e, stackTrace);
      throw AuthException(
        'An unexpected error occurred while changing the password: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<void> deleteWallet({
    required String walletName,
    required String password,
  }) async {
    _log.info('Deleting wallet: $walletName');
    await ensureInitialized();
    try {
      await _authService.deleteWallet(
        walletName: walletName,
        password: password,
      );
      _log.info('Successfully deleted wallet: $walletName');
    } on AuthException {
      _log.warning('Auth exception while deleting wallet: $walletName');
      rethrow;
    } catch (e, stackTrace) {
      _log.severe(
        'Unexpected error while deleting wallet: $walletName',
        e,
        stackTrace,
      );
      throw AuthException(
        'An unexpected error occurred while deleting the wallet: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<void> setOrRemoveActiveUserKeyValue(String key, dynamic value) async {
    _log.fine('Setting/removing active user key-value: $key');
    try {
      final activeUser = await _authService.getActiveUser();

      if (activeUser == null) {
        _log.warning('Attempted to set key-value for non-existent active user');
        throw AuthException.notFound();
      }

      final updatedMetadata = JsonMap.from(activeUser.metadata)..[key] = value;

      if (value == null) updatedMetadata.remove(key);

      await _authService.setActiveUserMetadata(updatedMetadata);
      _log.fine('Successfully updated active user metadata for key: $key');
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to set/remove active user key-value: $key',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _assertAuthState(bool expected) async {
    await ensureInitialized();
    final signedIn = await isSignedIn();
    if (signedIn != expected) {
      final message = 'User is ${signedIn ? 'signed in' : 'not signed in'}.';
      _log.warning('Auth state assertion failed: $message');
      throw AuthException(
        message,
        type: signedIn
            ? AuthExceptionType.alreadySignedIn
            : AuthExceptionType.unauthorized,
      );
    }
  }

  /// Creates an authentication strategy based on the private key policy
  Future<AuthenticationStrategy> _createAuthStrategy(
    PrivateKeyPolicy policy,
  ) async {
    _log.fine(
      'Creating authentication strategy for policy: ${policy.toString()}',
    );

    if (_currentStrategy != null) {
      // "!" needed because dart linter cannot detect null checks apparently
      await _currentStrategy!.dispose();
      _log.finest('Disposed previous authentication strategy');
    }

    try {
      // Create strategy with full RPC method support
      _currentStrategy = AuthStrategyFactory.createStrategy(
        policy,
        _authService,
        _kdf.client,
        rpcMethods: _rpcMethods,
        trezorRepository: TrezorRepository(_kdf.client),
      );

      _log.info(
        'Successfully created authentication strategy for policy: ${policy.toString()}',
      );
      return _currentStrategy!;
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to create authentication strategy for policy: ${policy.toString()}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _log.info('Disposing KomodoDefiLocalAuth');
    try {
      await _currentStrategy?.dispose();
      _currentStrategy = null;
      await _authService.dispose();
      _log.info('Successfully disposed KomodoDefiLocalAuth');
    } catch (e, stackTrace) {
      _log.severe('Error during KomodoDefiLocalAuth disposal', e, stackTrace);
      rethrow;
    }
  }
}
