// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwapProgress _$SwapProgressFromJson(Map<String, dynamic> json) =>
    _SwapProgress(
      status: const SwapStatusConverter().fromJson(json['status'] as String),
      message: json['message'] as String,
      swapResult: json['swap_result'] == null
          ? null
          : SwapResult.fromJson(json['swap_result'] as Map<String, dynamic>),
      errorCode: _$JsonConverterFromJson<String, SwapErrorCode>(
          json['error_code'], const SwapErrorCodeConverter().fromJson),
      errorMessage: json['error_message'] as String?,
      uuid: json['uuid'] as String?,
    );

Map<String, dynamic> _$SwapProgressToJson(_SwapProgress instance) =>
    <String, dynamic>{
      'status': const SwapStatusConverter().toJson(instance.status),
      'message': instance.message,
      'swap_result': instance.swapResult,
      'error_code': _$JsonConverterToJson<String, SwapErrorCode>(
          instance.errorCode, const SwapErrorCodeConverter().toJson),
      'error_message': instance.errorMessage,
      'uuid': instance.uuid,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
