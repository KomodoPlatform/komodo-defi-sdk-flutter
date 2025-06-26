import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AddDelegationRequest
    extends BaseRequest<DelegationResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  AddDelegationRequest({
    required String rpcPass,
    required this.coin,
    required this.stakingType,
    required this.address,
  }) : super(method: 'add_delegation', rpcPass: rpcPass, mmrpc: '2.0');

  final String coin;
  final String stakingType;
  final String address;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      'staking_details': {'type': stakingType, 'address': address},
    },
  });

  @override
  DelegationResponse parse(Map<String, dynamic> json) =>
      DelegationResponse.parse(json);
}

class DelegationResponse extends BaseResponse {
  DelegationResponse({required super.mmrpc, required this.result});

  factory DelegationResponse.parse(Map<String, dynamic> json) =>
      DelegationResponse(
        mmrpc: json.valueOrNull<String>('mmrpc'),
        result: WithdrawResult.fromJson(json.value<JsonMap>('result')),
      );

  final WithdrawResult result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
