// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadResultSuccess _$DownloadResultSuccessFromJson(
  Map<String, dynamic> json,
) => DownloadResultSuccess(
  paramsPath: json['paramsPath'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$DownloadResultSuccessToJson(
  DownloadResultSuccess instance,
) => <String, dynamic>{
  'paramsPath': instance.paramsPath,
  'runtimeType': instance.$type,
};

DownloadResultFailure _$DownloadResultFailureFromJson(
  Map<String, dynamic> json,
) => DownloadResultFailure(
  error: json['error'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$DownloadResultFailureToJson(
  DownloadResultFailure instance,
) => <String, dynamic>{'error': instance.error, 'runtimeType': instance.$type};
