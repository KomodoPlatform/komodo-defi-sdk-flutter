// lib/src/rpc_methods/wallet/get_mnemonic_response.dart

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetMnemonicResponse extends BaseResponse {
  GetMnemonicResponse({required super.mmrpc, required this.mnemonic});

  @override
  factory GetMnemonicResponse.parse(Map<String, dynamic> json) {
    return GetMnemonicResponse(
      mmrpc: json.value<String>('mmrpc'),
      mnemonic: Mnemonic.fromRpcJson(json.value<JsonMap>('result')),
    );
  }

  final Mnemonic mnemonic;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': mnemonic.toJson(),
  };
}
