import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/client/kdf_api_client.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A high-level opinionated library that provides a simple way to build
/// cross-platform Komodo Defi Framework applications (primarily focused on
/// wallets).
///
/// Must be initialized before calling any other method in the [KomodoDefiSdk]
/// class.
class KomodoDefiSdk {
  /// Creates a new instance of the [KomodoDefiSdk] class.
  ///
  /// Must be initialized before calling any other method in the [KomodoDefiSdk]
  /// class.
  ///
  /// Defaults to a local instance unless [host] is provided.
  ///
  /// NB: This is not a singleton class. [TODO: elaborate on this]
  factory KomodoDefiSdk({IKdfHostConfig? host}) => KomodoDefiSdk._default(host);

  factory KomodoDefiSdk._default(IKdfHostConfig? hostConfig) {
    final rpcPassword = SecurityUtils.generatePasswordSecure(16);
    final kdf = KomodoDefiFramework.create(
      hostConfig: hostConfig ??
          LocalConfig(
            https: true,
            rpcPassword: rpcPassword,
          ),
      externalLogger: kDebugMode ? print : null,
    );
    final apiClient = KdfApiClient(kdf);

    return KomodoDefiSdk._(
      logCallback: kDebugMode ? print : null,
      apiClient: apiClient,
      kdfFramework: kdf,
    );
  }

  KomodoDefiSdk._({
    required LogCallback? logCallback,
    required ApiClient apiClient,
    required KomodoDefiFramework kdfFramework,
  })  : _logCallback = logCallback,
        _apiClient = apiClient,
        _kdfFramework = kdfFramework;

  KomodoDefiFramework _kdfFramework;

  ApiClient _apiClient;

  final LogCallback? _logCallback;
  // final IKdfHostConfig? _hostConfig;

  bool _isInitialized = false;

  /// Return a new instance of the [KomodoDefiLocalAuth] class.
  ///
  /// This class provides an abstraction layer on top of the
  /// [KomodoDefiFramework] class to provide a simple way to authenticate
  /// resembling a typical authentication service.
  late final KomodoDefiLocalAuth auth = KomodoDefiLocalAuth(
    kdf: _kdfFramework,
  );

  /// Initialize the [KomodoDefiSdk] instance.
  /// This method must be called before any other method in the [KomodoDefiSdk]
  /// class.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await auth.ensureInitialized();

    _isInitialized = true;
  }
}
