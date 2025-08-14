// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coin_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoinInfo {

 Coin get coin; CoinConfig? get coinConfig;
/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoinInfoCopyWith<CoinInfo> get copyWith => _$CoinInfoCopyWithImpl<CoinInfo>(this as CoinInfo, _$identity);

  /// Serializes this CoinInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoinInfo&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.coinConfig, coinConfig) || other.coinConfig == coinConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,coinConfig);

@override
String toString() {
  return 'CoinInfo(coin: $coin, coinConfig: $coinConfig)';
}


}

/// @nodoc
abstract mixin class $CoinInfoCopyWith<$Res>  {
  factory $CoinInfoCopyWith(CoinInfo value, $Res Function(CoinInfo) _then) = _$CoinInfoCopyWithImpl;
@useResult
$Res call({
 Coin coin, CoinConfig? coinConfig
});


$CoinCopyWith<$Res> get coin;$CoinConfigCopyWith<$Res>? get coinConfig;

}
/// @nodoc
class _$CoinInfoCopyWithImpl<$Res>
    implements $CoinInfoCopyWith<$Res> {
  _$CoinInfoCopyWithImpl(this._self, this._then);

  final CoinInfo _self;
  final $Res Function(CoinInfo) _then;

/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? coinConfig = freezed,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as Coin,coinConfig: freezed == coinConfig ? _self.coinConfig : coinConfig // ignore: cast_nullable_to_non_nullable
as CoinConfig?,
  ));
}
/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoinCopyWith<$Res> get coin {
  
  return $CoinCopyWith<$Res>(_self.coin, (value) {
    return _then(_self.copyWith(coin: value));
  });
}/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoinConfigCopyWith<$Res>? get coinConfig {
    if (_self.coinConfig == null) {
    return null;
  }

  return $CoinConfigCopyWith<$Res>(_self.coinConfig!, (value) {
    return _then(_self.copyWith(coinConfig: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _CoinInfo extends CoinInfo {
  const _CoinInfo({required this.coin, this.coinConfig}): super._();
  factory _CoinInfo.fromJson(Map<String, dynamic> json) => _$CoinInfoFromJson(json);

@override final  Coin coin;
@override final  CoinConfig? coinConfig;

/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoinInfoCopyWith<_CoinInfo> get copyWith => __$CoinInfoCopyWithImpl<_CoinInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoinInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoinInfo&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.coinConfig, coinConfig) || other.coinConfig == coinConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,coinConfig);

@override
String toString() {
  return 'CoinInfo(coin: $coin, coinConfig: $coinConfig)';
}


}

/// @nodoc
abstract mixin class _$CoinInfoCopyWith<$Res> implements $CoinInfoCopyWith<$Res> {
  factory _$CoinInfoCopyWith(_CoinInfo value, $Res Function(_CoinInfo) _then) = __$CoinInfoCopyWithImpl;
@override @useResult
$Res call({
 Coin coin, CoinConfig? coinConfig
});


@override $CoinCopyWith<$Res> get coin;@override $CoinConfigCopyWith<$Res>? get coinConfig;

}
/// @nodoc
class __$CoinInfoCopyWithImpl<$Res>
    implements _$CoinInfoCopyWith<$Res> {
  __$CoinInfoCopyWithImpl(this._self, this._then);

  final _CoinInfo _self;
  final $Res Function(_CoinInfo) _then;

/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? coinConfig = freezed,}) {
  return _then(_CoinInfo(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as Coin,coinConfig: freezed == coinConfig ? _self.coinConfig : coinConfig // ignore: cast_nullable_to_non_nullable
as CoinConfig?,
  ));
}

/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoinCopyWith<$Res> get coin {
  
  return $CoinCopyWith<$Res>(_self.coin, (value) {
    return _then(_self.copyWith(coin: value));
  });
}/// Create a copy of CoinInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoinConfigCopyWith<$Res>? get coinConfig {
    if (_self.coinConfig == null) {
    return null;
  }

  return $CoinConfigCopyWith<$Res>(_self.coinConfig!, (value) {
    return _then(_self.copyWith(coinConfig: value));
  });
}
}

// dart format on
