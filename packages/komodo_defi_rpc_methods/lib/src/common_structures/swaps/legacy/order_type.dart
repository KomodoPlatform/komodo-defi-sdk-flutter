import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:meta/meta.dart';

/// Legacy order type for trade orders
@immutable
class OrderType {
  const OrderType({required this.type});

  factory OrderType.fromJson(Map<String, dynamic> json) {
    return OrderType(
      type: OrderTypeEnum.fromString(json.value<String>('type')),
    );
  }

  /// Creates a GoodTillCancelled order type
  factory OrderType.goodTillCancelled() {
    return const OrderType(type: OrderTypeEnum.goodTillCancelled);
  }

  /// Creates a FillOrKill order type
  factory OrderType.fillOrKill() {
    return const OrderType(type: OrderTypeEnum.fillOrKill);
  }

  final OrderTypeEnum type;

  Map<String, dynamic> toJson() => {'type': type.value};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderType &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'OrderType(type: $type)';
}

/// Enum representing the different order types
enum OrderTypeEnum {
  /// Order is automatically converted to a maker order if not matched in 30 seconds,
  /// and stays in the orderbook until explicitly cancelled
  goodTillCancelled('GoodTillCancelled'),

  /// Order is cancelled if not matched within 30 seconds
  fillOrKill('FillOrKill');

  const OrderTypeEnum(this.value);

  final String value;

  static OrderTypeEnum fromString(String value) {
    switch (value) {
      case 'GoodTillCancelled':
        return OrderTypeEnum.goodTillCancelled;
      case 'FillOrKill':
        return OrderTypeEnum.fillOrKill;
      default:
        throw ArgumentError('Unknown OrderTypeEnum value: $value');
    }
  }

  @override
  String toString() => value;
}
