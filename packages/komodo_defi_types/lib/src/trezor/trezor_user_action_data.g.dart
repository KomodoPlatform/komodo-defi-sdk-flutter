// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trezor_user_action_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrezorUserActionData _$TrezorUserActionDataFromJson(
  Map<String, dynamic> json,
) => _TrezorUserActionData(
  actionType: $enumDecode(_$TrezorUserActionTypeEnumMap, json['action_type']),
  pin: const SensitiveStringConverter().fromJson(json['pin'] as String?),
  passphrase: const SensitiveStringConverter().fromJson(
    json['passphrase'] as String?,
  ),
);

Map<String, dynamic> _$TrezorUserActionDataToJson(
  _TrezorUserActionData instance,
) => <String, dynamic>{
  'action_type': _$TrezorUserActionTypeEnumMap[instance.actionType]!,
  'pin': const SensitiveStringConverter().toJson(instance.pin),
  'passphrase': const SensitiveStringConverter().toJson(instance.passphrase),
};

const _$TrezorUserActionTypeEnumMap = {
  TrezorUserActionType.trezorPin: 'TrezorPin',
  TrezorUserActionType.trezorPassphrase: 'TrezorPassphrase',
};
