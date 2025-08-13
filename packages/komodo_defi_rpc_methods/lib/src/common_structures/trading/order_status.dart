import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Order status information
class OrderStatus {
  OrderStatus({required this.type, this.data});

  factory OrderStatus.fromJson(JsonMap json) {
    return OrderStatus(
      type: json.value<String>('type'),
      data:
          json.containsKey('data')
              ? OrderStatusData.fromJson(json.value<JsonMap>('data'))
              : null,
    );
  }

  /// Status type string as returned by the node
  final String type;
  /// Optional structured data for the status
  final OrderStatusData? data;

  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data!.toJson(),
  };
}

/// Order status data
class OrderStatusData {
  OrderStatusData({this.swapUuid, this.cancelledBy, this.errorMessage});

  factory OrderStatusData.fromJson(JsonMap json) {
    return OrderStatusData(
      swapUuid: json.valueOrNull<String?>('swap_uuid'),
      cancelledBy: json.valueOrNull<String?>('cancelled_by'),
      errorMessage: json.valueOrNull<String?>('error_message'),
    );
  }

  /// Related swap UUID if available
  final String? swapUuid;
  /// Who cancelled the order (user/system), if applicable
  final String? cancelledBy;
  /// Error message if the order failed
  final String? errorMessage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (swapUuid != null) map['swap_uuid'] = swapUuid;
    if (cancelledBy != null) map['cancelled_by'] = cancelledBy;
    if (errorMessage != null) map['error_message'] = errorMessage;
    return map;
  }
}

/// Order match status
class OrderMatchStatus {
  OrderMatchStatus({required this.matched, required this.ongoing});

  factory OrderMatchStatus.fromJson(JsonMap json) {
    return OrderMatchStatus(
      matched: json.value<bool>('matched'),
      ongoing: json.value<bool>('ongoing'),
    );
  }

  /// True if order has been matched
  final bool matched;
  /// True if matching is currently in progress
  final bool ongoing;

  Map<String, dynamic> toJson() => {'matched': matched, 'ongoing': ongoing};
}

/// Order match settings
class OrderMatchBy {
  OrderMatchBy({required this.type, this.data});

  factory OrderMatchBy.fromJson(JsonMap json) {
    final dataJson = json.valueOrNull<JsonMap>('data');
    return OrderMatchBy(
      type: json.value<String>('type'),
      data: dataJson != null ? OrderMatchByData.fromJson(dataJson) : null,
    );
  }

  /// Matching strategy type
  final String type;
  /// Additional parameters for the strategy
  final OrderMatchByData? data;

  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data!.toJson(),
  };
}

/// Order match by data
class OrderMatchByData {
  OrderMatchByData({this.coin, this.value});

  factory OrderMatchByData.fromJson(JsonMap json) {
    return OrderMatchByData(
      coin: json.valueOrNull<String?>('coin'),
      value: json.valueOrNull<String?>('value'),
    );
  }

  /// Coin ticker if the strategy is coin-specific
  final String? coin;
  /// Strategy parameter value
  final String? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (coin != null) map['coin'] = coin;
    if (value != null) map['value'] = value;
    return map;
  }
}

/// Order confirmation settings
class OrderConfirmationSettings {
  OrderConfirmationSettings({
    required this.baseConfs,
    required this.baseNota,
    required this.relConfs,
    required this.relNota,
  });

  factory OrderConfirmationSettings.fromJson(JsonMap json) {
    return OrderConfirmationSettings(
      baseConfs: json.value<int>('base_confs'),
      baseNota: json.value<bool>('base_nota'),
      relConfs: json.value<int>('rel_confs'),
      relNota: json.value<bool>('rel_nota'),
    );
  }

  /// Required confirmations for the base coin
  final int baseConfs;
  /// Whether notarization is required for the base coin
  final bool baseNota;
  /// Required confirmations for the rel coin
  final int relConfs;
  /// Whether notarization is required for the rel coin
  final bool relNota;

  Map<String, dynamic> toJson() => {
    'base_confs': baseConfs,
    'base_nota': baseNota,
    'rel_confs': relConfs,
    'rel_nota': relNota,
  };
}

/// My order information
class MyOrderInfo {
  MyOrderInfo({
    required this.uuid,
    required this.orderType,
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    required this.createdAt,
    required this.lastUpdated,
    required this.wasTimedOut,
    required this.status,
    this.matchBy,
    this.confSettings,
  });

  factory MyOrderInfo.fromJson(JsonMap json) {
    return MyOrderInfo(
      uuid: json.value<String>('uuid'),
      orderType: json.value<String>('order_type'),
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
      price: json.value<String>('price'),
      volume: json.value<String>('volume'),
      createdAt: json.value<int>('created_at'),
      lastUpdated: json.value<int>('last_updated'),
      wasTimedOut: json.value<bool>('was_timed_out'),
      status: OrderStatus.fromJson(json.value<JsonMap>('status')),
      matchBy:
          json.containsKey('match_by')
              ? OrderMatchBy.fromJson(json.value<JsonMap>('match_by'))
              : null,
      confSettings:
          json.containsKey('conf_settings')
              ? OrderConfirmationSettings.fromJson(
                json.value<JsonMap>('conf_settings'),
              )
              : null,
    );
  }

  /// Order UUID
  final String uuid;
  /// Order type (maker/taker)
  final String orderType;
  /// Base coin ticker
  final String base;
  /// Rel/quote coin ticker
  final String rel;
  /// Price per unit of base in rel (string numeric)
  final String price;
  /// Volume in base units (string numeric)
  final String volume;
  /// Creation timestamp (unix seconds)
  final int createdAt;
  /// Last updated timestamp (unix seconds)
  final int lastUpdated;
  /// True if the order timed out
  final bool wasTimedOut;
  /// Current status details
  final OrderStatus status;
  /// Matching strategy used for this order
  final OrderMatchBy? matchBy;
  /// Confirmation settings applied to this order
  final OrderConfirmationSettings? confSettings;

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'order_type': orderType,
    'base': base,
    'rel': rel,
    'price': price,
    'volume': volume,
    'created_at': createdAt,
    'last_updated': lastUpdated,
    'was_timed_out': wasTimedOut,
    'status': status.toJson(),
    if (matchBy != null) 'match_by': matchBy!.toJson(),
    if (confSettings != null) 'conf_settings': confSettings!.toJson(),
  };
}
