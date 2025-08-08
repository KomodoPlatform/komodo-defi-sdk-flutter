// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirm_address_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfirmAddressDetails {

@JsonKey(name: 'expected_address') String get expectedAddress;
/// Create a copy of ConfirmAddressDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmAddressDetailsCopyWith<ConfirmAddressDetails> get copyWith => _$ConfirmAddressDetailsCopyWithImpl<ConfirmAddressDetails>(this as ConfirmAddressDetails, _$identity);

  /// Serializes this ConfirmAddressDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmAddressDetails&&(identical(other.expectedAddress, expectedAddress) || other.expectedAddress == expectedAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expectedAddress);

@override
String toString() {
  return 'ConfirmAddressDetails(expectedAddress: $expectedAddress)';
}


}

/// @nodoc
abstract mixin class $ConfirmAddressDetailsCopyWith<$Res>  {
  factory $ConfirmAddressDetailsCopyWith(ConfirmAddressDetails value, $Res Function(ConfirmAddressDetails) _then) = _$ConfirmAddressDetailsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'expected_address') String expectedAddress
});




}
/// @nodoc
class _$ConfirmAddressDetailsCopyWithImpl<$Res>
    implements $ConfirmAddressDetailsCopyWith<$Res> {
  _$ConfirmAddressDetailsCopyWithImpl(this._self, this._then);

  final ConfirmAddressDetails _self;
  final $Res Function(ConfirmAddressDetails) _then;

/// Create a copy of ConfirmAddressDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expectedAddress = null,}) {
  return _then(_self.copyWith(
expectedAddress: null == expectedAddress ? _self.expectedAddress : expectedAddress // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ConfirmAddressDetails implements ConfirmAddressDetails {
  const _ConfirmAddressDetails({@JsonKey(name: 'expected_address') required this.expectedAddress});
  factory _ConfirmAddressDetails.fromJson(Map<String, dynamic> json) => _$ConfirmAddressDetailsFromJson(json);

@override@JsonKey(name: 'expected_address') final  String expectedAddress;

/// Create a copy of ConfirmAddressDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmAddressDetailsCopyWith<_ConfirmAddressDetails> get copyWith => __$ConfirmAddressDetailsCopyWithImpl<_ConfirmAddressDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmAddressDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmAddressDetails&&(identical(other.expectedAddress, expectedAddress) || other.expectedAddress == expectedAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expectedAddress);

@override
String toString() {
  return 'ConfirmAddressDetails(expectedAddress: $expectedAddress)';
}


}

/// @nodoc
abstract mixin class _$ConfirmAddressDetailsCopyWith<$Res> implements $ConfirmAddressDetailsCopyWith<$Res> {
  factory _$ConfirmAddressDetailsCopyWith(_ConfirmAddressDetails value, $Res Function(_ConfirmAddressDetails) _then) = __$ConfirmAddressDetailsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'expected_address') String expectedAddress
});




}
/// @nodoc
class __$ConfirmAddressDetailsCopyWithImpl<$Res>
    implements _$ConfirmAddressDetailsCopyWith<$Res> {
  __$ConfirmAddressDetailsCopyWithImpl(this._self, this._then);

  final _ConfirmAddressDetails _self;
  final $Res Function(_ConfirmAddressDetails) _then;

/// Create a copy of ConfirmAddressDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expectedAddress = null,}) {
  return _then(_ConfirmAddressDetails(
expectedAddress: null == expectedAddress ? _self.expectedAddress : expectedAddress // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
