import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/addresses/address_operations.dart';
import 'package:komodo_defi_sdk/src/message_signing/message_signing_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/sdk/komodo_defi_sdk_config.dart';
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

  KomodoDefiSdk._(this._hostConfig, this._config, this._kdfFramework);

  final IKdfHostConfig? _hostConfig;
  final KomodoDefiSdkConfig _config;
  KomodoDefiFramework? _kdfFramework;

  // Private nullable fields
  ApiClient? _apiClient;
  LogCallback? _logCallback;
  KomodoDefiLocalAuth? _auth;
  AssetManager? _assets;
  PubkeyManager? _pubkeys;
  AddressOperations? _addresses;
  MnemonicValidator? _mnemonicValidator;
  TransactionHistoryManager? _transactionHistory;
  WithdrawalManager? _withdrawals;
  MessageSigningManager? _messageSigning;
  BalanceManager? _balances;

  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  /// The API client for making direct RPC calls.
  ///
  /// While the SDK provides high-level abstractions for most operations,
  /// the client can be used for direct API access when needed.
  ///
  /// Throws [StateError] if accessed before initialization.
  ApiClient get client => _assertSdkInitialized(_apiClient);

  /// The authentication manager instance.
  ///
  /// Handles user authentication, wallet management, and session state.
  ///
  /// Throws [StateError] if accessed before initialization.
  KomodoDefiLocalAuth get auth => _assertSdkInitialized(_auth);

  /// The pubkey manager instance.
  ///
  /// Handles generation and management of addresses for assets.
  ///
  /// Throws [StateError] if accessed before initialization.
  PubkeyManager get pubkeys => _assertSdkInitialized(_pubkeys);

  /// The address operations instance.
  ///
  /// Provides functionality for address validation and format conversion.
  ///
  /// Throws [StateError] if accessed before initialization.
  AddressOperations get addresses => _assertSdkInitialized(_addresses);

  /// The asset manager instance.
  ///
  /// Handles coin/token activation and configuration.
  ///
  /// Throws [StateError] if accessed before initialization.
  AssetManager get assets => _assertSdkInitialized(_assets);

  /// The transaction history manager instance.
  ///
  /// Manages transaction history and monitoring.
  ///
  /// Throws [StateError] if accessed before initialization.
  TransactionHistoryManager get transactions =>
      _assertSdkInitialized(_transactionHistory);

  /// The message signing manager instance.
  ///
  /// Provides functionality to sign and verify messages using cryptocurrencies.
  ///
  /// Throws [StateError] if accessed before initialization.
  MessageSigningManager get messageSigning =>
      _assertSdkInitialized(_messageSigning);

  T _assertSdkInitialized<T>(T? val) {
    if (!_isInitialized || val == null) {
      throw StateError(
        'Cannot call ${val.runtimeType} because KomodoDefiSdk is not '
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
      _assertSdkInitialized(_mnemonicValidator);

  /// The withdrawal manager instance.
  ///
  /// Handles asset withdrawal operations.
  ///
  /// Throws [StateError] if accessed before initialization.
  WithdrawalManager get withdrawals => _assertSdkInitialized(_withdrawals);

  /// Gets a reference to the balance manager for checking asset balances
  BalanceManager get balances {
    if (_balances == null) {
      throw StateError(
        'SDK has not been initialized. Call initialize() first.',
      );
    }
    return _balances!;
  }

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
    final rpcPassword = await ensureRpcPassword();

    final hostConfig =
        _hostConfig ?? LocalConfig(https: true, rpcPassword: rpcPassword);

    _kdfFramework ??= KomodoDefiFramework.create(
      hostConfig: hostConfig,
      externalLogger: kDebugMode ? print : null,
    );

    _apiClient = _kdfFramework!.client;

    // Initialize auth first as other managers depend on it
    _auth = KomodoDefiLocalAuth(kdf: _kdfFramework!, hostConfig: hostConfig);
    await _auth!.ensureInitialized();

    // Initialize asset history storage for sharing between managers
    final assetHistory = AssetHistoryStorage();
    final customAssetHistory = CustomAssetHistoryStorage();

    // Initialize asset manager first as it implements IAssetLookup
    _assets = AssetManager(
      _apiClient!,
      _auth!,
      _config,
      assetHistory,
      customAssetHistory,
    );
    await _assets!.init();

    // Initialize activation manager with asset lookup capabilities
    final activationManager = ActivationManager(
      _apiClient!,
      _auth!,
      assetHistory,
      customAssetHistory,
      _assets!,
    );

    // Set activation manager in AssetManager to complete circular dependency
    _assets!.setActivationManager(activationManager);

    // Initialize remaining managers with proper dependencies
    _pubkeys = PubkeyManager(_apiClient!, _auth!, _assets!);
    _addresses = AddressOperations(_apiClient!);
    _mnemonicValidator = MnemonicValidator();
    await _mnemonicValidator!.init();

    // Initialize balance manager
    _balances = BalanceManager(
      _apiClient!,
      activationManager,
      _assets!,
      _auth!,
    );

    // Initialize managers that work with transactions
    _transactionHistory = TransactionHistoryManager(
      _apiClient!,
      _auth!,
      _assets!,
      pubkeyManager: _pubkeys!,
    );

    // Initialize withdrawal manager last as it depends on asset activation
    _withdrawals = WithdrawalManager(_apiClient!, _auth!, _assets!);

    _messageSigning = MessageSigningManager(_apiClient!);

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

    // Dispose managers in reverse order of initialization
    await _withdrawals?.dispose();
    await _transactionHistory?.dispose();
    await _pubkeys?.dispose();
    await _assets?.dispose();
    await _auth?.dispose();
    await _balances?.dispose();

    // Clear references to managers
    _withdrawals = null;
    _transactionHistory = null;
    _messageSigning = null;
    _pubkeys = null;
    _assets = null;
    _auth = null;
    _balances = null;

    // Clean up framework
    if (_kdfFramework != null) {
      await _kdfFramework!.dispose();
      _kdfFramework = null;
    }
  }
}
