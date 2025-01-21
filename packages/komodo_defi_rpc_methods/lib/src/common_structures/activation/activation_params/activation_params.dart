import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:meta/meta.dart';

class ActivationParams implements KdfRequestParams {
  const ActivationParams({
    this.requiredConfirmations,
    this.requiresNotarization = false,
    this.privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
    this.minAddressesNumber,
    this.scanPolicy,
    this.gapLimit,
    this.mode,
    this.zcashParamsPath,
    this.scanBlocksPerIteration,
    this.scanIntervalMs,
  });

  /// Factory to create ActivationParams from JSON
  factory ActivationParams.fromConfigJson(JsonMap json) {
    final mode =
        ActivationMode.fromConfig(json, type: ActivationModeType.electrum);
    return ActivationParams(
      requiredConfirmations: json.valueOrNull<int>('required_confirmations'),
      requiresNotarization:
          json.valueOrNull<bool>('requires_notarization') ?? false,
      privKeyPolicy: json.valueOrNull<String>('priv_key_policy') == 'Trezor'
          ? PrivateKeyPolicy.trezor
          : PrivateKeyPolicy.contextPrivKey,
      minAddressesNumber: json.valueOrNull<int>('min_addresses_number'),
      scanPolicy: json.valueOrNull<String>('scan_policy') == null
          ? null
          : ScanPolicy.parse(json.value<String>('scan_policy')),
      gapLimit: json.valueOrNull<int>('gap_limit'),
      mode: mode,
      // ZHTLC specific params
      zcashParamsPath: json.valueOrNull<String>('zcash_params_path'),
      scanBlocksPerIteration:
          json.valueOrNull<int>('scan_blocks_per_iteration'),
      scanIntervalMs: json.valueOrNull<int>('scan_interval_ms'),
    );
  }

  final int? requiredConfirmations;
  final bool requiresNotarization;

  final ActivationMode? mode;

  /// Whether to use Trezor hardware wallet or context private key
  /// Defaults to ContextPrivKey
  final PrivateKeyPolicy privKeyPolicy;

  /// How many additional addreesses to generate at a minimum
  final int? minAddressesNumber;

  /// Whether or not to scan for new addresses
  /// Options: 'do_not_scan', 'scan_if_new_wallet' or 'scan'
  final ScanPolicy? scanPolicy;

  /// The max number of empty addresses in a row
  /// If transactions were sent to an address outside the gap_limit,
  /// they will not be identified when scanning
  final int? gapLimit;

  // ZHTLC specific params
  final String? zcashParamsPath;
  final int? scanBlocksPerIteration;
  final int? scanIntervalMs;

  @override
  @mustCallSuper
  JsonMap toJsonRequestParams() {
    return {
      if (requiredConfirmations != null)
        'required_confirmations': requiredConfirmations,
      'requires_notarization': requiresNotarization,
      'priv_key_policy': privKeyPolicy.id,
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
      privKeyPolicy: privKeyPolicy ?? this.privKeyPolicy,
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

enum PrivateKeyPolicy {
  contextPrivKey,
  trezor;

  String get id {
    switch (this) {
      case PrivateKeyPolicy.contextPrivKey:
        return 'ContextPrivKey';
      case PrivateKeyPolicy.trezor:
        return 'Trezor';
    }
  }
}

enum ActivationModeType {
  electrum,
  native,
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

class ActivationMode {
  ActivationMode({
    required this.rpc,
    this.rpcData,
  }) : assert(
          // If rpc is not native, rpcData must be provided. And if rpcData is provided, rpc must not be native
          (rpc != ActivationModeType.native.value && rpcData != null) ||
              (rpc == ActivationModeType.native.value && rpcData == null),
          'rpcData can only be provided for LightWallet or Electrum modes',
        );

  factory ActivationMode.fromConfig(
    JsonMap json, {
    required ActivationModeType type,
  }) {
    return ActivationMode(
      rpc: type.value,
      rpcData: type == ActivationModeType.native
          ? null
          : ActivationRpcData.fromJson(json),
    );
  }

  final String rpc;
  final ActivationRpcData? rpcData;

  JsonMap toJsonRequest() => {
        'rpc': rpc,
        if (rpcData != null) 'rpc_data': rpcData!.toJsonRequest(),
      };
}

enum ScanPolicy {
  doNotScan,
  scanIfNewWallet,
  scan;

  static Set<String> get validPolicies => {
        'do_not_scan',
        'scan_if_new_wallet',
        'scan',
      };

  static bool isValidScanPolicy(String policy) =>
      validPolicies.contains(policy);

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

/// Parser for activation RPC data
class ActivationRpcData {
  ActivationRpcData({
    this.lightWalletDServers,
    // this.electrumServers,
    this.electrum,
    this.syncParams,
  });

  factory ActivationRpcData.fromJson(JsonMap json) {
    return ActivationRpcData(
      lightWalletDServers: json
          .valueOrNull<List<dynamic>>('light_wallet_d_servers')
          ?.cast<String>(),
      // electrumServers: json
      //     .valueOrNull<List<dynamic>>('electrum_servers')
      //     ?.map((e) => ActivationServers.fromJsonConfig(e as JsonMap))
      //     .toList(),
      electrum: json
          .valueOrNull<List<dynamic>>('electrum')
          ?.map((e) => ActivationServers.fromJsonConfig(e as JsonMap))
          .toList(),
      syncParams: json.valueOrNull<dynamic>('sync_params'),
    );
  }

  final List<String>? lightWalletDServers;
  // final List<ActivationServers>? electrumServers;
  final List<ActivationServers>? electrum;
  final dynamic syncParams;

  bool get isEmpty => [
        lightWalletDServers,
        // electrumServers,
        electrum,
        syncParams,
      ].every(
        (element) =>
            element == null &&
            (element is List && element.isEmpty ||
                element is Map && element.isEmpty),
      );

  JsonMap toJsonRequest() => {
        if (lightWalletDServers != null)
          'light_wallet_d_servers': lightWalletDServers,
        // if (electrumServers != null)
        //   'servers': electrumServers!.map((e) => e.toJsonRequest()).toList(),
        if (electrum != null) ...{
          'servers': electrum!.map((e) => e.toJsonRequest()).toList(),
        },

        if (syncParams != null) 'sync_params': syncParams,
      };
}

class ActivationServers {
  ActivationServers({
    required this.url,
    this.wsUrl,
    this.protocol = 'TCP',
    this.disableCertVerification = false,
  });

  factory ActivationServers.fromJsonConfig(JsonMap json) {
    return ActivationServers(
      url: json.value<String>('url'),
      wsUrl: json.valueOrNull<String>('ws_url'),
      protocol: json.valueOrNull<String>('protocol') ?? 'TCP',
      disableCertVerification:
          json.valueOrNull<bool>('disable_cert_verification') ?? false,
    );
  }

  final String url;
  final String? wsUrl;
  final String protocol;
  final bool disableCertVerification;

  JsonMap toJsonRequest() => {
        'url': url,
        if (wsUrl != null) 'ws_url': wsUrl,
        'protocol': protocol,
        'disable_cert_verification': disableCertVerification,
      };
}
