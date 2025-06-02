import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Legacy request for creating a sell order
class SellRequest extends BaseRequest<SellResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  SellRequest({
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
  final Decimal price;
  final Decimal volume;
  final Decimal? minVolume;
  final MatchBy? matchBy;
  final OrderType? orderType;
  final int? baseConfs;
  final bool? baseNota;
  final int? relConfs;
  final bool? relNota;
  final bool saveInHistory;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'base': base,
    'rel': rel,
    'price': price.toJsonFractionalValue(),
    'volume': volume.toJsonFractionalValue(),
    if (minVolume != null)
      'min_volume': minVolume!.toJsonFractionalValue(),
    if (matchBy != null) 'match_by': matchBy!.toJson(),
    if (orderType != null) 'order_type': orderType!.toJson(),
    if (baseConfs != null) 'base_confs': baseConfs,
    if (baseNota != null) 'base_nota': baseNota,
    if (relConfs != null) 'rel_confs': relConfs,
    if (relNota != null) 'rel_nota': relNota,
    'save_in_history': saveInHistory,
  };

  @override
  SellResponse parse(Map<String, dynamic> json) => SellResponse.fromJson(json);
}

/// Legacy response for creating a sell order
class SellResponse extends BaseResponse {
  SellResponse({required super.mmrpc, required this.result});

  factory SellResponse.fromJson(Map<String, dynamic> json) {
    return SellResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result: OrderResult.fromJson(json.value<JsonMap>('result')),
    );
  }

  final OrderResult result;

  @override
  Map<String, dynamic> toJson() => {
    if (mmrpc != null) 'mmrpc': mmrpc,
    'result': result.toJson(),
  };
}
