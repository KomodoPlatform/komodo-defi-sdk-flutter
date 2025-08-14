// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'electrum.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Electrum {

 String? get url; String? get wsUrl; String? get protocol; List<Contact>? get contact;
/// Create a copy of Electrum
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ElectrumCopyWith<Electrum> get copyWith => _$ElectrumCopyWithImpl<Electrum>(this as Electrum, _$identity);

  /// Serializes this Electrum to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Electrum&&(identical(other.url, url) || other.url == url)&&(identical(other.wsUrl, wsUrl) || other.wsUrl == wsUrl)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&const DeepCollectionEquality().equals(other.contact, contact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,wsUrl,protocol,const DeepCollectionEquality().hash(contact));

@override
String toString() {
  return 'Electrum(url: $url, wsUrl: $wsUrl, protocol: $protocol, contact: $contact)';
}


}

/// @nodoc
abstract mixin class $ElectrumCopyWith<$Res>  {
  factory $ElectrumCopyWith(Electrum value, $Res Function(Electrum) _then) = _$ElectrumCopyWithImpl;
@useResult
$Res call({
 String? url, String? wsUrl, String? protocol, List<Contact>? contact
});




}
/// @nodoc
class _$ElectrumCopyWithImpl<$Res>
    implements $ElectrumCopyWith<$Res> {
  _$ElectrumCopyWithImpl(this._self, this._then);

  final Electrum _self;
  final $Res Function(Electrum) _then;

/// Create a copy of Electrum
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? wsUrl = freezed,Object? protocol = freezed,Object? contact = freezed,}) {
  return _then(_self.copyWith(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,wsUrl: freezed == wsUrl ? _self.wsUrl : wsUrl // ignore: cast_nullable_to_non_nullable
as String?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String?,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as List<Contact>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Electrum implements Electrum {
  const _Electrum({this.url, this.wsUrl, this.protocol, final  List<Contact>? contact}): _contact = contact;
  factory _Electrum.fromJson(Map<String, dynamic> json) => _$ElectrumFromJson(json);

@override final  String? url;
@override final  String? wsUrl;
@override final  String? protocol;
 final  List<Contact>? _contact;
@override List<Contact>? get contact {
  final value = _contact;
  if (value == null) return null;
  if (_contact is EqualUnmodifiableListView) return _contact;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Electrum
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ElectrumCopyWith<_Electrum> get copyWith => __$ElectrumCopyWithImpl<_Electrum>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ElectrumToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Electrum&&(identical(other.url, url) || other.url == url)&&(identical(other.wsUrl, wsUrl) || other.wsUrl == wsUrl)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&const DeepCollectionEquality().equals(other._contact, _contact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,wsUrl,protocol,const DeepCollectionEquality().hash(_contact));

@override
String toString() {
  return 'Electrum(url: $url, wsUrl: $wsUrl, protocol: $protocol, contact: $contact)';
}


}

/// @nodoc
abstract mixin class _$ElectrumCopyWith<$Res> implements $ElectrumCopyWith<$Res> {
  factory _$ElectrumCopyWith(_Electrum value, $Res Function(_Electrum) _then) = __$ElectrumCopyWithImpl;
@override @useResult
$Res call({
 String? url, String? wsUrl, String? protocol, List<Contact>? contact
});




}
/// @nodoc
class __$ElectrumCopyWithImpl<$Res>
    implements _$ElectrumCopyWith<$Res> {
  __$ElectrumCopyWithImpl(this._self, this._then);

  final _Electrum _self;
  final $Res Function(_Electrum) _then;

/// Create a copy of Electrum
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? wsUrl = freezed,Object? protocol = freezed,Object? contact = freezed,}) {
  return _then(_Electrum(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,wsUrl: freezed == wsUrl ? _self.wsUrl : wsUrl // ignore: cast_nullable_to_non_nullable
as String?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String?,contact: freezed == contact ? _self._contact : contact // ignore: cast_nullable_to_non_nullable
as List<Contact>?,
  ));
}


}

// dart format on
