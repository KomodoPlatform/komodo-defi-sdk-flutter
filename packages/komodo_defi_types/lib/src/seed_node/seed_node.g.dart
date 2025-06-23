// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seed_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeedNode _$SeedNodeFromJson(Map<String, dynamic> json) => _SeedNode(
      name: json['name'] as String,
      host: json['host'] as String,
      contact: (json['contact'] as List<dynamic>)
          .map((e) => SeedNodeContact.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SeedNodeToJson(_SeedNode instance) => <String, dynamic>{
      'name': instance.name,
      'host': instance.host,
      'contact': instance.contact,
    };

_SeedNodeContact _$SeedNodeContactFromJson(Map<String, dynamic> json) =>
    _SeedNodeContact(
      email: json['email'] as String,
    );

Map<String, dynamic> _$SeedNodeContactToJson(_SeedNodeContact instance) =>
    <String, dynamic>{
      'email': instance.email,
    };
