import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Abstract base class for secure wallet management.
///
/// Provides a common interface for managing wallet credentials, user lookup,
/// and authentication for different wallet types (Trezor, WalletConnect, etc.).
abstract class SecureWalletManager {
  SecureWalletManager(
    this.authService,
    this._secureStorage,
    this._generatePassword,
  );

  @protected
  final IAuthService authService;
  final FlutterSecureStorage _secureStorage;
  final String Function(int length) _generatePassword;

  /// The wallet name used for this wallet type.
  String get walletName;

  /// The secure storage key for the wallet password.
  String get passwordKey;

  /// Logger instance for this wallet manager.
  Logger get logger;

  /// Gets or generates a password for the wallet.
  ///
  /// [isNewUser] - Whether this is for a new user registration.
  /// Returns the password to use for wallet authentication.
  Future<String> getOrGeneratePassword({required bool isNewUser}) async {
    logger.fine('Getting wallet password (isNewUser: $isNewUser)');

    try {
      final existing = await _secureStorage.read(key: passwordKey);

      if (!isNewUser) {
        if (existing == null) {
          logger.severe('No stored password found for existing user');
          throw AuthException(
            'Authentication failed for $walletName wallet',
            type: AuthExceptionType.generalAuthError,
          );
        }
        logger.fine('Retrieved existing password for wallet');
        return existing;
      }

      if (existing != null) {
        logger.fine('Using existing password for new wallet');
        return existing;
      }

      logger.fine('Generating new password for wallet');
      final newPassword = _generatePassword(16);
      await _secureStorage.write(key: passwordKey, value: newPassword);
      logger.fine('New password generated and stored successfully');
      return newPassword;
    } catch (e, stackTrace) {
      logger.severe('Failed to get/generate wallet password', e, stackTrace);
      rethrow;
    }
  }

  /// Clears the stored password for the wallet.
  Future<void> clearStoredPassword() async {
    logger.info('Clearing stored wallet password');
    try {
      await _secureStorage.delete(key: passwordKey);
      logger.fine('Wallet password cleared successfully');
    } catch (e, stackTrace) {
      logger.severe('Failed to clear wallet password', e, stackTrace);
      rethrow;
    }
  }

  /// Finds an existing user for this wallet type.
  ///
  /// Returns the existing user if found, null otherwise.
  Future<KdfUser?> findExistingUser() async {
    logger.fine('Searching for existing wallet user');

    try {
      final users = await authService.getUsers();
      final existingUser = users.firstWhereOrNull(
        (KdfUser u) => isUserForThisWallet(u),
      );

      if (existingUser != null) {
        logger.fine(
          'Found existing wallet user: ${existingUser.walletId.name}',
        );
      } else {
        logger.fine('No existing wallet user found');
      }

      return existingUser;
    } catch (e, stackTrace) {
      logger.severe('Failed to find existing wallet user', e, stackTrace);
      rethrow;
    }
  }

  /// Authenticates with the wallet (sign in or register).
  ///
  /// [existingUser] - Existing user if found, null for new registration.
  /// [password] - Password to use for authentication.
  /// [authOptions] - Authentication options including private key policy.
  /// [walletName] - Optional wallet name for registration.
  Future<KdfUser> authenticateWallet({
    required KdfUser? existingUser,
    required String password,
    required AuthOptions authOptions,
    String? walletName,
  }) async {
    logger.fine(
      'Authenticating with wallet (existingUser: ${existingUser != null})',
    );

    try {
      if (existingUser != null) {
        logger.fine('Signing in to existing wallet');
        return await authService.signIn(
          walletName: this.walletName,
          password: password,
          options: authOptions,
        );
      } else {
        logger.fine('Registering new wallet');
        return await authService.register(
          walletName: walletName ?? this.walletName,
          password: password,
          options: authOptions,
        );
      }
    } catch (e, stackTrace) {
      logger.severe('Failed to authenticate with wallet', e, stackTrace);
      rethrow;
    }
  }

  /// Signs out the current user if they are using this wallet type.
  Future<void> signOutCurrentUser() async {
    logger.fine('Checking if current user needs to be signed out');

    try {
      final current = await authService.getActiveUser();
      if (current != null && isUserForThisWallet(current)) {
        logger.warning("Signing out current '${current.walletId.name}' user");
        try {
          await authService.signOut();
          logger.fine('Wallet user signed out successfully');
        } catch (e, stackTrace) {
          logger.warning('Error during wallet user sign out', e, stackTrace);
          // ignore sign out errors
        }
      } else {
        logger.finest('No wallet user to sign out');
      }
    } catch (e, stackTrace) {
      logger.severe(
        'Failed to check/sign out current wallet user',
        e,
        stackTrace,
      );
      // Don't rethrow as this is a cleanup operation
    }
  }

  /// Determines if the given user belongs to this wallet type.
  ///
  /// Subclasses should implement this to check wallet-specific criteria.
  bool isUserForThisWallet(KdfUser user);

  /// Disposes of any resources used by the wallet manager.
  void dispose() {
    logger.fine('Disposing wallet manager');
  }
}
