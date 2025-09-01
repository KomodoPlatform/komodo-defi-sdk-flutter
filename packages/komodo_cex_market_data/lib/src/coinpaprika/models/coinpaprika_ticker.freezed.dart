// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coinpaprika_ticker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoinPaprikaTicker {

/// Unique identifier for the coin (e.g., "btc-bitcoin")
 String get id;/// Full name of the coin (e.g., "Bitcoin")
 String get name;/// Symbol/ticker of the coin (e.g., "BTC")
 String get symbol;/// Market ranking of the coin
 int get rank;/// Circulating supply of the coin
 int get circulatingSupply;/// Total supply of the coin
 int get totalSupply;/// Maximum supply of the coin (nullable)
 int? get maxSupply;/// Beta value (volatility measure)
 double get betaValue;/// Date of first data point
 DateTime? get firstDataAt;/// Last updated timestamp
 DateTime? get lastUpdated;/// Map of quotes for different currencies (BTC, USD, etc.)
 Map<String, CoinPaprikaTickerQuote> get quotes;
/// Create a copy of CoinPaprikaTicker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoinPaprikaTickerCopyWith<CoinPaprikaTicker> get copyWith => _$CoinPaprikaTickerCopyWithImpl<CoinPaprikaTicker>(this as CoinPaprikaTicker, _$identity);

  /// Serializes this CoinPaprikaTicker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoinPaprikaTicker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.circulatingSupply, circulatingSupply) || other.circulatingSupply == circulatingSupply)&&(identical(other.totalSupply, totalSupply) || other.totalSupply == totalSupply)&&(identical(other.maxSupply, maxSupply) || other.maxSupply == maxSupply)&&(identical(other.betaValue, betaValue) || other.betaValue == betaValue)&&(identical(other.firstDataAt, firstDataAt) || other.firstDataAt == firstDataAt)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other.quotes, quotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,symbol,rank,circulatingSupply,totalSupply,maxSupply,betaValue,firstDataAt,lastUpdated,const DeepCollectionEquality().hash(quotes));

@override
String toString() {
  return 'CoinPaprikaTicker(id: $id, name: $name, symbol: $symbol, rank: $rank, circulatingSupply: $circulatingSupply, totalSupply: $totalSupply, maxSupply: $maxSupply, betaValue: $betaValue, firstDataAt: $firstDataAt, lastUpdated: $lastUpdated, quotes: $quotes)';
}


}

