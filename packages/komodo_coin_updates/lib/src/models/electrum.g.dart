// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electrum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Electrum _$ElectrumFromJson(Map<String, dynamic> json) => _Electrum(
  url: json['url'] as String?,
  wsUrl: json['ws_url'] as String?,
  protocol: json['protocol'] as String?,
  contact:
      (json['contact'] as List<dynamic>?)
          ?.map((e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ElectrumToJson(_Electrum instance) => <String, dynamic>{
  'url': instance.url,
  'ws_url': instance.wsUrl,
  'protocol': instance.protocol,
  'contact': instance.contact,
};
