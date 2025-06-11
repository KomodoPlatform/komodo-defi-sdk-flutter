import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class OneInchV6ClassicSwapTokensRequest
    extends
        BaseRequest<OneInchV6ClassicSwapTokensResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OneInchV6ClassicSwapTokensRequest({
    required super.rpcPass,
    required this.chainId,
  }) : super(method: '1inch_v6_0_classic_swap_tokens', mmrpc: '2.0');

  final int chainId;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'chain_id': chainId},
  };

  @override
  OneInchV6ClassicSwapTokensResponse parse(Map<String, dynamic> json) =>
      OneInchV6ClassicSwapTokensResponse.parse(json);
}

class OneInchV6ClassicSwapTokensResponse extends BaseResponse {
  OneInchV6ClassicSwapTokensResponse({
    required super.mmrpc,
    required this.result,
  });

  factory OneInchV6ClassicSwapTokensResponse.parse(Map<String, dynamic> json) =>
      OneInchV6ClassicSwapTokensResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: OneInchClassicSwapTokens.fromJson(
          json.value<JsonMap>('result'),
        ),
      );

  final OneInchClassicSwapTokens result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
