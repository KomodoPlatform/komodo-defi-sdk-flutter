import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'order_data.freezed.dart';
part 'order_data.g.dart';

/// Represents OrderDataV2 as returned by trading methods
/// NOTE: Only use this with V2 methods, as it is not compatible
/// with legacy API methods.
@freezed
sealed class OrderData with _$OrderData {
  const factory OrderData({
    required String coin,
    required AddressData address,
    required NumericFormatsValue price,
    required String pubkey,
    required String uuid,
    @JsonKey(name: 'is_mine') required bool isMine,
    @JsonKey(name: 'base_max_volume')
    required NumericFormatsValue baseMaxVolume,
    @JsonKey(name: 'base_min_volume')
    required NumericFormatsValue baseMinVolume,
    @JsonKey(name: 'rel_max_volume') required NumericFormatsValue relMaxVolume,
    @JsonKey(name: 'rel_min_volume') required NumericFormatsValue relMinVolume,
    @JsonKey(name: 'conf_settings') OrderConfigurationSettings? confSettings,
  }) = _OrderData;
  const OrderData._();

  factory OrderData.fromJson(JsonMap json) => _$OrderDataFromJson(json);
}

/// Address data for an order
@freezed
sealed class AddressData with _$AddressData {
  const factory AddressData({
    @JsonKey(name: 'address_data') required String addressData,
  }) = _AddressData;
  const AddressData._();

  factory AddressData.fromJson(JsonMap json) => _$AddressDataFromJson(json);
}

/// Configuration settings for an order
@freezed
sealed class OrderConfigurationSettings with _$OrderConfigurationSettings {
  const factory OrderConfigurationSettings({
    @JsonKey(name: 'base_confs') int? baseConfirm,
    @JsonKey(name: 'base_nota') bool? baseNota,
    @JsonKey(name: 'rel_confs') int? relConfirm,
    @JsonKey(name: 'rel_nota') bool? relNota,
  }) = _OrderConfigurationSettings;
  const OrderConfigurationSettings._();

  factory OrderConfigurationSettings.fromJson(JsonMap json) =>
      _$OrderConfigurationSettingsFromJson(json);
}
