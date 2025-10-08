import 'dart:async';

import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Authentication strategy for regular wallets using context private key.
///
/// This strategy handles standard wallet authentication where the private key
/// is managed by the application context rather than external hardware devices.
class RegularAuthStrategy implements AuthenticationStrategy {
  /// Creates a new regular authentication strategy.
  ///
  /// [authService] - The underlying authentication service to delegate operations to
  RegularAuthStrategy(this._authService);

  static final Logger _log = Logger('RegularAuthStrategy');
  final IAuthService _authService;

  @override
  Stream<AuthenticationState> signInStream({
    required AuthOptions options,
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting regular sign-in for wallet: $walletName');

    if (walletName == null || password == null) {
      _log.warning('Sign-in failed: missing wallet name or password');
      yield AuthenticationState.error(
        'Wallet name and password are required for regular authentication',
      );
      return;
    }

    // Validate that this is a context private key policy
    if (options.privKeyPolicy != const PrivateKeyPolicy.contextPrivKey()) {
      _log.severe(
        'Invalid policy for RegularAuthStrategy: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'RegularAuthStrategy only supports context private key policy',
      );
      return;
    }

    try {
      _log.fine('Validating credentials for wallet: $walletName');
      yield const AuthenticationState(
        status: AuthenticationStatus.authenticating,
        message: 'Signing in...',
      );

      final user = await _authService.signIn(
        walletName: walletName,
        password: password,
        options: options,
      );

      _log.info('Successfully signed in wallet: $walletName');
      yield AuthenticationState.completed(user);
    } catch (e, stackTrace) {
      _log.severe('Sign-in failed for wallet: $walletName', e, stackTrace);
      yield AuthenticationState.error('Sign-in failed: $e');
    }
  }

  @override
  Stream<AuthenticationState> registerStream({
    required AuthOptions options,
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting regular registration for wallet: $walletName');

    // Validate that this is a context private key policy
    if (options.privKeyPolicy != const PrivateKeyPolicy.contextPrivKey()) {
      _log.severe(
        'Invalid policy for RegularAuthStrategy registration: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'RegularAuthStrategy only supports context private key policy',
      );
      return;
    }

    try {
      _log.fine('Creating new wallet: $walletName');
      yield const AuthenticationState(
        status: AuthenticationStatus.authenticating,
        message: 'Registering wallet...',
      );

      final user = await _authService.register(
        walletName: walletName,
        password: password,
        options: options,
        mnemonic: mnemonic,
      );

      _log.info('Successfully registered wallet: $walletName');
      yield AuthenticationState.completed(user);
    } catch (e, stackTrace) {
      _log.severe('Registration failed for wallet: $walletName', e, stackTrace);
      yield AuthenticationState.error('Registration failed: $e');
    }
  }

  @override
  Future<void> cancel(int? taskId) async {
    _log.fine('Cancel requested for regular auth strategy (taskId: $taskId)');
    // Regular authentication doesn't have cancellable operations
    // This is a no-op for regular wallets
  }

  @override
  Future<void> dispose() async {
    _log.fine('Disposing regular auth strategy');
    // Regular authentication strategy doesn't hold any resources
    // This is a no-op for regular wallets
  }
}
