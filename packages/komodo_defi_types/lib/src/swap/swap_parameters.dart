import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Parameters for initiating a swap operation
class SwapParameters extends Equatable {
  const SwapParameters({
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    this.swapMethod = 'setprice',
    this.minVolume,
    this.baseConfs,
    this.baseNota,
    this.relConfs,
    this.relNota,
    this.saveInHistory = true,
  });

  /// The ticker of the base coin to be traded
  final String base;

  /// The ticker of the rel coin to be traded  
  final String rel;

  /// The price to exchange the coins
  final Decimal price;

  /// The volume of base coin to be traded
  final Decimal volume;

  /// The swap method to use (default: 'setprice')
  final String swapMethod;

  /// The minimum volume that will be accepted for partial fills
  final Decimal? minVolume;

  /// Number of confirmations required for base coin
  final int? baseConfs;

  /// Whether base coin uses notarization
  final bool? baseNota;

  /// Number of confirmations required for rel coin
  final int? relConfs;

  /// Whether rel coin uses notarization
  final bool? relNota;

  /// Whether to save the swap in history
  final bool saveInHistory;

  @override
  List<Object?> get props => [
        base,
        rel,
        price,
        volume,
        swapMethod,
        minVolume,
        baseConfs,
        baseNota,
        relConfs,
        relNota,
        saveInHistory,
      ];

  Map<String, dynamic> toJson() => {
        'base': base,
        'rel': rel,
        'price': price.toString(),
        'volume': volume.toString(),
        'swap_method': swapMethod,
        if (minVolume != null) 'min_volume': minVolume!.toString(),
        if (baseConfs != null) 'base_confs': baseConfs,
        if (baseNota != null) 'base_nota': baseNota,
        if (relConfs != null) 'rel_confs': relConfs,
        if (relNota != null) 'rel_nota': relNota,
        'save_in_history': saveInHistory,
      };
}