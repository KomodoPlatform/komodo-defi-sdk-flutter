import 'package:komodo_defi_types/src/common_structures/activation/activation_params/activation_params.dart';
import 'package:komodo_defi_types/src/common_structures/activation/evm_node.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

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
  JsonMap toRpcParams() => super.toRpcParams().deepMerge({
        'nodes': nodes.map((e) => e.url).toList(),
        'swap_contract_address': swapContractAddress,
        'fallback_swap_contract': fallbackSwapContract,
      });
}
