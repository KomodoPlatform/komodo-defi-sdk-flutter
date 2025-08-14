// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Node _$NodeFromJson(Map<String, dynamic> json) => _Node(
  url: json['url'] as String?,
  wsUrl: json['ws_url'] as String?,
  guiAuth: json['gui_auth'] as bool?,
  contact:
      json['contact'] == null
          ? null
          : Contact.fromJson(json['contact'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NodeToJson(_Node instance) => <String, dynamic>{
  'url': instance.url,
  'ws_url': instance.wsUrl,
  'gui_auth': instance.guiAuth,
  'contact': instance.contact,
};
