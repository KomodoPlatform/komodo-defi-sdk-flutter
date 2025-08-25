// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MigrationConfig {

/// Number of assets to activate in each batch.
///
/// Lower values reduce memory usage but may increase total activation time.
/// Higher values may cause timeouts or memory issues with large asset lists.
 int get activationBatchSize;/// Maximum time to wait for individual operations to complete.
///
/// This applies to asset activation, balance queries, and withdrawal operations.
@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration get operationTimeout;/// Number of times to retry failed operations before giving up.
///
/// Set to 0 to disable retries.
 int get retryAttempts;/// Delay between retry attempts.
///
/// Uses exponential backoff: delay * (2 ^ attempt)
@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration get retryDelay;/// How long to cache migration preview results.
///
/// Cached previews can be reused if the same migration is requested
/// within this timeframe.
@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration get previewCacheTimeout;/// Maximum number of concurrent withdrawal operations.
///
/// Limits network load and prevents overwhelming the blockchain network.
 int get maxConcurrentWithdrawals;/// Whether to emit detailed progress updates during migration.
///
/// When false, only major status changes are reported.
 bool get enableProgressUpdates;/// Whether to enable detailed logging for debugging purposes.
///
/// When false, only errors and major events are logged.
 bool get enableDetailedLogging;
/// Create a copy of MigrationConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationConfigCopyWith<MigrationConfig> get copyWith => _$MigrationConfigCopyWithImpl<MigrationConfig>(this as MigrationConfig, _$identity);

  /// Serializes this MigrationConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationConfig&&(identical(other.activationBatchSize, activationBatchSize) || other.activationBatchSize == activationBatchSize)&&(identical(other.operationTimeout, operationTimeout) || other.operationTimeout == operationTimeout)&&(identical(other.retryAttempts, retryAttempts) || other.retryAttempts == retryAttempts)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay)&&(identical(other.previewCacheTimeout, previewCacheTimeout) || other.previewCacheTimeout == previewCacheTimeout)&&(identical(other.maxConcurrentWithdrawals, maxConcurrentWithdrawals) || other.maxConcurrentWithdrawals == maxConcurrentWithdrawals)&&(identical(other.enableProgressUpdates, enableProgressUpdates) || other.enableProgressUpdates == enableProgressUpdates)&&(identical(other.enableDetailedLogging, enableDetailedLogging) || other.enableDetailedLogging == enableDetailedLogging));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activationBatchSize,operationTimeout,retryAttempts,retryDelay,previewCacheTimeout,maxConcurrentWithdrawals,enableProgressUpdates,enableDetailedLogging);

@override
String toString() {
  return 'MigrationConfig(activationBatchSize: $activationBatchSize, operationTimeout: $operationTimeout, retryAttempts: $retryAttempts, retryDelay: $retryDelay, previewCacheTimeout: $previewCacheTimeout, maxConcurrentWithdrawals: $maxConcurrentWithdrawals, enableProgressUpdates: $enableProgressUpdates, enableDetailedLogging: $enableDetailedLogging)';
}


}

