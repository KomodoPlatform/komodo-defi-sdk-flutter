import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'activation_params.freezed.dart';
part 'activation_params.g.dart';

/// Defines additional parameters used for activation. These params may vary depending
/// on the coin type.
///
/// Key parameters include:
/// - [requiredConfirmations]: Confirmations to wait for steps in swap
/// - [requiresNotarization]: For dPoW protected coins, waits for transactions to be notarized
/// - [privKeyPolicy]: Sets private key handling mode (default: ContextPrivKey)
/// - [minAddressesNumber]: For HD wallets, minimum additional addresses to generate
/// - [scanPolicy]: HD wallet address scanning behavior
/// - [gapLimit]: Maximum number of empty addresses in a row for HD wallets
/// - [mode]: Activation mode configuration for QTUM, UTXO & ZHTLC coins
///
/// For ZHTLC coins:
/// - [zcashParamsPath]: Path to Zcash parameters folder
/// - [scanBlocksPerIteration]: Number of blocks scanned per iteration (default: 1000)
/// - [scanIntervalMs]: Interval between scan iterations in ms (default: 0)
class ActivationParams implements RpcRequestParams {
  const ActivationParams({
    this.requiredConfirmations,
    this.requiresNotarization = false,
    this.privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
    this.minAddressesNumber,
    this.scanPolicy,
    this.gapLimit,
    this.mode,
    this.zcashParamsPath,
    this.scanBlocksPerIteration,
    this.scanIntervalMs,
  });

  /// Creates [ActivationParams] from configuration JSON
  factory ActivationParams.fromConfigJson(JsonMap json) {
    final mode = ActivationMode.fromConfig(
      json,
      type: ActivationModeType.electrum,
    );

    return ActivationParams(
      requiredConfirmations: json.valueOrNull<int>('required_confirmations'),
      requiresNotarization:
          json.valueOrNull<bool>('requires_notarization') ?? false,
      privKeyPolicy: PrivateKeyPolicy.fromLegacyJson(
        json.valueOrNull<dynamic>('priv_key_policy'),
      ),
      minAddressesNumber: json.valueOrNull<int>('min_addresses_number'),
      scanPolicy:
          json.valueOrNull<String>('scan_policy') == null
              ? null
              : ScanPolicy.parse(json.value<String>('scan_policy')),
      gapLimit: json.valueOrNull<int>('gap_limit'),
      mode: mode,
      zcashParamsPath: json.valueOrNull<String>('zcash_params_path'),
      scanBlocksPerIteration: json.valueOrNull<int>(
        'scan_blocks_per_iteration',
      ),
      scanIntervalMs: json.valueOrNull<int>('scan_interval_ms'),
    );
  }

  /// Optional. Number of confirmations to wait for during swap steps.
  /// Defaults to value in the coins file if not set.
  final int? requiredConfirmations;

  /// Optional, defaults to false. For dPoW protected coins, a true value will wait
  /// for transactions to be notarised when doing swaps.
  final bool requiresNotarization;

  /// Configuration for coin activation mode. Required for QTUM, UTXO & ZHTLC coins.
  final ActivationMode? mode;

  /// Whether to use Trezor hardware wallet or context private key.
  /// Defaults to ContextPrivKey.
  final PrivateKeyPolicy? privKeyPolicy;

  /// HD wallets only. How many additional addresses to generate at a minimum.
  final int? minAddressesNumber;

  /// HD wallets only. Whether or not to scan for new addresses.
  /// Note that 'scan' will result in multiple requests to the Komodo DeFi Framework.
  final ScanPolicy? scanPolicy;

  /// HD wallets only. The max number of empty addresses in a row.
  /// If transactions were sent to an address outside the gap_limit,
  /// they will not be identified when scanning.
  final int? gapLimit;

  /// ZHTLC coins only. Path to folder containing Zcash parameters.
  /// Optional, defaults to standard location.
  final String? zcashParamsPath;

  /// ZHTLC coins only. Sets the number of scanned blocks per iteration during
  /// BuildingWalletDb state. Optional, default value is 1000.
  final int? scanBlocksPerIteration;

  /// ZHTLC coins only. Sets the interval in milliseconds between iterations of
  /// BuildingWalletDb state. Optional, default value is 0.
  final int? scanIntervalMs;

