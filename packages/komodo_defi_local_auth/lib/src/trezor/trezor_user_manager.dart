import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/secure_wallet_manager.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Trezor-specific secure wallet manager.
///
/// Handles user management for Trezor wallets including secure password
/// generation, storage, and user authentication using the same patterns
/// as WalletConnect authentication.
class TrezorUserManager extends SecureWalletManager {
  /// Creates a new Trezor user manager.
  ///
  /// [authService] - The authentication service for user operations.
  /// [secureStorage] - Optional secure storage (uses default if not provided).
  /// [passwordGenerator] - Optional password generator function.
  TrezorUserManager(
    IAuthService authService, {
    FlutterSecureStorage? secureStorage,
    String Function(int length)? passwordGenerator,
  }) : super(
         authService,
         secureStorage ?? const FlutterSecureStorage(),
         passwordGenerator ?? SecurityUtils.generatePasswordSecure,
       );

  static const String trezorWalletName = 'My Trezor';
  static const String _passwordKey = 'trezor_wallet_password';
  static final _log = Logger('TrezorUserManager');

  @override
  String get walletName => trezorWalletName;

  @override
  String get passwordKey => _passwordKey;

  @override
  Logger get logger => _log;

  @override
  bool isUserForThisWallet(KdfUser user) {
    return user.walletId.name == trezorWalletName &&
        user.walletId.authOptions.privKeyPolicy ==
            const PrivateKeyPolicy.trezor();
  }

  /// Creates or authenticates a Trezor wallet.
  ///
  /// [derivationMethod] - The derivation method to use for the wallet.
  ///
  /// Returns the authenticated user.
  Future<KdfUser> createOrAuthenticateWallet({
    required DerivationMethod derivationMethod,
  }) async {
    logger.info('Creating or authenticating Trezor wallet');

    try {
      // Sign out any existing user first
      await signOutCurrentUser();

      // Find existing user or determine if this is a new registration
      final existingUser = await findExistingUser();
      final isNewUser = existingUser == null;
      logger.fine('User status: ${isNewUser ? 'new' : 'existing'}');

      // Get or generate password
      final password = await getOrGeneratePassword(isNewUser: isNewUser);

      // Create auth options with Trezor policy
      final authOptions = AuthOptions(
        derivationMethod: derivationMethod,
        privKeyPolicy: const PrivateKeyPolicy.trezor(),
      );

      // Authenticate with the wallet
      final user = await authenticateWallet(
        existingUser: existingUser,
        password: password,
        authOptions: authOptions,
      );

      logger.info(
        'Successfully ${isNewUser ? 'created' : 'authenticated'} '
        'Trezor wallet: ${user.walletId.name}',
      );

      return user;
    } catch (e, stackTrace) {
      logger.severe(
        'Failed to create or authenticate Trezor wallet',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Checks if there is an active Trezor user.
  Future<bool> hasActiveTrezorUser() async {
    try {
      final activeUser = await authService.getActiveUser();
      return activeUser != null && isUserForThisWallet(activeUser);
    } catch (e, stackTrace) {
      logger.warning('Failed to check for active Trezor user', e, stackTrace);
      return false;
    }
  }
}