/// @nodoc
abstract mixin class $MigrationConfigCopyWith<$Res>  {
  factory $MigrationConfigCopyWith(MigrationConfig value, $Res Function(MigrationConfig) _then) = _$MigrationConfigCopyWithImpl;
@useResult
$Res call({
 int activationBatchSize,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration operationTimeout, int retryAttempts,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration retryDelay,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration previewCacheTimeout, int maxConcurrentWithdrawals, bool enableProgressUpdates, bool enableDetailedLogging
});




}
/// @nodoc
class _$MigrationConfigCopyWithImpl<$Res>
    implements $MigrationConfigCopyWith<$Res> {
  _$MigrationConfigCopyWithImpl(this._self, this._then);

  final MigrationConfig _self;
  final $Res Function(MigrationConfig) _then;

/// Create a copy of MigrationConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activationBatchSize = null,Object? operationTimeout = null,Object? retryAttempts = null,Object? retryDelay = null,Object? previewCacheTimeout = null,Object? maxConcurrentWithdrawals = null,Object? enableProgressUpdates = null,Object? enableDetailedLogging = null,}) {
  return _then(_self.copyWith(
activationBatchSize: null == activationBatchSize ? _self.activationBatchSize : activationBatchSize // ignore: cast_nullable_to_non_nullable
as int,operationTimeout: null == operationTimeout ? _self.operationTimeout : operationTimeout // ignore: cast_nullable_to_non_nullable
as Duration,retryAttempts: null == retryAttempts ? _self.retryAttempts : retryAttempts // ignore: cast_nullable_to_non_nullable
as int,retryDelay: null == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration,previewCacheTimeout: null == previewCacheTimeout ? _self.previewCacheTimeout : previewCacheTimeout // ignore: cast_nullable_to_non_nullable
as Duration,maxConcurrentWithdrawals: null == maxConcurrentWithdrawals ? _self.maxConcurrentWithdrawals : maxConcurrentWithdrawals // ignore: cast_nullable_to_non_nullable
as int,enableProgressUpdates: null == enableProgressUpdates ? _self.enableProgressUpdates : enableProgressUpdates // ignore: cast_nullable_to_non_nullable
as bool,enableDetailedLogging: null == enableDetailedLogging ? _self.enableDetailedLogging : enableDetailedLogging // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationConfig].
extension MigrationConfigPatterns on MigrationConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationConfig value)  $default,){
final _that = this;
switch (_that) {
case _MigrationConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activationBatchSize, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration operationTimeout,  int retryAttempts, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration retryDelay, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration previewCacheTimeout,  int maxConcurrentWithdrawals,  bool enableProgressUpdates,  bool enableDetailedLogging)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationConfig() when $default != null:
return $default(_that.activationBatchSize,_that.operationTimeout,_that.retryAttempts,_that.retryDelay,_that.previewCacheTimeout,_that.maxConcurrentWithdrawals,_that.enableProgressUpdates,_that.enableDetailedLogging);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activationBatchSize, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration operationTimeout,  int retryAttempts, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration retryDelay, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration previewCacheTimeout,  int maxConcurrentWithdrawals,  bool enableProgressUpdates,  bool enableDetailedLogging)  $default,) {final _that = this;
switch (_that) {
case _MigrationConfig():
return $default(_that.activationBatchSize,_that.operationTimeout,_that.retryAttempts,_that.retryDelay,_that.previewCacheTimeout,_that.maxConcurrentWithdrawals,_that.enableProgressUpdates,_that.enableDetailedLogging);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activationBatchSize, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration operationTimeout,  int retryAttempts, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration retryDelay, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration previewCacheTimeout,  int maxConcurrentWithdrawals,  bool enableProgressUpdates,  bool enableDetailedLogging)?  $default,) {final _that = this;
switch (_that) {
case _MigrationConfig() when $default != null:
return $default(_that.activationBatchSize,_that.operationTimeout,_that.retryAttempts,_that.retryDelay,_that.previewCacheTimeout,_that.maxConcurrentWithdrawals,_that.enableProgressUpdates,_that.enableDetailedLogging);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationConfig implements MigrationConfig {
  const _MigrationConfig({this.activationBatchSize = MigrationConfig.defaultActivationBatchSize, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) this.operationTimeout = MigrationConfig.defaultOperationTimeout, this.retryAttempts = MigrationConfig.defaultRetryAttempts, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) this.retryDelay = MigrationConfig.defaultRetryDelay, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) this.previewCacheTimeout = MigrationConfig.defaultPreviewCacheTimeout, this.maxConcurrentWithdrawals = MigrationConfig.defaultMaxConcurrentWithdrawals, this.enableProgressUpdates = true, this.enableDetailedLogging = true});
  factory _MigrationConfig.fromJson(Map<String, dynamic> json) => _$MigrationConfigFromJson(json);

/// Number of assets to activate in each batch.
///
/// Lower values reduce memory usage but may increase total activation time.
/// Higher values may cause timeouts or memory issues with large asset lists.
@override@JsonKey() final  int activationBatchSize;
/// Maximum time to wait for individual operations to complete.
///
/// This applies to asset activation, balance queries, and withdrawal operations.
@override@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) final  Duration operationTimeout;
/// Number of times to retry failed operations before giving up.
///
/// Set to 0 to disable retries.
@override@JsonKey() final  int retryAttempts;
/// Delay between retry attempts.
///
/// Uses exponential backoff: delay * (2 ^ attempt)
@override@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) final  Duration retryDelay;
/// How long to cache migration preview results.
///
/// Cached previews can be reused if the same migration is requested
/// within this timeframe.
@override@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) final  Duration previewCacheTimeout;
/// Maximum number of concurrent withdrawal operations.
///
/// Limits network load and prevents overwhelming the blockchain network.
@override@JsonKey() final  int maxConcurrentWithdrawals;
/// Whether to emit detailed progress updates during migration.
///
/// When false, only major status changes are reported.
@override@JsonKey() final  bool enableProgressUpdates;
/// Whether to enable detailed logging for debugging purposes.
///
/// When false, only errors and major events are logged.
@override@JsonKey() final  bool enableDetailedLogging;

