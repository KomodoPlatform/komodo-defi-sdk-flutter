import 'dart:async';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

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
    // _currentUser = null;
    _authStateController.add(null);
  }

  Future<void> _ensureKdfRunning() async {
    if (!await _kdfFramework.isRunning()) {
      await _kdfFramework.startKdf(await _noAuthConfig);
    }
  }

  @override
  Future<KdfUser> signIn({
    required String walletName,
    required String password,
  }) async {
    final walletStatus = await _assertWalletOrStop(walletName);
    if (walletStatus ?? false) {
      // Wallet is already signed in
      return (await getActiveUser())!;
    }

    final config = await _generateStartupConfig(
      walletName: walletName,
      walletPassword: password,
      allowRegistrations: false,
    );
    return _authenticateUser(config);
  }

  @override
  Future<KdfUser> register({
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  }) async {
    await _assertWalletOrStop(walletName);
    final config = await _generateStartupConfig(
      walletName: walletName,
      walletPassword: password,
      allowRegistrations: true,
      plaintextMnemonic: mnemonic?.plaintextMnemonic,
    );
    return _authenticateUser(config);
  }

  Future<KdfUser> _authenticateUser(KdfStartupConfig config) async {
    Exception? exception;
    final foundAuthExceptions = <AuthException>[];

    final sub = _kdfFramework.logStream.listen((log) {
      foundAuthExceptions.addAll(AuthException.findExceptionsInLog(log));
    });

    try {
      await _stopKdf();
      final kdfResult = await _kdfFramework.startKdf(config);

      if (!kdfResult.isOk) {
        throw AuthException(
          'Failed session creation: ${kdfResult.name}',
          type: AuthExceptionType.generalAuthError,
        );
      }
    } on Exception catch (e) {
      exception = e;
    } finally {
      await sub.cancel();
    }
    if (foundAuthExceptions.isNotEmpty || exception != null) {
      throw foundAuthExceptions.lastOrNull ?? exception!;
    }

    final currentUser = await getActiveUser();

    if (currentUser == null) {
      throw AuthException(
        'No user signed in',
        type: AuthExceptionType.unauthorized,
      );
    }

    return currentUser;
  }

  @override
  Future<void> signOut() async {
    await _stopKdf();
  }

  @override
  Future<bool> isSignedIn() async {
    return await getActiveUser() != null;
  }

  @override
  Future<KdfUser?> getActiveUser() async {
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
    assert(
      encrypted || walletPassword != null,
      'walletPassword is required to retrieve plaintext mnemonic.',
    );

    if (await getActiveUser() == null) {
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
  }

  @override
  Future<List<KdfUser>> getUsers() async {
    await _ensureKdfRunning();
    final walletNames = await _client.rpc.wallet.getWalletNames();
    return walletNames.walletNames.map((e) => KdfUser(walletName: e)).toList();
  }

  @override
  Stream<KdfUser?> get authStateChanges => _authStateController.stream;

  @override
  // ignore: avoid_void_async
  void dispose() async {
    await _stopKdf();
    await _authStateController.close();
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
