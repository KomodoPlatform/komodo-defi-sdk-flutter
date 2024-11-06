import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class EthWithTokensActivationParams extends ActivationParams {
  EthWithTokensActivationParams({
    required this.nodes,
    required this.swapContractAddress,
    required this.fallbackSwapContract,
    required this.erc20Tokens,
    super.requiredConfirmations,
    super.requiresNotarization = false,
  });

  factory EthWithTokensActivationParams.fromJsonConfig(JsonMap json) {
    return EthWithTokensActivationParams(
      nodes: json.value<List<JsonMap>>('nodes').map(EvmNode.fromJson).toList(),
      swapContractAddress: json.value<String>('swap_contract_address'),
      fallbackSwapContract: json.value<String>('fallback_swap_contract'),
      erc20Tokens:
          // json
          //         .valueOrNull<List<JsonMap>>('erc20_tokens_requests')
          //         ?.map(TokensRequest.fromJson)
          //         .toList() ??
          [],
      requiredConfirmations: json.value<int>('required_confirmations'),
      requiresNotarization:
          json.valueOrNull<bool>('requires_notarization') ?? false,
    );
  }

  final List<EvmNode> nodes;
  final String swapContractAddress;
  final String fallbackSwapContract;
  final List<TokensRequest> erc20Tokens;

  EthWithTokensActivationParams copyWith({
    List<EvmNode>? nodes,
    String? swapContractAddress,
    String? fallbackSwapContract,
    List<TokensRequest>? erc20Tokens,
    int? requiredConfirmations,
    bool? requiresNotarization,
  }) {
    return EthWithTokensActivationParams(
      nodes: nodes ?? this.nodes,
      swapContractAddress: swapContractAddress ?? this.swapContractAddress,
      fallbackSwapContract: fallbackSwapContract ?? this.fallbackSwapContract,
      erc20Tokens: erc20Tokens ?? this.erc20Tokens,
      requiredConfirmations:
          requiredConfirmations ?? this.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? this.requiresNotarization,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'nodes': nodes,
        'swap_contract_address': swapContractAddress,
        'fallback_swap_contract': fallbackSwapContract,
        'erc20_tokens_requests': erc20Tokens.map((e) => e.toJson()).toList(),
        if (requiredConfirmations != null)
          'required_confirmations': requiredConfirmations,
        'requires_notarization': requiresNotarization,
      };
}
