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

// Mirrors `coins` section in build_config.json
 bool get fetchAtBuildEnabled; bool get updateCommitOnBuild; String get bundledCoinsRepoCommit; String get coinsRepoApiUrl; String get coinsRepoContentUrl; String get coinsRepoBranch; bool get runtimeUpdatesEnabled; Map<String, String> get mappedFiles; Map<String, String> get mappedFolders; bool get concurrentDownloadsEnabled; Map<String, String> get cdnBranchMirrors;
/// Create a copy of RuntimeUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuntimeUpdateConfigCopyWith<RuntimeUpdateConfig> get copyWith => _$RuntimeUpdateConfigCopyWithImpl<RuntimeUpdateConfig>(this as RuntimeUpdateConfig, _$identity);

  /// Serializes this RuntimeUpdateConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuntimeUpdateConfig&&(identical(other.fetchAtBuildEnabled, fetchAtBuildEnabled) || other.fetchAtBuildEnabled == fetchAtBuildEnabled)&&(identical(other.updateCommitOnBuild, updateCommitOnBuild) || other.updateCommitOnBuild == updateCommitOnBuild)&&(identical(other.bundledCoinsRepoCommit, bundledCoinsRepoCommit) || other.bundledCoinsRepoCommit == bundledCoinsRepoCommit)&&(identical(other.coinsRepoApiUrl, coinsRepoApiUrl) || other.coinsRepoApiUrl == coinsRepoApiUrl)&&(identical(other.coinsRepoContentUrl, coinsRepoContentUrl) || other.coinsRepoContentUrl == coinsRepoContentUrl)&&(identical(other.coinsRepoBranch, coinsRepoBranch) || other.coinsRepoBranch == coinsRepoBranch)&&(identical(other.runtimeUpdatesEnabled, runtimeUpdatesEnabled) || other.runtimeUpdatesEnabled == runtimeUpdatesEnabled)&&const DeepCollectionEquality().equals(other.mappedFiles, mappedFiles)&&const DeepCollectionEquality().equals(other.mappedFolders, mappedFolders)&&(identical(other.concurrentDownloadsEnabled, concurrentDownloadsEnabled) || other.concurrentDownloadsEnabled == concurrentDownloadsEnabled)&&const DeepCollectionEquality().equals(other.cdnBranchMirrors, cdnBranchMirrors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fetchAtBuildEnabled,updateCommitOnBuild,bundledCoinsRepoCommit,coinsRepoApiUrl,coinsRepoContentUrl,coinsRepoBranch,runtimeUpdatesEnabled,const DeepCollectionEquality().hash(mappedFiles),const DeepCollectionEquality().hash(mappedFolders),concurrentDownloadsEnabled,const DeepCollectionEquality().hash(cdnBranchMirrors));

@override
String toString() {
  return 'RuntimeUpdateConfig(fetchAtBuildEnabled: $fetchAtBuildEnabled, updateCommitOnBuild: $updateCommitOnBuild, bundledCoinsRepoCommit: $bundledCoinsRepoCommit, coinsRepoApiUrl: $coinsRepoApiUrl, coinsRepoContentUrl: $coinsRepoContentUrl, coinsRepoBranch: $coinsRepoBranch, runtimeUpdatesEnabled: $runtimeUpdatesEnabled, mappedFiles: $mappedFiles, mappedFolders: $mappedFolders, concurrentDownloadsEnabled: $concurrentDownloadsEnabled, cdnBranchMirrors: $cdnBranchMirrors)';
}


}

