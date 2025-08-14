// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_format.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddressFormat {

 String? get format; String? get network;
/// Create a copy of AddressFormat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressFormatCopyWith<AddressFormat> get copyWith => _$AddressFormatCopyWithImpl<AddressFormat>(this as AddressFormat, _$identity);

  /// Serializes this AddressFormat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressFormat&&(identical(other.format, format) || other.format == format)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,network);

@override
String toString() {
  return 'AddressFormat(format: $format, network: $network)';
}


}

/// @nodoc
abstract mixin class $AddressFormatCopyWith<$Res>  {
  factory $AddressFormatCopyWith(AddressFormat value, $Res Function(AddressFormat) _then) = _$AddressFormatCopyWithImpl;
@useResult
$Res call({
 String? format, String? network
});




}
/// @nodoc
class _$AddressFormatCopyWithImpl<$Res>
    implements $AddressFormatCopyWith<$Res> {
  _$AddressFormatCopyWithImpl(this._self, this._then);

  final AddressFormat _self;
  final $Res Function(AddressFormat) _then;

/// Create a copy of AddressFormat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = freezed,Object? network = freezed,}) {
  return _then(_self.copyWith(
format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AddressFormat implements AddressFormat {
  const _AddressFormat({this.format, this.network});
  factory _AddressFormat.fromJson(Map<String, dynamic> json) => _$AddressFormatFromJson(json);

@override final  String? format;
@override final  String? network;

/// Create a copy of AddressFormat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressFormatCopyWith<_AddressFormat> get copyWith => __$AddressFormatCopyWithImpl<_AddressFormat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressFormatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressFormat&&(identical(other.format, format) || other.format == format)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,network);

@override
String toString() {
  return 'AddressFormat(format: $format, network: $network)';
}


}

/// @nodoc
abstract mixin class _$AddressFormatCopyWith<$Res> implements $AddressFormatCopyWith<$Res> {
  factory _$AddressFormatCopyWith(_AddressFormat value, $Res Function(_AddressFormat) _then) = __$AddressFormatCopyWithImpl;
@override @useResult
$Res call({
 String? format, String? network
});




}
/// @nodoc
class __$AddressFormatCopyWithImpl<$Res>
    implements _$AddressFormatCopyWith<$Res> {
  __$AddressFormatCopyWithImpl(this._self, this._then);

  final _AddressFormat _self;
  final $Res Function(_AddressFormat) _then;

/// Create a copy of AddressFormat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = freezed,Object? network = freezed,}) {
  return _then(_AddressFormat(
format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
