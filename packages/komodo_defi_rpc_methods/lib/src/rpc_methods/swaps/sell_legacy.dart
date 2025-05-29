import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Legacy request for creating a sell order
class SellLegacyRequest
    extends BaseRequest<SellLegacyResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  SellLegacyRequest({
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    this.minVolume,
    this.matchBy,
    this.orderType,
    this.baseConfs,
    this.baseNota,
    this.relConfs,
    this.relNota,
    this.saveInHistory = true,
    super.rpcPass,
  }) : super(method: 'sell', mmrpc: null);

  final String base;
  final String rel;
  final dynamic price;
  final dynamic volume;
  final dynamic? minVolume;
  final Map<String, dynamic>? matchBy;
  final Map<String, dynamic>? orderType;
  final int? baseConfs;
  final bool? baseNota;
  final int? relConfs;
  final bool? relNota;
  final bool saveInHistory;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'base': base,
    'rel': rel,
    'price': price,
    'volume': volume,
    if (minVolume != null) 'min_volume': minVolume,
    if (matchBy != null) 'match_by': matchBy,
    if (orderType != null) 'order_type': orderType,
    if (baseConfs != null) 'base_confs': baseConfs,
    if (baseNota != null) 'base_nota': baseNota,
    if (relConfs != null) 'rel_confs': relConfs,
    if (relNota != null) 'rel_nota': relNota,
    'save_in_history': saveInHistory,
  };

  @override
  SellLegacyResponse parse(Map<String, dynamic> json) =>
      SellLegacyResponse.fromJson(json);
}

/// Legacy response for creating a sell order
class SellLegacyResponse extends BaseResponse {
  SellLegacyResponse({required super.mmrpc, required this.result});

  factory SellLegacyResponse.fromJson(Map<String, dynamic> json) {
    return SellLegacyResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result: LegacyOrderResult.fromJson(json.value<JsonMap>('result')),
    );
  }

  final LegacyOrderResult result;

  @override
  Map<String, dynamic> toJson() => {
    if (mmrpc != null) 'mmrpc': mmrpc,
    'result': result.toJson(),
  };
}
