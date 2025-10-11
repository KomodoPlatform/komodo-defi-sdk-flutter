// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_chain_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosChainInfo {

 String get chainId; String get name; String? get rpc; String? get nativeCurrency;@JsonKey(name: 'bech32_prefix') String? get bech32Prefix; List<String>? get apis; String? get prettyName; String? get networkType; List<dynamic>? get keyAlgos; int? get slip44; Map<String, dynamic>? get fees;
/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosChainInfoCopyWith<CosmosChainInfo> get copyWith => _$CosmosChainInfoCopyWithImpl<CosmosChainInfo>(this as CosmosChainInfo, _$identity);

  /// Serializes this CosmosChainInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosChainInfo&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.name, name) || other.name == name)&&(identical(other.rpc, rpc) || other.rpc == rpc)&&(identical(other.nativeCurrency, nativeCurrency) || other.nativeCurrency == nativeCurrency)&&(identical(other.bech32Prefix, bech32Prefix) || other.bech32Prefix == bech32Prefix)&&const DeepCollectionEquality().equals(other.apis, apis)&&(identical(other.prettyName, prettyName) || other.prettyName == prettyName)&&(identical(other.networkType, networkType) || other.networkType == networkType)&&const DeepCollectionEquality().equals(other.keyAlgos, keyAlgos)&&(identical(other.slip44, slip44) || other.slip44 == slip44)&&const DeepCollectionEquality().equals(other.fees, fees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chainId,name,rpc,nativeCurrency,bech32Prefix,const DeepCollectionEquality().hash(apis),prettyName,networkType,const DeepCollectionEquality().hash(keyAlgos),slip44,const DeepCollectionEquality().hash(fees));



}

