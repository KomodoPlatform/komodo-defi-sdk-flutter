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

 String get name; String get path; String get chainName; String get networkType; String get prettyName; String get chainId; String get status;@JsonKey(name: 'bech32_prefix') String get bech32Prefix; int get slip44; String get symbol; String get display; String get denom; int get decimals; CosmosBestApis get bestApis; CosmosProxyStatus get proxyStatus; CosmosVersions get versions; String? get image; String? get website; int? get height; List<CosmosExplorer>? get explorers;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get params; List<CosmosAsset>? get assets; List<String>? get keywords;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get prices; String? get coingeckoId;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get services;
/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosChainInfoCopyWith<CosmosChainInfo> get copyWith => _$CosmosChainInfoCopyWithImpl<CosmosChainInfo>(this as CosmosChainInfo, _$identity);

  /// Serializes this CosmosChainInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosChainInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.chainName, chainName) || other.chainName == chainName)&&(identical(other.networkType, networkType) || other.networkType == networkType)&&(identical(other.prettyName, prettyName) || other.prettyName == prettyName)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.status, status) || other.status == status)&&(identical(other.bech32Prefix, bech32Prefix) || other.bech32Prefix == bech32Prefix)&&(identical(other.slip44, slip44) || other.slip44 == slip44)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.display, display) || other.display == display)&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.bestApis, bestApis) || other.bestApis == bestApis)&&(identical(other.proxyStatus, proxyStatus) || other.proxyStatus == proxyStatus)&&(identical(other.versions, versions) || other.versions == versions)&&(identical(other.image, image) || other.image == image)&&(identical(other.website, website) || other.website == website)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.explorers, explorers)&&const DeepCollectionEquality().equals(other.params, params)&&const DeepCollectionEquality().equals(other.assets, assets)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&const DeepCollectionEquality().equals(other.prices, prices)&&(identical(other.coingeckoId, coingeckoId) || other.coingeckoId == coingeckoId)&&const DeepCollectionEquality().equals(other.services, services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,path,chainName,networkType,prettyName,chainId,status,bech32Prefix,slip44,symbol,display,denom,decimals,bestApis,proxyStatus,versions,image,website,height,const DeepCollectionEquality().hash(explorers),const DeepCollectionEquality().hash(params),const DeepCollectionEquality().hash(assets),const DeepCollectionEquality().hash(keywords),const DeepCollectionEquality().hash(prices),coingeckoId,const DeepCollectionEquality().hash(services)]);

@override
String toString() {
  return 'CosmosChainInfo(name: $name, path: $path, chainName: $chainName, networkType: $networkType, prettyName: $prettyName, chainId: $chainId, status: $status, bech32Prefix: $bech32Prefix, slip44: $slip44, symbol: $symbol, display: $display, denom: $denom, decimals: $decimals, bestApis: $bestApis, proxyStatus: $proxyStatus, versions: $versions, image: $image, website: $website, height: $height, explorers: $explorers, params: $params, assets: $assets, keywords: $keywords, prices: $prices, coingeckoId: $coingeckoId, services: $services)';
}


}

