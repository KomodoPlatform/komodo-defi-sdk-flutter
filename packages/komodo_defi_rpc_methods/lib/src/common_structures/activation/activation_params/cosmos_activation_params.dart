// cosmos_activation_params.dart
import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';

class CosmosActivationParams extends ActivationParams {
  CosmosActivationParams({
    required this.rpcUrls,
    this.isIrisToken = false,
  });
  final List<String> rpcUrls;
  final bool isIrisToken;

  @override
  Map<String, dynamic> toJsonRequestParams() => {
        'rpc_urls': rpcUrls,
        'is_iris_token': isIrisToken,
      };
}
