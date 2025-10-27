part of 'kdf_event.dart';

/// Order status update event from stream::order_status::enable
class OrderStatusEvent extends KdfEvent {
  OrderStatusEvent({
    required this.uuid,
    required this.orderInfo,
  });

  @override
  EventTypeString get typeEnum => EventTypeString.orderStatus;

  factory OrderStatusEvent.fromJson(JsonMap json) {
    return OrderStatusEvent(
      uuid: json.value<String>('uuid'),
      orderInfo: MyOrderInfo.fromJson(json.value<JsonMap>('order')),
    );
  }

  /// The UUID of the order
  final String uuid;

  /// Detailed order information
  final MyOrderInfo orderInfo;

  @override
  String toString() => 'OrderStatusEvent(uuid: $uuid)';
}

