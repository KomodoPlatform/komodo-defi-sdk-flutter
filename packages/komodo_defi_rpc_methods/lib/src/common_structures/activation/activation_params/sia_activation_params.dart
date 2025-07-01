import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class SiaActivationParams extends ActivationParams {
  SiaActivationParams({
    required this.serverUrl,
    this.txHistory = false,
    super.requiredConfirmations,
  });

  factory SiaActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);
    return SiaActivationParams(
      serverUrl: json.value<String>('server_url'),
      txHistory: json.valueOrNull<bool>('tx_history') ?? false,
      requiredConfirmations: base.requiredConfirmations,
    );
  }

  final String serverUrl;
  final bool txHistory;

  @override
  Map<String, dynamic> toRpcParams() {
    return {
      ...super.toRpcParams(),
      'tx_history': txHistory,
      'client_conf': {'server_url': serverUrl},
    };
  }
}
