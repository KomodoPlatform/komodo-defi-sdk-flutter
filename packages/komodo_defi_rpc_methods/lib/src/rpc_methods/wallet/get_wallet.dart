import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetWalletRequest
    extends BaseRequest<GetWalletResponse, GeneralErrorResponse>
    with RequestHandlingMixin<GetWalletResponse, GeneralErrorResponse> {
  GetWalletRequest()
      // TODO! Migrate to the confirmed rpc method name when the method is
      // merged into the KDF's `dev` branch.
      : super(method: 'get_wallet');

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'params': <String, dynamic>{
        //
      },
    };
  }

  @override
  GetWalletResponse parse(Map<String, dynamic> json) {
    return GetWalletResponse.parse(json);
  }
}

class GetWalletResponse extends BaseResponse {
  GetWalletResponse({required this.walletName}) : super(mmrpc: '2.0');

  // ignore: avoid_unused_constructor_parameters
  @override
  factory GetWalletResponse.parse(Map<String, dynamic> json) {
    return GetWalletResponse(
      walletName: json.value<String>('wallet_name'),
    );
  }

  final String walletName;

  @override
  Map<String, dynamic> toJson() {
    return {
      'wallet_name': walletName,
    };
  }
}
