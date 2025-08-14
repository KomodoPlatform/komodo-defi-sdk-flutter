// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rpc_url.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RpcUrl {

 String? get url;
/// Create a copy of RpcUrl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RpcUrlCopyWith<RpcUrl> get copyWith => _$RpcUrlCopyWithImpl<RpcUrl>(this as RpcUrl, _$identity);

  /// Serializes this RpcUrl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RpcUrl&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'RpcUrl(url: $url)';
}


}

/// @nodoc
abstract mixin class $RpcUrlCopyWith<$Res>  {
  factory $RpcUrlCopyWith(RpcUrl value, $Res Function(RpcUrl) _then) = _$RpcUrlCopyWithImpl;
@useResult
$Res call({
 String? url
});




}
/// @nodoc
class _$RpcUrlCopyWithImpl<$Res>
    implements $RpcUrlCopyWith<$Res> {
  _$RpcUrlCopyWithImpl(this._self, this._then);

  final RpcUrl _self;
  final $Res Function(RpcUrl) _then;

/// Create a copy of RpcUrl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,}) {
  return _then(_self.copyWith(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RpcUrl implements RpcUrl {
  const _RpcUrl({this.url});
  factory _RpcUrl.fromJson(Map<String, dynamic> json) => _$RpcUrlFromJson(json);

@override final  String? url;

/// Create a copy of RpcUrl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RpcUrlCopyWith<_RpcUrl> get copyWith => __$RpcUrlCopyWithImpl<_RpcUrl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RpcUrlToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RpcUrl&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'RpcUrl(url: $url)';
}


}

/// @nodoc
abstract mixin class _$RpcUrlCopyWith<$Res> implements $RpcUrlCopyWith<$Res> {
  factory _$RpcUrlCopyWith(_RpcUrl value, $Res Function(_RpcUrl) _then) = __$RpcUrlCopyWithImpl;
@override @useResult
$Res call({
 String? url
});




}
/// @nodoc
class __$RpcUrlCopyWithImpl<$Res>
    implements _$RpcUrlCopyWith<$Res> {
  __$RpcUrlCopyWithImpl(this._self, this._then);

  final _RpcUrl _self;
  final $Res Function(_RpcUrl) _then;

/// Create a copy of RpcUrl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,}) {
  return _then(_RpcUrl(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
