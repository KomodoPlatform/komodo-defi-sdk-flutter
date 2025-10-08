import 'dart:async';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/namespaces/trezor_auth_namespace.dart';
import 'package:komodo_defi_local_auth/src/auth/namespaces/walletconnect_auth_namespace.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// The [KomodoDefiAuth] class provides a simplified local authentication
/// service for managing user sign-in, registration, and mnemonic handling
/// within the Komodo DeFi Framework.
///
/// By default, the class operates in HD mode, which may be unexpected for
/// developers familiar with the KDF API's default behavior. The default
/// [AuthOptions] enables HD wallet mode, but this can be changed using
/// the [AuthOptions] parameter in the sign-in and registration methods.
///
/// NB: Pubkey address
abstract interface class KomodoDefiAuth {
  /// Ensures that the local authentication system has been initialized.
  ///
  /// This method must be called before interacting with authentication features.
  /// If the system is already initialized, this method does nothing.
  Future<void> ensureInitialized();

  /// Signs in a user with the specified [walletName] and [password].
  ///
  /// By default, the system will launch in HD mode (enabled in the [AuthOptions]),
  /// which may differ from the non-HD mode used in other areas of the KDF API.
  /// Developers can override the [derivationMethod] in [AuthOptions] to change
  /// this behavior.
  ///
  /// Throws [AuthException] if an error occurs during sign-in.
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  });

  /// Signs in a user with the specified [walletName] and [password].
  ///
  /// Returns a stream of [AuthenticationState] that provides real-time updates
  /// of the authentication process. For Trezor wallets, this includes device
  /// initialization states. For regular wallets, it will emit completion or error states.
  Stream<AuthenticationState> signInStream({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  });

  /// Registers a new user with the specified [walletName] and [password].
  ///
  /// By default, the system will launch in HD mode (enabled in the [AuthOptions]),
  /// which may differ from the non-HD mode used in other areas of the KDF API.
  /// Developers can override the [DerivationMethod] in [AuthOptions] to change
  /// this behavior. An optional [mnemonic] can be provided during registration.
  ///
  /// Throws [AuthException] if registration is disabled or if an error occurs
  /// during registration.
  Future<KdfUser> register({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
    Mnemonic? mnemonic,
  });

  /// Registers a new user with the specified [walletName] and [password].
  ///
  /// Returns a stream of [AuthenticationState] that provides real-time updates
  /// of the registration process. For Trezor wallets, this includes device
  /// initialization states. For regular wallets, it will emit completion or error states.
  Stream<AuthenticationState> registerStream({
    required String walletName,
    required String password,
    AuthOptions options = const AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
    Mnemonic? mnemonic,
  });

  /// A stream that emits authentication state changes for the current user.
  ///
  /// Returns a [Stream] of [KdfUser?] representing the currently signed-in
  /// user. The stream will emit `null` if the user is signed out.
  Stream<KdfUser?> get authStateChanges;

  /// Watches the current user state and emits updates when it changes.
  ///
  /// Returns a [Stream] of [KdfUser?] that continuously monitors the current
  /// user state. This is useful for reactive UI updates when the user signs
  /// in, signs out, or when user data is updated.
  ///
  /// The stream will emit `null` if no user is signed in, and a [KdfUser]
  /// object when a user is authenticated.
  Stream<KdfUser?> watchCurrentUser();

  /// Retrieves the current signed-in user, if available.
  ///
  /// Returns a [KdfUser] if a user is signed in, otherwise returns `null`.
  Future<KdfUser?> get currentUser;

  /// Retrieves a list of all users registered on the device.
  ///
  /// Returns a [List] of [KdfUser] objects representing all registered users.
  Future<List<KdfUser>> getUsers();

  /// Signs out the current user.
  ///
  /// Throws [AuthException] if an error occurs during the sign-out process.
  Future<void> signOut();

  /// Checks whether a user is currently signed in.
  ///
  /// Returns `true` if a user is signed in, otherwise `false`.
  Future<bool> isSignedIn();

  /// Retrieves the encrypted mnemonic of the currently signed-in user.
  ///
  /// Throws [AuthException] if an error occurs during retrieval or if no user
  /// is signed in.
  Future<Mnemonic> getMnemonicEncrypted();

  /// Retrieves the plain text mnemonic of the currently signed-in user.
  ///
  /// A [walletPassword] must be provided to decrypt the mnemonic.
  /// Throws [AuthException] if an error occurs during retrieval or if no user
  /// is signed in.
  Future<Mnemonic> getMnemonicPlainText(String walletPassword);

  /// Changes the password used to encrypt/decrypt the mnemonic.
  ///
  /// This is used to change the password that protects the wallet's seed phrase.
  /// Both the current and new passwords must be provided.
  ///
  /// Throws [AuthException] if the current password is incorrect or if no user
  /// is signed in.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Deletes the specified wallet.
  Future<void> deleteWallet({
    required String walletName,
    required String password,
  });

  /// Sets the value of a single key in the active user's metadata.
  ///
  /// This preserves any existing metadata, and overwrites the value only for
  /// the specified key.
  ///
  /// Throws an exception if there is no active user.
  ///
  /// Setting a value to `null` will remove the key from the metadata.
  ///
  /// This does not emit an auth state change event.
  ///
  ///
  /// NB: This is intended to only be a short-term solution until the SDK
  /// is fully integrated with KW. This may be deprecated in the future.
  ///
  /// Example:
  /// final _komodoDefiSdk = KomodoDefiSdk.global;
  ///
  ///   await _komodoDefiSdk.auth.setOrRemoveActiveUserKeyValue(
  ///   'custom_tokens',
  ///   {
  ///     'tokens': [
  ///       {
  ///         'foo': 'bar',
  ///         'name': 'Foo Token',
  ///         'symbol': 'FOO',
  ///         // ...
  ///       }
  ///     ],
  ///   }.toJsonString(),
  /// );
  /// final tokenJson = (await _komodoDefiSdk.auth.currentUser)
  ///     ?.metadata
  ///     .valueOrNull<JsonList>('custom_tokens', 'tokens');
  ///
  /// print('Custom tokens: $tokenJson');

  Future<void> setOrRemoveActiveUserKeyValue(String key, dynamic value);

  /// Trezor hardware wallet authentication namespace
  ///
  /// Provides access to Trezor-specific authentication methods including
  /// PIN provision, passphrase handling, and initialization cancellation.
  ///
  /// Example usage:
  /// ```dart
  /// await auth.trezor.setPin(taskId, '123456');
  /// await auth.trezor.setPassphrase(taskId, 'my-passphrase');
  /// await auth.trezor.cancelInitialization(taskId);
  /// ```
  TrezorAuthNamespace get trezor;

  /// WalletConnect authentication namespace
  ///
  /// Provides access to WalletConnect session management and authentication
  /// methods including session retrieval, connectivity testing, and termination.
  ///
  /// Example usage:
  /// ```dart
  /// final sessions = await auth.walletConnect.getSessions();
  /// final session = await auth.walletConnect.getSession('topic');
  /// final isActive = await auth.walletConnect.pingSession('topic');
  /// await auth.walletConnect.deleteSession('topic');
  /// await auth.walletConnect.cancelAuthentication();
  /// ```
  WalletConnectAuthNamespace get walletConnect;

  /// Disposes of any resources held by the authentication service.
  ///
  /// This method should be called when the authentication service is no longer
  /// needed to clean up resources.
  Future<void> dispose();
}
