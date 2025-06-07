import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class OneInchV6ClassicSwapCreateRequest
    extends
        BaseRequest<OneInchV6ClassicSwapCreateResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OneInchV6ClassicSwapCreateRequest({
    required super.rpcPass,
    required this.base,
    required this.rel,
    required this.amount,
    required this.slippage,
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
    this.excludedProtocols,
    this.permit,
    this.compatibility,
    this.receiver,
    this.referrer,
    this.disableEstimate,
    this.allowPartialFill,
    this.usePermit2,
  }) : super(method: '1inch_v6_0_classic_swap_create', mmrpc: '2.0');

  final String base;
  final String rel;
  final num amount;
  final num slippage;
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
  final String? excludedProtocols;
  final String? permit;
  final bool? compatibility;
  final String? receiver;
  final String? referrer;
  final bool? disableEstimate;
  final bool? allowPartialFill;
  final bool? usePermit2;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'base': base,
      'rel': rel,
      'amount': amount,
      'slippage': slippage,
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
      if (excludedProtocols != null) 'excluded_protocols': excludedProtocols,
      if (permit != null) 'permit': permit,
      if (compatibility != null) 'compatibility': compatibility,
      if (receiver != null) 'receiver': receiver,
      if (referrer != null) 'referrer': referrer,
      if (disableEstimate != null) 'disable_estimate': disableEstimate,
      if (allowPartialFill != null) 'allow_partial_fill': allowPartialFill,
      if (usePermit2 != null) 'use_permit2': usePermit2,
    },
  };

  @override
  OneInchV6ClassicSwapCreateResponse parse(Map<String, dynamic> json) =>
      OneInchV6ClassicSwapCreateResponse.parse(json);
}

class OneInchV6ClassicSwapCreateResponse extends BaseResponse {
  OneInchV6ClassicSwapCreateResponse({
    required super.mmrpc,
    required this.result,
  });

  factory OneInchV6ClassicSwapCreateResponse.parse(Map<String, dynamic> json) =>
      OneInchV6ClassicSwapCreateResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: OneInchClassicSwapCreate.fromJson(
          json.value<JsonMap>('result'),
        ),
      );

  final OneInchClassicSwapCreate result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
