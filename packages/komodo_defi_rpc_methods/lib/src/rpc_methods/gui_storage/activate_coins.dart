import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/gui_storage/models.dart';

class ActivateCoinsRequest
    extends BaseRequest<ActivateCoinsResponse, GeneralErrorResponse>
    with RequestHandlingMixin<ActivateCoinsResponse, GeneralErrorResponse> {
  ActivateCoinsRequest({required this.accountId, required this.tickers})
      : super(method: 'activate_coins');
  final AccountId accountId;
  final List<String> tickers;

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'params': {
        'account_id': accountId.toJson(),
        'tickers': tickers,
      },
    };
  }

  @override
  ActivateCoinsResponse fromJson(Map<String, dynamic> json) {
    return ActivateCoinsResponse.fromJson(json);
  }
}

// TODO! Complete
class ActivateCoinsResponse extends BaseResponse {
  ActivateCoinsResponse() : super(mmrpc: '2.0');

  // ignore: public_member_api_docs, avoid_unused_constructor_parameters
  factory ActivateCoinsResponse.fromJson(Map<String, dynamic> json) {
    return ActivateCoinsResponse();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
