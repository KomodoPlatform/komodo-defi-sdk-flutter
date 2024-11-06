import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Erc20ActivationParams extends ActivationParams {
  Erc20ActivationParams({
    required this.nodes,
    required this.swapContractAddress,
    required this.fallbackSwapContract,
  });

  factory Erc20ActivationParams.fromJsonConfig(JsonMap json) {
    return Erc20ActivationParams(
      nodes: json.value<JsonList>('nodes').map(EvmNode.fromJson).toList(),
      swapContractAddress: json['swap_contract_address'] as String,
      fallbackSwapContract: json['fallback_swap_contract'] as String,
    );
  }
  final List<EvmNode> nodes;
  final String swapContractAddress;
  final String fallbackSwapContract;

  @override
  JsonMap toJson() => {
        'nodes': nodes,
        'swap_contract_address': swapContractAddress,
        'fallback_swap_contract': fallbackSwapContract,
      };
}
