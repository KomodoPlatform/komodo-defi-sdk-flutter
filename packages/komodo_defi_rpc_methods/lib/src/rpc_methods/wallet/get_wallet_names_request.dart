// lib/src/rpc_methods/wallet/get_wallet_names_request.dart

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

class GetWalletNamesRequest
    extends BaseRequest<GetWalletNamesResponse, GeneralErrorResponse> {
  GetWalletNamesRequest([String? rpcPass])
    : super(rpcPass: rpcPass, method: 'get_wallet_names');

  @override
  GetWalletNamesResponse parse(Map<String, dynamic> json) =>
      GetWalletNamesResponse.parse(json);
}
