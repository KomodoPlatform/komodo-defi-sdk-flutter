// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Protocol _$ProtocolFromJson(Map<String, dynamic> json) => _Protocol(
  type: json['type'] as String?,
  protocolData:
      json['protocol_data'] == null
          ? null
          : ProtocolData.fromJson(
            json['protocol_data'] as Map<String, dynamic>,
          ),
  bip44: json['bip44'] as String?,
);

Map<String, dynamic> _$ProtocolToJson(_Protocol instance) => <String, dynamic>{
  'type': instance.type,
  'protocol_data': instance.protocolData,
  'bip44': instance.bip44,
};
