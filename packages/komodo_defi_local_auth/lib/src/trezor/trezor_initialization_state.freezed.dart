// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trezor_initialization_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrezorInitializationState {

 AuthenticationStatus get status; String? get message; TrezorDeviceInfo? get deviceInfo; String? get error; int? get taskId;
/// Create a copy of TrezorInitializationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrezorInitializationStateCopyWith<TrezorInitializationState> get copyWith => _$TrezorInitializationStateCopyWithImpl<TrezorInitializationState>(this as TrezorInitializationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrezorInitializationState&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.error, error) || other.error == error)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,deviceInfo,error,taskId);

@override
String toString() {
  return 'TrezorInitializationState(status: $status, message: $message, deviceInfo: $deviceInfo, error: $error, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TrezorInitializationStateCopyWith<$Res>  {
  factory $TrezorInitializationStateCopyWith(TrezorInitializationState value, $Res Function(TrezorInitializationState) _then) = _$TrezorInitializationStateCopyWithImpl;
@useResult
$Res call({
 AuthenticationStatus status, String? message, TrezorDeviceInfo? deviceInfo, String? error, int? taskId
});


$TrezorDeviceInfoCopyWith<$Res>? get deviceInfo;

}
/// @nodoc
class _$TrezorInitializationStateCopyWithImpl<$Res>
    implements $TrezorInitializationStateCopyWith<$Res> {
  _$TrezorInitializationStateCopyWithImpl(this._self, this._then);

  final TrezorInitializationState _self;
  final $Res Function(TrezorInitializationState) _then;

/// Create a copy of TrezorInitializationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? message = freezed,Object? deviceInfo = freezed,Object? error = freezed,Object? taskId = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthenticationStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as TrezorDeviceInfo?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TrezorInitializationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrezorDeviceInfoCopyWith<$Res>? get deviceInfo {
    if (_self.deviceInfo == null) {
    return null;
  }

  return $TrezorDeviceInfoCopyWith<$Res>(_self.deviceInfo!, (value) {
    return _then(_self.copyWith(deviceInfo: value));
  });
}
}


/// @nodoc


class _TrezorInitializationState extends TrezorInitializationState {
  const _TrezorInitializationState({required this.status, this.message, this.deviceInfo, this.error, this.taskId}): super._();
  

@override final  AuthenticationStatus status;
@override final  String? message;
@override final  TrezorDeviceInfo? deviceInfo;
@override final  String? error;
@override final  int? taskId;

/// Create a copy of TrezorInitializationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrezorInitializationStateCopyWith<_TrezorInitializationState> get copyWith => __$TrezorInitializationStateCopyWithImpl<_TrezorInitializationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrezorInitializationState&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.error, error) || other.error == error)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,deviceInfo,error,taskId);

@override
String toString() {
  return 'TrezorInitializationState(status: $status, message: $message, deviceInfo: $deviceInfo, error: $error, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class _$TrezorInitializationStateCopyWith<$Res> implements $TrezorInitializationStateCopyWith<$Res> {
  factory _$TrezorInitializationStateCopyWith(_TrezorInitializationState value, $Res Function(_TrezorInitializationState) _then) = __$TrezorInitializationStateCopyWithImpl;
@override @useResult
$Res call({
 AuthenticationStatus status, String? message, TrezorDeviceInfo? deviceInfo, String? error, int? taskId
});


@override $TrezorDeviceInfoCopyWith<$Res>? get deviceInfo;

}
/// @nodoc
class __$TrezorInitializationStateCopyWithImpl<$Res>
    implements _$TrezorInitializationStateCopyWith<$Res> {
  __$TrezorInitializationStateCopyWithImpl(this._self, this._then);

  final _TrezorInitializationState _self;
  final $Res Function(_TrezorInitializationState) _then;

/// Create a copy of TrezorInitializationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = freezed,Object? deviceInfo = freezed,Object? error = freezed,Object? taskId = freezed,}) {
  return _then(_TrezorInitializationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthenticationStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as TrezorDeviceInfo?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TrezorInitializationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrezorDeviceInfoCopyWith<$Res>? get deviceInfo {
    if (_self.deviceInfo == null) {
    return null;
  }

  return $TrezorDeviceInfoCopyWith<$Res>(_self.deviceInfo!, (value) {
    return _then(_self.copyWith(deviceInfo: value));
  });
}
}

// dart format on
