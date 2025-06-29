import 'package:get_it/get_it.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/bootstrap.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_sdk/src/message_signing/message_signing_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A high-level SDK that provides a simple way to build cross-platform applications
/// using the Komodo DeFi Framework, with a primary focus on wallet functionality.
///
/// The SDK provides an intuitive abstraction layer over the underlying Komodo DeFi
/// Framework API, handling binary/media file fetching, authentication, asset management,
/// and other core wallet functionality.
///
/// ## Getting Started
///
/// Create and initialize a new SDK instance:
///
/// ```dart
/// final sdk = KomodoDefiSdk();
/// await sdk.initialize();
/// ```
///
/// Or with custom configuration:
///
/// ```dart
/// final sdk = KomodoDefiSdk(
///   host: RemoteConfig(
///     userpass: 'your-password',
///     ipAddress: 'https://your-server.com',
///     port: 7783
///   ),
///   config: KomodoDefiSdkConfig(
///     defaultAssets: {'KMD', 'BTC'},
///     preActivateDefaultAssets: true
///   )
/// );
/// await sdk.initialize();
/// ```
///
/// ## Core Features
///
/// The SDK provides access to several core managers:
///
/// * [auth] - Handles user authentication and wallet management
/// * [assets] - Manages coin/token activation and configuration
/// * [pubkeys] - Handles address generation and management
/// * [transactions] - Manages transaction history and monitoring
/// * [withdrawals] - Handles asset withdrawal operations
/// * [addresses] - Provides address validation and format conversion
///
/// ## Usage Example
///
/// Here's a basic example showing how to authenticate and activate an asset:
///
/// ```dart
/// // Initialize SDK
/// final sdk = KomodoDefiSdk();
/// await sdk.initialize();
///
/// // Sign in user
/// await sdk.auth.signIn(
///   password: 'user-password',
///   walletId: WalletId('my-wallet')
/// );
///
/// // Activate Bitcoin
/// final btc = sdk.assets.findAssetsByTicker('BTC').first;
/// await sdk.assets.activateAsset(btc).last;
///
/// // Get addresses
/// final addresses = await sdk.pubkeys.getPubkeys(btc);
/// print('BTC Addresses: ${addresses.keys.map((k) => k.address).join(", ")}');
/// ```
///
/// ## Cleanup
///
/// Be sure to dispose of the SDK when it's no longer needed:
///
/// ```dart
/// await sdk.dispose();
/// ```
///
/// This will clean up all resources and stop any background operations.
class KomodoDefiSdk with SecureRpcPasswordMixin {
  /// Creates a new instance of [KomodoDefiSdk] with optional host configuration
  /// and SDK configuration.
  ///
  /// If [host] is not provided, defaults to local configuration.
  /// If [config] is not provided, uses default configuration.
  ///
  /// Example:
  /// ```dart
  /// final sdk = KomodoDefiSdk(
  ///   host: RemoteConfig(
  ///     userpass: 'password',
  ///     ipAddress: 'https://example.com',
  ///     port: 7783
  ///   )
  /// );
  /// ```
  factory KomodoDefiSdk({IKdfHostConfig? host, KomodoDefiSdkConfig? config}) {
    return KomodoDefiSdk._(host, config ?? const KomodoDefiSdkConfig(), null);
  }

  /// Creates a new SDK instance from an existing KDF framework instance.
  ///
  /// This is useful when you already have a configured framework instance
  /// and want to use it with the SDK.
  ///
  /// Example:
  /// ```dart
  /// final framework = KomodoDefiFramework.create(...);
  /// final sdk = KomodoDefiSdk.fromFramework(framework);
  /// ```
  factory KomodoDefiSdk.fromFramework(
    KomodoDefiFramework framework, {
    KomodoDefiSdkConfig? config,
  }) {
    return KomodoDefiSdk._(
      null,
      config ?? const KomodoDefiSdkConfig(),
      framework,
    );
  }

  KomodoDefiSdk._(this._hostConfig, this._config, this._kdfFramework) {
    _container = GetIt.asNewInstance();
  }

  final IKdfHostConfig? _hostConfig;
  final KomodoDefiSdkConfig _config;
  KomodoDefiFramework? _kdfFramework;
  late final GetIt _container;
  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  /// The API client for making direct RPC calls.
  ///
  /// While the SDK provides high-level abstractions for most operations,
  /// the client can be used for direct API access when needed.
  ///
  /// Throws [StateError] if accessed before initialization.
  ApiClient get client => _assertSdkInitialized(_container<ApiClient>());

  /// The authentication manager instance.
  ///
  /// Handles user authentication, wallet management, and session state.
  ///
  /// Throws [StateError] if accessed before initialization.
  KomodoDefiLocalAuth get auth =>
      _assertSdkInitialized(_container<KomodoDefiLocalAuth>());

