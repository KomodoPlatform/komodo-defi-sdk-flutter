import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Match configuration for order matching
abstract class MatchBy {
  const MatchBy();

  factory MatchBy.fromJson(Map<String, dynamic> json) {
    final type = json.value<String>('type');
    switch (type) {
      case 'Any':
        return const MatchByAny();
      case 'Orders':
        return MatchByOrders.fromJson(json);
      case 'Pubkeys':
        return MatchByPubkeys.fromJson(json);
      default:
        throw ArgumentError('Unknown match type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

/// Match with any other order
class MatchByAny extends MatchBy {
  const MatchByAny();

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'Any'};
  }
}

/// Match with specific order UUIDs
class MatchByOrders extends MatchBy {
  const MatchByOrders({required this.data});

  factory MatchByOrders.fromJson(Map<String, dynamic> json) {
    return MatchByOrders(
      data: List<String>.from(json.value<List<dynamic>>('data')),
    );
  }

  /// List of order UUIDs to match with
  final List<String> data;

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'Orders', 'data': data};
  }
}

/// Match with specific node pubkeys
class MatchByPubkeys extends MatchBy {
  const MatchByPubkeys({required this.data});

  factory MatchByPubkeys.fromJson(Map<String, dynamic> json) {
    return MatchByPubkeys(
      data: List<String>.from(json.value<List<dynamic>>('data')),
    );
  }

  /// List of node pubkeys to match with
  final List<String> data;

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'Pubkeys', 'data': data};
  }
}
