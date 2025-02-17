import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/eth/enable_custom_erc20.dart';

/// Extensions for ETH-related RPC methods
// lib/src/rpc_methods/eth/eth_rpc_extensions.dart
class Erc20MethodsNamespace extends BaseRpcMethodNamespace {
  Erc20MethodsNamespace(super.client);

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
    required Erc20ActivationParams activationParams,
  }) {
    return execute(
      EnableErc20Request(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: activationParams,
      ),
    );
  }

  Future<EnableErc20Response> enableCustomErc20Token({
    required String ticker,
    required Erc20ActivationParams activationParams,
    required String platform, 
    required String contractAddress,
  }) {
    return execute(
      EnableCustomErc20TokenRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: activationParams,
        platform: platform,
        contractAddress: contractAddress,
      ),
    );
  }
}
