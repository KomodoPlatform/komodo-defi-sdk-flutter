import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetStakingInfosRequest
    extends BaseRequest<StakingInfosResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetStakingInfosRequest({required String rpcPass, required this.coin})
    : super(method: 'get_staking_infos', rpcPass: rpcPass, mmrpc: '2.0');

  final String coin;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin},
  });

  @override
  StakingInfosResponse parse(Map<String, dynamic> json) =>
      StakingInfosResponse.parse(json);
}

class StakingInfosResponse extends BaseResponse {
  StakingInfosResponse({required super.mmrpc, required this.result});

  factory StakingInfosResponse.parse(Map<String, dynamic> json) =>
      StakingInfosResponse(
        mmrpc: json.valueOrNull<String>('mmrpc'),
        result: StakingInfo.fromJson(json.value<JsonMap>('result')),
      );

  final StakingInfo result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