/// @nodoc
abstract mixin class $CosmosChainInfoCopyWith<$Res>  {
  factory $CosmosChainInfoCopyWith(CosmosChainInfo value, $Res Function(CosmosChainInfo) _then) = _$CosmosChainInfoCopyWithImpl;
@useResult
$Res call({
 String name, String path, String chainName, String networkType, String prettyName, String chainId, String status,@JsonKey(name: 'bech32_prefix') String bech32Prefix, int slip44, String symbol, String display, String denom, int decimals, CosmosBestApis bestApis, CosmosProxyStatus proxyStatus, CosmosVersions versions, String? image, String? website, int? height, List<CosmosExplorer>? explorers,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? params, List<CosmosAsset>? assets, List<String>? keywords,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? prices, String? coingeckoId,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? services
});


$CosmosBestApisCopyWith<$Res> get bestApis;$CosmosProxyStatusCopyWith<$Res> get proxyStatus;$CosmosVersionsCopyWith<$Res> get versions;

}
/// @nodoc
class _$CosmosChainInfoCopyWithImpl<$Res>
    implements $CosmosChainInfoCopyWith<$Res> {
  _$CosmosChainInfoCopyWithImpl(this._self, this._then);

  final CosmosChainInfo _self;
  final $Res Function(CosmosChainInfo) _then;

/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? chainName = null,Object? networkType = null,Object? prettyName = null,Object? chainId = null,Object? status = null,Object? bech32Prefix = null,Object? slip44 = null,Object? symbol = null,Object? display = null,Object? denom = null,Object? decimals = null,Object? bestApis = null,Object? proxyStatus = null,Object? versions = null,Object? image = freezed,Object? website = freezed,Object? height = freezed,Object? explorers = freezed,Object? params = freezed,Object? assets = freezed,Object? keywords = freezed,Object? prices = freezed,Object? coingeckoId = freezed,Object? services = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,chainName: null == chainName ? _self.chainName : chainName // ignore: cast_nullable_to_non_nullable
as String,networkType: null == networkType ? _self.networkType : networkType // ignore: cast_nullable_to_non_nullable
as String,prettyName: null == prettyName ? _self.prettyName : prettyName // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,bech32Prefix: null == bech32Prefix ? _self.bech32Prefix : bech32Prefix // ignore: cast_nullable_to_non_nullable
as String,slip44: null == slip44 ? _self.slip44 : slip44 // ignore: cast_nullable_to_non_nullable
as int,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,denom: null == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,bestApis: null == bestApis ? _self.bestApis : bestApis // ignore: cast_nullable_to_non_nullable
as CosmosBestApis,proxyStatus: null == proxyStatus ? _self.proxyStatus : proxyStatus // ignore: cast_nullable_to_non_nullable
as CosmosProxyStatus,versions: null == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as CosmosVersions,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,explorers: freezed == explorers ? _self.explorers : explorers // ignore: cast_nullable_to_non_nullable
as List<CosmosExplorer>?,params: freezed == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,assets: freezed == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<CosmosAsset>?,keywords: freezed == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>?,prices: freezed == prices ? _self.prices : prices // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,coingeckoId: freezed == coingeckoId ? _self.coingeckoId : coingeckoId // ignore: cast_nullable_to_non_nullable
as String?,services: freezed == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosBestApisCopyWith<$Res> get bestApis {
  
  return $CosmosBestApisCopyWith<$Res>(_self.bestApis, (value) {
    return _then(_self.copyWith(bestApis: value));
  });
}/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosProxyStatusCopyWith<$Res> get proxyStatus {
  
  return $CosmosProxyStatusCopyWith<$Res>(_self.proxyStatus, (value) {
    return _then(_self.copyWith(proxyStatus: value));
  });
}/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosVersionsCopyWith<$Res> get versions {
  
  return $CosmosVersionsCopyWith<$Res>(_self.versions, (value) {
    return _then(_self.copyWith(versions: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  String chainName,  String networkType,  String prettyName,  String chainId,  String status, @JsonKey(name: 'bech32_prefix')  String bech32Prefix,  int slip44,  String symbol,  String display,  String denom,  int decimals,  CosmosBestApis bestApis,  CosmosProxyStatus proxyStatus,  CosmosVersions versions,  String? image,  String? website,  int? height,  List<CosmosExplorer>? explorers, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? params,  List<CosmosAsset>? assets,  List<String>? keywords, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? prices,  String? coingeckoId, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? services)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosChainInfo() when $default != null:
return $default(_that.name,_that.path,_that.chainName,_that.networkType,_that.prettyName,_that.chainId,_that.status,_that.bech32Prefix,_that.slip44,_that.symbol,_that.display,_that.denom,_that.decimals,_that.bestApis,_that.proxyStatus,_that.versions,_that.image,_that.website,_that.height,_that.explorers,_that.params,_that.assets,_that.keywords,_that.prices,_that.coingeckoId,_that.services);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  String chainName,  String networkType,  String prettyName,  String chainId,  String status, @JsonKey(name: 'bech32_prefix')  String bech32Prefix,  int slip44,  String symbol,  String display,  String denom,  int decimals,  CosmosBestApis bestApis,  CosmosProxyStatus proxyStatus,  CosmosVersions versions,  String? image,  String? website,  int? height,  List<CosmosExplorer>? explorers, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? params,  List<CosmosAsset>? assets,  List<String>? keywords, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? prices,  String? coingeckoId, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? services)  $default,) {final _that = this;
switch (_that) {
case _CosmosChainInfo():
return $default(_that.name,_that.path,_that.chainName,_that.networkType,_that.prettyName,_that.chainId,_that.status,_that.bech32Prefix,_that.slip44,_that.symbol,_that.display,_that.denom,_that.decimals,_that.bestApis,_that.proxyStatus,_that.versions,_that.image,_that.website,_that.height,_that.explorers,_that.params,_that.assets,_that.keywords,_that.prices,_that.coingeckoId,_that.services);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  String chainName,  String networkType,  String prettyName,  String chainId,  String status, @JsonKey(name: 'bech32_prefix')  String bech32Prefix,  int slip44,  String symbol,  String display,  String denom,  int decimals,  CosmosBestApis bestApis,  CosmosProxyStatus proxyStatus,  CosmosVersions versions,  String? image,  String? website,  int? height,  List<CosmosExplorer>? explorers, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? params,  List<CosmosAsset>? assets,  List<String>? keywords, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? prices,  String? coingeckoId, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? services)?  $default,) {final _that = this;
switch (_that) {
case _CosmosChainInfo() when $default != null:
return $default(_that.name,_that.path,_that.chainName,_that.networkType,_that.prettyName,_that.chainId,_that.status,_that.bech32Prefix,_that.slip44,_that.symbol,_that.display,_that.denom,_that.decimals,_that.bestApis,_that.proxyStatus,_that.versions,_that.image,_that.website,_that.height,_that.explorers,_that.params,_that.assets,_that.keywords,_that.prices,_that.coingeckoId,_that.services);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _CosmosChainInfo extends CosmosChainInfo {
  const _CosmosChainInfo({required this.name, required this.path, required this.chainName, required this.networkType, required this.prettyName, required this.chainId, required this.status, @JsonKey(name: 'bech32_prefix') required this.bech32Prefix, required this.slip44, required this.symbol, required this.display, required this.denom, required this.decimals, required this.bestApis, required this.proxyStatus, required this.versions, this.image, this.website, this.height, final  List<CosmosExplorer>? explorers, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? params, final  List<CosmosAsset>? assets, final  List<String>? keywords, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? prices, this.coingeckoId, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? services}): _explorers = explorers,_params = params,_assets = assets,_keywords = keywords,_prices = prices,_services = services,super._();
  factory _CosmosChainInfo.fromJson(Map<String, dynamic> json) => _$CosmosChainInfoFromJson(json);

@override final  String name;
@override final  String path;
@override final  String chainName;
@override final  String networkType;
@override final  String prettyName;
@override final  String chainId;
@override final  String status;
@override@JsonKey(name: 'bech32_prefix') final  String bech32Prefix;
@override final  int slip44;
@override final  String symbol;
@override final  String display;
@override final  String denom;
@override final  int decimals;
@override final  CosmosBestApis bestApis;
@override final  CosmosProxyStatus proxyStatus;
@override final  CosmosVersions versions;
@override final  String? image;
@override final  String? website;
@override final  int? height;
 final  List<CosmosExplorer>? _explorers;
@override List<CosmosExplorer>? get explorers {
  final value = _explorers;
  if (value == null) return null;
  if (_explorers is EqualUnmodifiableListView) return _explorers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _params;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get params {
  final value = _params;
  if (value == null) return null;
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<CosmosAsset>? _assets;
@override List<CosmosAsset>? get assets {
  final value = _assets;
  if (value == null) return null;
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _keywords;
@override List<String>? get keywords {
  final value = _keywords;
  if (value == null) return null;
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _prices;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get prices {
  final value = _prices;
  if (value == null) return null;
  if (_prices is EqualUnmodifiableMapView) return _prices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? coingeckoId;
 final  Map<String, dynamic>? _services;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get services {
  final value = _services;
  if (value == null) return null;
  if (_services is EqualUnmodifiableMapView) return _services;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosChainInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.chainName, chainName) || other.chainName == chainName)&&(identical(other.networkType, networkType) || other.networkType == networkType)&&(identical(other.prettyName, prettyName) || other.prettyName == prettyName)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.status, status) || other.status == status)&&(identical(other.bech32Prefix, bech32Prefix) || other.bech32Prefix == bech32Prefix)&&(identical(other.slip44, slip44) || other.slip44 == slip44)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.display, display) || other.display == display)&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.bestApis, bestApis) || other.bestApis == bestApis)&&(identical(other.proxyStatus, proxyStatus) || other.proxyStatus == proxyStatus)&&(identical(other.versions, versions) || other.versions == versions)&&(identical(other.image, image) || other.image == image)&&(identical(other.website, website) || other.website == website)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other._explorers, _explorers)&&const DeepCollectionEquality().equals(other._params, _params)&&const DeepCollectionEquality().equals(other._assets, _assets)&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&const DeepCollectionEquality().equals(other._prices, _prices)&&(identical(other.coingeckoId, coingeckoId) || other.coingeckoId == coingeckoId)&&const DeepCollectionEquality().equals(other._services, _services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,path,chainName,networkType,prettyName,chainId,status,bech32Prefix,slip44,symbol,display,denom,decimals,bestApis,proxyStatus,versions,image,website,height,const DeepCollectionEquality().hash(_explorers),const DeepCollectionEquality().hash(_params),const DeepCollectionEquality().hash(_assets),const DeepCollectionEquality().hash(_keywords),const DeepCollectionEquality().hash(_prices),coingeckoId,const DeepCollectionEquality().hash(_services)]);

@override
String toString() {
  return 'CosmosChainInfo(name: $name, path: $path, chainName: $chainName, networkType: $networkType, prettyName: $prettyName, chainId: $chainId, status: $status, bech32Prefix: $bech32Prefix, slip44: $slip44, symbol: $symbol, display: $display, denom: $denom, decimals: $decimals, bestApis: $bestApis, proxyStatus: $proxyStatus, versions: $versions, image: $image, website: $website, height: $height, explorers: $explorers, params: $params, assets: $assets, keywords: $keywords, prices: $prices, coingeckoId: $coingeckoId, services: $services)';
}


}

/// @nodoc
abstract mixin class _$CosmosChainInfoCopyWith<$Res> implements $CosmosChainInfoCopyWith<$Res> {
  factory _$CosmosChainInfoCopyWith(_CosmosChainInfo value, $Res Function(_CosmosChainInfo) _then) = __$CosmosChainInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, String chainName, String networkType, String prettyName, String chainId, String status,@JsonKey(name: 'bech32_prefix') String bech32Prefix, int slip44, String symbol, String display, String denom, int decimals, CosmosBestApis bestApis, CosmosProxyStatus proxyStatus, CosmosVersions versions, String? image, String? website, int? height, List<CosmosExplorer>? explorers,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? params, List<CosmosAsset>? assets, List<String>? keywords,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? prices, String? coingeckoId,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? services
});


