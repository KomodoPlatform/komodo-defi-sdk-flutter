import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class OneInchV6ClassicSwapQuoteRequest
    extends BaseRequest<OneInchV6ClassicSwapQuoteResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OneInchV6ClassicSwapQuoteRequest({
    required super.rpcPass,
    required this.base,
    required this.rel,
    required this.amount,
    this.fee,
    this.protocols,
    this.gasPrice,
    this.complexityLevel,
    this.parts,
    this.mainRouteParts,
    this.gasLimit,
    this.includeTokensInfo,
    this.includeProtocols,
    this.includeGas,
    this.connectorTokens,
  }) : super(method: '1inch_v6_0_classic_swap_quote', mmrpc: '2.0');

  final String base;
  final String rel;
  final num amount;
  final num? fee;
  final String? protocols;
  final String? gasPrice;
  final int? complexityLevel;
  final int? parts;
  final int? mainRouteParts;
  final int? gasLimit;
  final bool? includeTokensInfo;
  final bool? includeProtocols;
  final bool? includeGas;
  final String? connectorTokens;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'base': base,
      'rel': rel,
      'amount': amount,
      if (fee != null) 'fee': fee,
      if (protocols != null) 'protocols': protocols,
      if (gasPrice != null) 'gas_price': gasPrice,
      if (complexityLevel != null) 'complexity_level': complexityLevel,
      if (parts != null) 'parts': parts,
      if (mainRouteParts != null) 'main_route_parts': mainRouteParts,
      if (gasLimit != null) 'gas_limit': gasLimit,
      if (includeTokensInfo != null) 'include_tokens_info': includeTokensInfo,
      if (includeProtocols != null) 'include_protocols': includeProtocols,
      if (includeGas != null) 'include_gas': includeGas,
      if (connectorTokens != null) 'connector_tokens': connectorTokens,
    },
  };

  @override
  OneInchV6ClassicSwapQuoteResponse parse(Map<String, dynamic> json) =>
      OneInchV6ClassicSwapQuoteResponse.parse(json);
}

class OneInchV6ClassicSwapQuoteResponse extends BaseResponse {
  OneInchV6ClassicSwapQuoteResponse({
    required super.mmrpc,
    required this.result,
  });

  factory OneInchV6ClassicSwapQuoteResponse.parse(Map<String, dynamic> json) =>
      OneInchV6ClassicSwapQuoteResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: OneInchClassicSwapQuote.fromJson(json.value<JsonMap>('result')),
      );

  final OneInchClassicSwapQuote result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
