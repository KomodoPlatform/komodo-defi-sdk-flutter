import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get orders history filtered by various criteria
class OrdersHistoryByFilterRequest
    extends BaseRequest<OrdersHistoryByFilterResponse, GeneralErrorResponse> {
  OrdersHistoryByFilterRequest({
    required String rpcPass,
    this.orderType,
    this.initialAction,
    this.base,
    this.rel,
    this.fromPrice,
    this.toPrice,
    this.fromVolume,
    this.toVolume,
    this.fromTimestamp,
    this.toTimestamp,
    this.wasTaker,
    this.status,
    this.includeDetails = false,
  }) : super(method: 'orders_history_by_filter', rpcPass: rpcPass, mmrpc: null);

  /// Return only orders that match the order_type; can be "Maker" or "Taker"
  final String? orderType;

  /// Return only orders that match the initial_action; can be "Sell" or "Buy"
  final String? initialAction;

  /// Return only orders that match the order.base = base condition
  final String? base;

  /// Return only orders that match the order.rel = rel condition
  final String? rel;

  /// Return only orders that match the order.price >= from_price condition
  final Decimal? fromPrice;

  /// Return only orders that match the order.price <= to_price condition
  final Decimal? toPrice;

  /// Return only orders that match the order.volume >= from_volume condition
  final Decimal? fromVolume;

  /// Return only orders that match the order.volume <= to_volume condition
  final Decimal? toVolume;

  /// Timestamp in UNIX format. Return only orders that match the
  /// order.created_at >= from_timestamp condition
  final int? fromTimestamp;

  /// Timestamp in UNIX format. Return only orders that match the
  /// order.created_at <= to_timestamp condition
  final int? toTimestamp;

  /// Return only GoodTillCancelled orders that got converted from taker
  /// to maker
  final bool? wasTaker;

  /// Return only orders that match the status
  final String? status;

  /// Whether to include complete order details in response; defaults to false
  final bool includeDetails;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};

    if (orderType != null) params['order_type'] = orderType;
    if (initialAction != null) params['initial_action'] = initialAction;
    if (base != null) params['base'] = base;
    if (rel != null) params['rel'] = rel;
    if (fromPrice != null) params['from_price'] = fromPrice!.toDouble();
    if (toPrice != null) params['to_price'] = toPrice!.toDouble();
    if (fromVolume != null) params['from_volume'] = fromVolume!.toDouble();
    if (toVolume != null) params['to_volume'] = toVolume!.toDouble();
    if (fromTimestamp != null) params['from_timestamp'] = fromTimestamp;
    if (toTimestamp != null) params['to_timestamp'] = toTimestamp;
    if (wasTaker != null) params['was_taker'] = wasTaker;
    if (status != null) params['status'] = status;
    params['include_details'] = includeDetails;

    return super.toJson().deepMerge(params);
  }

  @override
  OrdersHistoryByFilterResponse parse(Map<String, dynamic> json) =>
      OrdersHistoryByFilterResponse.parse(json);
}

class OrdersHistoryByFilterResponse extends BaseResponse {
  OrdersHistoryByFilterResponse({
    required super.mmrpc,
    required this.result,
    super.id,
  });

  factory OrdersHistoryByFilterResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    return OrdersHistoryByFilterResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      result: OrdersHistoryResult.fromJson(result),
    );
  }

  /// The result containing orders, details, and metadata
  final OrdersHistoryResult result;

  @override
  Map<String, dynamic> toJson() {
    return {
      if (mmrpc != null) 'mmrpc': mmrpc,
      if (id != null) 'id': id,
      'result': result.toJson(),
    };
  }
}

/// Result data for orders history by filter response
class OrdersHistoryResult {
  OrdersHistoryResult({
    required this.orders,
    required this.details,
    required this.foundRecords,
    required this.warnings,
  });

  factory OrdersHistoryResult.fromJson(Map<String, dynamic> json) {
    return OrdersHistoryResult(
      orders:
          json
              .value<List<dynamic>>('orders')
              .map<OrderSummaryData>(
                (order) => OrderSummaryData.fromJson(order as JsonMap),
              )
              .toList(),
      details:
          json
              .value<List<dynamic>>('details')
              .map<OrderDetail>(
                (detail) => OrderDetail.fromJson(detail as JsonMap),
              )
              .toList(),
      foundRecords: json.value<int>('found_records'),
      warnings:
          json
              .value<List<dynamic>>('warnings')
              .map<OrderWarning>(
                (warning) => OrderWarning.fromJson(warning as JsonMap),
              )
              .toList(),
    );
  }

  /// Array of OrderSummaryData that match the selected filters
  final List<OrderSummaryData> orders;

  /// Array of complete order details for every order that matches the
  /// selected filters
  final List<OrderDetail> details;

  /// The number of returned orders
  final int foundRecords;

  /// Array containing warnings objects
  final List<OrderWarning> warnings;

  Map<String, dynamic> toJson() => {
    'orders': orders.map((order) => order.toJson()).toList(),
    'details': details.map((detail) => detail.toJson()).toList(),
    'found_records': foundRecords,
    'warnings': warnings.map((warning) => warning.toJson()).toList(),
  };
}

