import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Order status information
class OrderStatus {
  OrderStatus({
    required this.type,
    this.data,
  });

  factory OrderStatus.fromJson(JsonMap json) {
    return OrderStatus(
      type: json.value<String>('type'),
      data: json.valueOrNull<JsonMap?>('data'),
    );
  }

  final String type;
  final JsonMap? data;

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

  factory OrderMatchStatus.fromJson(JsonMap json) {
    return OrderMatchStatus(
      matched: json.value<bool>('matched'),
      ongoing: json.value<bool>('ongoing'),
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
      matchBy: json.valueOrNull<JsonMap?>('match_by'),
      confSettings: json.valueOrNull<JsonMap?>('conf_settings'),
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
  final JsonMap? matchBy;
  final JsonMap? confSettings;

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