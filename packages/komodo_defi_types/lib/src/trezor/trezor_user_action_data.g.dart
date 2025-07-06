// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trezor_user_action_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrezorUserActionData _$TrezorUserActionDataFromJson(
        Map<String, dynamic> json) =>
    _TrezorUserActionData(
      actionType:
          $enumDecode(_$TrezorUserActionTypeEnumMap, json['actionType']),
      pin: json['pin'] as String?,
      passphrase: json['passphrase'] as String?,
    );

Map<String, dynamic> _$TrezorUserActionDataToJson(
        _TrezorUserActionData instance) =>
    <String, dynamic>{
      'actionType': _$TrezorUserActionTypeEnumMap[instance.actionType]!,
      'pin': instance.pin,
      'passphrase': instance.passphrase,
    };

const _$TrezorUserActionTypeEnumMap = {
  TrezorUserActionType.trezorPin: 'trezorPin',
  TrezorUserActionType.trezorPassphrase: 'trezorPassphrase',
};