  @override
  @mustCallSuper
  JsonMap toRpcParams() {
    return {
      if (requiredConfirmations != null)
        'required_confirmations': requiredConfirmations,
      'requires_notarization': requiresNotarization,
      // IMPORTANT: Serialization format varies by coin type:
      // - ETH/ERC20: Uses full JSON object format with type discrimination
      // - Other coins: Uses legacy PascalCase string format for backward compatibility
      // This difference is maintained for API compatibility reasons.
      'priv_key_policy':
          (privKeyPolicy ?? const PrivateKeyPolicy.contextPrivKey())
              .pascalCaseName,
      if (minAddressesNumber != null)
        'min_addresses_number': minAddressesNumber,
      if (scanPolicy != null) 'scan_policy': scanPolicy!.value,
      if (gapLimit != null) 'gap_limit': gapLimit,
      if (mode != null) 'mode': mode!.toJsonRequest(),
      if (zcashParamsPath != null) 'zcash_params_path': zcashParamsPath,
      if (scanBlocksPerIteration != null)
        'scan_blocks_per_iteration': scanBlocksPerIteration,
      if (scanIntervalMs != null) 'scan_interval_ms': scanIntervalMs,
    };
  }

  ActivationParams genericCopyWith({
    int? requiredConfirmations,
    bool? requiresNotarization,
    PrivateKeyPolicy? privKeyPolicy,
    int? minAddressesNumber,
    ScanPolicy? scanPolicy,
    int? gapLimit,
    ActivationMode? mode,
    String? zcashParamsPath,
    int? scanBlocksPerIteration,
    int? scanIntervalMs,
  }) {
    return ActivationParams(
      requiredConfirmations:
          requiredConfirmations ?? this.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? this.requiresNotarization,
      privKeyPolicy:
          privKeyPolicy ??
          this.privKeyPolicy ??
          const PrivateKeyPolicy.contextPrivKey(),
      minAddressesNumber: minAddressesNumber ?? this.minAddressesNumber,
      scanPolicy: scanPolicy ?? this.scanPolicy,
      gapLimit: gapLimit ?? this.gapLimit,
      mode: mode ?? this.mode,
      zcashParamsPath: zcashParamsPath ?? this.zcashParamsPath,
      scanBlocksPerIteration:
          scanBlocksPerIteration ?? this.scanBlocksPerIteration,
      scanIntervalMs: scanIntervalMs ?? this.scanIntervalMs,
    );
  }
}

/// Defines the private key policy for activation
/// API uses pascal case for PrivKeyPolicy types, so we use it as the
/// union key case to ensure compatibility with existing APIs.
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
abstract class PrivateKeyPolicy with _$PrivateKeyPolicy {
  /// Private constructor to allow for additional methods and properties
  const PrivateKeyPolicy._();

  /// Use context private key (default)
  const factory PrivateKeyPolicy.contextPrivKey() = _ContextPrivKey;

  /// Use Trezor hardware wallet
  const factory PrivateKeyPolicy.trezor() = _Trezor;

  /// Use MetaMask for activation. WASM (web) only.
  const factory PrivateKeyPolicy.metamask() = _Metamask;

  /// Use WalletConnect for hardware wallet activation
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PrivateKeyPolicy.walletConnect(String sessionTopic) =
      _WalletConnect;

  factory PrivateKeyPolicy.fromJson(Map<String, dynamic> json) =>
      _$PrivateKeyPolicyFromJson(json);

