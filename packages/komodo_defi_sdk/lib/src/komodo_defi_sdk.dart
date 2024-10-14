import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/assets/assets.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Export coin activation extension
export 'package:komodo_defi_sdk/src/assets/assets.dart'
    show
        // ApiClientCoinActivation,
        AssetActivation;

/// A high-level opinionated library that provides a simple way to build
/// cross-platform Komodo Defi Framework applications (primarily focused on
/// wallets).
class KomodoDefiSdk with SecureRpcPasswordMixin {
  /// Creates a new instance of the [KomodoDefiSdk] class.
  ///
  /// This constructor is synchronous, but internal initialization is handled
  /// asynchronously when needed.
  ///
  /// Defaults to a local instance unless [host] is provided.
  ///
  /// NB: This is not a singleton class. [TODO: elaborate on this]
  factory KomodoDefiSdk({IKdfHostConfig? host}) {
    return KomodoDefiSdk._(host);
  }

  KomodoDefiSdk._(this._hostConfig);

  late final IKdfHostConfig? _hostConfig;
  late final KomodoDefiFramework? _kdfFramework;
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

    // TODO!: Pass in Komodo coin config to KDF instance?

    _kdfFramework = KomodoDefiFramework.create(
      hostConfig: hostConfig,
      externalLogger: kDebugMode ? print : null,
    );

    _apiClient = _kdfFramework!.client;

    _auth = KomodoDefiLocalAuth(
      kdf: _kdfFramework,
      hostConfig: hostConfig,
    );

    // TODO: Log storage
    _logCallback = kDebugMode ? print : null;

    await _auth!.ensureInitialized();

    _assets = AssetManager(_apiClient!, _auth!);
    await _assets!.init();

    _isInitialized = true;
  }

  AssetManager get assets => _assertSdkInitialized(_assets);
  AssetManager? _assets;

  late final PubkeyManager pubkeys =
      _assertSdkInitialized(PubkeyManager(client));
  // PubkeyManager? _pubkeyManager;
}

/// RPC library extension of API client
extension KomodoDefiSdkRpc on ApiClient {
  KomodoDefiRpcMethods get rpc => KomodoDefiRpcMethods(this);
}
