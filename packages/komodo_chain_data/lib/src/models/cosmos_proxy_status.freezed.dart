// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_proxy_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosProxyStatus {

 bool get rest; bool get rpc;
/// Create a copy of CosmosProxyStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosProxyStatusCopyWith<CosmosProxyStatus> get copyWith => _$CosmosProxyStatusCopyWithImpl<CosmosProxyStatus>(this as CosmosProxyStatus, _$identity);

  /// Serializes this CosmosProxyStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosProxyStatus&&(identical(other.rest, rest) || other.rest == rest)&&(identical(other.rpc, rpc) || other.rpc == rpc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rest,rpc);

@override
String toString() {
  return 'CosmosProxyStatus(rest: $rest, rpc: $rpc)';
}


}

/// @nodoc
abstract mixin class $CosmosProxyStatusCopyWith<$Res>  {
  factory $CosmosProxyStatusCopyWith(CosmosProxyStatus value, $Res Function(CosmosProxyStatus) _then) = _$CosmosProxyStatusCopyWithImpl;
@useResult
$Res call({
 bool rest, bool rpc
});




}
/// @nodoc
class _$CosmosProxyStatusCopyWithImpl<$Res>
    implements $CosmosProxyStatusCopyWith<$Res> {
  _$CosmosProxyStatusCopyWithImpl(this._self, this._then);

  final CosmosProxyStatus _self;
  final $Res Function(CosmosProxyStatus) _then;

/// Create a copy of CosmosProxyStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rest = null,Object? rpc = null,}) {
  return _then(_self.copyWith(
rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as bool,rpc: null == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosProxyStatus].
extension CosmosProxyStatusPatterns on CosmosProxyStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosProxyStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosProxyStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosProxyStatus value)  $default,){
final _that = this;
switch (_that) {
case _CosmosProxyStatus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosProxyStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosProxyStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool rest,  bool rpc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosProxyStatus() when $default != null:
return $default(_that.rest,_that.rpc);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool rest,  bool rpc)  $default,) {final _that = this;
switch (_that) {
case _CosmosProxyStatus():
return $default(_that.rest,_that.rpc);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool rest,  bool rpc)?  $default,) {final _that = this;
switch (_that) {
case _CosmosProxyStatus() when $default != null:
return $default(_that.rest,_that.rpc);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosProxyStatus extends CosmosProxyStatus {
  const _CosmosProxyStatus({required this.rest, required this.rpc}): super._();
  factory _CosmosProxyStatus.fromJson(Map<String, dynamic> json) => _$CosmosProxyStatusFromJson(json);

@override final  bool rest;
@override final  bool rpc;

/// Create a copy of CosmosProxyStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosProxyStatusCopyWith<_CosmosProxyStatus> get copyWith => __$CosmosProxyStatusCopyWithImpl<_CosmosProxyStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosProxyStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosProxyStatus&&(identical(other.rest, rest) || other.rest == rest)&&(identical(other.rpc, rpc) || other.rpc == rpc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rest,rpc);

@override
String toString() {
  return 'CosmosProxyStatus(rest: $rest, rpc: $rpc)';
}


}

/// @nodoc
abstract mixin class _$CosmosProxyStatusCopyWith<$Res> implements $CosmosProxyStatusCopyWith<$Res> {
  factory _$CosmosProxyStatusCopyWith(_CosmosProxyStatus value, $Res Function(_CosmosProxyStatus) _then) = __$CosmosProxyStatusCopyWithImpl;
@override @useResult
$Res call({
 bool rest, bool rpc
});




}
/// @nodoc
class __$CosmosProxyStatusCopyWithImpl<$Res>
    implements _$CosmosProxyStatusCopyWith<$Res> {
  __$CosmosProxyStatusCopyWithImpl(this._self, this._then);

  final _CosmosProxyStatus _self;
  final $Res Function(_CosmosProxyStatus) _then;

/// Create a copy of CosmosProxyStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rest = null,Object? rpc = null,}) {
  return _then(_CosmosProxyStatus(
rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as bool,rpc: null == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