/// @nodoc
abstract mixin class $RuntimeUpdateConfigCopyWith<$Res>  {
  factory $RuntimeUpdateConfigCopyWith(RuntimeUpdateConfig value, $Res Function(RuntimeUpdateConfig) _then) = _$RuntimeUpdateConfigCopyWithImpl;
@useResult
$Res call({
 bool fetchAtBuildEnabled, bool updateCommitOnBuild, String bundledCoinsRepoCommit, String coinsRepoApiUrl, String coinsRepoContentUrl, String coinsRepoBranch, bool runtimeUpdatesEnabled, Map<String, String> mappedFiles, Map<String, String> mappedFolders, bool concurrentDownloadsEnabled, Map<String, String> cdnBranchMirrors
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
@pragma('vm:prefer-inline') @override $Res call({Object? fetchAtBuildEnabled = null,Object? updateCommitOnBuild = null,Object? bundledCoinsRepoCommit = null,Object? coinsRepoApiUrl = null,Object? coinsRepoContentUrl = null,Object? coinsRepoBranch = null,Object? runtimeUpdatesEnabled = null,Object? mappedFiles = null,Object? mappedFolders = null,Object? concurrentDownloadsEnabled = null,Object? cdnBranchMirrors = null,}) {
  return _then(_self.copyWith(
fetchAtBuildEnabled: null == fetchAtBuildEnabled ? _self.fetchAtBuildEnabled : fetchAtBuildEnabled // ignore: cast_nullable_to_non_nullable
as bool,updateCommitOnBuild: null == updateCommitOnBuild ? _self.updateCommitOnBuild : updateCommitOnBuild // ignore: cast_nullable_to_non_nullable
as bool,bundledCoinsRepoCommit: null == bundledCoinsRepoCommit ? _self.bundledCoinsRepoCommit : bundledCoinsRepoCommit // ignore: cast_nullable_to_non_nullable
as String,coinsRepoApiUrl: null == coinsRepoApiUrl ? _self.coinsRepoApiUrl : coinsRepoApiUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoContentUrl: null == coinsRepoContentUrl ? _self.coinsRepoContentUrl : coinsRepoContentUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoBranch: null == coinsRepoBranch ? _self.coinsRepoBranch : coinsRepoBranch // ignore: cast_nullable_to_non_nullable
as String,runtimeUpdatesEnabled: null == runtimeUpdatesEnabled ? _self.runtimeUpdatesEnabled : runtimeUpdatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,mappedFiles: null == mappedFiles ? _self.mappedFiles : mappedFiles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,mappedFolders: null == mappedFolders ? _self.mappedFolders : mappedFolders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,concurrentDownloadsEnabled: null == concurrentDownloadsEnabled ? _self.concurrentDownloadsEnabled : concurrentDownloadsEnabled // ignore: cast_nullable_to_non_nullable
as bool,cdnBranchMirrors: null == cdnBranchMirrors ? _self.cdnBranchMirrors : cdnBranchMirrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _RuntimeUpdateConfig implements RuntimeUpdateConfig {
  const _RuntimeUpdateConfig({this.fetchAtBuildEnabled = true, this.updateCommitOnBuild = true, this.bundledCoinsRepoCommit = 'master', this.coinsRepoApiUrl = 'https://api.github.com/repos/KomodoPlatform/coins', this.coinsRepoContentUrl = 'https://raw.githubusercontent.com/KomodoPlatform/coins', this.coinsRepoBranch = 'master', this.runtimeUpdatesEnabled = true, final  Map<String, String> mappedFiles = const <String, String>{'assets/config/coins_config.json' : 'utils/coins_config_unfiltered.json', 'assets/config/coins.json' : 'coins', 'assets/config/seed_nodes.json' : 'seed-nodes.json'}, final  Map<String, String> mappedFolders = const <String, String>{'assets/coin_icons/png/' : 'icons'}, this.concurrentDownloadsEnabled = false, final  Map<String, String> cdnBranchMirrors = const <String, String>{'master' : 'https://komodoplatform.github.io/coins', 'main' : 'https://komodoplatform.github.io/coins'}}): _mappedFiles = mappedFiles,_mappedFolders = mappedFolders,_cdnBranchMirrors = cdnBranchMirrors;
  factory _RuntimeUpdateConfig.fromJson(Map<String, dynamic> json) => _$RuntimeUpdateConfigFromJson(json);

// Mirrors `coins` section in build_config.json
@override@JsonKey() final  bool fetchAtBuildEnabled;
@override@JsonKey() final  bool updateCommitOnBuild;
@override@JsonKey() final  String bundledCoinsRepoCommit;
@override@JsonKey() final  String coinsRepoApiUrl;
@override@JsonKey() final  String coinsRepoContentUrl;
@override@JsonKey() final  String coinsRepoBranch;
@override@JsonKey() final  bool runtimeUpdatesEnabled;
 final  Map<String, String> _mappedFiles;
@override@JsonKey() Map<String, String> get mappedFiles {
  if (_mappedFiles is EqualUnmodifiableMapView) return _mappedFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mappedFiles);
}

 final  Map<String, String> _mappedFolders;
@override@JsonKey() Map<String, String> get mappedFolders {
  if (_mappedFolders is EqualUnmodifiableMapView) return _mappedFolders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mappedFolders);
}

@override@JsonKey() final  bool concurrentDownloadsEnabled;
 final  Map<String, String> _cdnBranchMirrors;
@override@JsonKey() Map<String, String> get cdnBranchMirrors {
  if (_cdnBranchMirrors is EqualUnmodifiableMapView) return _cdnBranchMirrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cdnBranchMirrors);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuntimeUpdateConfig&&(identical(other.fetchAtBuildEnabled, fetchAtBuildEnabled) || other.fetchAtBuildEnabled == fetchAtBuildEnabled)&&(identical(other.updateCommitOnBuild, updateCommitOnBuild) || other.updateCommitOnBuild == updateCommitOnBuild)&&(identical(other.bundledCoinsRepoCommit, bundledCoinsRepoCommit) || other.bundledCoinsRepoCommit == bundledCoinsRepoCommit)&&(identical(other.coinsRepoApiUrl, coinsRepoApiUrl) || other.coinsRepoApiUrl == coinsRepoApiUrl)&&(identical(other.coinsRepoContentUrl, coinsRepoContentUrl) || other.coinsRepoContentUrl == coinsRepoContentUrl)&&(identical(other.coinsRepoBranch, coinsRepoBranch) || other.coinsRepoBranch == coinsRepoBranch)&&(identical(other.runtimeUpdatesEnabled, runtimeUpdatesEnabled) || other.runtimeUpdatesEnabled == runtimeUpdatesEnabled)&&const DeepCollectionEquality().equals(other._mappedFiles, _mappedFiles)&&const DeepCollectionEquality().equals(other._mappedFolders, _mappedFolders)&&(identical(other.concurrentDownloadsEnabled, concurrentDownloadsEnabled) || other.concurrentDownloadsEnabled == concurrentDownloadsEnabled)&&const DeepCollectionEquality().equals(other._cdnBranchMirrors, _cdnBranchMirrors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fetchAtBuildEnabled,updateCommitOnBuild,bundledCoinsRepoCommit,coinsRepoApiUrl,coinsRepoContentUrl,coinsRepoBranch,runtimeUpdatesEnabled,const DeepCollectionEquality().hash(_mappedFiles),const DeepCollectionEquality().hash(_mappedFolders),concurrentDownloadsEnabled,const DeepCollectionEquality().hash(_cdnBranchMirrors));

@override
String toString() {
  return 'RuntimeUpdateConfig(fetchAtBuildEnabled: $fetchAtBuildEnabled, updateCommitOnBuild: $updateCommitOnBuild, bundledCoinsRepoCommit: $bundledCoinsRepoCommit, coinsRepoApiUrl: $coinsRepoApiUrl, coinsRepoContentUrl: $coinsRepoContentUrl, coinsRepoBranch: $coinsRepoBranch, runtimeUpdatesEnabled: $runtimeUpdatesEnabled, mappedFiles: $mappedFiles, mappedFolders: $mappedFolders, concurrentDownloadsEnabled: $concurrentDownloadsEnabled, cdnBranchMirrors: $cdnBranchMirrors)';
}


}

/// @nodoc
abstract mixin class _$RuntimeUpdateConfigCopyWith<$Res> implements $RuntimeUpdateConfigCopyWith<$Res> {
  factory _$RuntimeUpdateConfigCopyWith(_RuntimeUpdateConfig value, $Res Function(_RuntimeUpdateConfig) _then) = __$RuntimeUpdateConfigCopyWithImpl;
@override @useResult
$Res call({
 bool fetchAtBuildEnabled, bool updateCommitOnBuild, String bundledCoinsRepoCommit, String coinsRepoApiUrl, String coinsRepoContentUrl, String coinsRepoBranch, bool runtimeUpdatesEnabled, Map<String, String> mappedFiles, Map<String, String> mappedFolders, bool concurrentDownloadsEnabled, Map<String, String> cdnBranchMirrors
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
@override @pragma('vm:prefer-inline') $Res call({Object? fetchAtBuildEnabled = null,Object? updateCommitOnBuild = null,Object? bundledCoinsRepoCommit = null,Object? coinsRepoApiUrl = null,Object? coinsRepoContentUrl = null,Object? coinsRepoBranch = null,Object? runtimeUpdatesEnabled = null,Object? mappedFiles = null,Object? mappedFolders = null,Object? concurrentDownloadsEnabled = null,Object? cdnBranchMirrors = null,}) {
  return _then(_RuntimeUpdateConfig(
fetchAtBuildEnabled: null == fetchAtBuildEnabled ? _self.fetchAtBuildEnabled : fetchAtBuildEnabled // ignore: cast_nullable_to_non_nullable
as bool,updateCommitOnBuild: null == updateCommitOnBuild ? _self.updateCommitOnBuild : updateCommitOnBuild // ignore: cast_nullable_to_non_nullable
as bool,bundledCoinsRepoCommit: null == bundledCoinsRepoCommit ? _self.bundledCoinsRepoCommit : bundledCoinsRepoCommit // ignore: cast_nullable_to_non_nullable
as String,coinsRepoApiUrl: null == coinsRepoApiUrl ? _self.coinsRepoApiUrl : coinsRepoApiUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoContentUrl: null == coinsRepoContentUrl ? _self.coinsRepoContentUrl : coinsRepoContentUrl // ignore: cast_nullable_to_non_nullable
as String,coinsRepoBranch: null == coinsRepoBranch ? _self.coinsRepoBranch : coinsRepoBranch // ignore: cast_nullable_to_non_nullable
as String,runtimeUpdatesEnabled: null == runtimeUpdatesEnabled ? _self.runtimeUpdatesEnabled : runtimeUpdatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,mappedFiles: null == mappedFiles ? _self._mappedFiles : mappedFiles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,mappedFolders: null == mappedFolders ? _self._mappedFolders : mappedFolders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,concurrentDownloadsEnabled: null == concurrentDownloadsEnabled ? _self.concurrentDownloadsEnabled : concurrentDownloadsEnabled // ignore: cast_nullable_to_non_nullable
as bool,cdnBranchMirrors: null == cdnBranchMirrors ? _self._cdnBranchMirrors : cdnBranchMirrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
