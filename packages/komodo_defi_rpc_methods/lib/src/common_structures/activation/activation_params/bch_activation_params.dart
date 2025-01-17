// bch_activation_params.dart
import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class BchActivationParams extends ActivationParams {
  BchActivationParams({
    required this.bchdUrls,
    required super.mode,
    super.requiredConfirmations,
    super.requiresNotarization,
    super.privKeyPolicy,
    super.minAddressesNumber,
    super.scanPolicy,
    super.gapLimit,
  });

  /// Create BCH activation params from JSON config
  factory BchActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return BchActivationParams(
      bchdUrls: json.value<List<dynamic>>('bchd_urls').cast<String>(),
      mode: base.mode ??
          (throw const FormatException(
            'BCH activation requires mode parameter',
          )),
      requiredConfirmations: base.requiredConfirmations,
      requiresNotarization: base.requiresNotarization,
      privKeyPolicy: base.privKeyPolicy,
      minAddressesNumber: base.minAddressesNumber,
      scanPolicy: base.scanPolicy,
      gapLimit: base.gapLimit,
    );
  }

  final List<String> bchdUrls;

  @override
  Map<String, dynamic> toJsonRequestParams() {
    return {
      ...super.toJsonRequestParams(),
      'bchd_urls': bchdUrls,
    };
  }
}
