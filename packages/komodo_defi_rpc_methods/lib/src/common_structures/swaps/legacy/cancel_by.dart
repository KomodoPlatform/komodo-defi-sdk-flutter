import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Cancel configuration for order cancellation
abstract class CancelBy {
  const CancelBy();

  factory CancelBy.fromJson(Map<String, dynamic> json) {
    final type = json.value<String>('type');
    switch (type) {
      case 'All':
        return const CancelByAll();
      case 'Pair':
        return CancelByPair.fromJson(json);
      case 'Coin':
        return CancelByCoin.fromJson(json);
      default:
        throw ArgumentError('Unknown cancel type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

/// Cancel all orders
class CancelByAll extends CancelBy {
  const CancelByAll();

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'All'};
  }
}

/// Cancel orders for a specific trading pair
class CancelByPair extends CancelBy {
  const CancelByPair({required this.data});

  factory CancelByPair.fromJson(Map<String, dynamic> json) {
    final data = json.value<JsonMap>('data');
    return CancelByPair(data: CancelByPairData.fromJson(data));
  }

  /// The trading pair data
  final CancelByPairData data;

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'Pair', 'data': data.toJson()};
  }
}

/// Data for cancelling orders by trading pair
class CancelByPairData {
  const CancelByPairData({required this.base, required this.rel});

  factory CancelByPairData.fromJson(Map<String, dynamic> json) {
    return CancelByPairData(
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
    );
  }

  /// Base currency of the pair
  final String base;

  /// Related currency (quote currency) of the pair
  final String rel;

  Map<String, dynamic> toJson() => {'base': base, 'rel': rel};
}

/// Cancel orders for a specific coin
class CancelByCoin extends CancelBy {
  const CancelByCoin({required this.data});

  factory CancelByCoin.fromJson(Map<String, dynamic> json) {
    final data = json.value<JsonMap>('data');
    return CancelByCoin(data: CancelByCoinData.fromJson(data));
  }

  /// The coin data
  final CancelByCoinData data;

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'Coin', 'data': data.toJson()};
  }
}

/// Data for cancelling orders by coin
class CancelByCoinData {
  const CancelByCoinData({required this.ticker});

  factory CancelByCoinData.fromJson(Map<String, dynamic> json) {
    return CancelByCoinData(ticker: json.value<String>('ticker'));
  }

  /// The ticker symbol of the coin
  final String ticker;

  Map<String, dynamic> toJson() => {'ticker': ticker};
}
