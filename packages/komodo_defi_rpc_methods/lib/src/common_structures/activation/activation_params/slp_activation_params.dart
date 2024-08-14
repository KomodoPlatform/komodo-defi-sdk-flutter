import 'package:komodo_defi_rpc_methods/src/common_structures/common_structures.dart';

class SlpActivationParams extends ActivationParams {
  SlpActivationParams({
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
