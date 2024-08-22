import 'dart:async';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract interface class IAuthService {
  Future<KdfUser> signInOrRegister({
    required String walletName,
    required String password,
  });

  Future<KdfUser> importWalletEncrypted({
    required String walletName,
    required String password,
    required String encryptedMnemonic,
  });

  Future<KdfUser> importWalletPlaintext({
    required String walletName,
    required String password,
    required String plaintextMnemonic,
  });

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<KdfUser?> getCurrentUser();

  Future<String> getMnemonic({
    required bool encrypted,
    required String walletPassword,
  });

  Stream<KdfUser?> get authStateChanges;

  void dispose();
}

class KdfAuthService implements IAuthService {
  KdfAuthService(this._kdfFramework);

  ApiClient get _client => _kdfFramework.client;

  final methods = KomodoDefiRpcMethods.rpc;

  final KomodoDefiFramework _kdfFramework;
  final StreamController<KdfUser?> _authStateController =
      StreamController.broadcast();
  KdfUser? _currentUser;

  @override
  Future<KdfUser> signInOrRegister({
    required String walletName,
    required String password,
  }) async {
    final config = await KdfStartupConfig.generateWithDefaults(
      walletName: walletName,
      walletPassword: password,
    );

    return await _startKdfWithConfig(config);
  }

  Future<KdfUser> _startKdfWithConfig(KdfStartupConfig config) async {
    try {
      // Start the logStream listener
      final logSubscription = _kdfFramework.logStream.listen(_processLog);

      final kdfResult = await _kdfFramework.startKdf(config);

      await logSubscription.cancel();

      if (kdfResult.isAlreadyRunning) {
        throw AuthException(
          'Wallet is already running.',
          type: AuthExceptionType.walletAlreadyRunning,
        );
      }

      if (kdfResult.isRunning()) {
        _currentUser = KdfUser(
          uid: config.walletName.hashCode.toString(),
          walletName: config.walletName,
        );
        _authStateController.add(_currentUser);
        return _currentUser!;
      } else {
        throw AuthException(
          'Failed to start KDF.',
          type: AuthExceptionType.walletStartFailed,
        );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow; // Rethrow the AuthException to the caller
      } else {
        throw AuthException(
          e.toString(),
          type: AuthExceptionType.generalAuthError,
        );
      }
    }
  }

  void _processLog(String log) {
    final foundExceptions = AuthException.foundExceptions(log);

    if (foundExceptions.contains(AuthExceptionType.invalidWalletPassword)) {
      throw AuthException(
        'Failed to start wallet: Incorrect wallet password.',
        type: AuthExceptionType.invalidWalletPassword,
      );
    }
  }

  @override
  Future<KdfUser> importWalletPlaintext({
    required String walletName,
    required String password,
    required String plaintextMnemonic,
  }) async {
    final config = await KdfStartupConfig.generateWithDefaults(
      walletName: walletName,
      walletPassword: password,
      seed: plaintextMnemonic,
    );
    return _startKdfWithConfig(config);
  }

  @override
  Future<KdfUser> importWalletEncrypted({
    required String walletName,
    required String password,
    required String encryptedMnemonic,
  }) async {
    final config = await KdfStartupConfig.generateWithDefaults(
      walletName: walletName,
      walletPassword: password,
      seed: encryptedMnemonic,
    );
    return _startKdfWithConfig(config);
  }

  @override
  Future<void> signOut() async {
    try {
      await _kdfFramework.kdfStop();
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      throw AuthException(
        "Couldn't sign out: $e",
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return _currentUser != null;
  }

  @override
  Future<KdfUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<String> getMnemonic({
    required bool encrypted,
    required String walletPassword,
  }) async {
    if (_currentUser == null) {
      throw AuthException(
        'No user signed in',
        type: AuthExceptionType.generalAuthError,
      );
    }

    final result = await _kdfFramework.executeRpc({
      'userpass': _currentUser!.walletName,
      'method': 'get_mnemonic',
      'params': {
        'format': encrypted ? 'encrypted' : 'plaintext',
        if (!encrypted) 'password': _currentUser!.walletName,
      },
    });

    if (encrypted) {
      return result.value<String>('encrypted_mnemonic_data');
    } else {
      return result.value<String>('mnemonic');
    }
  }

  @override
  Stream<KdfUser?> get authStateChanges => _authStateController.stream;

  @override
  void dispose() {
    _authStateController.close();
  }
}
