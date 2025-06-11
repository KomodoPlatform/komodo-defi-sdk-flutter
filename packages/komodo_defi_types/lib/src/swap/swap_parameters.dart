import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'swap_parameters.freezed.dart';

/// Parameters for initiating a swap operation
@Freezed(fromJson: false, toJson: false)
class SwapParameters with _$SwapParameters {
  const SwapParameters._();
  const factory SwapParameters({
    required AssetId base,
    required AssetId rel,
    required Decimal price,
    required Decimal volume,
    @Default('setprice') String swapMethod,
    Decimal? minVolume,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    @Default(true) bool saveInHistory,
  }) = _SwapParameters;

  factory SwapParameters.fromJson(JsonMap json) => SwapParameters(
        base: AssetId(json['base'] as String),
        rel: AssetId(json['rel'] as String),
        price: Decimal.parse(json['price'].toString()),
        volume: Decimal.parse(json['volume'].toString()),
        swapMethod: json['swap_method'] as String? ?? 'setprice',
        minVolume: json['min_volume'] != null
            ? Decimal.parse(json['min_volume'].toString())
            : null,
        baseConfs: json['base_confs'] as int?,
        baseNota: json['base_nota'] as bool?,
        relConfs: json['rel_confs'] as int?,
        relNota: json['rel_nota'] as bool?,
        saveInHistory: json['save_in_history'] as bool? ?? true,
      );

  JsonMap toJson() => {
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
