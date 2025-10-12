// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_api_endpoint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosApiEndpoint {

 String get address; String? get provider;
/// Create a copy of CosmosApiEndpoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosApiEndpointCopyWith<CosmosApiEndpoint> get copyWith => _$CosmosApiEndpointCopyWithImpl<CosmosApiEndpoint>(this as CosmosApiEndpoint, _$identity);

  /// Serializes this CosmosApiEndpoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosApiEndpoint&&(identical(other.address, address) || other.address == address)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,provider);

@override
String toString() {
  return 'CosmosApiEndpoint(address: $address, provider: $provider)';
}


}

/// @nodoc
abstract mixin class $CosmosApiEndpointCopyWith<$Res>  {
  factory $CosmosApiEndpointCopyWith(CosmosApiEndpoint value, $Res Function(CosmosApiEndpoint) _then) = _$CosmosApiEndpointCopyWithImpl;
@useResult
$Res call({
 String address, String? provider
});




}
/// @nodoc
class _$CosmosApiEndpointCopyWithImpl<$Res>
    implements $CosmosApiEndpointCopyWith<$Res> {
  _$CosmosApiEndpointCopyWithImpl(this._self, this._then);

  final CosmosApiEndpoint _self;
  final $Res Function(CosmosApiEndpoint) _then;

/// Create a copy of CosmosApiEndpoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? provider = freezed,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosApiEndpoint].
extension CosmosApiEndpointPatterns on CosmosApiEndpoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosApiEndpoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosApiEndpoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosApiEndpoint value)  $default,){
final _that = this;
switch (_that) {
case _CosmosApiEndpoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosApiEndpoint value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosApiEndpoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  String? provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosApiEndpoint() when $default != null:
return $default(_that.address,_that.provider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  String? provider)  $default,) {final _that = this;
switch (_that) {
case _CosmosApiEndpoint():
return $default(_that.address,_that.provider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  String? provider)?  $default,) {final _that = this;
switch (_that) {
case _CosmosApiEndpoint() when $default != null:
return $default(_that.address,_that.provider);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosApiEndpoint extends CosmosApiEndpoint {
  const _CosmosApiEndpoint({required this.address, this.provider}): super._();
  factory _CosmosApiEndpoint.fromJson(Map<String, dynamic> json) => _$CosmosApiEndpointFromJson(json);

@override final  String address;
@override final  String? provider;

/// Create a copy of CosmosApiEndpoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosApiEndpointCopyWith<_CosmosApiEndpoint> get copyWith => __$CosmosApiEndpointCopyWithImpl<_CosmosApiEndpoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosApiEndpointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosApiEndpoint&&(identical(other.address, address) || other.address == address)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,provider);

@override
String toString() {
  return 'CosmosApiEndpoint(address: $address, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$CosmosApiEndpointCopyWith<$Res> implements $CosmosApiEndpointCopyWith<$Res> {
  factory _$CosmosApiEndpointCopyWith(_CosmosApiEndpoint value, $Res Function(_CosmosApiEndpoint) _then) = __$CosmosApiEndpointCopyWithImpl;
@override @useResult
$Res call({
 String address, String? provider
});




}
/// @nodoc
class __$CosmosApiEndpointCopyWithImpl<$Res>
    implements _$CosmosApiEndpointCopyWith<$Res> {
  __$CosmosApiEndpointCopyWithImpl(this._self, this._then);

  final _CosmosApiEndpoint _self;
  final $Res Function(_CosmosApiEndpoint) _then;

/// Create a copy of CosmosApiEndpoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? provider = freezed,}) {
  return _then(_CosmosApiEndpoint(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
