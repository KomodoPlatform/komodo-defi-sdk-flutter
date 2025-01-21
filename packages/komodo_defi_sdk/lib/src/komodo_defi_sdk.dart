import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/assets/asset_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/sdk/sdk_config.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
import 'package:komodo_defi_sdk/src/transaction_history/transaction_history_manager.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

KomodoDefiSdk? _instance;

// TODO! Ensure the lazy initialization of the SDK instance works reliably
// for all all public properties, or otherwise make initialization required.
/// A high-level opinionated library that provides a simple way to build
/// cross-platform Komodo Defi Framework applications (primarily focused on
/// wallets).
class KomodoDefiSdk with SecureRpcPasswordMixin {
  /// Creates a new instance of the [KomodoDefiSdk] class.
  ///
  /// NB: This is a singleton class. Use the [KomodoDefiSdk.newInstance]
  /// constructor to create a new instance.
  ///
  /// This constructor is synchronous, but internal initialization is handled
  /// asynchronously when needed.
  ///
  /// Defaults to a local instance unless [host] is provided.
  factory KomodoDefiSdk({
    IKdfHostConfig? host,
    KomodoDefiSdkConfig? config,
  }) {
    if (_instance != null && host != null && _instance!._hostConfig != host) {
      throw StateError(
        'KomodoDefiSdk is a singleton and has already been initialized.',
      );
    }
    return _instance ??= KomodoDefiSdk._(
      host,
      config ?? const KomodoDefiSdkConfig(),
    );
  }

  // KomodoDefiSdk get global => _instance!;

  /// Creates a new instance of the [KomodoDefiSdk] class.
  factory KomodoDefiSdk.newInstance({
    IKdfHostConfig? host,
    KomodoDefiSdkConfig? config,
  }) {
    return KomodoDefiSdk._(host, config ?? const KomodoDefiSdkConfig());
  }

  /// Creates a new instance of the [KomodoDefiSdk] class from an existing
  /// [KomodoDefiFramework] instance.
  ///
  /// This may be useful when wanting to create a new SDK instance from a
  /// pre-existing framework instance created in a different package/project.
  factory KomodoDefiSdk.fromFramework(
    KomodoDefiFramework framework, {
    KomodoDefiSdkConfig? config,
  }) {
    return _instance ??= KomodoDefiSdk._(
      null,
      config ?? const KomodoDefiSdkConfig(),
      framework,
    );
  }

  KomodoDefiSdk._(this._hostConfig, this._config, [this._kdfFramework]);

  final IKdfHostConfig? _hostConfig;
  final KomodoDefiSdkConfig _config;

  /// The global instance of the [KomodoDefiSdk].
  ///
  /// Avoid using this unless the SDK instance is not available in the context
  /// from which it is being accessed. This allows us to keep the flexibility
  /// for future expansions to support multiple SDK instances at once. However,
  /// there are no plans to support this at the moment, but it will reduce the
  /// work needed to support it in the future.
  static KomodoDefiSdk get global => _instance!;

  KomodoDefiFramework? _kdfFramework;

  // ignore: unused_field
  LogCallback? _logCallback;

  late KomodoDefiLocalAuth? _auth;
  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  late final ApiClient? _apiClient;
  ApiClient get client {
    if (!_isInitialized) {
      throw StateError(
        'KomodoDefiSdk is not initialized. Call initialize() or await ensureInitialized() first.',
      );
    }
    return _apiClient!;
  }

  KomodoDefiLocalAuth get auth {
    return _assertSdkInitialized(_auth);
  }

  T _assertSdkInitialized<T>(T? val) {
    if (!_isInitialized || val == null) {
      throw StateError(
        'KomodoDefiSdk is not initialized. Call initialize() or await ensureInitialized() first.',
      );
    }

    return val;
  }

  /// Explicitly initialize the [KomodoDefiSdk] instance.
  /// This method can be called to pre-initialize the SDK if desired.
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }

    _initializationFuture = _initialize();
    await _initializationFuture;
  }

  /// Ensures that the SDK is initialized before performing any operation.
  /// This method is called internally when needed, but can also be called
  /// explicitly if pre-initialization is desired.
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // TODO: Bootstrapper system with concurrency similar to KW
  Future<void> _initialize() async {
    final rpcPassword = await ensureRpcPassword();

    final hostConfig = _hostConfig ??
        LocalConfig(
          https: true,
          rpcPassword: rpcPassword,
        );

    // Ensure _kdfFramework is initialized
    _kdfFramework ??= KomodoDefiFramework.create(
      hostConfig: hostConfig,
      externalLogger: kDebugMode ? print : null,
    );

    _apiClient = _kdfFramework!.client;

    _auth = KomodoDefiLocalAuth(
      kdf: _kdfFramework!,
      hostConfig: hostConfig,
    );

    _assets = AssetManager(_apiClient!, _auth!, _config);

    _mnemonicValidator = MnemonicValidator();

    await Future.wait([
      _auth!.ensureInitialized(),
      _assets!.init(),
      _mnemonicValidator!.init(),
    ]);

    _isInitialized = true;
  }

  // Helper extension methods
  Future<AuthOptions?> currentUserAuthOptions() async {
    final user = await auth.currentUser;
    return user == null
        ? null
        : KomodoDefiLocalAuth.storedAuthOptions(user.walletId.name);
  }

  late final AssetManager? _assets;
  AssetManager get assets => _assertSdkInitialized(_assets);

  TransactionHistoryManager get transactions =>
      _assertSdkInitialized(_transactionHistory);
  late final TransactionHistoryManager _transactionHistory =
      TransactionHistoryManager(
    _apiClient!,
    _auth!,
  );

  late final PubkeyManager pubkeys = _assertSdkInitialized(
    PubkeyManager(_apiClient!),
  );

  late final MnemonicValidator? _mnemonicValidator;
  MnemonicValidator get mnemonicValidator =>
      _assertSdkInitialized(_mnemonicValidator);

  WithdrawalManager get withdrawals => _assertSdkInitialized(_withdrawals);
  late final WithdrawalManager _withdrawals = WithdrawalManager(_apiClient!);
}