/// @nodoc
abstract mixin class $CosmosChainInfoCopyWith<$Res>  {
  factory $CosmosChainInfoCopyWith(CosmosChainInfo value, $Res Function(CosmosChainInfo) _then) = _$CosmosChainInfoCopyWithImpl;
@useResult
$Res call({
 String chainId, String name, String? rpc, String? nativeCurrency,@JsonKey(name: 'bech32_prefix') String? bech32Prefix, List<String>? apis, String? prettyName, String? networkType, List<dynamic>? keyAlgos, int? slip44, Map<String, dynamic>? fees
});




}
/// @nodoc
class _$CosmosChainInfoCopyWithImpl<$Res>
    implements $CosmosChainInfoCopyWith<$Res> {
  _$CosmosChainInfoCopyWithImpl(this._self, this._then);

  final CosmosChainInfo _self;
  final $Res Function(CosmosChainInfo) _then;

/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chainId = null,Object? name = null,Object? rpc = freezed,Object? nativeCurrency = freezed,Object? bech32Prefix = freezed,Object? apis = freezed,Object? prettyName = freezed,Object? networkType = freezed,Object? keyAlgos = freezed,Object? slip44 = freezed,Object? fees = freezed,}) {
  return _then(_self.copyWith(
chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rpc: freezed == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as String?,nativeCurrency: freezed == nativeCurrency ? _self.nativeCurrency : nativeCurrency // ignore: cast_nullable_to_non_nullable
as String?,bech32Prefix: freezed == bech32Prefix ? _self.bech32Prefix : bech32Prefix // ignore: cast_nullable_to_non_nullable
as String?,apis: freezed == apis ? _self.apis : apis // ignore: cast_nullable_to_non_nullable
as List<String>?,prettyName: freezed == prettyName ? _self.prettyName : prettyName // ignore: cast_nullable_to_non_nullable
as String?,networkType: freezed == networkType ? _self.networkType : networkType // ignore: cast_nullable_to_non_nullable
as String?,keyAlgos: freezed == keyAlgos ? _self.keyAlgos : keyAlgos // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,slip44: freezed == slip44 ? _self.slip44 : slip44 // ignore: cast_nullable_to_non_nullable
as int?,fees: freezed == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosChainInfo].
extension CosmosChainInfoPatterns on CosmosChainInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosChainInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosChainInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosChainInfo value)  $default,){
final _that = this;
switch (_that) {
case _CosmosChainInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosChainInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosChainInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chainId,  String name,  String? rpc,  String? nativeCurrency, @JsonKey(name: 'bech32_prefix')  String? bech32Prefix,  List<String>? apis,  String? prettyName,  String? networkType,  List<dynamic>? keyAlgos,  int? slip44,  Map<String, dynamic>? fees)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosChainInfo() when $default != null:
return $default(_that.chainId,_that.name,_that.rpc,_that.nativeCurrency,_that.bech32Prefix,_that.apis,_that.prettyName,_that.networkType,_that.keyAlgos,_that.slip44,_that.fees);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chainId,  String name,  String? rpc,  String? nativeCurrency, @JsonKey(name: 'bech32_prefix')  String? bech32Prefix,  List<String>? apis,  String? prettyName,  String? networkType,  List<dynamic>? keyAlgos,  int? slip44,  Map<String, dynamic>? fees)  $default,) {final _that = this;
switch (_that) {
case _CosmosChainInfo():
return $default(_that.chainId,_that.name,_that.rpc,_that.nativeCurrency,_that.bech32Prefix,_that.apis,_that.prettyName,_that.networkType,_that.keyAlgos,_that.slip44,_that.fees);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chainId,  String name,  String? rpc,  String? nativeCurrency, @JsonKey(name: 'bech32_prefix')  String? bech32Prefix,  List<String>? apis,  String? prettyName,  String? networkType,  List<dynamic>? keyAlgos,  int? slip44,  Map<String, dynamic>? fees)?  $default,) {final _that = this;
switch (_that) {
case _CosmosChainInfo() when $default != null:
return $default(_that.chainId,_that.name,_that.rpc,_that.nativeCurrency,_that.bech32Prefix,_that.apis,_that.prettyName,_that.networkType,_that.keyAlgos,_that.slip44,_that.fees);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosChainInfo extends CosmosChainInfo {
  const _CosmosChainInfo({required this.chainId, required this.name, this.rpc, this.nativeCurrency, @JsonKey(name: 'bech32_prefix') this.bech32Prefix, final  List<String>? apis, this.prettyName, this.networkType, final  List<dynamic>? keyAlgos, this.slip44, final  Map<String, dynamic>? fees}): _apis = apis,_keyAlgos = keyAlgos,_fees = fees,super._();
  factory _CosmosChainInfo.fromJson(Map<String, dynamic> json) => _$CosmosChainInfoFromJson(json);

@override final  String chainId;
@override final  String name;
@override final  String? rpc;
@override final  String? nativeCurrency;
@override@JsonKey(name: 'bech32_prefix') final  String? bech32Prefix;
 final  List<String>? _apis;
@override List<String>? get apis {
  final value = _apis;
  if (value == null) return null;
  if (_apis is EqualUnmodifiableListView) return _apis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? prettyName;
@override final  String? networkType;
 final  List<dynamic>? _keyAlgos;
@override List<dynamic>? get keyAlgos {
  final value = _keyAlgos;
  if (value == null) return null;
  if (_keyAlgos is EqualUnmodifiableListView) return _keyAlgos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? slip44;
 final  Map<String, dynamic>? _fees;
@override Map<String, dynamic>? get fees {
  final value = _fees;
  if (value == null) return null;
  if (_fees is EqualUnmodifiableMapView) return _fees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosChainInfoCopyWith<_CosmosChainInfo> get copyWith => __$CosmosChainInfoCopyWithImpl<_CosmosChainInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosChainInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosChainInfo&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.name, name) || other.name == name)&&(identical(other.rpc, rpc) || other.rpc == rpc)&&(identical(other.nativeCurrency, nativeCurrency) || other.nativeCurrency == nativeCurrency)&&(identical(other.bech32Prefix, bech32Prefix) || other.bech32Prefix == bech32Prefix)&&const DeepCollectionEquality().equals(other._apis, _apis)&&(identical(other.prettyName, prettyName) || other.prettyName == prettyName)&&(identical(other.networkType, networkType) || other.networkType == networkType)&&const DeepCollectionEquality().equals(other._keyAlgos, _keyAlgos)&&(identical(other.slip44, slip44) || other.slip44 == slip44)&&const DeepCollectionEquality().equals(other._fees, _fees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chainId,name,rpc,nativeCurrency,bech32Prefix,const DeepCollectionEquality().hash(_apis),prettyName,networkType,const DeepCollectionEquality().hash(_keyAlgos),slip44,const DeepCollectionEquality().hash(_fees));



}

/// @nodoc
abstract mixin class _$CosmosChainInfoCopyWith<$Res> implements $CosmosChainInfoCopyWith<$Res> {
  factory _$CosmosChainInfoCopyWith(_CosmosChainInfo value, $Res Function(_CosmosChainInfo) _then) = __$CosmosChainInfoCopyWithImpl;
@override @useResult
$Res call({
 String chainId, String name, String? rpc, String? nativeCurrency,@JsonKey(name: 'bech32_prefix') String? bech32Prefix, List<String>? apis, String? prettyName, String? networkType, List<dynamic>? keyAlgos, int? slip44, Map<String, dynamic>? fees
});




}
/// @nodoc
class __$CosmosChainInfoCopyWithImpl<$Res>
    implements _$CosmosChainInfoCopyWith<$Res> {
  __$CosmosChainInfoCopyWithImpl(this._self, this._then);

  final _CosmosChainInfo _self;
  final $Res Function(_CosmosChainInfo) _then;

/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chainId = null,Object? name = null,Object? rpc = freezed,Object? nativeCurrency = freezed,Object? bech32Prefix = freezed,Object? apis = freezed,Object? prettyName = freezed,Object? networkType = freezed,Object? keyAlgos = freezed,Object? slip44 = freezed,Object? fees = freezed,}) {
  return _then(_CosmosChainInfo(
chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rpc: freezed == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as String?,nativeCurrency: freezed == nativeCurrency ? _self.nativeCurrency : nativeCurrency // ignore: cast_nullable_to_non_nullable
as String?,bech32Prefix: freezed == bech32Prefix ? _self.bech32Prefix : bech32Prefix // ignore: cast_nullable_to_non_nullable
as String?,apis: freezed == apis ? _self._apis : apis // ignore: cast_nullable_to_non_nullable
as List<String>?,prettyName: freezed == prettyName ? _self.prettyName : prettyName // ignore: cast_nullable_to_non_nullable
as String?,networkType: freezed == networkType ? _self.networkType : networkType // ignore: cast_nullable_to_non_nullable
as String?,keyAlgos: freezed == keyAlgos ? _self._keyAlgos : keyAlgos // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,slip44: freezed == slip44 ? _self.slip44 : slip44 // ignore: cast_nullable_to_non_nullable
as int?,fees: freezed == fees ? _self._fees : fees // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
