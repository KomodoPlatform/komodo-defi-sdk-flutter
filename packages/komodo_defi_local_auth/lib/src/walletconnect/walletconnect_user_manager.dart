import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/secure_wallet_manager.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// WalletConnect-specific secure wallet manager.
///
/// Handles user management for WalletConnect wallets including secure password
/// generation, storage, and user authentication following the same patterns
/// as Trezor authentication.
class WalletConnectUserManager extends SecureWalletManager {
  /// Creates a new WalletConnect user manager.
  ///
  /// [authService] - The authentication service for user operations.
  /// [secureStorage] - Optional secure storage (uses default if not provided).
  /// [passwordGenerator] - Optional password generator function.
  WalletConnectUserManager(
    IAuthService authService, {
    FlutterSecureStorage? secureStorage,
    String Function(int length)? passwordGenerator,
  }) : super(
         authService,
         secureStorage ?? const FlutterSecureStorage(),
         passwordGenerator ?? SecurityUtils.generatePasswordSecure,
       );

  static const String walletConnectWalletName = 'My WalletConnect';
  static const String _passwordKey = 'walletconnect_wallet_password';
  static final _log = Logger('WalletConnectUserManager');

  @override
  String get walletName => walletConnectWalletName;

  @override
  String get passwordKey => _passwordKey;

  @override
  Logger get logger => _log;

  @override
  bool isUserForThisWallet(KdfUser user) {
    return user.walletId.name == walletConnectWalletName &&
        user.walletId.authOptions.privKeyPolicy.maybeWhen(
          walletConnect: (_) => true,
          orElse: () => false,
        );
  }

  /// Creates or authenticates a WalletConnect wallet with the given session topic.
  ///
  /// [sessionTopic] - The WalletConnect session topic to associate with the wallet.
  /// [derivationMethod] - The derivation method to use for the wallet.
  /// [walletName] - Optional custom wallet name (defaults to 'My WalletConnect').
  ///
  /// Returns the authenticated user.
  Future<KdfUser> createOrAuthenticateWallet({
    required String sessionTopic,
    required DerivationMethod derivationMethod,
    String? walletName,
  }) async {
    logger.info('Creating or authenticating WalletConnect wallet');

    try {
      // Sign out any existing user first
      await signOutCurrentUser();

      // Find existing user or determine if this is a new registration
      final existingUser = await findExistingUser();
      final isNewUser = existingUser == null;
      logger.fine('User status: ${isNewUser ? 'new' : 'existing'}');

      // Get or generate password
      final password = await getOrGeneratePassword(isNewUser: isNewUser);

      // Create auth options with WalletConnect policy
      final authOptions = AuthOptions(
        derivationMethod: derivationMethod,
        privKeyPolicy: PrivateKeyPolicy.walletConnect(sessionTopic),
      );

      // Authenticate with the wallet
      final user = await authenticateWallet(
        existingUser: existingUser,
        password: password,
        authOptions: authOptions,
        walletName: walletName,
      );

      logger.info(
        'Successfully ${isNewUser ? 'created' : 'authenticated'} WalletConnect wallet: ${user.walletId.name}',
      );

      return user;
    } catch (e, stackTrace) {
      logger.severe(
        'Failed to create or authenticate WalletConnect wallet',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Updates the session topic for an existing WalletConnect wallet.
  ///
  /// [newSessionTopic] - The new session topic to associate with the wallet.
  /// [derivationMethod] - The derivation method to use for the wallet.
  ///
  /// Returns the updated authenticated user.
  Future<KdfUser> updateSessionTopic({
    required String newSessionTopic,
    required DerivationMethod derivationMethod,
  }) async {
    logger.info('Updating WalletConnect session topic');

    try {
      final existingUser = await findExistingUser();
      if (existingUser == null) {
        throw AuthException(
          'No existing WalletConnect wallet found to update',
          type: AuthExceptionType.generalAuthError,
        );
      }

      // Get existing password
      final password = await getOrGeneratePassword(isNewUser: false);

      // Create auth options with new session topic
      final authOptions = AuthOptions(
        derivationMethod: derivationMethod,
        privKeyPolicy: PrivateKeyPolicy.walletConnect(newSessionTopic),
      );

      // Re-authenticate with new session topic
      final user = await authenticateWallet(
        existingUser: existingUser,
        password: password,
        authOptions: authOptions,
      );

      logger.info('Successfully updated WalletConnect session topic');
      return user;
    } catch (e, stackTrace) {
      logger.severe(
        'Failed to update WalletConnect session topic',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Gets the current session topic from the active WalletConnect user.
  ///
  /// Returns the session topic if available, null otherwise.
  Future<String?> getCurrentSessionTopic() async {
    logger.fine('Getting current WalletConnect session topic');

    try {
      final activeUser = await authService.getActiveUser();
      if (activeUser != null && isUserForThisWallet(activeUser)) {
        return activeUser.walletId.authOptions.privKeyPolicy.maybeWhen(
          walletConnect: (String topic) => topic,
          orElse: () => null,
        );
      }
      return null;
    } catch (e, stackTrace) {
      logger.warning('Failed to get current session topic', e, stackTrace);
      return null;
    }
  }

  /// Checks if there is an active WalletConnect user.
  Future<bool> hasActiveWalletConnectUser() async {
    try {
      final activeUser = await authService.getActiveUser();
      return activeUser != null && isUserForThisWallet(activeUser);
    } catch (e, stackTrace) {
      logger.warning(
        'Failed to check for active WalletConnect user',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
