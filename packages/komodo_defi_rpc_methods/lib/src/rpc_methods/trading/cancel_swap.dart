import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to cancel a swap
class CancelSwapRequest
    extends BaseRequest<CancelSwapResponse, GeneralErrorResponse> {
  CancelSwapRequest({
    required String rpcPass,
    required this.uuid,
  }) : super(
         method: 'cancel_swap',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// UUID of the swap to cancel
  final String uuid;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson().deepMerge({'params': {'uuid': uuid}});

  @override
  CancelSwapResponse parse(Map<String, dynamic> json) =>
      CancelSwapResponse.parse(json);
}

/// Response from cancelling a swap
class CancelSwapResponse extends BaseResponse {
  CancelSwapResponse({
    required super.mmrpc,
    required this.cancelled,
  });

  factory CancelSwapResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return CancelSwapResponse(
      mmrpc: json.value<String>('mmrpc'),
      cancelled: result.value<bool>('success'),
    );
  }

  /// True if the swap was cancelled (request accepted by node)
  final bool cancelled;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'success': cancelled,
    },
  };
}