  /// The pubkey manager instance.
  ///
  /// Handles generation and management of addresses for assets.
  ///
  /// Throws [StateError] if accessed before initialization.
  PubkeyManager get pubkeys =>
      _assertSdkInitialized(_container<PubkeyManager>());

  /// The address operations instance.
  ///
  /// Provides functionality for address validation and format conversion.
  ///
  /// Throws [StateError] if accessed before initialization.
  AddressOperations get addresses =>
      _assertSdkInitialized(_container<AddressOperations>());

  /// The asset manager instance.
  ///
  /// Handles coin/token activation and configuration.
  ///
  /// Throws [StateError] if accessed before initialization.
  AssetManager get assets => _assertSdkInitialized(_container<AssetManager>());

  /// The transaction history manager instance.
  ///
  /// Manages transaction history and monitoring.
  ///
  /// Throws [StateError] if accessed before initialization.
  TransactionHistoryManager get transactions =>
      _assertSdkInitialized(_container<TransactionHistoryManager>());

  /// The message signing manager instance.
  ///
  /// Provides functionality to sign and verify messages using cryptocurrencies.
  ///
  /// Throws [StateError] if accessed before initialization.
  MessageSigningManager get messageSigning =>
      _assertSdkInitialized(_container<MessageSigningManager>());

  T _assertSdkInitialized<T>(T val) {
    if (!_isInitialized) {
      throw StateError(
        'Cannot call $T because KomodoDefiSdk is not '
        'initialized. Call initialize() or await ensureInitialized() first.',
      );
    }
    return val;
  }

  /// The mnemonic validator instance.
  ///
  /// Provides functionality for validating BIP39 mnemonics.
  ///
  /// Throws [StateError] if accessed before initialization.
  MnemonicValidator get mnemonicValidator =>
      _assertSdkInitialized(_container<MnemonicValidator>());

  /// The withdrawal manager instance.
  ///
  /// Handles asset withdrawal operations.
  ///
  /// Throws [StateError] if accessed before initialization.
  WithdrawalManager get withdrawals =>
      _assertSdkInitialized(_container<WithdrawalManager>());

  /// The price manager instance.
  ///
  /// Provides functionality for fetching asset prices.
  ///
  /// Throws [StateError] if accessed before initialization.
  MarketDataManager get marketData =>
      _assertSdkInitialized(_container<MarketDataManager>());

  /// Gets a reference to the balance manager for checking asset balances.
  ///
  /// Provides functionality for checking and monitoring asset balances.
  ///
  /// Throws [StateError] if accessed before initialization.
  BalanceManager get balances =>
      _assertSdkInitialized(_container<BalanceManager>());

  /// Initializes the SDK instance.
  ///
  /// This must be called before using any SDK functionality. The initialization
  /// process sets up all required managers and establishes necessary connections.
  ///
  /// If the SDK is already initialized, this method returns immediately.
  ///
  /// Example:
  /// ```dart
  /// final sdk = KomodoDefiSdk();
  /// await sdk.initialize();
  /// ```
  Future<void> initialize() async {
    if (_isInitialized) return;
    _initializationFuture ??= _initialize();
    await _initializationFuture;
  }

  /// Ensures the SDK is initialized before performing any operation.
  ///
  /// This is a convenience method that can be used instead of [initialize]
  /// when you're not sure if the SDK has already been initialized.
  ///
  /// Example:
  /// ```dart
  /// await sdk.ensureInitialized();
  /// // Now safe to use SDK functionality
  /// ```
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _initialize() async {
    await bootstrap(
      hostConfig: _hostConfig,
      config: _config,
      kdfFramework: _kdfFramework,
      container: _container,
    );
    _isInitialized = true;
  }

  /// Gets the current user's authentication options.
  ///
  /// Returns null if no user is currently authenticated.
  ///
  /// Example:
  /// ```dart
  /// final options = await sdk.currentUserAuthOptions();
  /// if (options != null) {
  ///   print('Current derivation method: ${options.derivationMethod}');
  /// }
  /// ```
  Future<AuthOptions?> currentUserAuthOptions() async {
    _assertSdkInitialized(auth);
    final user = await auth.currentUser;
    return user == null
        ? null
        : KomodoDefiLocalAuth.storedAuthOptions(user.walletId.name);
  }

  /// Disposes of this SDK instance and cleans up all resources.
  ///
  /// This should be called when the SDK is no longer needed to ensure
  /// proper cleanup of resources and background operations.
  ///
  /// Example:
  /// ```dart
  /// await sdk.dispose();
  /// ```
  Future<void> dispose() async {
    if (!_isInitialized) return;
    _isInitialized = false;

    // Reset scoped container
    await _container.reset();

    // Clean up framework if we created it
    if (_kdfFramework != null) {
      await _kdfFramework!.dispose();
      _kdfFramework = null;
    }
  }
}
