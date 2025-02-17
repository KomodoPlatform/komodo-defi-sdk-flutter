import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class EthWithTokensActivationParams extends ActivationParams {
  EthWithTokensActivationParams({
    required this.nodes,
    required this.swapContractAddress,
    required this.fallbackSwapContract,
    required this.erc20Tokens,
    required this.txHistory,
    super.requiredConfirmations,
    super.requiresNotarization = false,
  });

  factory EthWithTokensActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return EthWithTokensActivationParams(
      nodes: json.value<List<JsonMap>>('nodes').map(EvmNode.fromJson).toList(),
      swapContractAddress: json.value<String>('swap_contract_address'),
      fallbackSwapContract: json.value<String>('fallback_swap_contract'),
      erc20Tokens: json
              .valueOrNull<List<JsonMap>>('erc20_tokens_requests')
              ?.map(TokensRequest.fromJson)
              .toList() ??
          [],
      requiredConfirmations: base.requiredConfirmations,
      requiresNotarization: base.requiresNotarization,
      txHistory: json.valueOrNull<bool>('tx_history'),
    );
  }

  final List<EvmNode> nodes;
  final String swapContractAddress;
  final String fallbackSwapContract;
  final List<TokensRequest> erc20Tokens;

  final bool? txHistory;

  EthWithTokensActivationParams copyWith({
    List<EvmNode>? nodes,
    String? swapContractAddress,
    String? fallbackSwapContract,
    List<TokensRequest>? erc20Tokens,
    int? requiredConfirmations,
    bool? requiresNotarization,
    bool? txHistory,
  }) {
    return EthWithTokensActivationParams(
      nodes: nodes ?? this.nodes,
      swapContractAddress: swapContractAddress ?? this.swapContractAddress,
      fallbackSwapContract: fallbackSwapContract ?? this.fallbackSwapContract,
      erc20Tokens: erc20Tokens ?? this.erc20Tokens,
      requiredConfirmations:
          requiredConfirmations ?? this.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? this.requiresNotarization,
      txHistory: txHistory ?? this.txHistory,
    );
  }

  @override
  Map<String, dynamic> toRpcParams() {
    return {
      ...super.toRpcParams(),
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'swap_contract_address': swapContractAddress,
      'fallback_swap_contract': fallbackSwapContract,
      'erc20_tokens_requests': erc20Tokens.map((e) => e.toJson()).toList(),
      if (txHistory != null) 'tx_history': txHistory,
    };
  }
}
