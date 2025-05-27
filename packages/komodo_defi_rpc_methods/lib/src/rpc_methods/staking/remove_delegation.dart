import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class RemoveDelegationRequest
    extends BaseRequest<DelegationResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  RemoveDelegationRequest({required String rpcPass, required this.coin})
    : super(method: 'remove_delegation', rpcPass: rpcPass, mmrpc: '2.0');

  final String coin;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin},
  });

  @override
  DelegationResponse parse(Map<String, dynamic> json) =>
      DelegationResponse.parse(json);
}
