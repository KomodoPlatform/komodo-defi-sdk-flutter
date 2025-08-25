// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MigrationResult {

 String get migrationId; MigrationResultStatus get status; List<AssetMigrationProgress> get assetResults; int get successCount; int get failureCount; int get totalCount; DateTime get startedAt; DateTime get completedAt; String? get summary; Map<String, dynamic>? get metadata;
/// Create a copy of MigrationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationResultCopyWith<MigrationResult> get copyWith => _$MigrationResultCopyWithImpl<MigrationResult>(this as MigrationResult, _$identity);

  /// Serializes this MigrationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationResult&&(identical(other.migrationId, migrationId) || other.migrationId == migrationId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.assetResults, assetResults)&&(identical(other.successCount, successCount) || other.successCount == successCount)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,migrationId,status,const DeepCollectionEquality().hash(assetResults),successCount,failureCount,totalCount,startedAt,completedAt,summary,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'MigrationResult(migrationId: $migrationId, status: $status, assetResults: $assetResults, successCount: $successCount, failureCount: $failureCount, totalCount: $totalCount, startedAt: $startedAt, completedAt: $completedAt, summary: $summary, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MigrationResultCopyWith<$Res>  {
  factory $MigrationResultCopyWith(MigrationResult value, $Res Function(MigrationResult) _then) = _$MigrationResultCopyWithImpl;
@useResult
$Res call({
 String migrationId, MigrationResultStatus status, List<AssetMigrationProgress> assetResults, int successCount, int failureCount, int totalCount, DateTime startedAt, DateTime completedAt, String? summary, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$MigrationResultCopyWithImpl<$Res>
    implements $MigrationResultCopyWith<$Res> {
  _$MigrationResultCopyWithImpl(this._self, this._then);

  final MigrationResult _self;
  final $Res Function(MigrationResult) _then;

/// Create a copy of MigrationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? migrationId = null,Object? status = null,Object? assetResults = null,Object? successCount = null,Object? failureCount = null,Object? totalCount = null,Object? startedAt = null,Object? completedAt = null,Object? summary = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
migrationId: null == migrationId ? _self.migrationId : migrationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MigrationResultStatus,assetResults: null == assetResults ? _self.assetResults : assetResults // ignore: cast_nullable_to_non_nullable
as List<AssetMigrationProgress>,successCount: null == successCount ? _self.successCount : successCount // ignore: cast_nullable_to_non_nullable
as int,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationResult].
extension MigrationResultPatterns on MigrationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationResult value)  $default,){
final _that = this;
switch (_that) {
case _MigrationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationResult value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String migrationId,  MigrationResultStatus status,  List<AssetMigrationProgress> assetResults,  int successCount,  int failureCount,  int totalCount,  DateTime startedAt,  DateTime completedAt,  String? summary,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationResult() when $default != null:
return $default(_that.migrationId,_that.status,_that.assetResults,_that.successCount,_that.failureCount,_that.totalCount,_that.startedAt,_that.completedAt,_that.summary,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String migrationId,  MigrationResultStatus status,  List<AssetMigrationProgress> assetResults,  int successCount,  int failureCount,  int totalCount,  DateTime startedAt,  DateTime completedAt,  String? summary,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _MigrationResult():
return $default(_that.migrationId,_that.status,_that.assetResults,_that.successCount,_that.failureCount,_that.totalCount,_that.startedAt,_that.completedAt,_that.summary,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String migrationId,  MigrationResultStatus status,  List<AssetMigrationProgress> assetResults,  int successCount,  int failureCount,  int totalCount,  DateTime startedAt,  DateTime completedAt,  String? summary,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _MigrationResult() when $default != null:
return $default(_that.migrationId,_that.status,_that.assetResults,_that.successCount,_that.failureCount,_that.totalCount,_that.startedAt,_that.completedAt,_that.summary,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationResult extends MigrationResult {
  const _MigrationResult({required this.migrationId, required this.status, required final  List<AssetMigrationProgress> assetResults, required this.successCount, required this.failureCount, required this.totalCount, required this.startedAt, required this.completedAt, this.summary, final  Map<String, dynamic>? metadata}): _assetResults = assetResults,_metadata = metadata,super._();
  factory _MigrationResult.fromJson(Map<String, dynamic> json) => _$MigrationResultFromJson(json);

@override final  String migrationId;
@override final  MigrationResultStatus status;
 final  List<AssetMigrationProgress> _assetResults;
@override List<AssetMigrationProgress> get assetResults {
  if (_assetResults is EqualUnmodifiableListView) return _assetResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetResults);
}

@override final  int successCount;
@override final  int failureCount;
@override final  int totalCount;
@override final  DateTime startedAt;
@override final  DateTime completedAt;
@override final  String? summary;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of MigrationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationResultCopyWith<_MigrationResult> get copyWith => __$MigrationResultCopyWithImpl<_MigrationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationResult&&(identical(other.migrationId, migrationId) || other.migrationId == migrationId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._assetResults, _assetResults)&&(identical(other.successCount, successCount) || other.successCount == successCount)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,migrationId,status,const DeepCollectionEquality().hash(_assetResults),successCount,failureCount,totalCount,startedAt,completedAt,summary,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'MigrationResult(migrationId: $migrationId, status: $status, assetResults: $assetResults, successCount: $successCount, failureCount: $failureCount, totalCount: $totalCount, startedAt: $startedAt, completedAt: $completedAt, summary: $summary, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$MigrationResultCopyWith<$Res> implements $MigrationResultCopyWith<$Res> {
  factory _$MigrationResultCopyWith(_MigrationResult value, $Res Function(_MigrationResult) _then) = __$MigrationResultCopyWithImpl;
@override @useResult
$Res call({
 String migrationId, MigrationResultStatus status, List<AssetMigrationProgress> assetResults, int successCount, int failureCount, int totalCount, DateTime startedAt, DateTime completedAt, String? summary, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$MigrationResultCopyWithImpl<$Res>
    implements _$MigrationResultCopyWith<$Res> {
  __$MigrationResultCopyWithImpl(this._self, this._then);

  final _MigrationResult _self;
  final $Res Function(_MigrationResult) _then;

/// Create a copy of MigrationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? migrationId = null,Object? status = null,Object? assetResults = null,Object? successCount = null,Object? failureCount = null,Object? totalCount = null,Object? startedAt = null,Object? completedAt = null,Object? summary = freezed,Object? metadata = freezed,}) {
  return _then(_MigrationResult(
migrationId: null == migrationId ? _self.migrationId : migrationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MigrationResultStatus,assetResults: null == assetResults ? _self._assetResults : assetResults // ignore: cast_nullable_to_non_nullable
as List<AssetMigrationProgress>,successCount: null == successCount ? _self.successCount : successCount // ignore: cast_nullable_to_non_nullable
as int,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
