// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protocol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Protocol {

 String? get type; ProtocolData? get protocolData; String? get bip44;
/// Create a copy of Protocol
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProtocolCopyWith<Protocol> get copyWith => _$ProtocolCopyWithImpl<Protocol>(this as Protocol, _$identity);

  /// Serializes this Protocol to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Protocol&&(identical(other.type, type) || other.type == type)&&(identical(other.protocolData, protocolData) || other.protocolData == protocolData)&&(identical(other.bip44, bip44) || other.bip44 == bip44));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,protocolData,bip44);

@override
String toString() {
  return 'Protocol(type: $type, protocolData: $protocolData, bip44: $bip44)';
}


}

/// @nodoc
abstract mixin class $ProtocolCopyWith<$Res>  {
  factory $ProtocolCopyWith(Protocol value, $Res Function(Protocol) _then) = _$ProtocolCopyWithImpl;
@useResult
$Res call({
 String? type, ProtocolData? protocolData, String? bip44
});


$ProtocolDataCopyWith<$Res>? get protocolData;

}
/// @nodoc
class _$ProtocolCopyWithImpl<$Res>
    implements $ProtocolCopyWith<$Res> {
  _$ProtocolCopyWithImpl(this._self, this._then);

  final Protocol _self;
  final $Res Function(Protocol) _then;

/// Create a copy of Protocol
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? protocolData = freezed,Object? bip44 = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,protocolData: freezed == protocolData ? _self.protocolData : protocolData // ignore: cast_nullable_to_non_nullable
as ProtocolData?,bip44: freezed == bip44 ? _self.bip44 : bip44 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Protocol
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolDataCopyWith<$Res>? get protocolData {
    if (_self.protocolData == null) {
    return null;
  }

  return $ProtocolDataCopyWith<$Res>(_self.protocolData!, (value) {
    return _then(_self.copyWith(protocolData: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Protocol implements Protocol {
  const _Protocol({this.type, this.protocolData, this.bip44});
  factory _Protocol.fromJson(Map<String, dynamic> json) => _$ProtocolFromJson(json);

@override final  String? type;
@override final  ProtocolData? protocolData;
@override final  String? bip44;

/// Create a copy of Protocol
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProtocolCopyWith<_Protocol> get copyWith => __$ProtocolCopyWithImpl<_Protocol>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProtocolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Protocol&&(identical(other.type, type) || other.type == type)&&(identical(other.protocolData, protocolData) || other.protocolData == protocolData)&&(identical(other.bip44, bip44) || other.bip44 == bip44));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,protocolData,bip44);

@override
String toString() {
  return 'Protocol(type: $type, protocolData: $protocolData, bip44: $bip44)';
}


}

/// @nodoc
abstract mixin class _$ProtocolCopyWith<$Res> implements $ProtocolCopyWith<$Res> {
  factory _$ProtocolCopyWith(_Protocol value, $Res Function(_Protocol) _then) = __$ProtocolCopyWithImpl;
@override @useResult
$Res call({
 String? type, ProtocolData? protocolData, String? bip44
});


@override $ProtocolDataCopyWith<$Res>? get protocolData;

}
/// @nodoc
class __$ProtocolCopyWithImpl<$Res>
    implements _$ProtocolCopyWith<$Res> {
  __$ProtocolCopyWithImpl(this._self, this._then);

  final _Protocol _self;
  final $Res Function(_Protocol) _then;

/// Create a copy of Protocol
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? protocolData = freezed,Object? bip44 = freezed,}) {
  return _then(_Protocol(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,protocolData: freezed == protocolData ? _self.protocolData : protocolData // ignore: cast_nullable_to_non_nullable
as ProtocolData?,bip44: freezed == bip44 ? _self.bip44 : bip44 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Protocol
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolDataCopyWith<$Res>? get protocolData {
    if (_self.protocolData == null) {
    return null;
  }

  return $ProtocolDataCopyWith<$Res>(_self.protocolData!, (value) {
    return _then(_self.copyWith(protocolData: value));
  });
}
}

// dart format on
