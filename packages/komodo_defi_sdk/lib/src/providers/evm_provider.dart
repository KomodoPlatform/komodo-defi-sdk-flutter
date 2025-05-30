import 'package:komodo_defi_types/komodo_defi_types.dart';

/// {@template evm_provider}
/// Basic EIP-1193 provider implementation used for WebView injection.
/// {@endtemplate}
class EvmProvider {
  /// {@macro evm_provider}
  EvmProvider(this._client);

  final ApiClient _client;

  /// Current active EVM chain ID in hexadecimal string format.
  String? currentChainId;

  /// Sends an EIP-1193 request to the underlying client.
  Future<dynamic> request({required String method, dynamic params}) async {
    final rpcRequest = <String, dynamic>{
      'method': method,
      if (params != null) 'params': params,
    };
    final response = await _client.executeRpc(rpcRequest);
    return response['result'];
  }

  /// Convenience helper for `wallet_switchEthereumChain`.
  Future<void> switchChain(String chainId) async {
    await request(
      method: 'wallet_switchEthereumChain',
      params: {'chainId': chainId},
    );
    currentChainId = chainId;
  }
}
