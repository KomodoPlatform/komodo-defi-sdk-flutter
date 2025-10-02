// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadProgress _$DownloadProgressFromJson(Map<String, dynamic> json) =>
    _DownloadProgress(
      fileName: json['fileName'] as String,
      downloaded: (json['downloaded'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$DownloadProgressToJson(_DownloadProgress instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'downloaded': instance.downloaded,
      'total': instance.total,
    };
