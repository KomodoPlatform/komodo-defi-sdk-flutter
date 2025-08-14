// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'runtime_update_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RuntimeUpdateConfig {

 String get bundledCoinsRepoCommit; String get coinsRepoApiUrl; String get coinsRepoContentUrl; String get coinsRepoBranch; bool get runtimeUpdatesEnabled;
/// Create a copy of RuntimeUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuntimeUpdateConfigCopyWith<RuntimeUpdateConfig> get copyWith => _$RuntimeUpdateConfigCopyWithImpl<RuntimeUpdateConfig>(this as RuntimeUpdateConfig, _$identity);

  /// Serializes this RuntimeUpdateConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuntimeUpdateConfig&&(identical(other.bundledCoinsRepoCommit, bundledCoinsRepoCommit) || other.bundledCoinsRepoCommit == bundledCoinsRepoCommit)&&(identical(other.coinsRepoApiUrl, coinsRepoApiUrl) || other.coinsRepoApiUrl == coinsRepoApiUrl)&&(identical(other.coinsRepoContentUrl, coinsRepoContentUrl) || other.coinsRepoContentUrl == coinsRepoContentUrl)&&(identical(other.coinsRepoBranch, coinsRepoBranch) || other.coinsRepoBranch == coinsRepoBranch)&&(identical(other.runtimeUpdatesEnabled, runtimeUpdatesEnabled) || other.runtimeUpdatesEnabled == runtimeUpdatesEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bundledCoinsRepoCommit,coinsRepoApiUrl,coinsRepoContentUrl,coinsRepoBranch,runtimeUpdatesEnabled);

@override
String toString() {
  return 'RuntimeUpdateConfig(bundledCoinsRepoCommit: $bundledCoinsRepoCommit, coinsRepoApiUrl: $coinsRepoApiUrl, coinsRepoContentUrl: $coinsRepoContentUrl, coinsRepoBranch: $coinsRepoBranch, runtimeUpdatesEnabled: $runtimeUpdatesEnabled)';
}


}

