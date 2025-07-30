import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get estimated Tendermint/Cosmos fee
class GetTendermintEstimatedFeeRequest
    extends
        BaseRequest<GetTendermintEstimatedFeeResponse, GeneralErrorResponse> {
  GetTendermintEstimatedFeeRequest({
    required super.rpcPass,
    required this.coin,
    this.estimatorType = FeeEstimatorType.simple,
  }) : super(method: 'get_tendermint_estimated_fee', mmrpc: '2.0');

  final String coin;
  final FeeEstimatorType estimatorType;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'estimator_type': estimatorType.toString()},
  };

  @override
  GetTendermintEstimatedFeeResponse parse(Map<String, dynamic> json) =>
      GetTendermintEstimatedFeeResponse.parse(json);
}

/// Response containing Tendermint fee estimates
class GetTendermintEstimatedFeeResponse extends BaseResponse {
  GetTendermintEstimatedFeeResponse({
    required super.mmrpc,
    required this.result,
  });

  factory GetTendermintEstimatedFeeResponse.parse(Map<String, dynamic> json) =>
      GetTendermintEstimatedFeeResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: TendermintEstimatedFee.fromJson(json.value<JsonMap>('result')),
      );

  final TendermintEstimatedFee result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
