import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/regular_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/trezor_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/walletconnect_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_repository.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Factory class for creating authentication strategies based on private key policy.
///
/// This factory provides a centralized way to create the appropriate authentication
/// strategy for different wallet types (regular, Trezor, WalletConnect, MetaMask).
class AuthStrategyFactory {
  /// Creates an authentication strategy based on the provided private key policy.
  ///
  /// Parameters:
  /// - [policy] - The private key policy that determines which strategy to create
  /// - [authService] - The underlying authentication service for all strategies
  /// - [apiClient] - API client for hardware wallet operations
  /// - [rpcMethods] - RPC methods required for WalletConnect and other operations
  /// - [trezorRepository] - Optional Trezor repository (created if not provided for Trezor strategy)
  ///
  /// Returns the appropriate [AuthenticationStrategy] implementation.
  ///
  /// Throws [ArgumentError] if the policy type is not supported or if required dependencies are missing.
  static AuthenticationStrategy createStrategy(
    PrivateKeyPolicy policy,
    IAuthService authService,
    ApiClient apiClient, {
    required KomodoDefiRpcMethods rpcMethods,
    TrezorRepository? trezorRepository,
  }) {
    return policy.when(
      contextPrivKey: () => RegularAuthStrategy(authService),
      trezor: () => TrezorAuthStrategy(
        authService,
        trezorRepository ?? TrezorRepository(apiClient),
      ),
      walletConnect: (sessionTopic) =>
          WalletConnectAuthStrategy(authService, rpcMethods.walletConnect),
      metamask: () => throw ArgumentError(
        'MetaMask authentication strategy is not yet implemented',
      ),
    );
  }

  /// Validates that the required dependencies are available for the given policy.
  ///
  /// Parameters:
  /// - [policy] - The private key policy to validate
  /// - [apiClient] - The API client instance (required)
  /// - [rpcMethods] - The RPC methods instance (required)
  ///
  /// Returns true if all required dependencies are available, false otherwise.
  static bool validateDependencies(
    PrivateKeyPolicy policy, {
    required ApiClient apiClient,
    required KomodoDefiRpcMethods rpcMethods,
  }) {
    return policy.when(
      contextPrivKey: () =>
          true, // Basic dependencies are always satisfied when required
      trezor: () => true, // Dependencies are required parameters
      walletConnect: (sessionTopic) =>
          true, // Dependencies are required parameters
      metamask: () => false, // Not yet implemented
    );
  }

  /// Gets a human-readable description of the strategy type.
  ///
  /// Parameters:
  /// - [policy] - The private key policy
  ///
  /// Returns a string description of the authentication strategy.
  static String getStrategyDescription(PrivateKeyPolicy policy) {
    return policy.when(
      contextPrivKey: () =>
          'Regular wallet authentication using context private key',
      trezor: () => 'Trezor hardware wallet authentication',
      walletConnect: (sessionTopic) =>
          'WalletConnect mobile wallet authentication '
          '(Session: ${sessionTopic.isEmpty ? 'new' : sessionTopic})',
      metamask: () =>
          'MetaMask browser wallet authentication (not implemented)',
    );
  }

  /// Gets the list of supported private key policy types.
  ///
  /// Returns a list of [PrivateKeyPolicy] instances representing all
  /// currently supported authentication strategies.
  static List<PrivateKeyPolicy> getSupportedPolicies() {
    return [
      const PrivateKeyPolicy.contextPrivKey(),
      const PrivateKeyPolicy.trezor(),
      const PrivateKeyPolicy.walletConnect(
        '',
      ), // Empty session topic for new connections
      // MetaMask is not included as it's not yet implemented
    ];
  }

  /// Checks if a given private key policy is supported.
  ///
  /// Parameters:
  /// - [policy] - The private key policy to check
  ///
  /// Returns true if the policy is supported, false otherwise.
  static bool isPolicySupported(PrivateKeyPolicy policy) {
    return policy.when(
      contextPrivKey: () => true,
      trezor: () => true,
      walletConnect: (sessionTopic) => true,
      metamask: () => false, // Not yet implemented
    );
  }
}
