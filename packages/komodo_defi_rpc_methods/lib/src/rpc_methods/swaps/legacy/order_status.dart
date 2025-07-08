import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get the status of an order by UUID
class OrderStatusRequest
    extends BaseRequest<OrderStatusResponse, GeneralErrorResponse> {
  OrderStatusRequest({required this.uuid, super.rpcPass})
    : super(method: 'order_status', mmrpc: null);

  /// UUID of the order to display
  final String uuid;

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'uuid': uuid};

  @override
  OrderStatusResponse parse(Map<String, dynamic> json) =>
      OrderStatusResponse.fromJson(json);
}

/// Response for order status request
class OrderStatusResponse extends BaseResponse {
  OrderStatusResponse({
    required super.mmrpc,
    required this.type,
    required this.order,
    this.baseOrderbookTicker,
    this.relOrderbookTicker,
    this.cancellationReason,
  });

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      type: json.value<String>('type'),
      order: OrderStatusData.fromJson(json.value<JsonMap>('order')),
      baseOrderbookTicker: json.valueOrNull<String>('base_orderbook_ticker'),
      relOrderbookTicker: json.valueOrNull<String>('rel_orderbook_ticker'),
      cancellationReason: json.valueOrNull<String>('cancellation_reason'),
    );
  }

  /// Type of the order ("Maker" or "Taker")
  final String type;

  /// Order status data
  final OrderStatusData order;

  /// The orderbook ticker for base coin
  final String? baseOrderbookTicker;

  /// The orderbook ticker for rel coin
  final String? relOrderbookTicker;

  /// Cancellation reason (if applicable)
  final String? cancellationReason;

  @override
  Map<String, dynamic> toJson() => {
    if (mmrpc != null) 'mmrpc': mmrpc,
    'type': type,
    'order': order.toJson(),
    if (baseOrderbookTicker != null)
      'base_orderbook_ticker': baseOrderbookTicker,
    if (relOrderbookTicker != null) 'rel_orderbook_ticker': relOrderbookTicker,
    if (cancellationReason != null) 'cancellation_reason': cancellationReason,
  };
}

/// Order status data that handles both Maker and Taker order types
class OrderStatusData {
  OrderStatusData({
    required this.createdAt,
    required this.matches,
    this.availableAmount,
    this.base,
    this.cancellable,
    this.maxBaseVol,
    this.maxBaseVolRat,
    this.minBaseVol,
    this.minBaseVolRat,
    this.price,
    this.priceRat,
    this.rel,
    this.startedSwaps,
    this.uuid,
    this.confSettings,
    this.updatedAt,
    this.request,
    this.orderType,
    this.baseOrderbookTicker,
    this.relOrderbookTicker,
  });

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    // Parse matches map
    final matchesJson = json.value<Map<String, dynamic>>('matches');
    final matches = <String, OrderMatch>{};
    matchesJson.forEach((key, value) {
      matches[key] = OrderMatch.fromJson(value as Map<String, dynamic>);
    });