/// @nodoc
abstract mixin class $CoinPaprikaTickerCopyWith<$Res>  {
  factory $CoinPaprikaTickerCopyWith(CoinPaprikaTicker value, $Res Function(CoinPaprikaTicker) _then) = _$CoinPaprikaTickerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String symbol, int rank, int circulatingSupply, int totalSupply, int? maxSupply, double betaValue, DateTime? firstDataAt, DateTime? lastUpdated, Map<String, CoinPaprikaTickerQuote> quotes
});




}
/// @nodoc
class _$CoinPaprikaTickerCopyWithImpl<$Res>
    implements $CoinPaprikaTickerCopyWith<$Res> {
  _$CoinPaprikaTickerCopyWithImpl(this._self, this._then);

  final CoinPaprikaTicker _self;
  final $Res Function(CoinPaprikaTicker) _then;

/// Create a copy of CoinPaprikaTicker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? symbol = null,Object? rank = null,Object? circulatingSupply = null,Object? totalSupply = null,Object? maxSupply = freezed,Object? betaValue = null,Object? firstDataAt = freezed,Object? lastUpdated = freezed,Object? quotes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,circulatingSupply: null == circulatingSupply ? _self.circulatingSupply : circulatingSupply // ignore: cast_nullable_to_non_nullable
as int,totalSupply: null == totalSupply ? _self.totalSupply : totalSupply // ignore: cast_nullable_to_non_nullable
as int,maxSupply: freezed == maxSupply ? _self.maxSupply : maxSupply // ignore: cast_nullable_to_non_nullable
as int?,betaValue: null == betaValue ? _self.betaValue : betaValue // ignore: cast_nullable_to_non_nullable
as double,firstDataAt: freezed == firstDataAt ? _self.firstDataAt : firstDataAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,quotes: null == quotes ? _self.quotes : quotes // ignore: cast_nullable_to_non_nullable
as Map<String, CoinPaprikaTickerQuote>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoinPaprikaTicker].
extension CoinPaprikaTickerPatterns on CoinPaprikaTicker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoinPaprikaTicker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoinPaprikaTicker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoinPaprikaTicker value)  $default,){
final _that = this;
switch (_that) {
case _CoinPaprikaTicker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoinPaprikaTicker value)?  $default,){
final _that = this;
switch (_that) {
case _CoinPaprikaTicker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String symbol,  int rank,  int circulatingSupply,  int totalSupply,  int? maxSupply,  double betaValue,  DateTime? firstDataAt,  DateTime? lastUpdated,  Map<String, CoinPaprikaTickerQuote> quotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoinPaprikaTicker() when $default != null:
return $default(_that.id,_that.name,_that.symbol,_that.rank,_that.circulatingSupply,_that.totalSupply,_that.maxSupply,_that.betaValue,_that.firstDataAt,_that.lastUpdated,_that.quotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String symbol,  int rank,  int circulatingSupply,  int totalSupply,  int? maxSupply,  double betaValue,  DateTime? firstDataAt,  DateTime? lastUpdated,  Map<String, CoinPaprikaTickerQuote> quotes)  $default,) {final _that = this;
switch (_that) {
case _CoinPaprikaTicker():
return $default(_that.id,_that.name,_that.symbol,_that.rank,_that.circulatingSupply,_that.totalSupply,_that.maxSupply,_that.betaValue,_that.firstDataAt,_that.lastUpdated,_that.quotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String symbol,  int rank,  int circulatingSupply,  int totalSupply,  int? maxSupply,  double betaValue,  DateTime? firstDataAt,  DateTime? lastUpdated,  Map<String, CoinPaprikaTickerQuote> quotes)?  $default,) {final _that = this;
switch (_that) {
case _CoinPaprikaTicker() when $default != null:
return $default(_that.id,_that.name,_that.symbol,_that.rank,_that.circulatingSupply,_that.totalSupply,_that.maxSupply,_that.betaValue,_that.firstDataAt,_that.lastUpdated,_that.quotes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CoinPaprikaTicker implements CoinPaprikaTicker {
  const _CoinPaprikaTicker({this.id = '', this.name = '', this.symbol = '', this.rank = 0, this.circulatingSupply = 0, this.totalSupply = 0, this.maxSupply, this.betaValue = 0.0, this.firstDataAt, this.lastUpdated, required final  Map<String, CoinPaprikaTickerQuote> quotes}): _quotes = quotes;
  factory _CoinPaprikaTicker.fromJson(Map<String, dynamic> json) => _$CoinPaprikaTickerFromJson(json);

/// Unique identifier for the coin (e.g., "btc-bitcoin")
@override@JsonKey() final  String id;
/// Full name of the coin (e.g., "Bitcoin")
@override@JsonKey() final  String name;
/// Symbol/ticker of the coin (e.g., "BTC")
@override@JsonKey() final  String symbol;
/// Market ranking of the coin
@override@JsonKey() final  int rank;
/// Circulating supply of the coin
@override@JsonKey() final  int circulatingSupply;
/// Total supply of the coin
@override@JsonKey() final  int totalSupply;
/// Maximum supply of the coin (nullable)
@override final  int? maxSupply;
/// Beta value (volatility measure)
@override@JsonKey() final  double betaValue;
/// Date of first data point
@override final  DateTime? firstDataAt;
/// Last updated timestamp
@override final  DateTime? lastUpdated;
/// Map of quotes for different currencies (BTC, USD, etc.)
 final  Map<String, CoinPaprikaTickerQuote> _quotes;
/// Map of quotes for different currencies (BTC, USD, etc.)
@override Map<String, CoinPaprikaTickerQuote> get quotes {
  if (_quotes is EqualUnmodifiableMapView) return _quotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_quotes);
}


/// Create a copy of CoinPaprikaTicker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoinPaprikaTickerCopyWith<_CoinPaprikaTicker> get copyWith => __$CoinPaprikaTickerCopyWithImpl<_CoinPaprikaTicker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoinPaprikaTickerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoinPaprikaTicker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.circulatingSupply, circulatingSupply) || other.circulatingSupply == circulatingSupply)&&(identical(other.totalSupply, totalSupply) || other.totalSupply == totalSupply)&&(identical(other.maxSupply, maxSupply) || other.maxSupply == maxSupply)&&(identical(other.betaValue, betaValue) || other.betaValue == betaValue)&&(identical(other.firstDataAt, firstDataAt) || other.firstDataAt == firstDataAt)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other._quotes, _quotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,symbol,rank,circulatingSupply,totalSupply,maxSupply,betaValue,firstDataAt,lastUpdated,const DeepCollectionEquality().hash(_quotes));

@override
String toString() {
  return 'CoinPaprikaTicker(id: $id, name: $name, symbol: $symbol, rank: $rank, circulatingSupply: $circulatingSupply, totalSupply: $totalSupply, maxSupply: $maxSupply, betaValue: $betaValue, firstDataAt: $firstDataAt, lastUpdated: $lastUpdated, quotes: $quotes)';
}


}

/// @nodoc
abstract mixin class _$CoinPaprikaTickerCopyWith<$Res> implements $CoinPaprikaTickerCopyWith<$Res> {
  factory _$CoinPaprikaTickerCopyWith(_CoinPaprikaTicker value, $Res Function(_CoinPaprikaTicker) _then) = __$CoinPaprikaTickerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String symbol, int rank, int circulatingSupply, int totalSupply, int? maxSupply, double betaValue, DateTime? firstDataAt, DateTime? lastUpdated, Map<String, CoinPaprikaTickerQuote> quotes
});




}
/// @nodoc
class __$CoinPaprikaTickerCopyWithImpl<$Res>
    implements _$CoinPaprikaTickerCopyWith<$Res> {
  __$CoinPaprikaTickerCopyWithImpl(this._self, this._then);

  final _CoinPaprikaTicker _self;
  final $Res Function(_CoinPaprikaTicker) _then;

/// Create a copy of CoinPaprikaTicker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? symbol = null,Object? rank = null,Object? circulatingSupply = null,Object? totalSupply = null,Object? maxSupply = freezed,Object? betaValue = null,Object? firstDataAt = freezed,Object? lastUpdated = freezed,Object? quotes = null,}) {
  return _then(_CoinPaprikaTicker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,circulatingSupply: null == circulatingSupply ? _self.circulatingSupply : circulatingSupply // ignore: cast_nullable_to_non_nullable
as int,totalSupply: null == totalSupply ? _self.totalSupply : totalSupply // ignore: cast_nullable_to_non_nullable
as int,maxSupply: freezed == maxSupply ? _self.maxSupply : maxSupply // ignore: cast_nullable_to_non_nullable
as int?,betaValue: null == betaValue ? _self.betaValue : betaValue // ignore: cast_nullable_to_non_nullable
as double,firstDataAt: freezed == firstDataAt ? _self.firstDataAt : firstDataAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,quotes: null == quotes ? _self._quotes : quotes // ignore: cast_nullable_to_non_nullable
as Map<String, CoinPaprikaTickerQuote>,
  ));
}


}

// dart format on
