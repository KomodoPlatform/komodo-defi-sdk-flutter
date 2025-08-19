/// Defines the request_by object for best_orders.
///
/// Mirrors the KDF API structure:
/// - type: "volume" | "number"
/// - value: Decimal (as string) when type == volume, Unsigned int when type == number
class RequestBy {
  RequestBy._(this.type, this.volumeValue, this.numberValue);

  /// Create a volume-based request_by with a decimal value represented as string.
  factory RequestBy.volume(String value) => RequestBy._('volume', value, null);

  /// Create a number-based request_by with an unsigned integer value.
  factory RequestBy.number(int value) => RequestBy._('number', null, value);

  final String type;
  final String? volumeValue;
  final int? numberValue;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'value': type == 'volume' ? volumeValue! : numberValue!,
    };
  }
}
