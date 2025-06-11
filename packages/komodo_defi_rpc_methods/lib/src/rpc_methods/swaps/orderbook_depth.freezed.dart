// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orderbook_depth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderbookDepthResponse {

 String? get mmrpc; String? get id; List<PairDepth> get result;
/// Create a copy of OrderbookDepthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderbookDepthResponseCopyWith<OrderbookDepthResponse> get copyWith => _$OrderbookDepthResponseCopyWithImpl<OrderbookDepthResponse>(this as OrderbookDepthResponse, _$identity);

  /// Serializes this OrderbookDepthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderbookDepthResponse&&(identical(other.mmrpc, mmrpc) || other.mmrpc == mmrpc)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.result, result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mmrpc,id,const DeepCollectionEquality().hash(result));

@override
String toString() {
  return 'OrderbookDepthResponse(mmrpc: $mmrpc, id: $id, result: $result)';
}


}

/// @nodoc
abstract mixin class $OrderbookDepthResponseCopyWith<$Res>  {
  factory $OrderbookDepthResponseCopyWith(OrderbookDepthResponse value, $Res Function(OrderbookDepthResponse) _then) = _$OrderbookDepthResponseCopyWithImpl;
@useResult
$Res call({
 String? mmrpc, String? id, List<PairDepth> result
});




}
/// @nodoc
class _$OrderbookDepthResponseCopyWithImpl<$Res>
    implements $OrderbookDepthResponseCopyWith<$Res> {
  _$OrderbookDepthResponseCopyWithImpl(this._self, this._then);

  final OrderbookDepthResponse _self;
  final $Res Function(OrderbookDepthResponse) _then;

/// Create a copy of OrderbookDepthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mmrpc = freezed,Object? id = freezed,Object? result = null,}) {
  return _then(_self.copyWith(
mmrpc: freezed == mmrpc ? _self.mmrpc : mmrpc // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as List<PairDepth>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _OrderbookDepthResponse implements OrderbookDepthResponse {
  const _OrderbookDepthResponse({this.mmrpc, this.id, required final  List<PairDepth> result}): _result = result;
  factory _OrderbookDepthResponse.fromJson(Map<String, dynamic> json) => _$OrderbookDepthResponseFromJson(json);

@override final  String? mmrpc;
@override final  String? id;
 final  List<PairDepth> _result;
@override List<PairDepth> get result {
  if (_result is EqualUnmodifiableListView) return _result;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_result);
}


/// Create a copy of OrderbookDepthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderbookDepthResponseCopyWith<_OrderbookDepthResponse> get copyWith => __$OrderbookDepthResponseCopyWithImpl<_OrderbookDepthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderbookDepthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderbookDepthResponse&&(identical(other.mmrpc, mmrpc) || other.mmrpc == mmrpc)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._result, _result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mmrpc,id,const DeepCollectionEquality().hash(_result));

@override
String toString() {
  return 'OrderbookDepthResponse(mmrpc: $mmrpc, id: $id, result: $result)';
}


}

/// @nodoc
abstract mixin class _$OrderbookDepthResponseCopyWith<$Res> implements $OrderbookDepthResponseCopyWith<$Res> {
  factory _$OrderbookDepthResponseCopyWith(_OrderbookDepthResponse value, $Res Function(_OrderbookDepthResponse) _then) = __$OrderbookDepthResponseCopyWithImpl;
@override @useResult
$Res call({
 String? mmrpc, String? id, List<PairDepth> result
});




}
/// @nodoc
class __$OrderbookDepthResponseCopyWithImpl<$Res>
    implements _$OrderbookDepthResponseCopyWith<$Res> {
  __$OrderbookDepthResponseCopyWithImpl(this._self, this._then);

  final _OrderbookDepthResponse _self;
  final $Res Function(_OrderbookDepthResponse) _then;

/// Create a copy of OrderbookDepthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mmrpc = freezed,Object? id = freezed,Object? result = null,}) {
  return _then(_OrderbookDepthResponse(
mmrpc: freezed == mmrpc ? _self.mmrpc : mmrpc // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,result: null == result ? _self._result : result // ignore: cast_nullable_to_non_nullable
as List<PairDepth>,
  ));
}


}


/// @nodoc
mixin _$PairDepth {

 List<String> get pair; DepthInfo get depth;
/// Create a copy of PairDepth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairDepthCopyWith<PairDepth> get copyWith => _$PairDepthCopyWithImpl<PairDepth>(this as PairDepth, _$identity);

  /// Serializes this PairDepth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairDepth&&const DeepCollectionEquality().equals(other.pair, pair)&&(identical(other.depth, depth) || other.depth == depth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pair),depth);

@override
String toString() {
  return 'PairDepth(pair: $pair, depth: $depth)';
}


}

