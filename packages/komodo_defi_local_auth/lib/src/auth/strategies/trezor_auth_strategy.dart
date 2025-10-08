import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_connection_monitor.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_initialization_state.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_repository.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Authentication strategy for Trezor hardware wallets.
///
/// This strategy handles Trezor-specific authentication flows including
/// device initialization, PIN/passphrase handling, and connection monitoring.
class TrezorAuthStrategy implements AuthenticationStrategy {
  /// Creates a new Trezor authentication strategy.
  ///
  /// [authService] - The underlying authentication service
  /// [trezorRepository] - Repository for Trezor device operations
  /// [connectionMonitor] - Optional connection monitor (created if not provided)
  /// [secureStorage] - Optional secure storage (uses default if not provided)
  /// [passwordGenerator] - Optional password generator function
  TrezorAuthStrategy(
    this._authService,
    this._trezorRepository, {
    TrezorConnectionMonitor? connectionMonitor,
    FlutterSecureStorage? secureStorage,
    String Function(int length)? passwordGenerator,
  }) : _connectionMonitor =
           connectionMonitor ?? TrezorConnectionMonitor(_trezorRepository),
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _generatePassword =
           passwordGenerator ?? SecurityUtils.generatePasswordSecure;

  static const String trezorWalletName = 'My Trezor';
  static const String _passwordKey = 'trezor_wallet_password';
  static final _log = Logger('TrezorAuthStrategy');

  final IAuthService _authService;
  final TrezorRepository _trezorRepository;
  final FlutterSecureStorage _secureStorage;
  final TrezorConnectionMonitor _connectionMonitor;
  final String Function(int length) _generatePassword;

