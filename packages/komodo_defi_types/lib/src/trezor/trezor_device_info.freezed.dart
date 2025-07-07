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
  String? get type;
  String? get model;
  @JsonKey(name: 'device_name')
  String? get deviceName;
  @JsonKey(name: 'device_id')
  String get deviceId;
  @JsonKey(name: 'device_pubkey')
  String get devicePubkey;

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
            (identical(other.type, type) || other.type == type) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.devicePubkey, devicePubkey) ||
                other.devicePubkey == devicePubkey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, model, deviceName, deviceId, devicePubkey);

  @override
  String toString() {
    return 'TrezorDeviceInfo(type: $type, model: $model, deviceName: $deviceName, deviceId: $deviceId, devicePubkey: $devicePubkey)';
  }
}

/// @nodoc
abstract mixin class $TrezorDeviceInfoCopyWith<$Res> {
  factory $TrezorDeviceInfoCopyWith(
          TrezorDeviceInfo value, $Res Function(TrezorDeviceInfo) _then) =
      _$TrezorDeviceInfoCopyWithImpl;
  @useResult
  $Res call(
      {String? type,
      String? model,
      @JsonKey(name: 'device_name') String? deviceName,
      @JsonKey(name: 'device_id') String deviceId,
      @JsonKey(name: 'device_pubkey') String devicePubkey});
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
    Object? type = freezed,
    Object? model = freezed,
    Object? deviceName = freezed,
    Object? deviceId = null,
    Object? devicePubkey = null,
  }) {
    return _then(_self.copyWith(
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
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      devicePubkey: null == devicePubkey
          ? _self.devicePubkey
          : devicePubkey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TrezorDeviceInfo implements TrezorDeviceInfo {
  const _TrezorDeviceInfo(
      {this.type,
      this.model,
      @JsonKey(name: 'device_name') this.deviceName,
      @JsonKey(name: 'device_id') required this.deviceId,
      @JsonKey(name: 'device_pubkey') required this.devicePubkey});
  factory _TrezorDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$TrezorDeviceInfoFromJson(json);

  @override
  final String? type;
  @override
  final String? model;
  @override
  @JsonKey(name: 'device_name')
  final String? deviceName;
  @override
  @JsonKey(name: 'device_id')
  final String deviceId;
  @override
  @JsonKey(name: 'device_pubkey')
  final String devicePubkey;

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
            (identical(other.type, type) || other.type == type) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.devicePubkey, devicePubkey) ||
                other.devicePubkey == devicePubkey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, model, deviceName, deviceId, devicePubkey);

  @override
  String toString() {
    return 'TrezorDeviceInfo(type: $type, model: $model, deviceName: $deviceName, deviceId: $deviceId, devicePubkey: $devicePubkey)';
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
      {String? type,
      String? model,
      @JsonKey(name: 'device_name') String? deviceName,
      @JsonKey(name: 'device_id') String deviceId,
      @JsonKey(name: 'device_pubkey') String devicePubkey});
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
    Object? type = freezed,
    Object? model = freezed,
    Object? deviceName = freezed,
    Object? deviceId = null,
    Object? devicePubkey = null,
  }) {
    return _then(_TrezorDeviceInfo(
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
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      devicePubkey: null == devicePubkey
          ? _self.devicePubkey
          : devicePubkey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
