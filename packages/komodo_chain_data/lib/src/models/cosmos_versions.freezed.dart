// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_versions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosVersions {

 String? get applicationVersion; String? get cosmosSdkVersion; String? get tendermintVersion;
/// Create a copy of CosmosVersions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosVersionsCopyWith<CosmosVersions> get copyWith => _$CosmosVersionsCopyWithImpl<CosmosVersions>(this as CosmosVersions, _$identity);

  /// Serializes this CosmosVersions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosVersions&&(identical(other.applicationVersion, applicationVersion) || other.applicationVersion == applicationVersion)&&(identical(other.cosmosSdkVersion, cosmosSdkVersion) || other.cosmosSdkVersion == cosmosSdkVersion)&&(identical(other.tendermintVersion, tendermintVersion) || other.tendermintVersion == tendermintVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,applicationVersion,cosmosSdkVersion,tendermintVersion);

@override
String toString() {
  return 'CosmosVersions(applicationVersion: $applicationVersion, cosmosSdkVersion: $cosmosSdkVersion, tendermintVersion: $tendermintVersion)';
}


}

/// @nodoc
abstract mixin class $CosmosVersionsCopyWith<$Res>  {
  factory $CosmosVersionsCopyWith(CosmosVersions value, $Res Function(CosmosVersions) _then) = _$CosmosVersionsCopyWithImpl;
@useResult
$Res call({
 String? applicationVersion, String? cosmosSdkVersion, String? tendermintVersion
});




}
/// @nodoc
class _$CosmosVersionsCopyWithImpl<$Res>
    implements $CosmosVersionsCopyWith<$Res> {
  _$CosmosVersionsCopyWithImpl(this._self, this._then);

  final CosmosVersions _self;
  final $Res Function(CosmosVersions) _then;

/// Create a copy of CosmosVersions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? applicationVersion = freezed,Object? cosmosSdkVersion = freezed,Object? tendermintVersion = freezed,}) {
  return _then(_self.copyWith(
applicationVersion: freezed == applicationVersion ? _self.applicationVersion : applicationVersion // ignore: cast_nullable_to_non_nullable
as String?,cosmosSdkVersion: freezed == cosmosSdkVersion ? _self.cosmosSdkVersion : cosmosSdkVersion // ignore: cast_nullable_to_non_nullable
as String?,tendermintVersion: freezed == tendermintVersion ? _self.tendermintVersion : tendermintVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosVersions].
extension CosmosVersionsPatterns on CosmosVersions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosVersions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosVersions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosVersions value)  $default,){
final _that = this;
switch (_that) {
case _CosmosVersions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosVersions value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosVersions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? applicationVersion,  String? cosmosSdkVersion,  String? tendermintVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosVersions() when $default != null:
return $default(_that.applicationVersion,_that.cosmosSdkVersion,_that.tendermintVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? applicationVersion,  String? cosmosSdkVersion,  String? tendermintVersion)  $default,) {final _that = this;
switch (_that) {
case _CosmosVersions():
return $default(_that.applicationVersion,_that.cosmosSdkVersion,_that.tendermintVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? applicationVersion,  String? cosmosSdkVersion,  String? tendermintVersion)?  $default,) {final _that = this;
switch (_that) {
case _CosmosVersions() when $default != null:
return $default(_that.applicationVersion,_that.cosmosSdkVersion,_that.tendermintVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosVersions extends CosmosVersions {
  const _CosmosVersions({this.applicationVersion, this.cosmosSdkVersion, this.tendermintVersion}): super._();
  factory _CosmosVersions.fromJson(Map<String, dynamic> json) => _$CosmosVersionsFromJson(json);

@override final  String? applicationVersion;
@override final  String? cosmosSdkVersion;
@override final  String? tendermintVersion;

/// Create a copy of CosmosVersions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosVersionsCopyWith<_CosmosVersions> get copyWith => __$CosmosVersionsCopyWithImpl<_CosmosVersions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosVersionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosVersions&&(identical(other.applicationVersion, applicationVersion) || other.applicationVersion == applicationVersion)&&(identical(other.cosmosSdkVersion, cosmosSdkVersion) || other.cosmosSdkVersion == cosmosSdkVersion)&&(identical(other.tendermintVersion, tendermintVersion) || other.tendermintVersion == tendermintVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,applicationVersion,cosmosSdkVersion,tendermintVersion);

@override
String toString() {
  return 'CosmosVersions(applicationVersion: $applicationVersion, cosmosSdkVersion: $cosmosSdkVersion, tendermintVersion: $tendermintVersion)';
}


}

/// @nodoc
abstract mixin class _$CosmosVersionsCopyWith<$Res> implements $CosmosVersionsCopyWith<$Res> {
  factory _$CosmosVersionsCopyWith(_CosmosVersions value, $Res Function(_CosmosVersions) _then) = __$CosmosVersionsCopyWithImpl;
@override @useResult
$Res call({
 String? applicationVersion, String? cosmosSdkVersion, String? tendermintVersion
});




}
/// @nodoc
class __$CosmosVersionsCopyWithImpl<$Res>
    implements _$CosmosVersionsCopyWith<$Res> {
  __$CosmosVersionsCopyWithImpl(this._self, this._then);

  final _CosmosVersions _self;
  final $Res Function(_CosmosVersions) _then;

/// Create a copy of CosmosVersions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? applicationVersion = freezed,Object? cosmosSdkVersion = freezed,Object? tendermintVersion = freezed,}) {
  return _then(_CosmosVersions(
applicationVersion: freezed == applicationVersion ? _self.applicationVersion : applicationVersion // ignore: cast_nullable_to_non_nullable
as String?,cosmosSdkVersion: freezed == cosmosSdkVersion ? _self.cosmosSdkVersion : cosmosSdkVersion // ignore: cast_nullable_to_non_nullable
as String?,tendermintVersion: freezed == tendermintVersion ? _self.tendermintVersion : tendermintVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
