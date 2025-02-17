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
}
