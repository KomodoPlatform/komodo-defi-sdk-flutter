// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_best_apis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosBestApis {

 List<CosmosApiEndpoint> get rest; List<CosmosApiEndpoint> get rpc;
/// Create a copy of CosmosBestApis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosBestApisCopyWith<CosmosBestApis> get copyWith => _$CosmosBestApisCopyWithImpl<CosmosBestApis>(this as CosmosBestApis, _$identity);

  /// Serializes this CosmosBestApis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosBestApis&&const DeepCollectionEquality().equals(other.rest, rest)&&const DeepCollectionEquality().equals(other.rpc, rpc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rest),const DeepCollectionEquality().hash(rpc));

@override
String toString() {
  return 'CosmosBestApis(rest: $rest, rpc: $rpc)';
}


}

/// @nodoc
abstract mixin class $CosmosBestApisCopyWith<$Res>  {
  factory $CosmosBestApisCopyWith(CosmosBestApis value, $Res Function(CosmosBestApis) _then) = _$CosmosBestApisCopyWithImpl;
@useResult
$Res call({
 List<CosmosApiEndpoint> rest, List<CosmosApiEndpoint> rpc
});




}
/// @nodoc
class _$CosmosBestApisCopyWithImpl<$Res>
    implements $CosmosBestApisCopyWith<$Res> {
  _$CosmosBestApisCopyWithImpl(this._self, this._then);

  final CosmosBestApis _self;
  final $Res Function(CosmosBestApis) _then;

/// Create a copy of CosmosBestApis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rest = null,Object? rpc = null,}) {
  return _then(_self.copyWith(
rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as List<CosmosApiEndpoint>,rpc: null == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as List<CosmosApiEndpoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosBestApis].
extension CosmosBestApisPatterns on CosmosBestApis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosBestApis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosBestApis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosBestApis value)  $default,){
final _that = this;
switch (_that) {
case _CosmosBestApis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosBestApis value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosBestApis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CosmosApiEndpoint> rest,  List<CosmosApiEndpoint> rpc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosBestApis() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CosmosApiEndpoint> rest,  List<CosmosApiEndpoint> rpc)  $default,) {final _that = this;
switch (_that) {
case _CosmosBestApis():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CosmosApiEndpoint> rest,  List<CosmosApiEndpoint> rpc)?  $default,) {final _that = this;
switch (_that) {
case _CosmosBestApis() when $default != null:
return $default(_that.rest,_that.rpc);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosBestApis extends CosmosBestApis {
  const _CosmosBestApis({required final  List<CosmosApiEndpoint> rest, required final  List<CosmosApiEndpoint> rpc}): _rest = rest,_rpc = rpc,super._();
  factory _CosmosBestApis.fromJson(Map<String, dynamic> json) => _$CosmosBestApisFromJson(json);

 final  List<CosmosApiEndpoint> _rest;
@override List<CosmosApiEndpoint> get rest {
  if (_rest is EqualUnmodifiableListView) return _rest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rest);
}

 final  List<CosmosApiEndpoint> _rpc;
@override List<CosmosApiEndpoint> get rpc {
  if (_rpc is EqualUnmodifiableListView) return _rpc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rpc);
}


/// Create a copy of CosmosBestApis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosBestApisCopyWith<_CosmosBestApis> get copyWith => __$CosmosBestApisCopyWithImpl<_CosmosBestApis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosBestApisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosBestApis&&const DeepCollectionEquality().equals(other._rest, _rest)&&const DeepCollectionEquality().equals(other._rpc, _rpc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rest),const DeepCollectionEquality().hash(_rpc));

@override
String toString() {
  return 'CosmosBestApis(rest: $rest, rpc: $rpc)';
}


}

/// @nodoc
abstract mixin class _$CosmosBestApisCopyWith<$Res> implements $CosmosBestApisCopyWith<$Res> {
  factory _$CosmosBestApisCopyWith(_CosmosBestApis value, $Res Function(_CosmosBestApis) _then) = __$CosmosBestApisCopyWithImpl;
@override @useResult
$Res call({
 List<CosmosApiEndpoint> rest, List<CosmosApiEndpoint> rpc
});




}
/// @nodoc
class __$CosmosBestApisCopyWithImpl<$Res>
    implements _$CosmosBestApisCopyWith<$Res> {
  __$CosmosBestApisCopyWithImpl(this._self, this._then);

  final _CosmosBestApis _self;
  final $Res Function(_CosmosBestApis) _then;

/// Create a copy of CosmosBestApis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rest = null,Object? rpc = null,}) {
  return _then(_CosmosBestApis(
rest: null == rest ? _self._rest : rest // ignore: cast_nullable_to_non_nullable
as List<CosmosApiEndpoint>,rpc: null == rpc ? _self._rpc : rpc // ignore: cast_nullable_to_non_nullable
as List<CosmosApiEndpoint>,
  ));
}


}

// dart format on
