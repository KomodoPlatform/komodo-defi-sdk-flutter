import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// ZHTLC activation parameters
///
/// Extends [ActivationParams] to ensure correct Light wallet mode is used
/// and that ZHTLC-specific defaults are applied.
class ZhtlcActivationParams extends ActivationParams {
  const ZhtlcActivationParams({
    required super.mode,
    super.requiredConfirmations,
    super.requiresNotarization = false,
    super.privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
    super.minAddressesNumber,
    super.scanPolicy,
    super.gapLimit,
    this.zcashParamsPath,
    this.scanBlocksPerIteration,
    this.scanIntervalMs,
  });

  factory ZhtlcActivationParams.fromConfigJson(JsonMap json) {
    // ZHTLC coins use Light wallet mode
    final mode = ActivationMode.fromConfig(
      json,
      type: ActivationModeType.lightWallet,
    );

    final base = ActivationParams.fromConfigJson(json);

    return ZhtlcActivationParams(
      mode: mode,
      requiredConfirmations: base.requiredConfirmations,
      requiresNotarization: base.requiresNotarization,
      privKeyPolicy: base.privKeyPolicy,
      minAddressesNumber: base.minAddressesNumber,
      scanPolicy: base.scanPolicy,
      gapLimit: base.gapLimit,
      zcashParamsPath: json.valueOrNull<String>('zcash_params_path'),
      scanBlocksPerIteration: json.valueOrNull<int>(
        'scan_blocks_per_iteration',
      ),
      scanIntervalMs: json.valueOrNull<int>('scan_interval_ms'),
    );
  }

  @override
  JsonMap toRpcParams() => super.toRpcParams().deepMerge({
    if (zcashParamsPath != null) 'zcash_params_path': zcashParamsPath,
    if (scanBlocksPerIteration != null)
      'scan_blocks_per_iteration': scanBlocksPerIteration,
    if (scanIntervalMs != null) 'scan_interval_ms': scanIntervalMs,
  });

  ZhtlcActivationParams copyWith({
    ActivationMode? mode,
    int? requiredConfirmations,
    bool? requiresNotarization,
    PrivateKeyPolicy? privKeyPolicy,
    int? minAddressesNumber,
    ScanPolicy? scanPolicy,
    int? gapLimit,
    String? zcashParamsPath,
    int? scanBlocksPerIteration,
    int? scanIntervalMs,
  }) {
    return ZhtlcActivationParams(
      mode: mode ?? this.mode,
      requiredConfirmations:
          requiredConfirmations ?? this.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? this.requiresNotarization,
      privKeyPolicy: privKeyPolicy ?? this.privKeyPolicy,
      minAddressesNumber: minAddressesNumber ?? this.minAddressesNumber,
      scanPolicy: scanPolicy ?? this.scanPolicy,
      gapLimit: gapLimit ?? this.gapLimit,
      zcashParamsPath: zcashParamsPath ?? this.zcashParamsPath,
      scanBlocksPerIteration:
          scanBlocksPerIteration ?? this.scanBlocksPerIteration,
      scanIntervalMs: scanIntervalMs ?? this.scanIntervalMs,
    );
  }

  /// ZHTLC coins only. Path to folder containing Zcash parameters.
  /// Optional, defaults to standard location.
  final String? zcashParamsPath;

  /// ZHTLC coins only. Sets the number of scanned blocks per iteration during
  /// BuildingWalletDb state. Optional, default value is 1000.
  final int? scanBlocksPerIteration;

  /// ZHTLC coins only. Sets the interval in milliseconds between iterations of
  /// BuildingWalletDb state. Optional, default value is 0.
  final int? scanIntervalMs;
}