/// @nodoc
abstract mixin class $PairDepthCopyWith<$Res>  {
  factory $PairDepthCopyWith(PairDepth value, $Res Function(PairDepth) _then) = _$PairDepthCopyWithImpl;
@useResult
$Res call({
 List<String> pair, DepthInfo depth
});


$DepthInfoCopyWith<$Res> get depth;

}
/// @nodoc
class _$PairDepthCopyWithImpl<$Res>
    implements $PairDepthCopyWith<$Res> {
  _$PairDepthCopyWithImpl(this._self, this._then);

  final PairDepth _self;
  final $Res Function(PairDepth) _then;

/// Create a copy of PairDepth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pair = null,Object? depth = null,}) {
  return _then(_self.copyWith(
pair: null == pair ? _self.pair : pair // ignore: cast_nullable_to_non_nullable
as List<String>,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as DepthInfo,
  ));
}
/// Create a copy of PairDepth
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DepthInfoCopyWith<$Res> get depth {
  
  return $DepthInfoCopyWith<$Res>(_self.depth, (value) {
    return _then(_self.copyWith(depth: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _PairDepth extends PairDepth {
  const _PairDepth({required final  List<String> pair, required this.depth}): _pair = pair,super._();
  factory _PairDepth.fromJson(Map<String, dynamic> json) => _$PairDepthFromJson(json);

 final  List<String> _pair;
@override List<String> get pair {
  if (_pair is EqualUnmodifiableListView) return _pair;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pair);
}

@override final  DepthInfo depth;

/// Create a copy of PairDepth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairDepthCopyWith<_PairDepth> get copyWith => __$PairDepthCopyWithImpl<_PairDepth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairDepthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairDepth&&const DeepCollectionEquality().equals(other._pair, _pair)&&(identical(other.depth, depth) || other.depth == depth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pair),depth);

@override
String toString() {
  return 'PairDepth(pair: $pair, depth: $depth)';
}


}

/// @nodoc
abstract mixin class _$PairDepthCopyWith<$Res> implements $PairDepthCopyWith<$Res> {
  factory _$PairDepthCopyWith(_PairDepth value, $Res Function(_PairDepth) _then) = __$PairDepthCopyWithImpl;
@override @useResult
$Res call({
 List<String> pair, DepthInfo depth
});


@override $DepthInfoCopyWith<$Res> get depth;

}
/// @nodoc
class __$PairDepthCopyWithImpl<$Res>
    implements _$PairDepthCopyWith<$Res> {
  __$PairDepthCopyWithImpl(this._self, this._then);

  final _PairDepth _self;
  final $Res Function(_PairDepth) _then;

/// Create a copy of PairDepth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pair = null,Object? depth = null,}) {
  return _then(_PairDepth(
pair: null == pair ? _self._pair : pair // ignore: cast_nullable_to_non_nullable
as List<String>,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as DepthInfo,
  ));
}

/// Create a copy of PairDepth
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DepthInfoCopyWith<$Res> get depth {
  
  return $DepthInfoCopyWith<$Res>(_self.depth, (value) {
    return _then(_self.copyWith(depth: value));
  });
}
}


/// @nodoc
mixin _$DepthInfo {

 int get asks; int get bids;
/// Create a copy of DepthInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepthInfoCopyWith<DepthInfo> get copyWith => _$DepthInfoCopyWithImpl<DepthInfo>(this as DepthInfo, _$identity);

  /// Serializes this DepthInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepthInfo&&(identical(other.asks, asks) || other.asks == asks)&&(identical(other.bids, bids) || other.bids == bids));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,asks,bids);

@override
String toString() {
  return 'DepthInfo(asks: $asks, bids: $bids)';
}


}

/// @nodoc
abstract mixin class $DepthInfoCopyWith<$Res>  {
  factory $DepthInfoCopyWith(DepthInfo value, $Res Function(DepthInfo) _then) = _$DepthInfoCopyWithImpl;
@useResult
$Res call({
 int asks, int bids
});




}
/// @nodoc
class _$DepthInfoCopyWithImpl<$Res>
    implements $DepthInfoCopyWith<$Res> {
  _$DepthInfoCopyWithImpl(this._self, this._then);

  final DepthInfo _self;
  final $Res Function(DepthInfo) _then;

/// Create a copy of DepthInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asks = null,Object? bids = null,}) {
  return _then(_self.copyWith(
asks: null == asks ? _self.asks : asks // ignore: cast_nullable_to_non_nullable
as int,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _DepthInfo extends DepthInfo {
  const _DepthInfo({required this.asks, required this.bids}): super._();
  factory _DepthInfo.fromJson(Map<String, dynamic> json) => _$DepthInfoFromJson(json);

@override final  int asks;
@override final  int bids;

/// Create a copy of DepthInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepthInfoCopyWith<_DepthInfo> get copyWith => __$DepthInfoCopyWithImpl<_DepthInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepthInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepthInfo&&(identical(other.asks, asks) || other.asks == asks)&&(identical(other.bids, bids) || other.bids == bids));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,asks,bids);

@override
String toString() {
  return 'DepthInfo(asks: $asks, bids: $bids)';
}


}

/// @nodoc
abstract mixin class _$DepthInfoCopyWith<$Res> implements $DepthInfoCopyWith<$Res> {
  factory _$DepthInfoCopyWith(_DepthInfo value, $Res Function(_DepthInfo) _then) = __$DepthInfoCopyWithImpl;
@override @useResult
$Res call({
 int asks, int bids
});




}
/// @nodoc
class __$DepthInfoCopyWithImpl<$Res>
    implements _$DepthInfoCopyWith<$Res> {
  __$DepthInfoCopyWithImpl(this._self, this._then);

  final _DepthInfo _self;
  final $Res Function(_DepthInfo) _then;

/// Create a copy of DepthInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asks = null,Object? bids = null,}) {
  return _then(_DepthInfo(
asks: null == asks ? _self.asks : asks // ignore: cast_nullable_to_non_nullable
as int,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
