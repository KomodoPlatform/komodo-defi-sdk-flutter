import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TendermintActivationParams extends ActivationParams {
  TendermintActivationParams({
    required this.rpcUrls,
    required List<TokensRequest> tokensParams,
    required this.getBalances,
    required this.nodes,
    required this.txHistory,
    super.requiredConfirmations,
    super.requiresNotarization,
    super.privKeyPolicy,
  }) : _tokensParams = tokensParams;

  factory TendermintActivationParams.fromJson(
    JsonMap json, {
    PrivateKeyPolicy? privKeyPolicy,
  }) {
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
      privKeyPolicy: privKeyPolicy ?? base.privKeyPolicy,
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
          requiredConfirmations ?? this.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? this.requiresNotarization,
      getBalances: getBalances ?? this.getBalances,
      privKeyPolicy: privKeyPolicy ?? this.privKeyPolicy,
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
      'priv_key_policy':
          (privKeyPolicy ?? const PrivateKeyPolicy.contextPrivKey())
              .pascalCaseName,
    };
  }
}

// tendermint_token_activation_params.dart
class TendermintTokenActivationParams extends ActivationParams {
  TendermintTokenActivationParams({
    super.requiredConfirmations,
    super.privKeyPolicy,
  });

  factory TendermintTokenActivationParams.fromJson(
    JsonMap json, {
    PrivateKeyPolicy? privKeyPolicy,
  }) {
    final base = ActivationParams.fromConfigJson(json);

    return TendermintTokenActivationParams(
      requiredConfirmations: base.requiredConfirmations ?? 3,
      privKeyPolicy: privKeyPolicy ?? base.privKeyPolicy,
    );
  }

  @override
  JsonMap toRpcParams() {
    return {
      ...super.toRpcParams(),
      'priv_key_policy':
          (privKeyPolicy ?? const PrivateKeyPolicy.contextPrivKey())
              .pascalCaseName,
    };
  }
}
