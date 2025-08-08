import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TendermintActivationParams extends ActivationParams {
  TendermintActivationParams({
    required super.mode,
    required this.rpcUrls,
    required List<TokensRequest> tokensParams,
    required this.getBalances,
    required this.nodes,
    required this.txHistory,
    super.requiredConfirmations,
    super.requiresNotarization,
    super.privKeyPolicy,
  }) : _tokensParams = tokensParams;

  factory TendermintActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    final rpcUrls =
        json
            .value<JsonList>('rpc_urls')
            .map((e) => EvmNode.fromJson(e).url)
            .toList();
    final tokensParams =
        json
            .valueOrNull<List<dynamic>>('tokens_params')
            ?.map((e) => TokensRequest.fromJson(e as JsonMap))
            .toList() ??
        [];
    final getBalances = json.valueOrNull<bool>('get_balances') ?? true;
    final txHistory = json.valueOrNull<bool>('tx_history') ?? false;
    final nodes =
        json.value<JsonList>('rpc_urls').map(EvmNode.fromJson).toList();

    return TendermintActivationParams(
      mode:
          base.mode ??
          (throw const FormatException(
            'Tendermint activation requires mode parameter',
          )),
      rpcUrls: rpcUrls,
      tokensParams: tokensParams,
      txHistory: txHistory,
      requiredConfirmations: base.requiredConfirmations,
      requiresNotarization: base.requiresNotarization,
      getBalances: getBalances,
      privKeyPolicy: base.privKeyPolicy,
      nodes: nodes,
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
      mode: mode,
      rpcUrls: rpcUrls ?? this.rpcUrls,
      tokensParams: tokensParams ?? _tokensParams,
      txHistory: txHistory ?? this.txHistory,
      requiredConfirmations:
          requiredConfirmations ?? this.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? this.requiresNotarization,
      getBalances: getBalances ?? this.getBalances,
      privKeyPolicy:
          privKeyPolicy ??
          this.privKeyPolicy ??
          const PrivateKeyPolicy.contextPrivKey(),
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

/// Simple activation params for Tendermint tokens - single address only
class TendermintTokenActivationParams extends ActivationParams {
  TendermintTokenActivationParams({
    required super.mode,
    super.requiredConfirmations,
    super.privKeyPolicy,
  });

  factory TendermintTokenActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return TendermintTokenActivationParams(
      mode:
          base.mode ??
          (throw const FormatException(
            'Tendermint token activation requires mode parameter',
          )),
      requiredConfirmations: base.requiredConfirmations ?? 3,
      privKeyPolicy: base.privKeyPolicy,
    );
  }

  TendermintTokenActivationParams copyWith({
    int? requiredConfirmations,
    PrivateKeyPolicy? privKeyPolicy,
  }) {
    return TendermintTokenActivationParams(
      mode: mode,
      requiredConfirmations:
          requiredConfirmations ?? this.requiredConfirmations,
      privKeyPolicy: privKeyPolicy ?? this.privKeyPolicy,
    );
  }
}
