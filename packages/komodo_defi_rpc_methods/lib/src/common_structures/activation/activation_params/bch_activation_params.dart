// bch_activation_params.dart
import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';

class BchActivationParams extends ActivationParams {
  BchActivationParams({
    required this.electrumServers,
    required this.bchdUrls,
  });
  final List<Map<String, dynamic>> electrumServers;
  final List<String> bchdUrls;

  @override
  Map<String, dynamic> toJson() => {
        'servers': electrumServers,
        'bchd_urls': bchdUrls,
      };
}
