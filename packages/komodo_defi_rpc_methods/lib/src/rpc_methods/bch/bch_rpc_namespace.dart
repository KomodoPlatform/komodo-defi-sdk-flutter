import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class SlpMethodsNamespace extends BaseRpcMethodNamespace {
  SlpMethodsNamespace(super.client);

  Future<EnableBchWithTokensResponse> enableBchWithTokens({
    required String ticker,
    required BchActivationParams params,
    List<TokensRequest> slpTokensRequests = const [],
    AddressFormat? addressFormat,
    bool getBalances = true,
    UtxoMergeParams? utxoMergeParams,
  }) {
    return execute(
      EnableBchWithTokensRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: params,
        slpTokensRequests: slpTokensRequests,
        addressFormat: addressFormat,
        getBalances: getBalances,
        utxoMergeParams: utxoMergeParams,
      ),
    );
  }

  Future<EnableSlpResponse> enableSlpToken({
    required String ticker,
    required SlpActivationParams params,
  }) {
    return execute(
      EnableSlpRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: params,
      ),
    );
  }
}
