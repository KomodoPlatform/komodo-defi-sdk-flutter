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
    super.privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
    super.minAddressesNumber,
    super.scanPolicy,
    super.gapLimit,
    super.zcashParamsPath,
    super.scanBlocksPerIteration,
    super.scanIntervalMs,
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
      zcashParamsPath: base.zcashParamsPath,
      scanBlocksPerIteration: base.scanBlocksPerIteration,
      scanIntervalMs: base.scanIntervalMs,
    );
  }

  @override
  JsonMap toRpcParams() => super.toRpcParams();

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
}
