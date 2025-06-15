import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request type for best orders - either by number or volume
abstract class RequestBy {
  const RequestBy();

  factory RequestBy.fromJson(Map<String, dynamic> json) {
    final type = json.value<String>('type');
    switch (type) {
      case 'number':
        return RequestByNumber.fromJson(json);
      case 'volume':
        return RequestByVolume.fromJson(json);
      default:
        throw ArgumentError('Unknown request type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

/// Request by number of orders
class RequestByNumber extends RequestBy {
  const RequestByNumber({required this.value});

  factory RequestByNumber.fromJson(Map<String, dynamic> json) {
    return RequestByNumber(value: json.value<int>('value'));
  }

  /// Number of orders to return
  final int value;

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'number', 'value': value};
  }
}

/// Request by volume
class RequestByVolume extends RequestBy {
  const RequestByVolume({required this.value});

  factory RequestByVolume.fromJson(Map<String, dynamic> json) {
    return RequestByVolume(value: json.value<double>('value'));
  }

  /// Volume threshold
  final double value;

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'volume', 'value': value};
  }
}