/// @nodoc
abstract mixin class $RuntimeUpdateConfigCopyWith<$Res>  {
  factory $RuntimeUpdateConfigCopyWith(RuntimeUpdateConfig value, $Res Function(RuntimeUpdateConfig) _then) = _$RuntimeUpdateConfigCopyWithImpl;
@useResult
$Res call({
 String bundledCoinsRepoCommit, String coinsRepoApiUrl, String coinsRepoContentUrl, String coinsRepoBranch, bool runtimeUpdatesEnabled
});




}
/// @nodoc
class _$RuntimeUpdateConfigCopyWithImpl<$Res>
    implements $RuntimeUpdateConfigCopyWith<$Res> {
  _$RuntimeUpdateConfigCopyWithImpl(this._self, this._then);

  final RuntimeUpdateConfig _self;
  final $Res Function(RuntimeUpdateConfig) _then;

/// Create a copy of RuntimeUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bundledCoinsRepoCommit = null,Object? coinsRepoApiUrl = null,Object? coinsRepoContentUrl = null,Object? coinsRepoBranch = null,Object? runtimeUpdatesEnabled = null,}) {
  return _then(_self.copyWith(
bundledCoinsRepoCommit: null == bundledCoinsRepoCommit ? _self.bundledCoinsRepoCommit : bundledCoinsRepoCommit // ignore: cast_nullable_to_non_nullable
as String,coinsRepoApiUrl: null == coinsRepoApiUrl ? _self.coinsRepoApiUrl : coinsRepoApiUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoContentUrl: null == coinsRepoContentUrl ? _self.coinsRepoContentUrl : coinsRepoContentUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoBranch: null == coinsRepoBranch ? _self.coinsRepoBranch : coinsRepoBranch // ignore: cast_nullable_to_non_nullable
as String,runtimeUpdatesEnabled: null == runtimeUpdatesEnabled ? _self.runtimeUpdatesEnabled : runtimeUpdatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RuntimeUpdateConfig implements RuntimeUpdateConfig {
  const _RuntimeUpdateConfig({required this.bundledCoinsRepoCommit, required this.coinsRepoApiUrl, required this.coinsRepoContentUrl, required this.coinsRepoBranch, required this.runtimeUpdatesEnabled});
  factory _RuntimeUpdateConfig.fromJson(Map<String, dynamic> json) => _$RuntimeUpdateConfigFromJson(json);

@override final  String bundledCoinsRepoCommit;
@override final  String coinsRepoApiUrl;
@override final  String coinsRepoContentUrl;
@override final  String coinsRepoBranch;
@override final  bool runtimeUpdatesEnabled;

/// Create a copy of RuntimeUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuntimeUpdateConfigCopyWith<_RuntimeUpdateConfig> get copyWith => __$RuntimeUpdateConfigCopyWithImpl<_RuntimeUpdateConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuntimeUpdateConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuntimeUpdateConfig&&(identical(other.bundledCoinsRepoCommit, bundledCoinsRepoCommit) || other.bundledCoinsRepoCommit == bundledCoinsRepoCommit)&&(identical(other.coinsRepoApiUrl, coinsRepoApiUrl) || other.coinsRepoApiUrl == coinsRepoApiUrl)&&(identical(other.coinsRepoContentUrl, coinsRepoContentUrl) || other.coinsRepoContentUrl == coinsRepoContentUrl)&&(identical(other.coinsRepoBranch, coinsRepoBranch) || other.coinsRepoBranch == coinsRepoBranch)&&(identical(other.runtimeUpdatesEnabled, runtimeUpdatesEnabled) || other.runtimeUpdatesEnabled == runtimeUpdatesEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bundledCoinsRepoCommit,coinsRepoApiUrl,coinsRepoContentUrl,coinsRepoBranch,runtimeUpdatesEnabled);

@override
String toString() {
  return 'RuntimeUpdateConfig(bundledCoinsRepoCommit: $bundledCoinsRepoCommit, coinsRepoApiUrl: $coinsRepoApiUrl, coinsRepoContentUrl: $coinsRepoContentUrl, coinsRepoBranch: $coinsRepoBranch, runtimeUpdatesEnabled: $runtimeUpdatesEnabled)';
}


}

/// @nodoc
abstract mixin class _$RuntimeUpdateConfigCopyWith<$Res> implements $RuntimeUpdateConfigCopyWith<$Res> {
  factory _$RuntimeUpdateConfigCopyWith(_RuntimeUpdateConfig value, $Res Function(_RuntimeUpdateConfig) _then) = __$RuntimeUpdateConfigCopyWithImpl;
@override @useResult
$Res call({
 String bundledCoinsRepoCommit, String coinsRepoApiUrl, String coinsRepoContentUrl, String coinsRepoBranch, bool runtimeUpdatesEnabled
});




}
/// @nodoc
class __$RuntimeUpdateConfigCopyWithImpl<$Res>
    implements _$RuntimeUpdateConfigCopyWith<$Res> {
  __$RuntimeUpdateConfigCopyWithImpl(this._self, this._then);

  final _RuntimeUpdateConfig _self;
  final $Res Function(_RuntimeUpdateConfig) _then;

/// Create a copy of RuntimeUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bundledCoinsRepoCommit = null,Object? coinsRepoApiUrl = null,Object? coinsRepoContentUrl = null,Object? coinsRepoBranch = null,Object? runtimeUpdatesEnabled = null,}) {
  return _then(_RuntimeUpdateConfig(
bundledCoinsRepoCommit: null == bundledCoinsRepoCommit ? _self.bundledCoinsRepoCommit : bundledCoinsRepoCommit // ignore: cast_nullable_to_non_nullable
as String,coinsRepoApiUrl: null == coinsRepoApiUrl ? _self.coinsRepoApiUrl : coinsRepoApiUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoContentUrl: null == coinsRepoContentUrl ? _self.coinsRepoContentUrl : coinsRepoContentUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoBranch: null == coinsRepoBranch ? _self.coinsRepoBranch : coinsRepoBranch // ignore: cast_nullable_to_non_nullable
as String,runtimeUpdatesEnabled: null == runtimeUpdatesEnabled ? _self.runtimeUpdatesEnabled : runtimeUpdatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
