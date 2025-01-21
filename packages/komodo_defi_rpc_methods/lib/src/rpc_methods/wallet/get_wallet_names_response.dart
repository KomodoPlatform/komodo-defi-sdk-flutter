import 'package:komodo_defi_rpc_methods/src/models/base_response.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetWalletNamesResponse extends BaseResponse {
  GetWalletNamesResponse({
    required super.mmrpc,
    required this.walletNames,
    this.activatedWallet,
  });

  factory GetWalletNamesResponse.parse(Map<String, dynamic> json) {
    return GetWalletNamesResponse(
      mmrpc: json.value<String>('mmrpc'),
      walletNames: List<String>.from(json.value('result', 'wallet_names')),
      activatedWallet: json.valueOrNull<String?>('result', 'activated_wallet'),
    );
  }

  final List<String> walletNames;
  final String? activatedWallet;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'wallet_names': walletNames,
          'activated_wallet': activatedWallet,
        },
      };
}