    return OrderStatusData(
      createdAt: json.value<int>('created_at'),
      matches: matches,
      availableAmount: json.valueOrNull<String>('available_amount'),
      base: json.valueOrNull<String>('base'),
      cancellable: json.valueOrNull<bool>('cancellable'),
      maxBaseVol: json.valueOrNull<String>('max_base_vol'),
      maxBaseVolRat:
          json.valueOrNull<List<dynamic>>('max_base_vol_rat') != null
              ? RationalValue.fromJson(
                json.value<List<dynamic>>('max_base_vol_rat'),
              )
              : null,
      minBaseVol: json.valueOrNull<String>('min_base_vol'),
      minBaseVolRat:
          json.valueOrNull<List<dynamic>>('min_base_vol_rat') != null
              ? RationalValue.fromJson(
                json.value<List<dynamic>>('min_base_vol_rat'),
              )
              : null,
      price: json.valueOrNull<String>('price'),
      priceRat:
          json.valueOrNull<List<dynamic>>('price_rat') != null
              ? RationalValue.fromJson(json.value<List<dynamic>>('price_rat'))
              : null,
      rel: json.valueOrNull<String>('rel'),
      startedSwaps:
          json.valueOrNull<List<dynamic>>('started_swaps')?.cast<String>(),
      uuid: json.valueOrNull<String>('uuid'),
      confSettings:
          json.valueOrNull<JsonMap>('conf_settings') != null
              ? OrderConfirmationSettings.fromJson(
                json.value<JsonMap>('conf_settings'),
              )
              : null,
      updatedAt: json.valueOrNull<int>('updated_at'),
      request:
          json.valueOrNull<JsonMap>('request') != null
              ? OrderMatchRequest.fromJson(json.value<JsonMap>('request'))
              : null,
      orderType:
          json.valueOrNull<JsonMap>('order_type') != null
              ? OrderType.fromJson(json.value<JsonMap>('order_type'))
              : null,
      baseOrderbookTicker: json.valueOrNull<String>('base_orderbook_ticker'),
      relOrderbookTicker: json.valueOrNull<String>('rel_orderbook_ticker'),
    );
  }

  /// Timestamp when the order was created
  final int createdAt;

  /// Order matches data
  final Map<String, OrderMatch> matches;

  // Maker order specific fields
  /// Available amount for maker orders
  final String? availableAmount;

  /// Base currency for maker orders
  final String? base;

  /// Whether the order can be cancelled
  final bool? cancellable;

  /// Maximum base volume for maker orders
  final String? maxBaseVol;

  /// Maximum base volume rational for maker orders
  final RationalValue? maxBaseVolRat;

  /// Minimum base volume for maker orders
  final String? minBaseVol;

  /// Minimum base volume rational for maker orders
  final RationalValue? minBaseVolRat;

  /// Price for maker orders
  final String? price;

  /// Price rational for maker orders
  final RationalValue? priceRat;

  /// Related currency for maker orders
  final String? rel;

  /// Started swaps for maker orders
  final List<String>? startedSwaps;

  /// UUID for maker orders
  final String? uuid;

  /// Confirmation settings for maker orders
  final OrderConfirmationSettings? confSettings;

  /// Updated timestamp for maker orders
  final int? updatedAt;

  // Taker order specific fields
  /// Original request for taker orders
  final OrderMatchRequest? request;

  /// Order type for taker orders
  final OrderType? orderType;

  /// Base orderbook ticker for taker orders
  final String? baseOrderbookTicker;

  /// Related orderbook ticker for taker orders
  final String? relOrderbookTicker;

  Map<String, dynamic> toJson() {
    final matchesJson = <String, dynamic>{};
    for (final entry in matches.entries) {
      matchesJson[entry.key] = entry.value.toJson();
    }

    return {
      'created_at': createdAt,
      'matches': matchesJson,
      if (availableAmount != null) 'available_amount': availableAmount,
      if (base != null) 'base': base,
      if (cancellable != null) 'cancellable': cancellable,
      if (maxBaseVol != null) 'max_base_vol': maxBaseVol,
      if (maxBaseVolRat != null) 'max_base_vol_rat': maxBaseVolRat!.toJson(),
      if (minBaseVol != null) 'min_base_vol': minBaseVol,
      if (minBaseVolRat != null) 'min_base_vol_rat': minBaseVolRat!.toJson(),
      if (price != null) 'price': price,
      if (priceRat != null) 'price_rat': priceRat!.toJson(),
      if (rel != null) 'rel': rel,
      if (startedSwaps != null) 'started_swaps': startedSwaps,
      if (uuid != null) 'uuid': uuid,
      if (confSettings != null) 'conf_settings': confSettings!.toJson(),
      if (updatedAt != null) 'updated_at': updatedAt,
      if (request != null) 'request': request!.toJson(),
      if (orderType != null) 'order_type': orderType!.toJson(),
      if (baseOrderbookTicker != null)
        'base_orderbook_ticker': baseOrderbookTicker,
      if (relOrderbookTicker != null)
        'rel_orderbook_ticker': relOrderbookTicker,
    };
  }
}
