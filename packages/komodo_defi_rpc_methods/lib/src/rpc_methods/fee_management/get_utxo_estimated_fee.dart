import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get estimated UTXO fee per kbyte
class GetUtxoEstimatedFeeRequest
    extends BaseRequest<GetUtxoEstimatedFeeResponse, GeneralErrorResponse> {
  GetUtxoEstimatedFeeRequest({
    required super.rpcPass,
    required this.coin,
    this.estimatorType = FeeEstimatorType.simple,
  }) : super(method: 'get_utxo_estimated_fee', mmrpc: '2.0');

  final String coin;
  final FeeEstimatorType estimatorType;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'estimator_type': estimatorType.toString()},
  };

  @override
  GetUtxoEstimatedFeeResponse parse(Map<String, dynamic> json) =>
      GetUtxoEstimatedFeeResponse.parse(json);
}

/// Response containing UTXO fee estimates
class GetUtxoEstimatedFeeResponse extends BaseResponse {
  GetUtxoEstimatedFeeResponse({required super.mmrpc, required this.result});

  factory GetUtxoEstimatedFeeResponse.parse(Map<String, dynamic> json) =>
      GetUtxoEstimatedFeeResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: UtxoEstimatedFee.fromJson(json.value<JsonMap>('result')),
      );

  final UtxoEstimatedFee result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
