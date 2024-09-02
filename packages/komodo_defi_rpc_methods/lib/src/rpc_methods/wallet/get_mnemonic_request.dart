// lib/src/rpc_methods/wallet/get_mnemonic_request.dart

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/rpc_methods.dart';

class GetMnemonicRequest
    extends BaseRequest<GetMnemonicResponse, GeneralErrorResponse>
    with RequestHandlingMixin<GetMnemonicResponse, GeneralErrorResponse> {
  GetMnemonicRequest({
    required super.rpcPass,
    required this.format,
    this.password,
  }) : super(method: 'get_mnemonic');

  final String format;
  final String? password;

  @override
  Map<String, dynamic> toJson() => {
        'userpass': rpcPass,
        'mmrpc': mmrpc,
        'method': method,
        'params': {
          'format': format,
          if (format == 'plaintext') 'password': password,
        },
      };

  @override
  GetMnemonicResponse parse(Map<String, dynamic> json) =>
      GetMnemonicResponse.parse(json);
}
