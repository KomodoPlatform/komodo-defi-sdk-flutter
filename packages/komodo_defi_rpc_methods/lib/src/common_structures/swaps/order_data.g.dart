// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderData _$OrderDataFromJson(Map<String, dynamic> json) => _OrderData(
  coin: json['coin'] as String,
  address: AddressData.fromJson(json['address'] as Map<String, dynamic>),
  price: NumericFormatsValue.fromJson(json['price'] as Map<String, dynamic>),
  pubkey: json['pubkey'] as String,
  uuid: json['uuid'] as String,
  isMine: json['is_mine'] as bool,
  baseMaxVolume: NumericFormatsValue.fromJson(
    json['base_max_volume'] as Map<String, dynamic>,
  ),
  baseMinVolume: NumericFormatsValue.fromJson(
    json['base_min_volume'] as Map<String, dynamic>,
  ),
  relMaxVolume: NumericFormatsValue.fromJson(
    json['rel_max_volume'] as Map<String, dynamic>,
  ),
  relMinVolume: NumericFormatsValue.fromJson(
    json['rel_min_volume'] as Map<String, dynamic>,
  ),
  confSettings:
      json['conf_settings'] == null
          ? null
          : OrderConfigurationSettings.fromJson(
            json['conf_settings'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$OrderDataToJson(_OrderData instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'address': instance.address.toJson(),
      'price': instance.price.toJson(),
      'pubkey': instance.pubkey,
      'uuid': instance.uuid,
      'is_mine': instance.isMine,
      'base_max_volume': instance.baseMaxVolume.toJson(),
      'base_min_volume': instance.baseMinVolume.toJson(),
      'rel_max_volume': instance.relMaxVolume.toJson(),
      'rel_min_volume': instance.relMinVolume.toJson(),
      'conf_settings': instance.confSettings?.toJson(),
    };

_AddressData _$AddressDataFromJson(Map<String, dynamic> json) =>
    _AddressData(addressData: json['address_data'] as String);

Map<String, dynamic> _$AddressDataToJson(_AddressData instance) =>
    <String, dynamic>{'address_data': instance.addressData};

_OrderConfigurationSettings _$OrderConfigurationSettingsFromJson(
  Map<String, dynamic> json,
) => _OrderConfigurationSettings(
  baseConfirm: (json['base_confs'] as num?)?.toInt(),
  baseNota: json['base_nota'] as bool?,
  relConfirm: (json['rel_confs'] as num?)?.toInt(),
  relNota: json['rel_nota'] as bool?,
);

Map<String, dynamic> _$OrderConfigurationSettingsToJson(
  _OrderConfigurationSettings instance,
) => <String, dynamic>{
  'base_confs': instance.baseConfirm,
  'base_nota': instance.baseNota,
  'rel_confs': instance.relConfirm,
  'rel_nota': instance.relNota,
};
