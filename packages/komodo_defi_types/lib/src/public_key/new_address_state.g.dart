// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_address_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NewAddressState _$NewAddressStateFromJson(Map<String, dynamic> json) =>
    _NewAddressState(
      status: $enumDecode(_$NewAddressStatusEnumMap, json['status']),
      message: json['message'] as String?,
      taskId: (json['taskId'] as num?)?.toInt(),
      address:
          json['address'] == null
              ? null
              : NewAddressInfo.fromJson(
                json['address'] as Map<String, dynamic>,
              ),
      expectedAddress: json['expectedAddress'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$NewAddressStateToJson(_NewAddressState instance) =>
    <String, dynamic>{
      'status': _$NewAddressStatusEnumMap[instance.status]!,
      'message': instance.message,
      'taskId': instance.taskId,
      'address': instance.address,
      'expectedAddress': instance.expectedAddress,
      'error': instance.error,
    };

const _$NewAddressStatusEnumMap = {
  NewAddressStatus.initializing: 'initializing',
  NewAddressStatus.waitingForDevice: 'waitingForDevice',
  NewAddressStatus.waitingForDeviceConfirmation: 'waitingForDeviceConfirmation',
  NewAddressStatus.pinRequired: 'pinRequired',
  NewAddressStatus.passphraseRequired: 'passphraseRequired',
  NewAddressStatus.confirmAddress: 'confirmAddress',
  NewAddressStatus.processing: 'processing',
  NewAddressStatus.completed: 'completed',
  NewAddressStatus.error: 'error',
  NewAddressStatus.cancelled: 'cancelled',
};
