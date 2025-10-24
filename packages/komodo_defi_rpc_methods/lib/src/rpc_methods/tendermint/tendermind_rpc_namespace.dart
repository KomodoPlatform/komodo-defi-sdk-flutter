import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class TendermintMethodsNamespace extends BaseRpcMethodNamespace {
  TendermintMethodsNamespace(super.client);

  /// Enable Tendermint chain with optional IBC assets
  Future<EnableTendermintWithAssetsResponse> enableTendermintWithAssets({
    required String ticker,
    required TendermintActivationParams params,
  }) {
    return execute(
      EnableTendermintWithAssetsRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        params: params,
      ),
    );
  }

  /// Enable individual Tendermint token
  Future<EnableTendermintTokenResponse> enableTendermintToken({
    required String ticker,
    required TendermintTokenActivationParams params,
  }) {
    return execute(
      EnableTendermintTokenRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        params: params,
      ),
    );
  }

  /// Initialize task-based Tendermint activation
  Future<NewTaskResponse> taskEnableTendermintInit({
    required String ticker,
    required List<TendermintTokenParams> tokensParams,
    required List<TendermintNode> nodes,
    bool getBalances = true,
    bool txHistory = true,
  }) {
    return execute(
      TaskEnableTendermintInitRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        tokensParams: tokensParams,
        nodes: nodes,
        getBalances: getBalances,
        txHistory: txHistory,
      ),
    );
  }

  /// Check task-based Tendermint activation status
  Future<TendermintTaskStatusResponse> taskEnableTendermintStatus({
    required int taskId,
    bool forgetIfFinished = false,
  }) {
    return execute(
      TaskEnableTendermintStatusRequest(
        rpcPass: rpcPass ?? '',
        taskId: taskId,
        forgetIfFinished: forgetIfFinished,
      ),
    );
  }

  /// Cancel task-based Tendermint activation
  Future<TendermintTaskCancelResponse> taskEnableTendermintCancel({
    required int taskId,
  }) {
    return execute(
      TaskEnableTendermintCancelRequest(rpcPass: rpcPass ?? '', taskId: taskId),
    );
  }
}