@override $CosmosBestApisCopyWith<$Res> get bestApis;@override $CosmosProxyStatusCopyWith<$Res> get proxyStatus;@override $CosmosVersionsCopyWith<$Res> get versions;

}
/// @nodoc
class __$CosmosChainInfoCopyWithImpl<$Res>
    implements _$CosmosChainInfoCopyWith<$Res> {
  __$CosmosChainInfoCopyWithImpl(this._self, this._then);

  final _CosmosChainInfo _self;
  final $Res Function(_CosmosChainInfo) _then;

/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? chainName = null,Object? networkType = null,Object? prettyName = null,Object? chainId = null,Object? status = null,Object? bech32Prefix = null,Object? slip44 = null,Object? symbol = null,Object? display = null,Object? denom = null,Object? decimals = null,Object? bestApis = null,Object? proxyStatus = null,Object? versions = null,Object? image = freezed,Object? website = freezed,Object? height = freezed,Object? explorers = freezed,Object? params = freezed,Object? assets = freezed,Object? keywords = freezed,Object? prices = freezed,Object? coingeckoId = freezed,Object? services = freezed,}) {
  return _then(_CosmosChainInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,chainName: null == chainName ? _self.chainName : chainName // ignore: cast_nullable_to_non_nullable
as String,networkType: null == networkType ? _self.networkType : networkType // ignore: cast_nullable_to_non_nullable
as String,prettyName: null == prettyName ? _self.prettyName : prettyName // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,bech32Prefix: null == bech32Prefix ? _self.bech32Prefix : bech32Prefix // ignore: cast_nullable_to_non_nullable
as String,slip44: null == slip44 ? _self.slip44 : slip44 // ignore: cast_nullable_to_non_nullable
as int,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,denom: null == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,bestApis: null == bestApis ? _self.bestApis : bestApis // ignore: cast_nullable_to_non_nullable
as CosmosBestApis,proxyStatus: null == proxyStatus ? _self.proxyStatus : proxyStatus // ignore: cast_nullable_to_non_nullable
as CosmosProxyStatus,versions: null == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as CosmosVersions,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,explorers: freezed == explorers ? _self._explorers : explorers // ignore: cast_nullable_to_non_nullable
as List<CosmosExplorer>?,params: freezed == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,assets: freezed == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<CosmosAsset>?,keywords: freezed == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>?,prices: freezed == prices ? _self._prices : prices // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,coingeckoId: freezed == coingeckoId ? _self.coingeckoId : coingeckoId // ignore: cast_nullable_to_non_nullable
as String?,services: freezed == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosBestApisCopyWith<$Res> get bestApis {
  
  return $CosmosBestApisCopyWith<$Res>(_self.bestApis, (value) {
    return _then(_self.copyWith(bestApis: value));
  });
}/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosProxyStatusCopyWith<$Res> get proxyStatus {
  
  return $CosmosProxyStatusCopyWith<$Res>(_self.proxyStatus, (value) {
    return _then(_self.copyWith(proxyStatus: value));
  });
}/// Create a copy of CosmosChainInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CosmosVersionsCopyWith<$Res> get versions {
  
  return $CosmosVersionsCopyWith<$Res>(_self.versions, (value) {
    return _then(_self.copyWith(versions: value));
  });
}
}

// dart format on
