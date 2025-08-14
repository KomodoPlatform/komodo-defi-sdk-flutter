// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Node {

 String? get url; String? get wsUrl; bool? get guiAuth; Contact? get contact;
/// Create a copy of Node
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NodeCopyWith<Node> get copyWith => _$NodeCopyWithImpl<Node>(this as Node, _$identity);

  /// Serializes this Node to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Node&&(identical(other.url, url) || other.url == url)&&(identical(other.wsUrl, wsUrl) || other.wsUrl == wsUrl)&&(identical(other.guiAuth, guiAuth) || other.guiAuth == guiAuth)&&(identical(other.contact, contact) || other.contact == contact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,wsUrl,guiAuth,contact);

@override
String toString() {
  return 'Node(url: $url, wsUrl: $wsUrl, guiAuth: $guiAuth, contact: $contact)';
}


}

/// @nodoc
abstract mixin class $NodeCopyWith<$Res>  {
  factory $NodeCopyWith(Node value, $Res Function(Node) _then) = _$NodeCopyWithImpl;
@useResult
$Res call({
 String? url, String? wsUrl, bool? guiAuth, Contact? contact
});


$ContactCopyWith<$Res>? get contact;

}
/// @nodoc
class _$NodeCopyWithImpl<$Res>
    implements $NodeCopyWith<$Res> {
  _$NodeCopyWithImpl(this._self, this._then);

  final Node _self;
  final $Res Function(Node) _then;

/// Create a copy of Node
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? wsUrl = freezed,Object? guiAuth = freezed,Object? contact = freezed,}) {
  return _then(_self.copyWith(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,wsUrl: freezed == wsUrl ? _self.wsUrl : wsUrl // ignore: cast_nullable_to_non_nullable
as String?,guiAuth: freezed == guiAuth ? _self.guiAuth : guiAuth // ignore: cast_nullable_to_non_nullable
as bool?,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,
  ));
}
/// Create a copy of Node
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get contact {
    if (_self.contact == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.contact!, (value) {
    return _then(_self.copyWith(contact: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Node implements Node {
  const _Node({this.url, this.wsUrl, this.guiAuth, this.contact});
  factory _Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

@override final  String? url;
@override final  String? wsUrl;
@override final  bool? guiAuth;
@override final  Contact? contact;

/// Create a copy of Node
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NodeCopyWith<_Node> get copyWith => __$NodeCopyWithImpl<_Node>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Node&&(identical(other.url, url) || other.url == url)&&(identical(other.wsUrl, wsUrl) || other.wsUrl == wsUrl)&&(identical(other.guiAuth, guiAuth) || other.guiAuth == guiAuth)&&(identical(other.contact, contact) || other.contact == contact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,wsUrl,guiAuth,contact);

@override
String toString() {
  return 'Node(url: $url, wsUrl: $wsUrl, guiAuth: $guiAuth, contact: $contact)';
}


}

/// @nodoc
abstract mixin class _$NodeCopyWith<$Res> implements $NodeCopyWith<$Res> {
  factory _$NodeCopyWith(_Node value, $Res Function(_Node) _then) = __$NodeCopyWithImpl;
@override @useResult
$Res call({
 String? url, String? wsUrl, bool? guiAuth, Contact? contact
});


@override $ContactCopyWith<$Res>? get contact;

}
/// @nodoc
class __$NodeCopyWithImpl<$Res>
    implements _$NodeCopyWith<$Res> {
  __$NodeCopyWithImpl(this._self, this._then);

  final _Node _self;
  final $Res Function(_Node) _then;

/// Create a copy of Node
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? wsUrl = freezed,Object? guiAuth = freezed,Object? contact = freezed,}) {
  return _then(_Node(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,wsUrl: freezed == wsUrl ? _self.wsUrl : wsUrl // ignore: cast_nullable_to_non_nullable
as String?,guiAuth: freezed == guiAuth ? _self.guiAuth : guiAuth // ignore: cast_nullable_to_non_nullable
as bool?,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,
  ));
}

/// Create a copy of Node
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get contact {
    if (_self.contact == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.contact!, (value) {
    return _then(_self.copyWith(contact: value));
  });
}
}

// dart format on
