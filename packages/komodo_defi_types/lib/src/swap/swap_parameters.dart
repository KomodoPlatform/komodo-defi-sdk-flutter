import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'swap_parameters.freezed.dart';
part 'swap_parameters.g.dart';

/// Parameters for initiating a swap operation
@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
abstract class SwapParameters with _$SwapParameters {
  const factory SwapParameters({
    @AssetIdConverter() required AssetId base,
    @AssetIdConverter() required AssetId rel,
    @DecimalConverter() required Decimal price,
    @DecimalConverter() required Decimal volume,
    @Default('setprice') String swapMethod,
    @DecimalConverter() Decimal? minVolume,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    @Default(true) bool saveInHistory,
  }) = _SwapParameters;

  const SwapParameters._();

  factory SwapParameters.fromJson(JsonMap json) =>
      _$SwapParametersFromJson(json);
}
