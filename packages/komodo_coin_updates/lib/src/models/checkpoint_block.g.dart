// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckPointBlock _$CheckPointBlockFromJson(Map<String, dynamic> json) =>
    _CheckPointBlock(
      height: json['height'] as num?,
      time: json['time'] as num?,
      hash: json['hash'] as String?,
      saplingTree: json['sapling_tree'] as String?,
    );

Map<String, dynamic> _$CheckPointBlockToJson(_CheckPointBlock instance) =>
    <String, dynamic>{
      'height': instance.height,
      'time': instance.time,
      'hash': instance.hash,
      'sapling_tree': instance.saplingTree,
    };
