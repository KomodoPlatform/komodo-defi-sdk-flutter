// zhtlc_activation_params.dart
import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';

class ZhtlcActivationParams extends ActivationParams {
  ZhtlcActivationParams({
    required super.mode,
    this.zcashParamsPath,
    this.scanBlocksPerIteration = 100,
    this.scanIntervalMs = 200,
  });

  final int scanBlocksPerIteration;
  final int scanIntervalMs;
  final String? zcashParamsPath;

  @override
  Map<String, dynamic> toJson() => {
        'mode': mode,
        'zcash_params_path': zcashParamsPath,
        'scan_blocks_per_iteration': scanBlocksPerIteration,
        'scan_interval_ms': scanIntervalMs,
      };
}
