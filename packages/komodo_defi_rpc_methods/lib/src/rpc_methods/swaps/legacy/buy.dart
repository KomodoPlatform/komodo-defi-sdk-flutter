import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Legacy request for creating a buy order
class BuyRequest extends BaseRequest<BuyResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  BuyRequest({
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
  }) : super(method: 'buy', mmrpc: null);

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
    'price': price,
    'volume': volume,
    if (minVolume != null) 'min_volume': minVolume,
    if (matchBy != null) 'match_by': matchBy!.toJson(),
    if (orderType != null) 'order_type': orderType,
    if (baseConfs != null) 'base_confs': baseConfs,
    if (baseNota != null) 'base_nota': baseNota,
    if (relConfs != null) 'rel_confs': relConfs,
    if (relNota != null) 'rel_nota': relNota,
    'save_in_history': saveInHistory,
  };

  @override
  BuyResponse parse(Map<String, dynamic> json) => BuyResponse.fromJson(json);
}

/// Legacy response for creating a buy order
class BuyResponse extends BaseResponse {
  BuyResponse({required super.mmrpc, required this.result});

  factory BuyResponse.fromJson(Map<String, dynamic> json) {
    return BuyResponse(
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

/// Result data for buy/sell order responses
class OrderResult {
  OrderResult({
    required this.action,
    required this.base,
    required this.baseAmount,
    required this.baseAmountRat,
    required this.destPubKey,
    required this.method,
    required this.rel,
    required this.relAmount,
    required this.relAmountRat,
    required this.senderPubkey,
    required this.uuid,
    required this.confSettings,
    this.matchBy,
    this.baseOrderbookTicker,
    this.relOrderbookTicker,
  });

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    return OrderResult(
      action: json.value<String>('action'),
      base: json.value<String>('base'),
      baseAmount: json.value<String>('base_amount'),
      baseAmountRat:
          RationalValue.fromJson(
            json.value<List<dynamic>>('base_amount_rat'),
          ).toDecimal(),
      destPubKey: json.value<String>('dest_pub_key'),
      method: json.value<String>('method'),
      rel: json.value<String>('rel'),
      relAmount: json.value<String>('rel_amount'),
      relAmountRat:
          RationalValue.fromJson(
            json.value<List<dynamic>>('rel_amount_rat'),
          ).toDecimal(),
      senderPubkey: json.value<String>('sender_pubkey'),
      uuid: json.value<String>('uuid'),
      matchBy:
          json.containsKey('match_by')
              ? MatchBy.fromJson(json.value<Map<String, dynamic>>('match_by'))
              : null,
      confSettings: OrderConfigurationSettings.fromJson(
        json.value<JsonMap>('conf_settings'),
      ),
      baseOrderbookTicker: json.valueOrNull<String>('base_orderbook_ticker'),
      relOrderbookTicker: json.valueOrNull<String>('rel_orderbook_ticker'),
    );
  }

  final String action;
  final String base;
  final String baseAmount;
  final Decimal baseAmountRat;
  final String destPubKey;
  final String method;
  final String rel;
  final String relAmount;
  final Decimal relAmountRat;
  final String senderPubkey;
  final String uuid;
  final MatchBy? matchBy;
  final OrderConfigurationSettings confSettings;
  final String? baseOrderbookTicker;
  final String? relOrderbookTicker;

  Map<String, dynamic> toJson() => {
    'action': action,
    'base': base,
    'base_amount': baseAmount,
    'base_amount_rat': baseAmountRat.toJsonFractionalValue(),
    'dest_pub_key': destPubKey,
    'method': method,
    'rel': rel,
    'rel_amount': relAmount,
    'rel_amount_rat': relAmountRat.toJsonFractionalValue(),
    'sender_pubkey': senderPubkey,
    'uuid': uuid,
    if (matchBy != null) 'match_by': matchBy?.toJson(),
    'conf_settings': confSettings.toJson(),
    if (baseOrderbookTicker != null)
      'base_orderbook_ticker': baseOrderbookTicker,
    if (relOrderbookTicker != null) 'rel_orderbook_ticker': relOrderbookTicker,
  };
}
