import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

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

  /// The ID of the base asset to be traded
  final AssetId base;

  /// The ID of the rel asset to be traded
  final AssetId rel;

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
        'base': base.id,
        'rel': rel.id,
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
