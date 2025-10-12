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
mixin _$NativeCurrency {

 String get name; String get symbol; int get decimals;
/// Create a copy of NativeCurrency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeCurrencyCopyWith<NativeCurrency> get copyWith => _$NativeCurrencyCopyWithImpl<NativeCurrency>(this as NativeCurrency, _$identity);

  /// Serializes this NativeCurrency to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeCurrency&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.decimals, decimals) || other.decimals == decimals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,decimals);

@override
String toString() {
  return 'NativeCurrency(name: $name, symbol: $symbol, decimals: $decimals)';
}


}

/// @nodoc
abstract mixin class $NativeCurrencyCopyWith<$Res>  {
  factory $NativeCurrencyCopyWith(NativeCurrency value, $Res Function(NativeCurrency) _then) = _$NativeCurrencyCopyWithImpl;
@useResult
$Res call({
 String name, String symbol, int decimals
});




}
/// @nodoc
class _$NativeCurrencyCopyWithImpl<$Res>
    implements $NativeCurrencyCopyWith<$Res> {
  _$NativeCurrencyCopyWithImpl(this._self, this._then);

  final NativeCurrency _self;
  final $Res Function(NativeCurrency) _then;

/// Create a copy of NativeCurrency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? symbol = null,Object? decimals = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeCurrency].
extension NativeCurrencyPatterns on NativeCurrency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeCurrency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeCurrency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeCurrency value)  $default,){
final _that = this;
switch (_that) {
case _NativeCurrency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeCurrency value)?  $default,){
final _that = this;
switch (_that) {
case _NativeCurrency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String symbol,  int decimals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeCurrency() when $default != null:
return $default(_that.name,_that.symbol,_that.decimals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String symbol,  int decimals)  $default,) {final _that = this;
switch (_that) {
case _NativeCurrency():
return $default(_that.name,_that.symbol,_that.decimals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String symbol,  int decimals)?  $default,) {final _that = this;
switch (_that) {
case _NativeCurrency() when $default != null:
return $default(_that.name,_that.symbol,_that.decimals);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NativeCurrency implements NativeCurrency {
  const _NativeCurrency({required this.name, required this.symbol, required this.decimals});
  factory _NativeCurrency.fromJson(Map<String, dynamic> json) => _$NativeCurrencyFromJson(json);

@override final  String name;
@override final  String symbol;
@override final  int decimals;

/// Create a copy of NativeCurrency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeCurrencyCopyWith<_NativeCurrency> get copyWith => __$NativeCurrencyCopyWithImpl<_NativeCurrency>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NativeCurrencyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeCurrency&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.decimals, decimals) || other.decimals == decimals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,decimals);

@override
String toString() {
  return 'NativeCurrency(name: $name, symbol: $symbol, decimals: $decimals)';
}


}

/// @nodoc
abstract mixin class _$NativeCurrencyCopyWith<$Res> implements $NativeCurrencyCopyWith<$Res> {
  factory _$NativeCurrencyCopyWith(_NativeCurrency value, $Res Function(_NativeCurrency) _then) = __$NativeCurrencyCopyWithImpl;
@override @useResult
$Res call({
 String name, String symbol, int decimals
});




}
/// @nodoc
class __$NativeCurrencyCopyWithImpl<$Res>
    implements _$NativeCurrencyCopyWith<$Res> {
  __$NativeCurrencyCopyWithImpl(this._self, this._then);

  final _NativeCurrency _self;
  final $Res Function(_NativeCurrency) _then;

/// Create a copy of NativeCurrency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? symbol = null,Object? decimals = null,}) {
  return _then(_NativeCurrency(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$EvmChainInfo {

 String get name; int get chainId; String get shortName; int get networkId; NativeCurrency get nativeCurrency; List<String> get rpc; List<String> get faucets;@JsonKey(name: 'infoURL') String get infoURL;
/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvmChainInfoCopyWith<EvmChainInfo> get copyWith => _$EvmChainInfoCopyWithImpl<EvmChainInfo>(this as EvmChainInfo, _$identity);

  /// Serializes this EvmChainInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvmChainInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.networkId, networkId) || other.networkId == networkId)&&(identical(other.nativeCurrency, nativeCurrency) || other.nativeCurrency == nativeCurrency)&&const DeepCollectionEquality().equals(other.rpc, rpc)&&const DeepCollectionEquality().equals(other.faucets, faucets)&&(identical(other.infoURL, infoURL) || other.infoURL == infoURL));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,chainId,shortName,networkId,nativeCurrency,const DeepCollectionEquality().hash(rpc),const DeepCollectionEquality().hash(faucets),infoURL);

@override
String toString() {
  return 'EvmChainInfo(name: $name, chainId: $chainId, shortName: $shortName, networkId: $networkId, nativeCurrency: $nativeCurrency, rpc: $rpc, faucets: $faucets, infoURL: $infoURL)';
}


}

/// @nodoc
abstract mixin class $EvmChainInfoCopyWith<$Res>  {
  factory $EvmChainInfoCopyWith(EvmChainInfo value, $Res Function(EvmChainInfo) _then) = _$EvmChainInfoCopyWithImpl;
@useResult
$Res call({
 String name, int chainId, String shortName, int networkId, NativeCurrency nativeCurrency, List<String> rpc, List<String> faucets,@JsonKey(name: 'infoURL') String infoURL
});


$NativeCurrencyCopyWith<$Res> get nativeCurrency;

}
/// @nodoc
class _$EvmChainInfoCopyWithImpl<$Res>
    implements $EvmChainInfoCopyWith<$Res> {
  _$EvmChainInfoCopyWithImpl(this._self, this._then);

  final EvmChainInfo _self;
  final $Res Function(EvmChainInfo) _then;

/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? chainId = null,Object? shortName = null,Object? networkId = null,Object? nativeCurrency = null,Object? rpc = null,Object? faucets = null,Object? infoURL = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,networkId: null == networkId ? _self.networkId : networkId // ignore: cast_nullable_to_non_nullable
as int,nativeCurrency: null == nativeCurrency ? _self.nativeCurrency : nativeCurrency // ignore: cast_nullable_to_non_nullable
as NativeCurrency,rpc: null == rpc ? _self.rpc : rpc // ignore: cast_nullable_to_non_nullable
as List<String>,faucets: null == faucets ? _self.faucets : faucets // ignore: cast_nullable_to_non_nullable
as List<String>,infoURL: null == infoURL ? _self.infoURL : infoURL // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeCurrencyCopyWith<$Res> get nativeCurrency {
  
  return $NativeCurrencyCopyWith<$Res>(_self.nativeCurrency, (value) {
    return _then(_self.copyWith(nativeCurrency: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int chainId,  String shortName,  int networkId,  NativeCurrency nativeCurrency,  List<String> rpc,  List<String> faucets, @JsonKey(name: 'infoURL')  String infoURL)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvmChainInfo() when $default != null:
return $default(_that.name,_that.chainId,_that.shortName,_that.networkId,_that.nativeCurrency,_that.rpc,_that.faucets,_that.infoURL);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int chainId,  String shortName,  int networkId,  NativeCurrency nativeCurrency,  List<String> rpc,  List<String> faucets, @JsonKey(name: 'infoURL')  String infoURL)  $default,) {final _that = this;
switch (_that) {
case _EvmChainInfo():
return $default(_that.name,_that.chainId,_that.shortName,_that.networkId,_that.nativeCurrency,_that.rpc,_that.faucets,_that.infoURL);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int chainId,  String shortName,  int networkId,  NativeCurrency nativeCurrency,  List<String> rpc,  List<String> faucets, @JsonKey(name: 'infoURL')  String infoURL)?  $default,) {final _that = this;
switch (_that) {
case _EvmChainInfo() when $default != null:
return $default(_that.name,_that.chainId,_that.shortName,_that.networkId,_that.nativeCurrency,_that.rpc,_that.faucets,_that.infoURL);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EvmChainInfo extends EvmChainInfo {
  const _EvmChainInfo({required this.name, required this.chainId, required this.shortName, required this.networkId, required this.nativeCurrency, required final  List<String> rpc, required final  List<String> faucets, @JsonKey(name: 'infoURL') required this.infoURL}): _rpc = rpc,_faucets = faucets,super._();
  factory _EvmChainInfo.fromJson(Map<String, dynamic> json) => _$EvmChainInfoFromJson(json);

@override final  String name;
@override final  int chainId;
@override final  String shortName;
@override final  int networkId;
@override final  NativeCurrency nativeCurrency;
 final  List<String> _rpc;
@override List<String> get rpc {
  if (_rpc is EqualUnmodifiableListView) return _rpc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rpc);
}

 final  List<String> _faucets;
@override List<String> get faucets {
  if (_faucets is EqualUnmodifiableListView) return _faucets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_faucets);
}

@override@JsonKey(name: 'infoURL') final  String infoURL;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvmChainInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.networkId, networkId) || other.networkId == networkId)&&(identical(other.nativeCurrency, nativeCurrency) || other.nativeCurrency == nativeCurrency)&&const DeepCollectionEquality().equals(other._rpc, _rpc)&&const DeepCollectionEquality().equals(other._faucets, _faucets)&&(identical(other.infoURL, infoURL) || other.infoURL == infoURL));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,chainId,shortName,networkId,nativeCurrency,const DeepCollectionEquality().hash(_rpc),const DeepCollectionEquality().hash(_faucets),infoURL);

@override
String toString() {
  return 'EvmChainInfo(name: $name, chainId: $chainId, shortName: $shortName, networkId: $networkId, nativeCurrency: $nativeCurrency, rpc: $rpc, faucets: $faucets, infoURL: $infoURL)';
}


}

/// @nodoc
abstract mixin class _$EvmChainInfoCopyWith<$Res> implements $EvmChainInfoCopyWith<$Res> {
  factory _$EvmChainInfoCopyWith(_EvmChainInfo value, $Res Function(_EvmChainInfo) _then) = __$EvmChainInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, int chainId, String shortName, int networkId, NativeCurrency nativeCurrency, List<String> rpc, List<String> faucets,@JsonKey(name: 'infoURL') String infoURL
});


@override $NativeCurrencyCopyWith<$Res> get nativeCurrency;

}
/// @nodoc
class __$EvmChainInfoCopyWithImpl<$Res>
    implements _$EvmChainInfoCopyWith<$Res> {
  __$EvmChainInfoCopyWithImpl(this._self, this._then);

  final _EvmChainInfo _self;
  final $Res Function(_EvmChainInfo) _then;

/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? chainId = null,Object? shortName = null,Object? networkId = null,Object? nativeCurrency = null,Object? rpc = null,Object? faucets = null,Object? infoURL = null,}) {
  return _then(_EvmChainInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,networkId: null == networkId ? _self.networkId : networkId // ignore: cast_nullable_to_non_nullable
as int,nativeCurrency: null == nativeCurrency ? _self.nativeCurrency : nativeCurrency // ignore: cast_nullable_to_non_nullable
as NativeCurrency,rpc: null == rpc ? _self._rpc : rpc // ignore: cast_nullable_to_non_nullable
as List<String>,faucets: null == faucets ? _self._faucets : faucets // ignore: cast_nullable_to_non_nullable
as List<String>,infoURL: null == infoURL ? _self.infoURL : infoURL // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of EvmChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeCurrencyCopyWith<$Res> get nativeCurrency {
  
  return $NativeCurrencyCopyWith<$Res>(_self.nativeCurrency, (value) {
    return _then(_self.copyWith(nativeCurrency: value));
  });
}
}

// dart format on
