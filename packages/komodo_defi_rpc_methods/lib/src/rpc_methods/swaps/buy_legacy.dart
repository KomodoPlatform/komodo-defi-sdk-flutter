import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Legacy request for creating a buy order
class BuyLegacyRequest
    extends BaseRequest<BuyLegacyResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  BuyLegacyRequest({
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
  final dynamic price;
  final dynamic volume;
  final dynamic minVolume;
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
  BuyLegacyResponse parse(Map<String, dynamic> json) =>
      BuyLegacyResponse.fromJson(json);
}

/// Legacy response for creating a buy order
class BuyLegacyResponse extends BaseResponse {
  BuyLegacyResponse({required super.mmrpc, required this.result});

  factory BuyLegacyResponse.fromJson(Map<String, dynamic> json) {
    return BuyLegacyResponse(
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

/// Result data for buy/sell order responses
class LegacyOrderResult {
  LegacyOrderResult({
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

  factory LegacyOrderResult.fromJson(Map<String, dynamic> json) {
    return LegacyOrderResult(
      action: json.value<String>('action'),
      base: json.value<String>('base'),
      baseAmount: json.value<String>('base_amount'),
      baseAmountRat: RationalValue.fromJson(
        json.value<List<dynamic>>('base_amount_rat'),
      ),
      destPubKey: json.value<String>('dest_pub_key'),
      method: json.value<String>('method'),
      rel: json.value<String>('rel'),
      relAmount: json.value<String>('rel_amount'),
      relAmountRat: RationalValue.fromJson(
        json.value<List<dynamic>>('rel_amount_rat'),
      ),
      senderPubkey: json.value<String>('sender_pubkey'),
      uuid: json.value<String>('uuid'),
      matchBy:
          json.containsKey('match_by')
              ? json.value<Map<String, dynamic>>('match_by')
              : null,
      confSettings: ConfSettings.fromJson(json.value<JsonMap>('conf_settings')),
      baseOrderbookTicker: json.valueOrNull<String>('base_orderbook_ticker'),
      relOrderbookTicker: json.valueOrNull<String>('rel_orderbook_ticker'),
    );
  }

  final String action;
  final String base;
  final String baseAmount;
  final RationalValue baseAmountRat;
  final String destPubKey;
  final String method;
  final String rel;
  final String relAmount;
  final RationalValue relAmountRat;
  final String senderPubkey;
  final String uuid;
  final Map<String, dynamic>? matchBy;
  final ConfSettings confSettings;
  final String? baseOrderbookTicker;
  final String? relOrderbookTicker;

  Map<String, dynamic> toJson() => {
    'action': action,
    'base': base,
    'base_amount': baseAmount,
    'base_amount_rat': baseAmountRat.toJson(),
    'dest_pub_key': destPubKey,
    'method': method,
    'rel': rel,
    'rel_amount': relAmount,
    'rel_amount_rat': relAmountRat.toJson(),
    'sender_pubkey': senderPubkey,
    'uuid': uuid,
    if (matchBy != null) 'match_by': matchBy,
    'conf_settings': confSettings.toJson(),
    if (baseOrderbookTicker != null)
      'base_orderbook_ticker': baseOrderbookTicker,
    if (relOrderbookTicker != null) 'rel_orderbook_ticker': relOrderbookTicker,
  };
}
