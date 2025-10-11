// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evm_chain_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvmChainInfo {

 String get chainId; String get name; int get networkId; String? get rpc; String? get nativeCurrency; List<String>? get explorers; String? get shortName; String? get chain; String? get icon;@JsonKey(name: 'infoURL') String? get infoURL;
/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvmChainInfoCopyWith<EvmChainInfo> get copyWith => _$EvmChainInfoCopyWithImpl<EvmChainInfo>(this as EvmChainInfo, _$identity);

  /// Serializes this EvmChainInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvmChainInfo&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.name, name) || other.name == name)&&(identical(other.networkId, networkId) || other.networkId == networkId)&&(identical(other.rpc, rpc) || other.rpc == rpc)&&(identical(other.nativeCurrency, nativeCurrency) || other.nativeCurrency == nativeCurrency)&&const DeepCollectionEquality().equals(other.explorers, explorers)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.chain, chain) || other.chain == chain)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.infoURL, infoURL) || other.infoURL == infoURL));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chainId,name,networkId,rpc,nativeCurrency,const DeepCollectionEquality().hash(explorers),shortName,chain,icon,infoURL);



}

/// @nodoc
abstract mixin class $EvmChainInfoCopyWith<$Res>  {
  factory $EvmChainInfoCopyWith(EvmChainInfo value, $Res Function(EvmChainInfo) _then) = _$EvmChainInfoCopyWithImpl;
@useResult
$Res call({
 String chainId, String name, int networkId, String? rpc, String? nativeCurrency, List<String>? explorers, String? shortName, String? chain, String? icon,@JsonKey(name: 'infoURL') String? infoURL
});




}
/// @nodoc
class _$EvmChainInfoCopyWithImpl<$Res>
    implements $EvmChainInfoCopyWith<$Res> {
  _$EvmChainInfoCopyWithImpl(this._self, this._then);

  final EvmChainInfo _self;
  final $Res Function(EvmChainInfo) _then;

/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chainId = null,Object? name = null,Object? networkId = null,Object? rpc = freezed,Object? nativeCurrency = freezed,Object? explorers = freezed,Object? shortName = freezed,Object? chain = freezed,Object? icon = freezed,Object? infoURL = freezed,}) {
  return _then(_self.copyWith(
chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,networkId: null == networkId ? _self.networkId : networkId // ignore: cast_nullable_to_non_nullable
as int,rpc: freezed == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as String?,nativeCurrency: freezed == nativeCurrency ? _self.nativeCurrency : nativeCurrency // ignore: cast_nullable_to_non_nullable
as String?,explorers: freezed == explorers ? _self.explorers : explorers // ignore: cast_nullable_to_non_nullable
as List<String>?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,chain: freezed == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,infoURL: freezed == infoURL ? _self.infoURL : infoURL // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EvmChainInfo].
extension EvmChainInfoPatterns on EvmChainInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvmChainInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvmChainInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvmChainInfo value)  $default,){
final _that = this;
switch (_that) {
case _EvmChainInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvmChainInfo value)?  $default,){
final _that = this;
switch (_that) {
case _EvmChainInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chainId,  String name,  int networkId,  String? rpc,  String? nativeCurrency,  List<String>? explorers,  String? shortName,  String? chain,  String? icon, @JsonKey(name: 'infoURL')  String? infoURL)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvmChainInfo() when $default != null:
return $default(_that.chainId,_that.name,_that.networkId,_that.rpc,_that.nativeCurrency,_that.explorers,_that.shortName,_that.chain,_that.icon,_that.infoURL);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chainId,  String name,  int networkId,  String? rpc,  String? nativeCurrency,  List<String>? explorers,  String? shortName,  String? chain,  String? icon, @JsonKey(name: 'infoURL')  String? infoURL)  $default,) {final _that = this;
switch (_that) {
case _EvmChainInfo():
return $default(_that.chainId,_that.name,_that.networkId,_that.rpc,_that.nativeCurrency,_that.explorers,_that.shortName,_that.chain,_that.icon,_that.infoURL);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chainId,  String name,  int networkId,  String? rpc,  String? nativeCurrency,  List<String>? explorers,  String? shortName,  String? chain,  String? icon, @JsonKey(name: 'infoURL')  String? infoURL)?  $default,) {final _that = this;
switch (_that) {
case _EvmChainInfo() when $default != null:
return $default(_that.chainId,_that.name,_that.networkId,_that.rpc,_that.nativeCurrency,_that.explorers,_that.shortName,_that.chain,_that.icon,_that.infoURL);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _EvmChainInfo extends EvmChainInfo {
  const _EvmChainInfo({required this.chainId, required this.name, required this.networkId, this.rpc, this.nativeCurrency, final  List<String>? explorers, this.shortName, this.chain, this.icon, @JsonKey(name: 'infoURL') this.infoURL}): _explorers = explorers,super._();
  factory _EvmChainInfo.fromJson(Map<String, dynamic> json) => _$EvmChainInfoFromJson(json);

@override final  String chainId;
@override final  String name;
@override final  int networkId;
@override final  String? rpc;
@override final  String? nativeCurrency;
 final  List<String>? _explorers;
@override List<String>? get explorers {
  final value = _explorers;
  if (value == null) return null;
  if (_explorers is EqualUnmodifiableListView) return _explorers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? shortName;
@override final  String? chain;
@override final  String? icon;
@override@JsonKey(name: 'infoURL') final  String? infoURL;

/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvmChainInfoCopyWith<_EvmChainInfo> get copyWith => __$EvmChainInfoCopyWithImpl<_EvmChainInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvmChainInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvmChainInfo&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.name, name) || other.name == name)&&(identical(other.networkId, networkId) || other.networkId == networkId)&&(identical(other.rpc, rpc) || other.rpc == rpc)&&(identical(other.nativeCurrency, nativeCurrency) || other.nativeCurrency == nativeCurrency)&&const DeepCollectionEquality().equals(other._explorers, _explorers)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.chain, chain) || other.chain == chain)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.infoURL, infoURL) || other.infoURL == infoURL));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chainId,name,networkId,rpc,nativeCurrency,const DeepCollectionEquality().hash(_explorers),shortName,chain,icon,infoURL);



}

