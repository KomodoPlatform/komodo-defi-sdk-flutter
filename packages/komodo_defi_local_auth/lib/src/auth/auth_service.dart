import 'dart:async';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

abstract interface class IAuthService {
  Future<List<KdfUser>> getUsers();

  Future<KdfUser> signIn({
    required String walletName,
    required String password,
  });

  Future<KdfUser> register({
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  });

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<KdfUser?> getActiveUser();

  Future<Mnemonic> getMnemonic({
    required bool encrypted,

    /// Required if [encrypted] is false.
    required String? walletPassword,
    // required String walletName,
  });

  Stream<KdfUser?> get authStateChanges;

  void dispose();
}

class KdfAuthService implements IAuthService {
  KdfAuthService(this._kdfFramework, this._hostConfig);

  final KomodoDefiFramework _kdfFramework;
  final IKdfHostConfig _hostConfig;
  final StreamController<KdfUser?> _authStateController =
      StreamController.broadcast();

  ApiClient get _client => _kdfFramework.client;
  final methods = KomodoDefiRpcMethods.rpc;

  final ReadWriteMutex _authMutex = ReadWriteMutex();

  Future<T> _runReadOperation<T>(Future<T> Function() operation) async {
    return _authMutex.protectRead(operation);
  }

  Future<T> _runWriteOperation<T>(Future<T> Function() operation) async {
    return _authMutex.protectWrite(operation);
  }

