import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Result of a completed swap operation
class SwapResult extends Equatable {
  const SwapResult({
    required this.uuid,
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    required this.orderType,
    this.txHash,
    this.createdAt,
  });

  /// Unique identifier for the swap/order
  final String uuid;

  /// Base coin ticker
  final String base;

  /// Rel coin ticker
  final String rel;

  /// Price of the trade
  final Decimal price;

  /// Volume of the trade
  final Decimal volume;

  /// Type of order (maker/taker)
  final String orderType;

  /// Transaction hash (for completed swaps)
  final String? txHash;

  /// Timestamp when the order was created
  final int? createdAt;

  @override
  List<Object?> get props => [
        uuid,
        base,
        rel,
        price,
        volume,
        orderType,
        txHash,
        createdAt,
      ];

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'base': base,
        'rel': rel,
        'price': price.toString(),
        'volume': volume.toString(),
        'order_type': orderType,
        if (txHash != null) 'tx_hash': txHash,
        if (createdAt != null) 'created_at': createdAt,
      };
}