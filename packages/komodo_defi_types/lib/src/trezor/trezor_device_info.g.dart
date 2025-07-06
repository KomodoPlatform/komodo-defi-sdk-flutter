// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trezor_device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrezorDeviceInfo _$TrezorDeviceInfoFromJson(Map<String, dynamic> json) =>
    _TrezorDeviceInfo(
      type: json['type'] as String?,
      model: json['model'] as String?,
      deviceName: json['device_name'] as String?,
      deviceId: json['device_id'] as String,
      devicePubkey: json['device_pubkey'] as String,
    );

Map<String, dynamic> _$TrezorDeviceInfoToJson(_TrezorDeviceInfo instance) =>
    <String, dynamic>{
      'type': instance.type,
      'model': instance.model,
      'device_name': instance.deviceName,
      'device_id': instance.deviceId,
      'device_pubkey': instance.devicePubkey,
    };