  @override
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
  }) async {
    final walletStatus =
        await _runReadOperation(() => _getWalletStatus(walletName));

    if (walletStatus) {
      final activeUser = await _runReadOperation(_getActiveUserInternal);
      return activeUser!;
    }

    return _runWriteOperation(() async {
      final config = await _generateStartupConfig(
        walletName: walletName,
        walletPassword: password,
        allowRegistrations: false,
      );
      return _authenticateUser(config);
    });
  }

  Future<bool> _getWalletStatus(String walletName) async {
    return await _assertWalletOrStop(walletName) ?? false;
  }

  @override
  @override
  Future<KdfUser> register({
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  }) async {
    // Perform the read operation outside the write lock
    final walletExists =
        await _runReadOperation(() => _assertWalletOrStop(walletName));

    // Proceed with the write operation if necessary
    return _runWriteOperation(() async {
      final config = await _generateStartupConfig(
        walletName: walletName,
        walletPassword: password,
        allowRegistrations: true,
        plaintextMnemonic: mnemonic?.plaintextMnemonic,
      );
      return _authenticateUser(config);
    });
  }

  Future<KdfUser> _authenticateUser(KdfStartupConfig config) async {
    final foundAuthExceptions = <AuthException>[];
    late StreamSubscription<String> sub;

    sub = _kdfFramework.logStream.listen((log) {
      // Capture authentication exceptions from the logs
      final exceptions = AuthException.findExceptionsInLog(log);
      if (exceptions.isNotEmpty) {
        foundAuthExceptions.addAll(exceptions);
      }
    });

    try {
      await _stopKdf();
      final kdfResult = await _kdfFramework.startKdf(config);

      if (!kdfResult.isStartingOrAlreadyRunning()) {
        throw AuthException(
          'Failed to start KDF: ${kdfResult.name}',
          type: AuthExceptionType.generalAuthError,
        );
      }

      // Wait for the KDF to fully start, checking status periodically
      for (var i = 0; i < 50; i++) {
        final status = await _kdfFramework.kdfMainStatus();
        if (status == MainStatus.rpcIsUp) {
          break;
        }

        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      // Re-throw any captured auth exceptions from the logs
      if (foundAuthExceptions.isNotEmpty) {
        throw foundAuthExceptions.first;
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow; // Re-throw the authentication-specific exception
      } else if (foundAuthExceptions.isNotEmpty) {
        // If general exception caught, but we have auth exceptions in logs, throw those
        throw foundAuthExceptions.last;
      } else {
        // For other types of exceptions, rethrow the original one
        rethrow;
      }
    } finally {
      await sub.cancel();
    }

    // Check the API status to ensure it's fully running
    final status = await _kdfFramework.kdfMainStatus();
    if (status != MainStatus.rpcIsUp) {
      throw AuthException(
        'KDF framework is not running properly: ${status.name}',
        type: AuthExceptionType.generalAuthError,
      );
    }

    // Ensure the user is properly authenticated
    final currentUser = await _getActiveUserInternal();
    if (currentUser == null) {
      throw AuthException(
        'No user signed in',
        type: AuthExceptionType.unauthorized,
      );
    }

    _authStateController.add(currentUser);
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    return _runWriteOperation(_stopKdf);
  }

  @override
  Future<bool> isSignedIn() async {
    return _runReadOperation(() async {
      return await _getActiveUserInternal() != null;
    });
  }

  @override
  Future<KdfUser?> getActiveUser() async {
    return _runReadOperation(_getActiveUserInternal);
  }

  Future<KdfUser?> _getActiveUserInternal() async {
    if (!await _kdfFramework.isRunning()) {
      return null;
    }
    final activeUser =
        (await _client.rpc.wallet.getWalletNames()).activatedWallet;
    return activeUser != null ? KdfUser(walletName: activeUser) : null;
  }

  @override
  Future<Mnemonic> getMnemonic({
    required bool encrypted,
    required String? walletPassword,
  }) async {
    return _runReadOperation(() async {
      assert(
        encrypted || walletPassword != null,
        'walletPassword is required to retrieve plaintext mnemonic.',
      );

      if (await _getActiveUserInternal() == null) {
        throw AuthException(
          'No user signed in',
          type: AuthExceptionType.unauthorized,
        );
      }

      final response = await _kdfFramework.client.executeRpc({
        'mmrpc': '2.0',
        'method': 'get_mnemonic',
        'params': {
          'format': encrypted ? 'encrypted' : 'plaintext',
          if (!encrypted) 'password': walletPassword,
        },
      });

      if (response is JsonRpcErrorResponse) {
        throw AuthException(
          response.error,
          type: AuthExceptionType.generalAuthError,
        );
      }

      return Mnemonic.fromRpcJson(response.value<JsonMap>('result'));
    });
  }

  @override
  Future<List<KdfUser>> getUsers() async {
    return _runReadOperation(() async {
      await _ensureKdfRunning();
      final walletNames = await _client.rpc.wallet.getWalletNames();
      return walletNames.walletNames
          .map((e) => KdfUser(walletName: e))
          .toList();
    });
  }

  @override
  Stream<KdfUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> dispose() async {
    return _runWriteOperation(() async {
      await _stopKdf();
      await _authStateController.close();
    });
  }

  Future<bool?> _assertWalletOrStop(String walletName) async {
    if (!await _kdfFramework.isRunning()) return null;

    final activeUser = await getActiveUser();
    if (activeUser == null) {
      await _stopKdf();
      return false;
    }

    if (activeUser.walletName != walletName) {
      await _stopKdf();
      return false;
    }

    return true;
  }

  Future<void> _stopKdf() async {
    await _kdfFramework.kdfStop();
    _authStateController.add(null);
  }

  Future<void> _ensureKdfRunning() async {
    if (!await _kdfFramework.isRunning()) {
      await _kdfFramework.startKdf(await _noAuthConfig);
    }
  }

  late final Future<KdfStartupConfig> _noAuthConfig =
      KdfStartupConfig.noAuthStartup(rpcPassword: _hostConfig.rpcPassword);

  Future<KdfStartupConfig> _generateStartupConfig({
    required String walletName,
    required String walletPassword,
    required bool allowRegistrations,
    String? plaintextMnemonic,
    String? encryptedMnemonic,
  }) async {
    if (plaintextMnemonic != null && encryptedMnemonic != null) {
      throw AuthException(
        'Both plaintext and encrypted mnemonics provided.',
        type: AuthExceptionType.generalAuthError,
      );
    }

    return KdfStartupConfig.generateWithDefaults(
      walletName: walletName,
      walletPassword: walletPassword,
      seed: plaintextMnemonic ?? encryptedMnemonic,
      rpcPassword: _hostConfig.rpcPassword,
      allowRegistrations: allowRegistrations,
    );
  }
}