  /// Converts a string or map to a [PrivateKeyPolicy]
  /// Throws [ArgumentError] if the input is invalid
  /// If the input is null, defaults to [PrivateKeyPolicy.contextPrivKey]
  /// If the input is a string, it must match one of the known policy types.
  /// If the input is a map, it must contain a 'type' key with a valid policy type.
  /// If the input is a map with a 'session_topic' key, it will be used for
  /// [PrivateKeyPolicy.walletConnect].
  factory PrivateKeyPolicy.fromLegacyJson(dynamic privKeyPolicy) {
    if (privKeyPolicy == null) {
      return const PrivateKeyPolicy.contextPrivKey();
    }

    if (privKeyPolicy is Map && privKeyPolicy['type'] != null) {
      return PrivateKeyPolicy.fromJson(privKeyPolicy as JsonMap);
    }

    if (privKeyPolicy is! String) {
      throw ArgumentError(
        'Invalid private key policy type: ${privKeyPolicy.runtimeType}',
      );
    }

    switch (privKeyPolicy) {
      case 'ContextPrivKey':
      case 'context_priv_key':
        return const PrivateKeyPolicy.contextPrivKey();
      case 'Trezor':
      case 'trezor':
        return const PrivateKeyPolicy.trezor();
      case 'Metamask':
      case 'metamask':
        return const PrivateKeyPolicy.metamask();
      case 'WalletConnect':
      case 'wallet_connect':
        return const PrivateKeyPolicy.walletConnect('');
      default:
        throw ArgumentError('Unknown private key policy type: $privKeyPolicy');
    }
  }

  /// Returns the PascalCase name of the private key policy type
  ///
  /// Examples:
  /// - `PrivateKeyPolicy.contextPrivKey()` → `"ContextPrivKey"`
  /// - `PrivateKeyPolicy.trezor()` → `"Trezor"`
  /// - `PrivateKeyPolicy.metamask()` → `"Metamask"`
  /// - `PrivateKeyPolicy.walletConnect(...)` → `"WalletConnect"`
  String get pascalCaseName {
    switch (runtimeType) {
      case _ContextPrivKey:
        return 'ContextPrivKey';
      case _Trezor:
        return 'Trezor';
      case _Metamask:
        return 'Metamask';
      case _WalletConnect:
        return 'WalletConnect';
      default:
        // Fallback: convert snake_case from JSON to PascalCase
        final snakeCaseType = toJson()['type'] as String;
        return snakeCaseType
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join();
    }
  }
}

/// Defines the type of activation mode for QTUM, UTXO & ZHTLC coins
enum ActivationModeType {
  /// Use Electrum servers for activation
  electrum,

  /// Use native blockchain node
  native,

  /// Use light wallet mode (ZHTLC coins only)
  lightWallet;

  String get value {
    switch (this) {
      case ActivationModeType.electrum:
        return 'Electrum';
      case ActivationModeType.native:
        return 'Native';
      case ActivationModeType.lightWallet:
        return 'Light';
    }
  }
}

/// Defines the activation mode for QTUM, BCH, UTXO & ZHTLC coins
class ActivationMode {
  ActivationMode({required this.rpc, this.rpcData})
    : assert(
        (rpc != ActivationModeType.native.value && rpcData != null) ||
            (rpc == ActivationModeType.native.value && rpcData == null),
        'rpcData can only be provided for LightWallet or Electrum modes',
      );

  /// Creates an [ActivationMode] from configuration JSON
  factory ActivationMode.fromConfig(
    JsonMap json, {
    required ActivationModeType type,
  }) {
    return ActivationMode(
      rpc: type.value,
      rpcData:
          type == ActivationModeType.native
              ? null
              : ActivationRpcData.fromJson(json),
    );
  }

  /// RPC mode: 'Native' for running a native blockchain node, 'Electrum' for using
  /// electrum servers, or 'Light' for ZHTLC coins
  final String rpc;

  /// Configuration data for Electrum or Light mode
  final ActivationRpcData? rpcData;

  JsonMap toJsonRequest() => {
    'rpc': rpc,
    if (rpcData != null) 'rpc_data': rpcData!.toJsonRequest(),
  };
}

/// Defines how to scan for new addresses in HD wallets
enum ScanPolicy {
  /// Do not scan for new addresses
  doNotScan,

  /// Only scan if this is a new wallet
  scanIfNewWallet,

  /// Always scan for new addresses (will result in multiple API requests)
  scan;

  static Set<String> get validPolicies => {
    'do_not_scan',
    'scan_if_new_wallet',
    'scan',
  };

  static bool isValidScanPolicy(String policy) =>
      validPolicies.contains(policy);

