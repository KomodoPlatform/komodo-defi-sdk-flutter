import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/gui_storage/models.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetAccountsRequest
    extends BaseRequest<GetAccountsResponse, GeneralErrorResponse>
    with RequestHandlingMixin<GetAccountsResponse, GeneralErrorResponse> {
  GetAccountsRequest() : super(method: 'get_accounts');

  @override
  Map<String, dynamic> toJson() {
    return {
      'method': method,
    };
  }

  @override
  GetAccountsResponse fromJson(Map<String, dynamic> json) {
    return GetAccountsResponse.fromJson(json);
  }
}

class GetAccountsResponse extends BaseResponse {
  GetAccountsResponse({required this.accounts}) : super(mmrpc: '2.0');

  factory GetAccountsResponse.fromJson(Map<String, dynamic> json) {
    return GetAccountsResponse(
      accounts: json
          .value<List<JsonMap>>('accounts')
          .map(AccountWithEnabledFlag.fromJson)
          .toList(),
    );
  }
  final List<AccountWithEnabledFlag> accounts;

  @override
  Map<String, dynamic> toJson() {
    return {
      'accounts': accounts.map((account) => account.toJson()).toList(),
    };
  }
}

class AccountWithEnabledFlag {
  AccountWithEnabledFlag({required this.accountInfo, required this.enabled});

  factory AccountWithEnabledFlag.fromJson(Map<String, dynamic> json) {
    return AccountWithEnabledFlag(
      accountInfo: AccountInfo.fromJson(json.value<JsonMap>('account_info')),
      enabled: json['enabled'] as bool,
    );
  }
  final AccountInfo accountInfo;
  final bool enabled;

  Map<String, dynamic> toJson() {
    return {
      'account_info': accountInfo.toJson(),
      'enabled': enabled,
    };
  }
}
