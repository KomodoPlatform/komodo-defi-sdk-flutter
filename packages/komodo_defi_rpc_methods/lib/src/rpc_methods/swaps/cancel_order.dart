import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to cancel a specific order
class CancelOrderRequest
    extends BaseRequest<CancelOrderResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  CancelOrderRequest({
    required this.uuid,
    super.rpcPass,
  }) : super(method: 'cancel_order', mmrpc: '2.0');

  final String uuid;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'userpass': rpcPass,
        'params': {
          'uuid': uuid,
        },
      };

  @override
  CancelOrderResponse parse(Map<String, dynamic> json) =>
      CancelOrderResponse.fromJson(json);
}

/// Response for cancel_order
class CancelOrderResponse extends BaseResponse {
  CancelOrderResponse({
    required super.mmrpc,
    required this.result,
  });

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': result,
      };
}