  /// Parses a string into a [ScanPolicy]
  /// Throws [ArgumentError] if the policy string is invalid
  static ScanPolicy parse(String policy) {
    if (!isValidScanPolicy(policy)) {
      throw ArgumentError.value(policy, 'policy', 'Invalid scan policy');
    }

    switch (policy) {
      case 'do_not_scan':
        return ScanPolicy.doNotScan;
      case 'scan_if_new_wallet':
        return ScanPolicy.scanIfNewWallet;
      case 'scan':
        return ScanPolicy.scan;
      default:
        throw ArgumentError.value(policy, 'policy', 'Invalid scan policy');
    }
  }

  /// Attempts to parse a string into a [ScanPolicy]
  /// Returns null if the input is null or invalid
  static ScanPolicy? tryParse(String? policy) {
    if (policy == null) {
      return null;
    }

    return parse(policy);
  }

  String get value {
    switch (this) {
      case ScanPolicy.doNotScan:
        return 'do_not_scan';
      case ScanPolicy.scanIfNewWallet:
        return 'scan_if_new_wallet';
      case ScanPolicy.scan:
        return 'scan';
    }
  }
}

/// Contains information about electrum & lightwallet_d servers for coins being used
/// in 'Electrum' or 'Light' mode
class ActivationRpcData {
  ActivationRpcData({this.lightWalletDServers, this.electrum, this.syncParams});

  /// Creates [ActivationRpcData] from JSON configuration
  factory ActivationRpcData.fromJson(JsonMap json) {
    return ActivationRpcData(
      lightWalletDServers:
          json
              .valueOrNull<List<dynamic>>('light_wallet_d_servers')
              ?.cast<String>(),
      electrum:
          json
              .valueOrNull<List<dynamic>>('electrum')
              ?.map((e) => ActivationServers.fromJsonConfig(e as JsonMap))
              .toList(),
      syncParams: json.valueOrNull<dynamic>('sync_params'),
    );
  }

  /// ZHTLC only. A list of urls which are hosting lightwallet_d servers for a coin
  final List<String>? lightWalletDServers;

  /// List of electrum servers for QTUM, BCH & UTXO coins
  final List<ActivationServers>? electrum;

  /// ZHTLC coins only. Optional, defaults to two days ago. Defines where to start
  /// scanning blockchain data upon initial activation.
  /// Options:
  /// - "earliest" (the coin's sapling_activation_height)
  /// - height (a specific block height)
  /// - date (a unix timestamp)
  final dynamic syncParams;

  bool get isEmpty => [lightWalletDServers, electrum, syncParams].every(
    (element) =>
        element == null &&
        (element is List && element.isEmpty ||
            element is Map && element.isEmpty),
  );

  JsonMap toJsonRequest() => {
    if (lightWalletDServers != null)
      'light_wallet_d_servers': lightWalletDServers,
    if (electrum != null) ...{
      'servers': electrum!.map((e) => e.toJsonRequest()).toList(),
    },
    if (syncParams != null) 'sync_params': syncParams,
  };
}

/// Contains information about electrum servers for coins being used in 'Electrum'
/// or 'Light' mode
class ActivationServers {
  ActivationServers({
    required this.url,
    this.wsUrl,
    this.protocol = 'TCP',
    this.disableCertVerification = false,
  });

  /// Creates [ActivationServers] from JSON configuration
  factory ActivationServers.fromJsonConfig(JsonMap json) {
    return ActivationServers(
      url: json.value<String>('url'),
      wsUrl: json.valueOrNull<String>('ws_url'),
      protocol: json.valueOrNull<String>('protocol') ?? 'TCP',
      disableCertVerification:
          json.valueOrNull<bool>('disable_cert_verification') ?? false,
    );
  }

  /// The URL and port for an electrum server
  final String url;

  /// Optional, for WSS only. The URL and port for an electrum server's WSS port
  final String? wsUrl;

  /// Optional, defaults to 'TCP'. Transport protocol used to connect to the server.
  /// Options: 'TCP' or 'SSL'
  final String protocol;

  /// Optional, defaults to false. If true, disables server SSL/TLS certificate
  /// verification (e.g. for self-signed certificates).
  /// WARNING: Use at your own risk!
  final bool disableCertVerification;

  JsonMap toJsonRequest() => {
    'url': url,
    if (wsUrl != null) 'ws_url': wsUrl,
    'protocol': protocol,
    'disable_cert_verification': disableCertVerification,
  };
}
