import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Structured address used within orderbook responses.
class OrderAddress {
  const OrderAddress({required this.addressData, required this.addressType});

  factory OrderAddress.fromJson(JsonMap json) {
    final addressData = json.valueOrNull<String>('address_data');
    final typeValue = json.valueOrNull<String>('address_type');

    if (typeValue == null) {
      throw ArgumentError('Key "address_type" not found in Map');
    }

    return OrderAddress(
      addressData: addressData,
      addressType: OrderAddressType.fromJson(typeValue),
    );
  }

  /// Address payload when nested under `address_data`.
  final String? addressData;

  /// Address type descriptor (e.g. Transparent, Shielded).
  final OrderAddressType addressType;

  Map<String, dynamic> toJson() => {
    'address_data': addressData,
    'address_type': addressType.toJson(),
  };
}

/// Available address types returned by the orderbook API.
enum OrderAddressType {
  transparent('Transparent'),
  shielded('Shielded');

  const OrderAddressType(this.value);

  final String value;

  /// Parses an [OrderAddressType] from its JSON representation.
  static OrderAddressType fromJson(String source) {
    return OrderAddressType.values.firstWhere(
      (type) => type.value.toLowerCase() == source.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown address type: $source'),
    );
  }

  /// Converts this enum to its JSON string representation.
  String toJson() => value;
}
