import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class OneInchV6ClassicSwapLiquiditySourcesRequest
    extends
        BaseRequest<
          OneInchV6ClassicSwapLiquiditySourcesResponse,
          GeneralErrorResponse
        >
    with RequestHandlingMixin {
  OneInchV6ClassicSwapLiquiditySourcesRequest({
    required super.rpcPass,
    required this.chainId,
  }) : super(method: '1inch_v6_0_classic_swap_liquidity_sources', mmrpc: '2.0');

  final int chainId;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'chain_id': chainId},
  };

  @override
  OneInchV6ClassicSwapLiquiditySourcesResponse parse(
    Map<String, dynamic> json,
  ) => OneInchV6ClassicSwapLiquiditySourcesResponse.parse(json);
}

class OneInchV6ClassicSwapLiquiditySourcesResponse extends BaseResponse {
  OneInchV6ClassicSwapLiquiditySourcesResponse({
    required super.mmrpc,
    required this.result,
  });

  factory OneInchV6ClassicSwapLiquiditySourcesResponse.parse(
    Map<String, dynamic> json,
  ) => OneInchV6ClassicSwapLiquiditySourcesResponse(
    mmrpc: json.value<String>('mmrpc'),
    result: OneInchClassicLiquiditySources.fromJson(
      json.value<JsonMap>('result'),
    ),
  );

  final OneInchClassicLiquiditySources result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
