// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosDenomUnit {

 String get denom; int get exponent; List<String>? get aliases;
/// Create a copy of CosmosDenomUnit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosDenomUnitCopyWith<CosmosDenomUnit> get copyWith => _$CosmosDenomUnitCopyWithImpl<CosmosDenomUnit>(this as CosmosDenomUnit, _$identity);

  /// Serializes this CosmosDenomUnit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosDenomUnit&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.exponent, exponent) || other.exponent == exponent)&&const DeepCollectionEquality().equals(other.aliases, aliases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,denom,exponent,const DeepCollectionEquality().hash(aliases));

@override
String toString() {
  return 'CosmosDenomUnit(denom: $denom, exponent: $exponent, aliases: $aliases)';
}


}

/// @nodoc
abstract mixin class $CosmosDenomUnitCopyWith<$Res>  {
  factory $CosmosDenomUnitCopyWith(CosmosDenomUnit value, $Res Function(CosmosDenomUnit) _then) = _$CosmosDenomUnitCopyWithImpl;
@useResult
$Res call({
 String denom, int exponent, List<String>? aliases
});




}
/// @nodoc
class _$CosmosDenomUnitCopyWithImpl<$Res>
    implements $CosmosDenomUnitCopyWith<$Res> {
  _$CosmosDenomUnitCopyWithImpl(this._self, this._then);

  final CosmosDenomUnit _self;
  final $Res Function(CosmosDenomUnit) _then;

/// Create a copy of CosmosDenomUnit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? denom = null,Object? exponent = null,Object? aliases = freezed,}) {
  return _then(_self.copyWith(
denom: null == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String,exponent: null == exponent ? _self.exponent : exponent // ignore: cast_nullable_to_non_nullable
as int,aliases: freezed == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosDenomUnit].
extension CosmosDenomUnitPatterns on CosmosDenomUnit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosDenomUnit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosDenomUnit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosDenomUnit value)  $default,){
final _that = this;
switch (_that) {
case _CosmosDenomUnit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosDenomUnit value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosDenomUnit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String denom,  int exponent,  List<String>? aliases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosDenomUnit() when $default != null:
return $default(_that.denom,_that.exponent,_that.aliases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String denom,  int exponent,  List<String>? aliases)  $default,) {final _that = this;
switch (_that) {
case _CosmosDenomUnit():
return $default(_that.denom,_that.exponent,_that.aliases);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String denom,  int exponent,  List<String>? aliases)?  $default,) {final _that = this;
switch (_that) {
case _CosmosDenomUnit() when $default != null:
return $default(_that.denom,_that.exponent,_that.aliases);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosDenomUnit extends CosmosDenomUnit {
  const _CosmosDenomUnit({required this.denom, required this.exponent, final  List<String>? aliases}): _aliases = aliases,super._();
  factory _CosmosDenomUnit.fromJson(Map<String, dynamic> json) => _$CosmosDenomUnitFromJson(json);

@override final  String denom;
@override final  int exponent;
 final  List<String>? _aliases;
@override List<String>? get aliases {
  final value = _aliases;
  if (value == null) return null;
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CosmosDenomUnit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosDenomUnitCopyWith<_CosmosDenomUnit> get copyWith => __$CosmosDenomUnitCopyWithImpl<_CosmosDenomUnit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosDenomUnitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosDenomUnit&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.exponent, exponent) || other.exponent == exponent)&&const DeepCollectionEquality().equals(other._aliases, _aliases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,denom,exponent,const DeepCollectionEquality().hash(_aliases));

@override
String toString() {
  return 'CosmosDenomUnit(denom: $denom, exponent: $exponent, aliases: $aliases)';
}


}

/// @nodoc
abstract mixin class _$CosmosDenomUnitCopyWith<$Res> implements $CosmosDenomUnitCopyWith<$Res> {
  factory _$CosmosDenomUnitCopyWith(_CosmosDenomUnit value, $Res Function(_CosmosDenomUnit) _then) = __$CosmosDenomUnitCopyWithImpl;
@override @useResult
$Res call({
 String denom, int exponent, List<String>? aliases
});




}
/// @nodoc
class __$CosmosDenomUnitCopyWithImpl<$Res>
    implements _$CosmosDenomUnitCopyWith<$Res> {
  __$CosmosDenomUnitCopyWithImpl(this._self, this._then);

  final _CosmosDenomUnit _self;
  final $Res Function(_CosmosDenomUnit) _then;

/// Create a copy of CosmosDenomUnit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? denom = null,Object? exponent = null,Object? aliases = freezed,}) {
  return _then(_CosmosDenomUnit(
denom: null == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String,exponent: null == exponent ? _self.exponent : exponent // ignore: cast_nullable_to_non_nullable
as int,aliases: freezed == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$CosmosLogoUris {

 String? get png; String? get svg;
/// Create a copy of CosmosLogoUris
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosLogoUrisCopyWith<CosmosLogoUris> get copyWith => _$CosmosLogoUrisCopyWithImpl<CosmosLogoUris>(this as CosmosLogoUris, _$identity);

  /// Serializes this CosmosLogoUris to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosLogoUris&&(identical(other.png, png) || other.png == png)&&(identical(other.svg, svg) || other.svg == svg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,png,svg);

@override
String toString() {
  return 'CosmosLogoUris(png: $png, svg: $svg)';
}


}

/// @nodoc
abstract mixin class $CosmosLogoUrisCopyWith<$Res>  {
  factory $CosmosLogoUrisCopyWith(CosmosLogoUris value, $Res Function(CosmosLogoUris) _then) = _$CosmosLogoUrisCopyWithImpl;
@useResult
$Res call({
 String? png, String? svg
});




}
/// @nodoc
class _$CosmosLogoUrisCopyWithImpl<$Res>
    implements $CosmosLogoUrisCopyWith<$Res> {
  _$CosmosLogoUrisCopyWithImpl(this._self, this._then);

  final CosmosLogoUris _self;
  final $Res Function(CosmosLogoUris) _then;

/// Create a copy of CosmosLogoUris
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? png = freezed,Object? svg = freezed,}) {
  return _then(_self.copyWith(
png: freezed == png ? _self.png : png // ignore: cast_nullable_to_non_nullable
as String?,svg: freezed == svg ? _self.svg : svg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosLogoUris].
extension CosmosLogoUrisPatterns on CosmosLogoUris {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosLogoUris value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosLogoUris() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosLogoUris value)  $default,){
final _that = this;
switch (_that) {
case _CosmosLogoUris():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosLogoUris value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosLogoUris() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? png,  String? svg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosLogoUris() when $default != null:
return $default(_that.png,_that.svg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? png,  String? svg)  $default,) {final _that = this;
switch (_that) {
case _CosmosLogoUris():
return $default(_that.png,_that.svg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? png,  String? svg)?  $default,) {final _that = this;
switch (_that) {
case _CosmosLogoUris() when $default != null:
return $default(_that.png,_that.svg);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosLogoUris extends CosmosLogoUris {
  const _CosmosLogoUris({this.png, this.svg}): super._();
  factory _CosmosLogoUris.fromJson(Map<String, dynamic> json) => _$CosmosLogoUrisFromJson(json);

@override final  String? png;
@override final  String? svg;

/// Create a copy of CosmosLogoUris
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosLogoUrisCopyWith<_CosmosLogoUris> get copyWith => __$CosmosLogoUrisCopyWithImpl<_CosmosLogoUris>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosLogoUrisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosLogoUris&&(identical(other.png, png) || other.png == png)&&(identical(other.svg, svg) || other.svg == svg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,png,svg);

@override
String toString() {
  return 'CosmosLogoUris(png: $png, svg: $svg)';
}


}

/// @nodoc
abstract mixin class _$CosmosLogoUrisCopyWith<$Res> implements $CosmosLogoUrisCopyWith<$Res> {
  factory _$CosmosLogoUrisCopyWith(_CosmosLogoUris value, $Res Function(_CosmosLogoUris) _then) = __$CosmosLogoUrisCopyWithImpl;
@override @useResult
$Res call({
 String? png, String? svg
});




}
/// @nodoc
class __$CosmosLogoUrisCopyWithImpl<$Res>
    implements _$CosmosLogoUrisCopyWith<$Res> {
  __$CosmosLogoUrisCopyWithImpl(this._self, this._then);

  final _CosmosLogoUris _self;
  final $Res Function(_CosmosLogoUris) _then;

/// Create a copy of CosmosLogoUris
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? png = freezed,Object? svg = freezed,}) {
  return _then(_CosmosLogoUris(
png: freezed == png ? _self.png : png // ignore: cast_nullable_to_non_nullable
as String?,svg: freezed == svg ? _self.svg : svg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CosmosAssetPrices {

 double get usd;
/// Create a copy of CosmosAssetPrices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosAssetPricesCopyWith<CosmosAssetPrices> get copyWith => _$CosmosAssetPricesCopyWithImpl<CosmosAssetPrices>(this as CosmosAssetPrices, _$identity);

  /// Serializes this CosmosAssetPrices to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosAssetPrices&&(identical(other.usd, usd) || other.usd == usd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usd);

@override
String toString() {
  return 'CosmosAssetPrices(usd: $usd)';
}


}

/// @nodoc
abstract mixin class $CosmosAssetPricesCopyWith<$Res>  {
  factory $CosmosAssetPricesCopyWith(CosmosAssetPrices value, $Res Function(CosmosAssetPrices) _then) = _$CosmosAssetPricesCopyWithImpl;
@useResult
$Res call({
 double usd
});




}
/// @nodoc
class _$CosmosAssetPricesCopyWithImpl<$Res>
    implements $CosmosAssetPricesCopyWith<$Res> {
  _$CosmosAssetPricesCopyWithImpl(this._self, this._then);

  final CosmosAssetPrices _self;
  final $Res Function(CosmosAssetPrices) _then;

/// Create a copy of CosmosAssetPrices
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? usd = null,}) {
  return _then(_self.copyWith(
usd: null == usd ? _self.usd : usd // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosAssetPrices].
extension CosmosAssetPricesPatterns on CosmosAssetPrices {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosAssetPrices value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosAssetPrices() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosAssetPrices value)  $default,){
final _that = this;
switch (_that) {
case _CosmosAssetPrices():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosAssetPrices value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosAssetPrices() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double usd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosAssetPrices() when $default != null:
return $default(_that.usd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double usd)  $default,) {final _that = this;
switch (_that) {
case _CosmosAssetPrices():
return $default(_that.usd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double usd)?  $default,) {final _that = this;
switch (_that) {
case _CosmosAssetPrices() when $default != null:
return $default(_that.usd);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosAssetPrices extends CosmosAssetPrices {
  const _CosmosAssetPrices({required this.usd}): super._();
  factory _CosmosAssetPrices.fromJson(Map<String, dynamic> json) => _$CosmosAssetPricesFromJson(json);

@override final  double usd;

/// Create a copy of CosmosAssetPrices
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosAssetPricesCopyWith<_CosmosAssetPrices> get copyWith => __$CosmosAssetPricesCopyWithImpl<_CosmosAssetPrices>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosAssetPricesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosAssetPrices&&(identical(other.usd, usd) || other.usd == usd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usd);

@override
String toString() {
  return 'CosmosAssetPrices(usd: $usd)';
}


}

/// @nodoc
abstract mixin class _$CosmosAssetPricesCopyWith<$Res> implements $CosmosAssetPricesCopyWith<$Res> {
  factory _$CosmosAssetPricesCopyWith(_CosmosAssetPrices value, $Res Function(_CosmosAssetPrices) _then) = __$CosmosAssetPricesCopyWithImpl;
@override @useResult
$Res call({
 double usd
});




}
/// @nodoc
class __$CosmosAssetPricesCopyWithImpl<$Res>
    implements _$CosmosAssetPricesCopyWith<$Res> {
  __$CosmosAssetPricesCopyWithImpl(this._self, this._then);

  final _CosmosAssetPrices _self;
  final $Res Function(_CosmosAssetPrices) _then;

/// Create a copy of CosmosAssetPrices
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usd = null,}) {
  return _then(_CosmosAssetPrices(
usd: null == usd ? _self.usd : usd // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CosmosAsset {

 String get name; String? get description; String get symbol; String get denom; int get decimals; CosmosDenomUnit get base; CosmosDenomUnit get display; List<CosmosDenomUnit> get denomUnits; CosmosLogoUris? get logoUris; String? get image; String? get coingeckoId; CosmosAssetPrices? get prices;
/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosAssetCopyWith<CosmosAsset> get copyWith => _$CosmosAssetCopyWithImpl<CosmosAsset>(this as CosmosAsset, _$identity);

  /// Serializes this CosmosAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosAsset&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.base, base) || other.base == base)&&(identical(other.display, display) || other.display == display)&&const DeepCollectionEquality().equals(other.denomUnits, denomUnits)&&(identical(other.logoUris, logoUris) || other.logoUris == logoUris)&&(identical(other.image, image) || other.image == image)&&(identical(other.coingeckoId, coingeckoId) || other.coingeckoId == coingeckoId)&&(identical(other.prices, prices) || other.prices == prices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,symbol,denom,decimals,base,display,const DeepCollectionEquality().hash(denomUnits),logoUris,image,coingeckoId,prices);

@override
String toString() {
  return 'CosmosAsset(name: $name, description: $description, symbol: $symbol, denom: $denom, decimals: $decimals, base: $base, display: $display, denomUnits: $denomUnits, logoUris: $logoUris, image: $image, coingeckoId: $coingeckoId, prices: $prices)';
}


}

/// @nodoc
abstract mixin class $CosmosAssetCopyWith<$Res>  {
  factory $CosmosAssetCopyWith(CosmosAsset value, $Res Function(CosmosAsset) _then) = _$CosmosAssetCopyWithImpl;
@useResult
$Res call({
 String name, String? description, String symbol, String denom, int decimals, CosmosDenomUnit base, CosmosDenomUnit display, List<CosmosDenomUnit> denomUnits, CosmosLogoUris? logoUris, String? image, String? coingeckoId, CosmosAssetPrices? prices
});


$CosmosDenomUnitCopyWith<$Res> get base;$CosmosDenomUnitCopyWith<$Res> get display;$CosmosLogoUrisCopyWith<$Res>? get logoUris;$CosmosAssetPricesCopyWith<$Res>? get prices;

}
/// @nodoc
class _$CosmosAssetCopyWithImpl<$Res>
    implements $CosmosAssetCopyWith<$Res> {
  _$CosmosAssetCopyWithImpl(this._self, this._then);

  final CosmosAsset _self;
  final $Res Function(CosmosAsset) _then;

/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? symbol = null,Object? denom = null,Object? decimals = null,Object? base = null,Object? display = null,Object? denomUnits = null,Object? logoUris = freezed,Object? image = freezed,Object? coingeckoId = freezed,Object? prices = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,denom: null == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as CosmosDenomUnit,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as CosmosDenomUnit,denomUnits: null == denomUnits ? _self.denomUnits : denomUnits // ignore: cast_nullable_to_non_nullable
as List<CosmosDenomUnit>,logoUris: freezed == logoUris ? _self.logoUris : logoUris // ignore: cast_nullable_to_non_nullable
as CosmosLogoUris?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,coingeckoId: freezed == coingeckoId ? _self.coingeckoId : coingeckoId // ignore: cast_nullable_to_non_nullable
as String?,prices: freezed == prices ? _self.prices : prices // ignore: cast_nullable_to_non_nullable
as CosmosAssetPrices?,
  ));
}
/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosDenomUnitCopyWith<$Res> get base {
  
  return $CosmosDenomUnitCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosDenomUnitCopyWith<$Res> get display {
  
  return $CosmosDenomUnitCopyWith<$Res>(_self.display, (value) {
    return _then(_self.copyWith(display: value));
  });
}/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosLogoUrisCopyWith<$Res>? get logoUris {
    if (_self.logoUris == null) {
    return null;
  }

  return $CosmosLogoUrisCopyWith<$Res>(_self.logoUris!, (value) {
    return _then(_self.copyWith(logoUris: value));
  });
}/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosAssetPricesCopyWith<$Res>? get prices {
    if (_self.prices == null) {
    return null;
  }

  return $CosmosAssetPricesCopyWith<$Res>(_self.prices!, (value) {
    return _then(_self.copyWith(prices: value));
  });
}
}


/// Adds pattern-matching-related methods to [CosmosAsset].
extension CosmosAssetPatterns on CosmosAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosAsset value)  $default,){
final _that = this;
switch (_that) {
case _CosmosAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosAsset value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  String symbol,  String denom,  int decimals,  CosmosDenomUnit base,  CosmosDenomUnit display,  List<CosmosDenomUnit> denomUnits,  CosmosLogoUris? logoUris,  String? image,  String? coingeckoId,  CosmosAssetPrices? prices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosAsset() when $default != null:
return $default(_that.name,_that.description,_that.symbol,_that.denom,_that.decimals,_that.base,_that.display,_that.denomUnits,_that.logoUris,_that.image,_that.coingeckoId,_that.prices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  String symbol,  String denom,  int decimals,  CosmosDenomUnit base,  CosmosDenomUnit display,  List<CosmosDenomUnit> denomUnits,  CosmosLogoUris? logoUris,  String? image,  String? coingeckoId,  CosmosAssetPrices? prices)  $default,) {final _that = this;
switch (_that) {
case _CosmosAsset():
return $default(_that.name,_that.description,_that.symbol,_that.denom,_that.decimals,_that.base,_that.display,_that.denomUnits,_that.logoUris,_that.image,_that.coingeckoId,_that.prices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  String symbol,  String denom,  int decimals,  CosmosDenomUnit base,  CosmosDenomUnit display,  List<CosmosDenomUnit> denomUnits,  CosmosLogoUris? logoUris,  String? image,  String? coingeckoId,  CosmosAssetPrices? prices)?  $default,) {final _that = this;
switch (_that) {
case _CosmosAsset() when $default != null:
return $default(_that.name,_that.description,_that.symbol,_that.denom,_that.decimals,_that.base,_that.display,_that.denomUnits,_that.logoUris,_that.image,_that.coingeckoId,_that.prices);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosAsset extends CosmosAsset {
  const _CosmosAsset({required this.name, this.description, required this.symbol, required this.denom, required this.decimals, required this.base, required this.display, required final  List<CosmosDenomUnit> denomUnits, this.logoUris, this.image, this.coingeckoId, this.prices}): _denomUnits = denomUnits,super._();
  factory _CosmosAsset.fromJson(Map<String, dynamic> json) => _$CosmosAssetFromJson(json);

@override final  String name;
@override final  String? description;
@override final  String symbol;
@override final  String denom;
@override final  int decimals;
@override final  CosmosDenomUnit base;
@override final  CosmosDenomUnit display;
 final  List<CosmosDenomUnit> _denomUnits;
@override List<CosmosDenomUnit> get denomUnits {
  if (_denomUnits is EqualUnmodifiableListView) return _denomUnits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_denomUnits);
}

@override final  CosmosLogoUris? logoUris;
@override final  String? image;
@override final  String? coingeckoId;
@override final  CosmosAssetPrices? prices;

/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosAssetCopyWith<_CosmosAsset> get copyWith => __$CosmosAssetCopyWithImpl<_CosmosAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosAsset&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.base, base) || other.base == base)&&(identical(other.display, display) || other.display == display)&&const DeepCollectionEquality().equals(other._denomUnits, _denomUnits)&&(identical(other.logoUris, logoUris) || other.logoUris == logoUris)&&(identical(other.image, image) || other.image == image)&&(identical(other.coingeckoId, coingeckoId) || other.coingeckoId == coingeckoId)&&(identical(other.prices, prices) || other.prices == prices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,symbol,denom,decimals,base,display,const DeepCollectionEquality().hash(_denomUnits),logoUris,image,coingeckoId,prices);

@override
String toString() {
  return 'CosmosAsset(name: $name, description: $description, symbol: $symbol, denom: $denom, decimals: $decimals, base: $base, display: $display, denomUnits: $denomUnits, logoUris: $logoUris, image: $image, coingeckoId: $coingeckoId, prices: $prices)';
}


}

/// @nodoc
abstract mixin class _$CosmosAssetCopyWith<$Res> implements $CosmosAssetCopyWith<$Res> {
  factory _$CosmosAssetCopyWith(_CosmosAsset value, $Res Function(_CosmosAsset) _then) = __$CosmosAssetCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, String symbol, String denom, int decimals, CosmosDenomUnit base, CosmosDenomUnit display, List<CosmosDenomUnit> denomUnits, CosmosLogoUris? logoUris, String? image, String? coingeckoId, CosmosAssetPrices? prices
});


@override $CosmosDenomUnitCopyWith<$Res> get base;@override $CosmosDenomUnitCopyWith<$Res> get display;@override $CosmosLogoUrisCopyWith<$Res>? get logoUris;@override $CosmosAssetPricesCopyWith<$Res>? get prices;

}
/// @nodoc
class __$CosmosAssetCopyWithImpl<$Res>
    implements _$CosmosAssetCopyWith<$Res> {
  __$CosmosAssetCopyWithImpl(this._self, this._then);

  final _CosmosAsset _self;
  final $Res Function(_CosmosAsset) _then;

/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? symbol = null,Object? denom = null,Object? decimals = null,Object? base = null,Object? display = null,Object? denomUnits = null,Object? logoUris = freezed,Object? image = freezed,Object? coingeckoId = freezed,Object? prices = freezed,}) {
  return _then(_CosmosAsset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,denom: null == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as CosmosDenomUnit,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as CosmosDenomUnit,denomUnits: null == denomUnits ? _self._denomUnits : denomUnits // ignore: cast_nullable_to_non_nullable
as List<CosmosDenomUnit>,logoUris: freezed == logoUris ? _self.logoUris : logoUris // ignore: cast_nullable_to_non_nullable
as CosmosLogoUris?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,coingeckoId: freezed == coingeckoId ? _self.coingeckoId : coingeckoId // ignore: cast_nullable_to_non_nullable
as String?,prices: freezed == prices ? _self.prices : prices // ignore: cast_nullable_to_non_nullable
as CosmosAssetPrices?,
  ));
}

/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosDenomUnitCopyWith<$Res> get base {
  
  return $CosmosDenomUnitCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosDenomUnitCopyWith<$Res> get display {
  
  return $CosmosDenomUnitCopyWith<$Res>(_self.display, (value) {
    return _then(_self.copyWith(display: value));
  });
}/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosLogoUrisCopyWith<$Res>? get logoUris {
    if (_self.logoUris == null) {
    return null;
  }

  return $CosmosLogoUrisCopyWith<$Res>(_self.logoUris!, (value) {
    return _then(_self.copyWith(logoUris: value));
  });
}/// Create a copy of CosmosAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosAssetPricesCopyWith<$Res>? get prices {
    if (_self.prices == null) {
    return null;
  }

  return $CosmosAssetPricesCopyWith<$Res>(_self.prices!, (value) {
    return _then(_self.copyWith(prices: value));
  });
}
}

// dart format on
