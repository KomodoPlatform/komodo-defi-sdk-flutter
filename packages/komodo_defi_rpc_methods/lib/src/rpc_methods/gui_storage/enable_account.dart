import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/gui_storage/add_account.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/gui_storage/models.dart';

class EnableAccountRequest
    extends BaseRequest<EnableAccountResponse, GeneralErrorResponse>
    with RequestHandlingMixin<EnableAccountResponse, GeneralErrorResponse> {
  EnableAccountRequest({required this.policy})
      : super(method: 'enable_account');
  final EnableAccountPolicy policy;

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'params': {
        'policy': policy.toJson(),
      },
    };
  }

  @override
  EnableAccountResponse fromJson(Map<String, dynamic> json) {
    return EnableAccountResponse.fromJson(json);
  }
}

// TODO! Complete
class EnableAccountResponse extends BaseResponse {
  EnableAccountResponse() : super(mmrpc: '2.0');

  // ignore: avoid_unused_constructor_parameters
  factory EnableAccountResponse.fromJson(Map<String, dynamic> json) {
    return EnableAccountResponse();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class EnableAccountPolicy {
  EnableAccountPolicy.newAccount(NewAccount<EnabledAccountId> newAccount)
      : type = 'new',
        account = newAccount;

  EnableAccountPolicy.existing(EnabledAccountId accountId)
      : type = 'existing',
        account = accountId;
  final String type;
  final dynamic account;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (type == 'existing') 'account_id': account.toJson(),
      if (type == 'new') 'new_account': account.toJson(),
    };
  }
}
