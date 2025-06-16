import 'package:komodo_defi_types/komodo_defi_types.dart';

/// {@template komodo_provider}
/// Provider wrapper exposing `komodo.request` for dApp consumption.
/// {@endtemplate}
class KomodoProvider {
  /// {@macro komodo_provider}
  KomodoProvider(this._client);

  final ApiClient _client;

  /// Executes a Komodo RPC method.
  Future<dynamic> request({required String method, dynamic params}) async {
    final rpcRequest = <String, dynamic>{
      'method': method,
      if (params != null) 'params': params,
    };
    final response = await _client.executeRpc(rpcRequest);
    return response['result'];
  }
}
