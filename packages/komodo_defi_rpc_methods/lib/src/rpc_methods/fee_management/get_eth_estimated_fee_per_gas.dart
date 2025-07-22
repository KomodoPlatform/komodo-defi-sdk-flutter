import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetEthEstimatedFeePerGasRequest
    extends
        BaseRequest<GetEthEstimatedFeePerGasResponse, GeneralErrorResponse> {
  GetEthEstimatedFeePerGasRequest({
    required super.rpcPass,
    required this.coin,
    required this.estimatorType,
  }) : super(method: 'get_eth_estimated_fee_per_gas', mmrpc: '2.0');

  final String coin;
  final FeeEstimatorType estimatorType;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'estimator_type': estimatorType.toString()},
  };

  @override
  GetEthEstimatedFeePerGasResponse parse(Map<String, dynamic> json) =>
      GetEthEstimatedFeePerGasResponse.parse(json);
}

class GetEthEstimatedFeePerGasResponse extends BaseResponse {
  GetEthEstimatedFeePerGasResponse({
    required super.mmrpc,
    required this.result,
  });

  factory GetEthEstimatedFeePerGasResponse.parse(Map<String, dynamic> json) =>
      GetEthEstimatedFeePerGasResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: EthEstimatedFeePerGas.fromJson(json.value<JsonMap>('result')),
      );

  final EthEstimatedFeePerGas result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
