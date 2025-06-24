import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TendermintActivationParams extends ActivationParams {
  TendermintActivationParams({
    required this.rpcUrls,
    required List<TokensRequest> tokensParams,
    required this.getBalances,
    required this.nodes,
    required this.txHistory,
    super.requiredConfirmations = 3,
    super.requiresNotarization = false,
    super.privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
  }) : _tokensParams = tokensParams;

  factory TendermintActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return TendermintActivationParams(
      rpcUrls:
          json
              .value<JsonList>('rpc_urls')
              .map((e) => EvmNode.fromJson(e).url)
              .toList(),
      tokensParams:
          json
              .valueOrNull<List<dynamic>>('tokens_params')
              ?.map((e) => TokensRequest.fromJson(e as JsonMap))
              .toList() ??
          [],
      txHistory: json.valueOrNull<bool>('tx_history') ?? false,
      requiredConfirmations: base.requiredConfirmations,
      requiresNotarization: base.requiresNotarization,
      getBalances: json.valueOrNull<bool>('get_balances') ?? true,
      privKeyPolicy: PrivateKeyPolicy.fromLegacyJson(
        json.valueOrNull<dynamic>('priv_key_policy'),
      ),
      nodes: json.value<JsonList>('rpc_urls').map(EvmNode.fromJson).toList(),
    );
  }

  final List<String> rpcUrls;
  final List<TokensRequest> _tokensParams;
  final bool getBalances;
  final bool txHistory;
  final List<EvmNode> nodes;

  List<TokensRequest> get tokensParams => List.unmodifiable(_tokensParams);

  TendermintActivationParams copyWith({
    List<String>? rpcUrls,
    List<TokensRequest>? tokensParams,
    bool? txHistory,
    int? requiredConfirmations,
    bool? requiresNotarization,
    bool? getBalances,
    PrivateKeyPolicy? privKeyPolicy,
    List<EvmNode>? nodes,
  }) {
    return TendermintActivationParams(
      rpcUrls: rpcUrls ?? this.rpcUrls,
      tokensParams: tokensParams ?? _tokensParams,
      txHistory: txHistory ?? this.txHistory,
      requiredConfirmations:
          requiredConfirmations ?? super.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? super.requiresNotarization,
      getBalances: getBalances ?? this.getBalances,
      privKeyPolicy: privKeyPolicy ?? super.privKeyPolicy,
      nodes: nodes ?? this.nodes,
    );
  }

  @override
  JsonMap toRpcParams() {
    return {
      ...super.toRpcParams(),
      'rpc_urls': rpcUrls,
      'tokens_params': _tokensParams.map((e) => e.toJson()).toList(),
      'get_balances': getBalances,
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'tx_history': txHistory,
    };
  }
}

// tendermint_token_activation_params.dart
class TendermintTokenActivationParams extends ActivationParams {
  TendermintTokenActivationParams({super.requiredConfirmations = 3});

  factory TendermintTokenActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return TendermintTokenActivationParams(
      requiredConfirmations: base.requiredConfirmations ?? 3,
    );
  }

  @override
  JsonMap toRpcParams() {
    return {...super.toRpcParams()};
  }
}
