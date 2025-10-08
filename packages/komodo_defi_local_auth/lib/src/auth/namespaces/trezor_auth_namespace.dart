import 'package:komodo_defi_local_auth/src/trezor/_trezor_index.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Trezor hardware wallet authentication namespace
///
/// Provides methods for interacting with Trezor hardware devices during
/// authentication processes, including PIN and passphrase provision.
class TrezorAuthNamespace {
  /// Creates a new Trezor authentication namespace.
  ///
  /// [trezorAuthService] - The Trezor-specific authentication service
  /// [ensureInitialized] - Function to ensure the auth service is initialized
  TrezorAuthNamespace(this._trezorAuthService, this._ensureInitialized);

  final TrezorAuthService _trezorAuthService;
  final Future<void> Function() _ensureInitialized;

  /// Provides PIN to a Trezor hardware device during authentication.
  ///
  /// The [taskId] should be obtained from the authentication state when the
  /// device requests PIN input. The [pin] should be entered as it appears on
  /// your keyboard numpad, mapped according to the grid shown on the Trezor device.
  ///
  /// This method should only be called when using Trezor authentication and
  /// the device is requesting PIN input.
  ///
  /// Throws [AuthException] if the device is not connected, the task ID is
  /// invalid, or if an error occurs during PIN provision.
  Future<void> setPin(int taskId, String pin) async {
    await _ensureInitialized();

    try {
      await _trezorAuthService.provideTrezorPin(taskId, pin);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Failed to provide PIN to hardware device: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  /// Provides passphrase to a Trezor hardware device during authentication.
  ///
  /// The [taskId] should be obtained from the authentication state when the
  /// device requests passphrase input. The [passphrase] acts like an additional
  /// word in your recovery seed. Use an empty string to access the default
  /// wallet without passphrase.
  ///
  /// This method should only be called when using Trezor authentication and
  /// the device is requesting passphrase input.
  ///
  /// Throws [AuthException] if the device is not connected, the task ID is
  /// invalid, or if an error occurs during passphrase provision.
  Future<void> setPassphrase(int taskId, String passphrase) async {
    await _ensureInitialized();

    try {
      await _trezorAuthService.provideTrezorPassphrase(taskId, passphrase);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Failed to provide passphrase to hardware device: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  /// Cancels an ongoing Trezor hardware device initialization.
  ///
  /// The [taskId] should be obtained from the authentication state when the
  /// device is being initialized. This method allows cancelling the initialization
  /// process if needed.
  ///
  /// This method should only be called when using Trezor authentication and
  /// there is an active initialization process.
  ///
  /// Throws [AuthException] if the task ID is invalid or if an error occurs
  /// during cancellation.
  Future<void> cancelInitialization(int taskId) async {
    await _ensureInitialized();

    try {
      await _trezorAuthService.cancelTrezorInitialization(taskId);
    } catch (e) {
      throw AuthException(
        'Failed to cancel hardware device initialization: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }
}
