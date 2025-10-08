import 'dart:async';

import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Abstract interface for authentication strategies that handle different
/// wallet types (regular, Trezor, WalletConnect, MetaMask).
///
/// Each strategy implements the specific authentication flow for its wallet type
/// while providing a consistent interface for the main authentication service.
abstract interface class AuthenticationStrategy {
  /// Authenticates a user with the specified parameters.
  ///
  /// Returns a stream of [AuthenticationState] that provides real-time updates
  /// of the authentication process. The stream will emit states appropriate
  /// for the specific wallet type (e.g., device prompts for Trezor, QR codes
  /// for WalletConnect).
  ///
  /// Parameters:
  /// - [options]: Authentication options including derivation method and private key policy
  /// - [walletName]: Name of the wallet to authenticate (may be null for hardware wallets)
  /// - [password]: Password for the wallet (may be null for some wallet types)
  /// - [mnemonic]: Optional mnemonic for registration flows
  Stream<AuthenticationState> signInStream({
    required AuthOptions options,
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  });

  /// Registers a new user with the specified parameters.
  ///
  /// Returns a stream of [AuthenticationState] that provides real-time updates
  /// of the registration process. The stream will emit states appropriate
  /// for the specific wallet type.
  ///
  /// Parameters:
  /// - [options]: Authentication options including derivation method and private key policy
  /// - [walletName]: Name of the wallet to register
  /// - [password]: Password for the wallet
  /// - [mnemonic]: Optional mnemonic for the wallet
  Stream<AuthenticationState> registerStream({
    required AuthOptions options,
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  });

  /// Cancels any ongoing authentication or registration operations.
  ///
  /// The [taskId] parameter is optional and may be used by strategies that
  /// track operations with specific task identifiers (e.g., Trezor).
  Future<void> cancel(int? taskId);

  /// Disposes of any resources held by the strategy.
  ///
  /// This method should be called when the strategy is no longer needed
  /// to clean up resources such as streams, timers, or connections.
  Future<void> dispose();
}
