import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Extensions for ETH-related RPC methods
class Erc20MethodsNamespace extends BaseRpcMethodNamespace {
  Erc20MethodsNamespace(super.client);

  /// Enable ETH with one or more ERC20 tokens
  Future<EnableEthWithTokensResponse> enableEthWithTokens({
    required String ticker,
    required EthWithTokensActivationParams params,
    bool getBalances = true,
  }) {
    return execute(
      EnableEthWithTokensRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: params,
        getBalances: getBalances,
      ),
    );
  }

  Future<EnableErc20Response> enableErc20({
    required String ticker,
    required List<EvmNode> nodes,
    required String swapContractAddress,
    required String fallbackSwapContract,
  }) {
    return execute(
      EnableErc20Request(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        nodes: nodes,
        swapContractAddress: swapContractAddress,
        fallbackSwapContract: fallbackSwapContract,
      ),
    );
  }
}
