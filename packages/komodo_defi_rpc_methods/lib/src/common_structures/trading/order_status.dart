/// Order status information
class OrderStatus {
  OrderStatus({
    required this.type,
    this.data,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  final String type;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data,
  };
}

/// Order match status
class OrderMatchStatus {
  OrderMatchStatus({
    required this.matched,
    required this.ongoing,
  });

  factory OrderMatchStatus.fromJson(Map<String, dynamic> json) {
    return OrderMatchStatus(
      matched: json['matched'] as bool,
      ongoing: json['ongoing'] as bool,
    );
  }

  final bool matched;
  final bool ongoing;

  Map<String, dynamic> toJson() => {
    'matched': matched,
    'ongoing': ongoing,
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

  factory MyOrderInfo.fromJson(Map<String, dynamic> json) {
    return MyOrderInfo(
      uuid: json['uuid'] as String,
      orderType: json['order_type'] as String,
      base: json['base'] as String,
      rel: json['rel'] as String,
      price: json['price'] as String,
      volume: json['volume'] as String,
      createdAt: json['created_at'] as int,
      lastUpdated: json['last_updated'] as int,
      wasTimedOut: json['was_timed_out'] as bool,
      status: OrderStatus.fromJson(json['status'] as Map<String, dynamic>),
      matchBy: json['match_by'] as Map<String, dynamic>?,
      confSettings: json['conf_settings'] as Map<String, dynamic>?,
    );
  }

  final String uuid;
  final String orderType;
  final String base;
  final String rel;
  final String price;
  final String volume;
  final int createdAt;
  final int lastUpdated;
  final bool wasTimedOut;
  final OrderStatus status;
  final Map<String, dynamic>? matchBy;
  final Map<String, dynamic>? confSettings;

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
    if (matchBy != null) 'match_by': matchBy,
    if (confSettings != null) 'conf_settings': confSettings,
  };
}