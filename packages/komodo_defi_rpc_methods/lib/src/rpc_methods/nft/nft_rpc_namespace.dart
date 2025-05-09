import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Extensions for NFT-related RPC methods
class NftMethodsNamespace extends BaseRpcMethodNamespace {
  NftMethodsNamespace(super.client);

  /// Enables NFT functionality for a given coin
  Future<EnableNftResponse> enableNft({
    required String ticker,
    required NftActivationParams activationParams,
  }) {
    return execute(
      EnableNftRequest(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        activationParams: activationParams,
      ),
    );
  }
}
