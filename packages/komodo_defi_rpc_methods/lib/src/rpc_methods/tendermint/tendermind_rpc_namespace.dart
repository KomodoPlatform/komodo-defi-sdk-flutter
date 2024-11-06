import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class TendermintMethodsNamespace extends BaseRpcMethodNamespace {
  TendermintMethodsNamespace(super.client);

  Future<EnableTendermintResponse> enableTendermintWithAssets({
    required String ticker,
    required CosmosActivationParams params,
    List<TokensRequest> assetsRequests = const [],
  }) {
    return execute(
      EnableTendermintRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: params,
        assetsRequests: assetsRequests,
      ),
    );
  }

  Future<EnableTendermintTokenResponse> enableTendermintToken({
    required String ticker,
    required CosmosActivationParams params,
  }) {
    return execute(
      EnableTendermintTokenRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: params,
      ),
    );
  }
}