  @override
  Stream<AuthenticationState> signInStream({
    required AuthOptions options,
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting Trezor sign-in for wallet: $walletName');

    // Validate that this is a Trezor private key policy
    if (options.privKeyPolicy != const PrivateKeyPolicy.trezor()) {
      _log.severe(
        'Invalid policy for TrezorAuthStrategy: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'TrezorAuthStrategy only supports Trezor private key policy',
      );
      return;
    }

    _log.fine(
      'Starting Trezor authentication stream with derivation method: ${options.derivationMethod}',
    );

    try {
      yield* _authenticateTrezorStream(
        derivationMethod: options.derivationMethod,
        passphrase: password,
      );
      _log.info('Successfully completed Trezor sign-in');
    } catch (e, stackTrace) {
      _log.severe('Trezor sign-in failed', e, stackTrace);
      await _signOutCurrentTrezorUser();
      yield AuthenticationState.error('Trezor sign-in failed: $e');
    }
  }

  @override
  Stream<AuthenticationState> registerStream({
    required AuthOptions options,
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting Trezor registration for wallet: $walletName');

    // Validate that this is a Trezor private key policy
    if (options.privKeyPolicy != const PrivateKeyPolicy.trezor()) {
      _log.severe(
        'Invalid policy for TrezorAuthStrategy registration: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'TrezorAuthStrategy only supports Trezor private key policy',
      );
      return;
    }

    _log.fine(
      'Starting Trezor registration with derivation method: ${options.derivationMethod}',
    );

    try {
      yield* _authenticateTrezorStream(
        derivationMethod: options.derivationMethod,
        passphrase: password,
      );
      _log.info('Successfully completed Trezor registration');
    } catch (e, stackTrace) {
      _log.severe('Trezor registration failed', e, stackTrace);
      await _signOutCurrentTrezorUser();
      yield AuthenticationState.error('Trezor registration failed: $e');
    }
  }

  @override
  Future<void> cancel(int? taskId) async {
    _log.info('Cancelling Trezor authentication (taskId: $taskId)');
    if (taskId != null) {
      try {
        await _trezorRepository.cancelInitialization(taskId);
        _log.fine('Trezor initialization cancelled successfully');
      } catch (e, stackTrace) {
        _log.severe('Failed to cancel Trezor initialization', e, stackTrace);
        rethrow;
      }
    } else {
      _log.warning('Cancel requested with null taskId');
    }
  }

  @override
  Future<void> dispose() async {
    _log.fine('Disposing Trezor auth strategy');
    try {
      _connectionMonitor.dispose();
      _log.fine('Trezor auth strategy disposed successfully');
    } catch (e, stackTrace) {
      _log.severe('Error disposing Trezor auth strategy', e, stackTrace);
      rethrow;
    }
  }

  /// Provides PIN to the Trezor device for the given task
  Future<void> provideTrezorPin(int taskId, String pin) async {
    _log.info('Providing PIN to Trezor device (taskId: $taskId)');
    try {
      await _trezorRepository.providePin(taskId, pin);
      _log.fine('PIN provided successfully');
    } catch (e, stackTrace) {
      _log.severe('Failed to provide PIN to Trezor device', e, stackTrace);
      rethrow;
    }
  }

  /// Provides passphrase to the Trezor device for the given task
  Future<void> provideTrezorPassphrase(int taskId, String passphrase) async {
    _log.info('Providing passphrase to Trezor device (taskId: $taskId)');
    try {
      await _trezorRepository.providePassphrase(taskId, passphrase);
      _log.fine('Passphrase provided successfully');
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to provide passphrase to Trezor device',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Cancels Trezor initialization for the given task
  Future<void> cancelTrezorInitialization(int taskId) async {
    _log.info('Cancelling Trezor initialization (taskId: $taskId)');
    try {
      await _trezorRepository.cancelInitialization(taskId);
      _log.fine('Trezor initialization cancelled successfully');
    } catch (e, stackTrace) {
      _log.severe('Failed to cancel Trezor initialization', e, stackTrace);
      rethrow;
    }
  }

  /// Clears the stored password for the Trezor wallet
  Future<void> clearTrezorPassword() async {
    _log.info('Clearing stored Trezor password');
    try {
      await _secureStorage.delete(key: _passwordKey);
      _log.fine('Trezor password cleared successfully');
    } catch (e, stackTrace) {
      _log.severe('Failed to clear Trezor password', e, stackTrace);
      rethrow;
    }
  }

  /// Gets or generates a password for the Trezor wallet
  Future<String> _getPassword({required bool isNewUser}) async {
    _log.fine('Getting Trezor wallet password (isNewUser: $isNewUser)');

    try {
      final existing = await _secureStorage.read(key: _passwordKey);

      if (!isNewUser) {
        if (existing == null) {
          _log.severe('No stored password found for existing Trezor user');
          throw AuthException(
            'Authentication failed for Trezor wallet',
            type: AuthExceptionType.generalAuthError,
          );
        }
        _log.fine('Retrieved existing password for Trezor wallet');
        return existing;
      }

      if (existing != null) {
        _log.fine('Using existing password for new Trezor wallet');
        return existing;
      }

      _log.fine('Generating new password for Trezor wallet');
      final newPassword = _generatePassword(16);
      await _secureStorage.write(key: _passwordKey, value: newPassword);
      _log.fine('New password generated and stored successfully');
      return newPassword;
    } catch (e, stackTrace) {
      _log.severe('Failed to get/generate Trezor password', e, stackTrace);
      rethrow;
    }
  }

  /// Start monitoring Trezor connection status after successful authentication
  void _startConnectionMonitoring({String? devicePubkey}) {
    _log.info('Starting Trezor connection monitoring');
    _log.fine('Device pubkey: ${devicePubkey ?? 'none'}');

    try {
      _connectionMonitor.startMonitoring(
        devicePubkey: devicePubkey,
        onConnectionLost: () async {
          _log.warning('Trezor connection lost, signing out user');
          await _signOutCurrentTrezorUser();
        },
        onStatusChanged: (status) {
          _log.fine('Trezor connection status: ${status.value}');
        },
      );
      _log.fine('Trezor connection monitoring started successfully');
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to start Trezor connection monitoring',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Stop monitoring Trezor connection status
  Future<void> _stopConnectionMonitoring() async {
    _log.fine('Stopping Trezor connection monitoring');

    if (_connectionMonitor.isMonitoring) {
      try {
        await _connectionMonitor.stopMonitoring();
        _log.fine('Trezor connection monitoring stopped successfully');
      } catch (e, stackTrace) {
        _log.severe(
          'Failed to stop Trezor connection monitoring',
          e,
          stackTrace,
        );
        rethrow;
      }
    } else {
      _log.finest('Trezor connection monitoring was not active');
    }
  }

  /// Signs out the current user if they are using the Trezor wallet
  Future<void> _signOutCurrentTrezorUser() async {
    _log.fine('Checking if current user needs to be signed out');

    try {
      final current = await _authService.getActiveUser();
      if (current?.walletId.name == trezorWalletName) {
        _log.warning("Signing out current '${current?.walletId.name}' user");
        await _stopConnectionMonitoring();
        try {
          await _authService.signOut();
          _log.fine('Trezor user signed out successfully');
        } catch (e, stackTrace) {
          _log.warning('Error during Trezor user sign out', e, stackTrace);
          // ignore sign out errors
        }
      } else {
        _log.finest('No Trezor user to sign out');
      }
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to check/sign out current Trezor user',
        e,
        stackTrace,
      );
      // Don't rethrow as this is a cleanup operation
    }
  }

  /// Finds an existing Trezor user in the user list
  Future<KdfUser?> _findExistingTrezorUser() async {
    _log.fine('Searching for existing Trezor user');

    try {
      final users = await _authService.getUsers();
      final trezorUser = users.firstWhereOrNull(
        (u) =>
            u.walletId.name == trezorWalletName &&
            u.walletId.authOptions.privKeyPolicy ==
                const PrivateKeyPolicy.trezor(),
      );

      if (trezorUser != null) {
        _log.fine('Found existing Trezor user: ${trezorUser.walletId.name}');
      } else {
        _log.fine('No existing Trezor user found');
      }

      return trezorUser;
    } catch (e, stackTrace) {
      _log.severe('Failed to find existing Trezor user', e, stackTrace);
      rethrow;
    }
  }

  /// Authenticates with the Trezor wallet (sign in or register)
  Future<void> _authenticateWithTrezorWallet({
    required KdfUser? existingUser,
    required String password,
    required DerivationMethod derivationMethod,
  }) async {
    _log.fine(
      'Authenticating with Trezor wallet (existingUser: ${existingUser != null})',
    );

    final authOptions = AuthOptions(
      derivationMethod: derivationMethod,
      privKeyPolicy: const PrivateKeyPolicy.trezor(),
    );

    try {
      if (existingUser != null) {
        _log.fine('Signing in to existing Trezor wallet');
        await _authService.signIn(
          walletName: trezorWalletName,
          password: password,
          options: authOptions,
        );
        _log.fine('Successfully signed in to Trezor wallet');
      } else {
        _log.fine('Registering new Trezor wallet');
        await _authService.register(
          walletName: trezorWalletName,
          password: password,
          options: authOptions,
        );
        _log.fine('Successfully registered new Trezor wallet');
      }
    } catch (e, stackTrace) {
      _log.severe('Failed to authenticate with Trezor wallet', e, stackTrace);
      rethrow;
    }
  }

  /// Initializes the Trezor device and yields state updates
  Stream<TrezorInitializationState> _initializeTrezorDevice() async* {
    _log.fine('Starting Trezor device initialization');

    try {
      await for (final state in _trezorRepository.initializeDevice()) {
        _log.finest(
          'Trezor initialization state: ${state.status} - ${state.message}',
        );
        yield state;

        if (state.status == AuthenticationStatus.completed ||
            state.status == AuthenticationStatus.error ||
            state.status == AuthenticationStatus.cancelled) {
          _log.fine(
            'Trezor initialization completed with status: ${state.status}',
          );
          break;
        }
      }
    } catch (e, stackTrace) {
      _log.severe('Error during Trezor device initialization', e, stackTrace);
      rethrow;
    }
  }

  /// Registers or signs in to the "My Trezor" wallet and initializes the device
  Stream<TrezorInitializationState> _initializeTrezorAndAuthenticate(
    DerivationMethod derivationMethod,
  ) async* {
    _log.info('Starting Trezor initialization and authentication');
    _log.fine('Derivation method: $derivationMethod');

    try {
      await _signOutCurrentTrezorUser();

      final existingUser = await _findExistingTrezorUser();
      final isNewUser = existingUser == null;
      _log.fine('User status: ${isNewUser ? 'new' : 'existing'}');

      final password = await _getPassword(isNewUser: isNewUser);

      await _authenticateWithTrezorWallet(
        existingUser: existingUser,
        password: password,
        derivationMethod: derivationMethod,
      );

      yield* _initializeTrezorDevice();
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to initialize Trezor and authenticate',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Main authentication stream that handles the complete Trezor flow
  Stream<AuthenticationState> _authenticateTrezorStream({
    required DerivationMethod derivationMethod,
    String? passphrase,
  }) async* {
    _log.info('Starting main Trezor authentication stream');

    try {
      await for (final trezorState in _initializeTrezorAndAuthenticate(
        derivationMethod,
      )) {
        _log.finest('Processing Trezor state: ${trezorState.status}');
        if (trezorState.status == AuthenticationStatus.passphraseRequired &&
            passphrase != null) {
          _log.fine(
            'Providing passphrase automatically (taskId: ${trezorState.taskId})',
          );
          await _trezorRepository.providePassphrase(
            trezorState.taskId!,
            passphrase,
          );
        }

        if (trezorState.status == AuthenticationStatus.completed) {
          _log.info('Trezor authentication completed successfully');
          final user = await _authService.getActiveUser();
          if (user != null) {
            _log.fine(
              'Retrieved signed-in user, starting connection monitoring',
            );
            _startConnectionMonitoring();
            yield AuthenticationState(
              status: AuthenticationStatus.completed,
              user: user,
              data: AuthenticationData.trezor(
                taskId: trezorState.taskId!,
                deviceInfo: trezorState.message,
              ),
            );
          } else {
            _log.severe(
              'Failed to retrieve signed-in user after successful authentication',
            );
            yield AuthenticationState.error(
              'Failed to retrieve signed-in user',
            );
          }
          break;
        }

        // Convert TrezorInitializationState to AuthenticationState with TrezorData
        yield AuthenticationState(
          status: trezorState.status,
          message: trezorState.message,
          taskId: trezorState.taskId,
          error: trezorState.error,
          data: trezorState.taskId != null
              ? AuthenticationData.trezor(
                  taskId: trezorState.taskId!,
                  deviceInfo: trezorState.message,
                )
              : null,
        );

        if (trezorState.status == AuthenticationStatus.error ||
            trezorState.status == AuthenticationStatus.cancelled) {
          _log.warning(
            'Trezor authentication failed with status: ${trezorState.status}',
          );
          await _signOutCurrentTrezorUser();
          break;
        }
      }
    } catch (e, stackTrace) {
      _log.severe('Trezor authentication stream error', e, stackTrace);
      await _signOutCurrentTrezorUser();
      yield AuthenticationState.error('Trezor stream error: $e');
    }
  }
}
