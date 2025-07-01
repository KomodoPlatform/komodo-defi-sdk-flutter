import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

class ScanForNewAddressesInitRequest
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  ScanForNewAddressesInitRequest({
    required super.rpcPass,
    required this.coin,
    this.accountId,
    this.gapLimit,
  }) : super(method: 'task::scan_for_new_addresses::init');

  final String coin;
  final int? accountId;
  final int? gapLimit;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'coin': coin,
        if (accountId != null) 'account_index': accountId,
        if (gapLimit != null) 'gap_limit': gapLimit,
      },
    };
  }

  @override
  NewTaskResponse parse(Map<String, dynamic> json) =>
      NewTaskResponse.parse(json);
}
