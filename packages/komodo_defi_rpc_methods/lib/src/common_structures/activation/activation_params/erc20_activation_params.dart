import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';

@Deprecated('Which is better???')
class Erc20ActivationParams extends ActivationParams {
  Erc20ActivationParams({
    required this.nodes,
    required this.swapContractAddress,
    required this.fallbackSwapContract,
  });
  final List<String> nodes;
  final String swapContractAddress;
  final String fallbackSwapContract;

  @override
  Map<String, dynamic> toJson() => {
        'nodes': nodes,
        'swap_contract_address': swapContractAddress,
        'fallback_swap_contract': fallbackSwapContract,
      };
}