/// Summary data for an order
class OrderSummaryData {
  OrderSummaryData({
    required this.uuid,
    required this.orderType,
    required this.initialAction,
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    required this.createdAt,
    required this.lastUpdated,
    required this.wasTaker,
    required this.status,
  });

  factory OrderSummaryData.fromJson(Map<String, dynamic> json) {
    return OrderSummaryData(
      uuid: json.value<String>('uuid'),
      orderType: json.value<String>('order_type'),
      initialAction: json.value<String>('initial_action'),
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
      price: json.value<num>('price'),
      volume: json.value<num>('volume'),
      createdAt: json.value<int>('created_at'),
      lastUpdated: json.value<int>('last_updated'),
      wasTaker: json.value<int>('was_taker'),
      status: json.value<String>('status'),
    );
  }

  /// UUID of the order
  final String uuid;

  /// Type of the order; "Maker" or "Taker"
  final String orderType;

  /// Initial action of the order; "Sell" or "Buy"
  final String initialAction;

  /// Base currency
  final String base;

  /// Rel currency
  final String rel;

  /// Price of the order
  final num price;

  /// Volume of the order
  final num volume;

  /// Timestamp when the order was created
  final int createdAt;

  /// Timestamp when the order was last updated
  final int lastUpdated;

  /// Whether the order was a taker (0 or 1)
  final int wasTaker;

  /// Status of the order
  final String status;

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'order_type': orderType,
    'initial_action': initialAction,
    'base': base,
    'rel': rel,
    'price': price,
    'volume': volume,
    'created_at': createdAt,
    'last_updated': lastUpdated,
    'was_taker': wasTaker,
    'status': status,
  };
}

/// Detailed order information
class OrderDetail {
  OrderDetail({required this.type, required this.order});

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      type: json.value<String>('type'),
      order: OrderDataV1.fromJson(json.value<JsonMap>('order')),
    );
  }

  /// Type of the order; "Maker" or "Taker"
  final String type;

  /// A standard OrderDataV1 object containing order details
  final OrderDataV1 order;

  Map<String, dynamic> toJson() => {'type': type, 'order': order.toJson()};
}

/// OrderDataV1 structure for detailed order information
class OrderDataV1 {
  OrderDataV1({
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

  factory OrderDataV1.fromJson(Map<String, dynamic> json) {
    return OrderDataV1(
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
      price: json.value<String>('price'),
      priceRat: RationalValue.fromJson(json.value<List<dynamic>>('price_rat')),
      maxBaseVol: json.value<String>('max_base_vol'),
      maxBaseVolRat: RationalValue.fromJson(
        json.value<List<dynamic>>('max_base_vol_rat'),
      ),
      minBaseVol: json.value<String>('min_base_vol'),
      minBaseVolRat: RationalValue.fromJson(
        json.value<List<dynamic>>('min_base_vol_rat'),
      ),
      createdAt: json.value<int>('created_at'),
      updatedAt: json.value<int>('updated_at'),
      matches: json.value<Map<String, dynamic>>('matches'),
      startedSwaps: json.value<List<dynamic>>('started_swaps').cast<String>(),
      uuid: json.value<String>('uuid'),
      confSettings: OrderConfirmationSettings.fromJson(
        json.value<JsonMap>('conf_settings'),
      ),
    );
  }

  /// Base currency
  final String base;

  /// Rel currency
  final String rel;

  /// Price as string
  final String price;

  /// Price rational format
  final RationalValue priceRat;

  /// Maximum base volume as string
  final String maxBaseVol;

  /// Maximum base volume rational format
  final RationalValue maxBaseVolRat;

  /// Minimum base volume as string
  final String minBaseVol;

  /// Minimum base volume rational format
  final RationalValue minBaseVolRat;

  /// Created timestamp
  final int createdAt;

  /// Updated timestamp
  final int updatedAt;

  /// Matches object
  final Map<String, dynamic> matches;

  /// Started swaps list
  final List<String> startedSwaps;

  /// UUID of the order
  final String uuid;

  /// Confirmation settings
  final OrderConfirmationSettings confSettings;

  Map<String, dynamic> toJson() => {
    'base': base,
    'rel': rel,
    'price': price,
    'price_rat': priceRat.toJson(),
    'max_base_vol': maxBaseVol,
    'max_base_vol_rat': maxBaseVolRat.toJson(),
    'min_base_vol': minBaseVol,
    'min_base_vol_rat': minBaseVolRat.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
    'matches': matches,
    'started_swaps': startedSwaps,
    'uuid': uuid,
    'conf_settings': confSettings.toJson(),
  };
}

/// Warning information for orders
class OrderWarning {
  OrderWarning({required this.uuid, required this.warning});

  factory OrderWarning.fromJson(Map<String, dynamic> json) {
    return OrderWarning(
      uuid: json.value<String>('uuid'),
      warning: json.value<String>('warning'),
    );
  }

  /// UUID of the order that produced this warning
  final String uuid;

  /// Warning message
  final String warning;

  Map<String, dynamic> toJson() => {'uuid': uuid, 'warning': warning};
}
