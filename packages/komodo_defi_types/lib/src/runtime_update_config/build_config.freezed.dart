// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuildConfig {

 ApiBuildUpdateConfig get api; AssetRuntimeUpdateConfig get coins;
/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildConfigCopyWith<BuildConfig> get copyWith => _$BuildConfigCopyWithImpl<BuildConfig>(this as BuildConfig, _$identity);

  /// Serializes this BuildConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildConfig&&(identical(other.api, api) || other.api == api)&&(identical(other.coins, coins) || other.coins == coins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,api,coins);

@override
String toString() {
  return 'BuildConfig(api: $api, coins: $coins)';
}


}

/// @nodoc
abstract mixin class $BuildConfigCopyWith<$Res>  {
  factory $BuildConfigCopyWith(BuildConfig value, $Res Function(BuildConfig) _then) = _$BuildConfigCopyWithImpl;
@useResult
$Res call({
 ApiBuildUpdateConfig api, AssetRuntimeUpdateConfig coins
});


$ApiBuildUpdateConfigCopyWith<$Res> get api;$AssetRuntimeUpdateConfigCopyWith<$Res> get coins;

}
/// @nodoc
class _$BuildConfigCopyWithImpl<$Res>
    implements $BuildConfigCopyWith<$Res> {
  _$BuildConfigCopyWithImpl(this._self, this._then);

  final BuildConfig _self;
  final $Res Function(BuildConfig) _then;

/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? api = null,Object? coins = null,}) {
  return _then(_self.copyWith(
api: null == api ? _self.api : api // ignore: cast_nullable_to_non_nullable
as ApiBuildUpdateConfig,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as AssetRuntimeUpdateConfig,
  ));
}
/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiBuildUpdateConfigCopyWith<$Res> get api {
  
  return $ApiBuildUpdateConfigCopyWith<$Res>(_self.api, (value) {
    return _then(_self.copyWith(api: value));
  });
}/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssetRuntimeUpdateConfigCopyWith<$Res> get coins {
  
  return $AssetRuntimeUpdateConfigCopyWith<$Res>(_self.coins, (value) {
    return _then(_self.copyWith(coins: value));
  });
}
}


/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _BuildConfig implements BuildConfig {
  const _BuildConfig({required this.api, required this.coins});
  factory _BuildConfig.fromJson(Map<String, dynamic> json) => _$BuildConfigFromJson(json);

@override final  ApiBuildUpdateConfig api;
@override final  AssetRuntimeUpdateConfig coins;

/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildConfigCopyWith<_BuildConfig> get copyWith => __$BuildConfigCopyWithImpl<_BuildConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuildConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildConfig&&(identical(other.api, api) || other.api == api)&&(identical(other.coins, coins) || other.coins == coins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,api,coins);

@override
String toString() {
  return 'BuildConfig(api: $api, coins: $coins)';
}


}

/// @nodoc
abstract mixin class _$BuildConfigCopyWith<$Res> implements $BuildConfigCopyWith<$Res> {
  factory _$BuildConfigCopyWith(_BuildConfig value, $Res Function(_BuildConfig) _then) = __$BuildConfigCopyWithImpl;
@override @useResult
$Res call({
 ApiBuildUpdateConfig api, AssetRuntimeUpdateConfig coins
});


@override $ApiBuildUpdateConfigCopyWith<$Res> get api;@override $AssetRuntimeUpdateConfigCopyWith<$Res> get coins;

}
/// @nodoc
class __$BuildConfigCopyWithImpl<$Res>
    implements _$BuildConfigCopyWith<$Res> {
  __$BuildConfigCopyWithImpl(this._self, this._then);

  final _BuildConfig _self;
  final $Res Function(_BuildConfig) _then;

/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? api = null,Object? coins = null,}) {
  return _then(_BuildConfig(
api: null == api ? _self.api : api // ignore: cast_nullable_to_non_nullable
as ApiBuildUpdateConfig,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as AssetRuntimeUpdateConfig,
  ));
}

/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiBuildUpdateConfigCopyWith<$Res> get api {
  
  return $ApiBuildUpdateConfigCopyWith<$Res>(_self.api, (value) {
    return _then(_self.copyWith(api: value));
  });
}/// Create a copy of BuildConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssetRuntimeUpdateConfigCopyWith<$Res> get coins {
  
  return $AssetRuntimeUpdateConfigCopyWith<$Res>(_self.coins, (value) {
    return _then(_self.copyWith(coins: value));
  });
}
}

// dart format on