/// Create a copy of MigrationConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationConfigCopyWith<_MigrationConfig> get copyWith => __$MigrationConfigCopyWithImpl<_MigrationConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationConfig&&(identical(other.activationBatchSize, activationBatchSize) || other.activationBatchSize == activationBatchSize)&&(identical(other.operationTimeout, operationTimeout) || other.operationTimeout == operationTimeout)&&(identical(other.retryAttempts, retryAttempts) || other.retryAttempts == retryAttempts)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay)&&(identical(other.previewCacheTimeout, previewCacheTimeout) || other.previewCacheTimeout == previewCacheTimeout)&&(identical(other.maxConcurrentWithdrawals, maxConcurrentWithdrawals) || other.maxConcurrentWithdrawals == maxConcurrentWithdrawals)&&(identical(other.enableProgressUpdates, enableProgressUpdates) || other.enableProgressUpdates == enableProgressUpdates)&&(identical(other.enableDetailedLogging, enableDetailedLogging) || other.enableDetailedLogging == enableDetailedLogging));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activationBatchSize,operationTimeout,retryAttempts,retryDelay,previewCacheTimeout,maxConcurrentWithdrawals,enableProgressUpdates,enableDetailedLogging);

@override
String toString() {
  return 'MigrationConfig(activationBatchSize: $activationBatchSize, operationTimeout: $operationTimeout, retryAttempts: $retryAttempts, retryDelay: $retryDelay, previewCacheTimeout: $previewCacheTimeout, maxConcurrentWithdrawals: $maxConcurrentWithdrawals, enableProgressUpdates: $enableProgressUpdates, enableDetailedLogging: $enableDetailedLogging)';
}


}

/// @nodoc
abstract mixin class _$MigrationConfigCopyWith<$Res> implements $MigrationConfigCopyWith<$Res> {
  factory _$MigrationConfigCopyWith(_MigrationConfig value, $Res Function(_MigrationConfig) _then) = __$MigrationConfigCopyWithImpl;
@override @useResult
$Res call({
 int activationBatchSize,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration operationTimeout, int retryAttempts,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration retryDelay,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration previewCacheTimeout, int maxConcurrentWithdrawals, bool enableProgressUpdates, bool enableDetailedLogging
});




}
/// @nodoc
class __$MigrationConfigCopyWithImpl<$Res>
    implements _$MigrationConfigCopyWith<$Res> {
  __$MigrationConfigCopyWithImpl(this._self, this._then);

  final _MigrationConfig _self;
  final $Res Function(_MigrationConfig) _then;

/// Create a copy of MigrationConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activationBatchSize = null,Object? operationTimeout = null,Object? retryAttempts = null,Object? retryDelay = null,Object? previewCacheTimeout = null,Object? maxConcurrentWithdrawals = null,Object? enableProgressUpdates = null,Object? enableDetailedLogging = null,}) {
  return _then(_MigrationConfig(
activationBatchSize: null == activationBatchSize ? _self.activationBatchSize : activationBatchSize // ignore: cast_nullable_to_non_nullable
as int,operationTimeout: null == operationTimeout ? _self.operationTimeout : operationTimeout // ignore: cast_nullable_to_non_nullable
as Duration,retryAttempts: null == retryAttempts ? _self.retryAttempts : retryAttempts // ignore: cast_nullable_to_non_nullable
as int,retryDelay: null == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration,previewCacheTimeout: null == previewCacheTimeout ? _self.previewCacheTimeout : previewCacheTimeout // ignore: cast_nullable_to_non_nullable
as Duration,maxConcurrentWithdrawals: null == maxConcurrentWithdrawals ? _self.maxConcurrentWithdrawals : maxConcurrentWithdrawals // ignore: cast_nullable_to_non_nullable
as int,enableProgressUpdates: null == enableProgressUpdates ? _self.enableProgressUpdates : enableProgressUpdates // ignore: cast_nullable_to_non_nullable
as bool,enableDetailedLogging: null == enableDetailedLogging ? _self.enableDetailedLogging : enableDetailedLogging // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
