// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trezor_device_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrezorDeviceInfo {
  String get deviceId;
  String get devicePubkey;
  String? get type;
  String? get model;
  String? get deviceName;

  /// Create a copy of TrezorDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrezorDeviceInfoCopyWith<TrezorDeviceInfo> get copyWith =>
      _$TrezorDeviceInfoCopyWithImpl<TrezorDeviceInfo>(
          this as TrezorDeviceInfo, _$identity);

  /// Serializes this TrezorDeviceInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrezorDeviceInfo &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.devicePubkey, devicePubkey) ||
                other.devicePubkey == devicePubkey) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, deviceId, devicePubkey, type, model, deviceName);

  @override
  String toString() {
    return 'TrezorDeviceInfo(deviceId: $deviceId, devicePubkey: $devicePubkey, type: $type, model: $model, deviceName: $deviceName)';
  }
}

/// @nodoc
abstract mixin class $TrezorDeviceInfoCopyWith<$Res> {
  factory $TrezorDeviceInfoCopyWith(
          TrezorDeviceInfo value, $Res Function(TrezorDeviceInfo) _then) =
      _$TrezorDeviceInfoCopyWithImpl;
  @useResult
  $Res call(
      {String deviceId,
      String devicePubkey,
      String? type,
      String? model,
      String? deviceName});
}

/// @nodoc
class _$TrezorDeviceInfoCopyWithImpl<$Res>
    implements $TrezorDeviceInfoCopyWith<$Res> {
  _$TrezorDeviceInfoCopyWithImpl(this._self, this._then);

  final TrezorDeviceInfo _self;
  final $Res Function(TrezorDeviceInfo) _then;

  /// Create a copy of TrezorDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? devicePubkey = null,
    Object? type = freezed,
    Object? model = freezed,
    Object? deviceName = freezed,
  }) {
    return _then(_self.copyWith(
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      devicePubkey: null == devicePubkey
          ? _self.devicePubkey
          : devicePubkey // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _self.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _TrezorDeviceInfo implements TrezorDeviceInfo {
  const _TrezorDeviceInfo(
      {required this.deviceId,
      required this.devicePubkey,
      this.type,
      this.model,
      this.deviceName});
  factory _TrezorDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$TrezorDeviceInfoFromJson(json);

  @override
  final String deviceId;
  @override
  final String devicePubkey;
  @override
  final String? type;
  @override
  final String? model;
  @override
  final String? deviceName;

  /// Create a copy of TrezorDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrezorDeviceInfoCopyWith<_TrezorDeviceInfo> get copyWith =>
      __$TrezorDeviceInfoCopyWithImpl<_TrezorDeviceInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TrezorDeviceInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrezorDeviceInfo &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.devicePubkey, devicePubkey) ||
                other.devicePubkey == devicePubkey) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, deviceId, devicePubkey, type, model, deviceName);

  @override
  String toString() {
    return 'TrezorDeviceInfo(deviceId: $deviceId, devicePubkey: $devicePubkey, type: $type, model: $model, deviceName: $deviceName)';
  }
}

/// @nodoc
abstract mixin class _$TrezorDeviceInfoCopyWith<$Res>
    implements $TrezorDeviceInfoCopyWith<$Res> {
  factory _$TrezorDeviceInfoCopyWith(
          _TrezorDeviceInfo value, $Res Function(_TrezorDeviceInfo) _then) =
      __$TrezorDeviceInfoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String deviceId,
      String devicePubkey,
      String? type,
      String? model,
      String? deviceName});
}

/// @nodoc
class __$TrezorDeviceInfoCopyWithImpl<$Res>
    implements _$TrezorDeviceInfoCopyWith<$Res> {
  __$TrezorDeviceInfoCopyWithImpl(this._self, this._then);

  final _TrezorDeviceInfo _self;
  final $Res Function(_TrezorDeviceInfo) _then;

  /// Create a copy of TrezorDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? deviceId = null,
    Object? devicePubkey = null,
    Object? type = freezed,
    Object? model = freezed,
    Object? deviceName = freezed,
  }) {
    return _then(_TrezorDeviceInfo(
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      devicePubkey: null == devicePubkey
          ? _self.devicePubkey
          : devicePubkey // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _self.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
