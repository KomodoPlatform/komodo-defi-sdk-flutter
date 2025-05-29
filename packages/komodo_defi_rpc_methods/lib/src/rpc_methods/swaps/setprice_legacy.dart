import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Legacy request for creating a maker order (setprice)
class SetPriceLegacyRequest
    extends BaseRequest<SetPriceLegacyResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  SetPriceLegacyRequest({
    required this.base,
    required this.rel,
    required this.price,
    this.volume,
    this.max = false,
    this.cancelPrevious = true,
    this.minVolume,
    this.baseConfs,
    this.baseNota,
    this.relConfs,
    this.relNota,
    this.saveInHistory = true,
    super.rpcPass,
  }) : super(method: 'setprice', mmrpc: null);

  final String base;
  final String rel;
  final dynamic price;
  final dynamic? volume;
  final bool max;
  final bool cancelPrevious;
  final dynamic? minVolume;
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
    if (volume != null) 'volume': volume,
    'max': max,
    'cancel_previous': cancelPrevious,
    if (minVolume != null) 'min_volume': minVolume,
    if (baseConfs != null) 'base_confs': baseConfs,
    if (baseNota != null) 'base_nota': baseNota,
    if (relConfs != null) 'rel_confs': relConfs,
    if (relNota != null) 'rel_nota': relNota,
    'save_in_history': saveInHistory,
  };

  @override
  SetPriceLegacyResponse parse(Map<String, dynamic> json) =>
      SetPriceLegacyResponse.fromJson(json);
}

/// Legacy response for creating a maker order (setprice)
class SetPriceLegacyResponse extends BaseResponse {
  SetPriceLegacyResponse({
    required super.mmrpc,
    required this.result,
    this.baseOrderbookTicker,
    this.relOrderbookTicker,
  });

  factory SetPriceLegacyResponse.fromJson(Map<String, dynamic> json) {
    return SetPriceLegacyResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result: SetPriceResult.fromJson(json.value<JsonMap>('result')),
      baseOrderbookTicker: json.valueOrNull<String>('base_orderbook_ticker'),
      relOrderbookTicker: json.valueOrNull<String>('rel_orderbook_ticker'),
    );
  }

  final SetPriceResult result;
  final String? baseOrderbookTicker;
  final String? relOrderbookTicker;

  @override
  Map<String, dynamic> toJson() => {
    if (mmrpc != null) 'mmrpc': mmrpc,
    'result': result.toJson(),
    if (baseOrderbookTicker != null)
      'base_orderbook_ticker': baseOrderbookTicker,
    if (relOrderbookTicker != null) 'rel_orderbook_ticker': relOrderbookTicker,
  };
}

/// Result data for setprice response
class SetPriceResult {
  SetPriceResult({
    required this.base,
    required this.rel,
    required this.price,
    required this.priceRat,
    required this.maxBaseVol,
    required this.maxBaseVolRat,
    required this.minBaseVol,
    required this.minBaseVolRat,
    required this.createdAt,
    required this.updatedAt,
    required this.matches,
    required this.startedSwaps,
    required this.uuid,
    required this.confSettings,
  });

  factory SetPriceResult.fromJson(Map<String, dynamic> json) {
    return SetPriceResult(
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
      price: json.value<String>('price'),
      priceRat: json.value<dynamic>('price_rat'),
      maxBaseVol: json.value<String>('max_base_vol'),
      maxBaseVolRat: json.value<dynamic>('max_base_vol_rat'),
      minBaseVol: json.value<String>('min_base_vol'),
      minBaseVolRat: json.value<dynamic>('min_base_vol_rat'),
      createdAt: json.value<int>('created_at'),
      updatedAt: json.value<int>('updated_at'),
      matches: json.value<Map<String, dynamic>>('matches'),
      startedSwaps: json.value<List<dynamic>>('started_swaps').cast<String>(),
      uuid: json.value<String>('uuid'),
      confSettings: ConfSettings.fromJson(json.value<JsonMap>('conf_settings')),
    );
  }

  final String base;
  final String rel;
  final String price;
  final dynamic priceRat;
  final String maxBaseVol;
  final dynamic maxBaseVolRat;
  final String minBaseVol;
  final dynamic minBaseVolRat;
  final int createdAt;
  final int updatedAt;
  final Map<String, dynamic> matches;
  final List<String> startedSwaps;
  final String uuid;
  final ConfSettings confSettings;

  Map<String, dynamic> toJson() => {
    'base': base,
    'rel': rel,
    'price': price,
    'price_rat': priceRat,
    'max_base_vol': maxBaseVol,
    'max_base_vol_rat': maxBaseVolRat,
    'min_base_vol': minBaseVol,
    'min_base_vol_rat': minBaseVolRat,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'matches': matches,
    'started_swaps': startedSwaps,
    'uuid': uuid,
    'conf_settings': confSettings.toJson(),
  };
}

/// Confirmation settings for order
class ConfSettings {
  ConfSettings({this.baseConfs, this.baseNota, this.relConfs, this.relNota});

  factory ConfSettings.fromJson(Map<String, dynamic> json) {
    return ConfSettings(
      baseConfs: json.valueOrNull<int>('base_confs'),
      baseNota: json.valueOrNull<bool>('base_nota'),
      relConfs: json.valueOrNull<int>('rel_confs'),
      relNota: json.valueOrNull<bool>('rel_nota'),
    );
  }

  final int? baseConfs;
  final bool? baseNota;
  final int? relConfs;
  final bool? relNota;

  Map<String, dynamic> toJson() => {
    if (baseConfs != null) 'base_confs': baseConfs,
    if (baseNota != null) 'base_nota': baseNota,
    if (relConfs != null) 'rel_confs': relConfs,
    if (relNota != null) 'rel_nota': relNota,
  };
}
