import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/gui_storage/models.dart';

class AddAccountRequest
    extends BaseRequest<AddAccountResponse, GeneralErrorResponse>
    with RequestHandlingMixin<AddAccountResponse, GeneralErrorResponse> {
  AddAccountRequest({required this.account}) : super(method: 'add_account');
  final NewAccount<AccountId> account;

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'params': {
        'account': account.toJson(),
      },
    };
  }

  @override
  AddAccountResponse fromJson(Map<String, dynamic> json) {
    return AddAccountResponse.fromJson(json);
  }
}

// TODO! Complete
class AddAccountResponse extends BaseResponse {
  AddAccountResponse() : super(mmrpc: '2.0');

  // ignore: avoid_unused_constructor_parameters
  factory AddAccountResponse.fromJson(Map<String, dynamic> json) {
    return AddAccountResponse();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class NewAccount<T extends AccountId> {
  NewAccount({
    required this.accountId,
    required this.name,
    required this.balanceUsd,
    this.description = '',
  });

  final T accountId;
  final String name;
  final String description;
  final BigDecimal balanceUsd;

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId.toJson(),
      'name': name,
      'description': description,
      'balance_usd': balanceUsd.toJson(),
    };
  }
}
