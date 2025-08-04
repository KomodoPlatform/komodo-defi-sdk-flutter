import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request for task-based Tendermint activation initialization
class TaskEnableTendermintInitRequest
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableTendermintInitRequest({
    required super.rpcPass,
    required this.ticker,
    required this.tokensParams,
    required this.nodes,
    this.getBalances = true,
    this.txHistory = true,
  }) : super(method: 'task::enable_tendermint::init', mmrpc: RpcVersion.v2_0);

  final String ticker;
  final List<TendermintTokenParams> tokensParams;
  final List<TendermintNode> nodes;
  final bool getBalances;
  final bool txHistory;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'ticker': ticker,
      'get_balances': getBalances,
      'tx_history': txHistory,
      'tokens_params': tokensParams.map((e) => e.toJson()).toList(),
      'nodes': nodes.map((e) => e.toJson()).toList(),
    },
  };

  @override
  NewTaskResponse parse(Map<String, dynamic> json) =>
      NewTaskResponse.parse(json);
}

/// Parameters for Tendermint token activation within the task
class TendermintTokenParams {
  const TendermintTokenParams({required this.ticker, this.activationParams});

  factory TendermintTokenParams.fromJson(JsonMap json) {
    return TendermintTokenParams(
      ticker: json.value<String>('ticker'),
      activationParams:
          json.valueOrNull<JsonMap>('activation_params') != null
              ? TendermintTokenActivationParams.fromJson(
                json.value<JsonMap>('activation_params'),
              )
              : null,
    );
  }

  final String ticker;
  final TendermintTokenActivationParams? activationParams;

  JsonMap toJson() => {
    'ticker': ticker,
    if (activationParams != null)
      'activation_params': activationParams!.toRpcParams(),
  };
}

/// Tendermint node configuration for task-based activation
class TendermintNode {
  const TendermintNode({
    required this.url,
    this.apiUrl,
    this.grpcUrl,
    this.wsUrl,
  });

  factory TendermintNode.fromJson(JsonMap json) {
    return TendermintNode(
      url: json.value<String>('url'),
      apiUrl: json.valueOrNull<String>('api_url'),
      grpcUrl: json.valueOrNull<String>('grpc_url'),
      wsUrl: json.valueOrNull<String>('ws_url'),
    );
  }

  final String url;
  final String? apiUrl;
  final String? grpcUrl;
  final String? wsUrl;

  JsonMap toJson() => {
    'url': url,
    if (apiUrl != null) 'api_url': apiUrl,
    if (grpcUrl != null) 'grpc_url': grpcUrl,
    if (wsUrl != null) 'ws_url': wsUrl,
  };
}
