import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'trezor_initialization_state.dart';
import 'trezor_manager.dart';

/// High level helper that handles sign in/register and Trezor device
/// initialization for the built in "My Trezor" wallet.
class TrezorWalletManager {
  TrezorWalletManager(this._auth, this._trezor);

  static const String trezorWalletName = 'My Trezor';
  static const String _passwordKey = 'trezor_wallet_password';

  final KomodoDefiLocalAuth _auth;
  final TrezorManager _trezor;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> _getPassword({required bool isNewUser}) async {
    final existing = await _secureStorage.read(key: _passwordKey);
    if (!isNewUser) {
      if (existing == null) {
        throw AuthException(
          'Trezor wallet exists but no stored password found',
          type: AuthExceptionType.generalAuthError,
        );
      }
      return existing;
    }

    if (existing != null) return existing;

    final newPassword = SecurityUtils.generatePasswordSecure(16);
    await _secureStorage.write(key: _passwordKey, value: newPassword);
    return newPassword;
  }

  /// Clears the stored password for the Trezor wallet.
  Future<void> clearPassword() => _secureStorage.delete(key: _passwordKey);

  /// Registers or signs in to the "My Trezor" wallet and initializes the device.
  ///
  /// Emits [TrezorInitializationState] updates while the device is initializing.
  Stream<TrezorInitializationState> initializeAndAuthenticate({
    required DerivationMethod derivationMethod,
    bool register = false,
  }) async* {
    final current = await _auth.currentUser;
    if (current?.walletId.name == trezorWalletName) {
      try {
        await _auth.signOut();
      } catch (_) {
        // ignore sign out errors
      }
    }

    final users = await _auth.getUsers();
    final existingUser = users.firstWhereOrNull(
      (u) =>
          u.walletId.name == trezorWalletName &&
          u.authOptions.privKeyPolicy == PrivateKeyPolicy.trezor,
    );
    final isNewUser = existingUser == null || register;
    final password = await _getPassword(isNewUser: isNewUser);

    if (existingUser != null && !register) {
      await _auth.signIn(
        walletName: trezorWalletName,
        password: password,
        options: AuthOptions(
          derivationMethod: derivationMethod,
          privKeyPolicy: PrivateKeyPolicy.trezor,
        ),
      );
    } else {
      await _auth.register(
        walletName: trezorWalletName,
        password: password,
        options: AuthOptions(
          derivationMethod: derivationMethod,
          privKeyPolicy: PrivateKeyPolicy.trezor,
        ),
      );
    }

    await for (final state in _trezor.initializeDevice()) {
      yield state;
      if (state.status == TrezorInitializationStatus.completed ||
          state.status == TrezorInitializationStatus.error ||
          state.status == TrezorInitializationStatus.cancelled) {
        break;
      }
    }
  }

  Future<void> providePin(int taskId, String pin) =>
      _trezor.providePin(taskId, pin);

  Future<void> providePassphrase(int taskId, String passphrase) =>
      _trezor.providePassphrase(taskId, passphrase);

  Future<void> cancelInitialization(int taskId) =>
      _trezor.cancelInitialization(taskId);
}
