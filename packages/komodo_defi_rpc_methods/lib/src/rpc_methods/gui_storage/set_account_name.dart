import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/gui_storage/models.dart';

class SetAccountNameRequest
    extends BaseRequest<SetAccountNameResponse, GeneralErrorResponse>
    with RequestHandlingMixin<SetAccountNameResponse, GeneralErrorResponse> {
  SetAccountNameRequest({required this.accountId, required this.name})
      : super(method: 'gui_storage::set_account_name');
  final AccountId accountId;
  final String name;

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'params': {
        'account_id': accountId.toJson(),
        'name': name,
      },
    };
  }

  @override
  SetAccountNameResponse fromJson(Map<String, dynamic> json) {
    return SetAccountNameResponse.fromJson(json);
  }
}

// TODO! Complete
class SetAccountNameResponse extends BaseResponse {
  SetAccountNameResponse() : super(mmrpc: '2.0');

  // ignore: avoid_unused_constructor_parameters
  factory SetAccountNameResponse.fromJson(Map<String, dynamic> json) {
    return SetAccountNameResponse();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
