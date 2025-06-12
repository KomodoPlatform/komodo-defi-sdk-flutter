import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'swap_parameters.freezed.dart';
part 'swap_parameters.g.dart';

/// Parameters for initiating a swap operation
@freezed
abstract class SwapParameters with _$SwapParameters {
  const factory SwapParameters({
    @AssetIdConverter() required AssetId base,
    @AssetIdConverter() required AssetId rel,
    @DecimalConverter() required Decimal price,
    @DecimalConverter() required Decimal volume,
    @JsonKey(name: 'swap_method') @Default('setprice') String swapMethod,
    @JsonKey(name: 'min_volume') @DecimalConverter() Decimal? minVolume,
    @JsonKey(name: 'base_confs') int? baseConfs,
    @JsonKey(name: 'base_nota') bool? baseNota,
    @JsonKey(name: 'rel_confs') int? relConfs,
    @JsonKey(name: 'rel_nota') bool? relNota,
    @JsonKey(name: 'save_in_history') @Default(true) bool saveInHistory,
  }) = _SwapParameters;

  const SwapParameters._();

  factory SwapParameters.fromJson(JsonMap json) =>
      _$SwapParametersFromJson(json);
}
