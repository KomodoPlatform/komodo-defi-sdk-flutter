import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to enable fee estimator for a specific coin
class FeeEstimatorEnableRequest
    extends BaseRequest<FeeEstimatorEnableResponse, GeneralErrorResponse> {
  FeeEstimatorEnableRequest({
    required super.rpcPass,
    required this.coin,
    required this.estimatorType,
  }) : super(method: 'fee_estimator_enable', mmrpc: '2.0');

  final String coin;
  final String estimatorType;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'estimator_type': estimatorType},
  };

  @override
  FeeEstimatorEnableResponse parse(Map<String, dynamic> json) =>
      FeeEstimatorEnableResponse.parse(json);
}

/// Response from enabling fee estimator
class FeeEstimatorEnableResponse extends BaseResponse {
  FeeEstimatorEnableResponse({required super.mmrpc, required this.result});

  factory FeeEstimatorEnableResponse.parse(Map<String, dynamic> json) =>
      FeeEstimatorEnableResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: json.value<String>('result'),
      );

  final String result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result};
}
