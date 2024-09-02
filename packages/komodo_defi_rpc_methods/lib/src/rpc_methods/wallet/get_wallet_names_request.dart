// lib/src/rpc_methods/wallet/get_wallet_names_request.dart

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/wallet/get_wallet_names_response.dart';

class GetWalletNamesRequest
    extends BaseRequest<GetWalletNamesResponse, GeneralErrorResponse>
    with RequestHandlingMixin<GetWalletNamesResponse, GeneralErrorResponse> {
  GetWalletNamesRequest([String? rpcPass])
      : super(rpcPass: rpcPass, method: 'get_wallet_names');

  @override
  Map<String, dynamic> toJson() => {
        'userpass': rpcPass,
        'mmrpc': mmrpc,
        'method': method,
      };

  @override
  GetWalletNamesResponse parse(Map<String, dynamic> json) =>
      GetWalletNamesResponse.parse(json);
}