/// @nodoc
abstract mixin class _$EvmChainInfoCopyWith<$Res> implements $EvmChainInfoCopyWith<$Res> {
  factory _$EvmChainInfoCopyWith(_EvmChainInfo value, $Res Function(_EvmChainInfo) _then) = __$EvmChainInfoCopyWithImpl;
@override @useResult
$Res call({
 String chainId, String name, int networkId, String? rpc, String? nativeCurrency, List<String>? explorers, String? shortName, String? chain, String? icon,@JsonKey(name: 'infoURL') String? infoURL
});




}
/// @nodoc
class __$EvmChainInfoCopyWithImpl<$Res>
    implements _$EvmChainInfoCopyWith<$Res> {
  __$EvmChainInfoCopyWithImpl(this._self, this._then);

  final _EvmChainInfo _self;
  final $Res Function(_EvmChainInfo) _then;

/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chainId = null,Object? name = null,Object? networkId = null,Object? rpc = freezed,Object? nativeCurrency = freezed,Object? explorers = freezed,Object? shortName = freezed,Object? chain = freezed,Object? icon = freezed,Object? infoURL = freezed,}) {
  return _then(_EvmChainInfo(
chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,networkId: null == networkId ? _self.networkId : networkId // ignore: cast_nullable_to_non_nullable
as int,rpc: freezed == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as String?,nativeCurrency: freezed == nativeCurrency ? _self.nativeCurrency : nativeCurrency // ignore: cast_nullable_to_non_nullable
as String?,explorers: freezed == explorers ? _self._explorers : explorers // ignore: cast_nullable_to_non_nullable
as List<String>?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,chain: freezed == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,infoURL: freezed == infoURL ? _self.infoURL : infoURL // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
