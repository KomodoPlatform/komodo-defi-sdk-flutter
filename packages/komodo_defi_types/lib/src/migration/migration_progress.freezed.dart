// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetMigrationProgress {

@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId get assetId; AssetMigrationStatus get status; String? get txHash; String? get errorMessage; double get progress;// 0.0 to 1.0
 DateTime? get startedAt; DateTime? get completedAt;
/// Create a copy of AssetMigrationProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetMigrationProgressCopyWith<AssetMigrationProgress> get copyWith => _$AssetMigrationProgressCopyWithImpl<AssetMigrationProgress>(this as AssetMigrationProgress, _$identity);

  /// Serializes this AssetMigrationProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetMigrationProgress&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.status, status) || other.status == status)&&(identical(other.txHash, txHash) || other.txHash == txHash)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,status,txHash,errorMessage,progress,startedAt,completedAt);

@override
String toString() {
  return 'AssetMigrationProgress(assetId: $assetId, status: $status, txHash: $txHash, errorMessage: $errorMessage, progress: $progress, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $AssetMigrationProgressCopyWith<$Res>  {
  factory $AssetMigrationProgressCopyWith(AssetMigrationProgress value, $Res Function(AssetMigrationProgress) _then) = _$AssetMigrationProgressCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId assetId, AssetMigrationStatus status, String? txHash, String? errorMessage, double progress, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$AssetMigrationProgressCopyWithImpl<$Res>
    implements $AssetMigrationProgressCopyWith<$Res> {
  _$AssetMigrationProgressCopyWithImpl(this._self, this._then);

  final AssetMigrationProgress _self;
  final $Res Function(AssetMigrationProgress) _then;

/// Create a copy of AssetMigrationProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetId = null,Object? status = null,Object? txHash = freezed,Object? errorMessage = freezed,Object? progress = null,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as AssetId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssetMigrationStatus,txHash: freezed == txHash ? _self.txHash : txHash // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetMigrationProgress].
extension AssetMigrationProgressPatterns on AssetMigrationProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetMigrationProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetMigrationProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetMigrationProgress value)  $default,){
final _that = this;
switch (_that) {
case _AssetMigrationProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetMigrationProgress value)?  $default,){
final _that = this;
switch (_that) {
case _AssetMigrationProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  AssetMigrationStatus status,  String? txHash,  String? errorMessage,  double progress,  DateTime? startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetMigrationProgress() when $default != null:
return $default(_that.assetId,_that.status,_that.txHash,_that.errorMessage,_that.progress,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  AssetMigrationStatus status,  String? txHash,  String? errorMessage,  double progress,  DateTime? startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _AssetMigrationProgress():
return $default(_that.assetId,_that.status,_that.txHash,_that.errorMessage,_that.progress,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  AssetMigrationStatus status,  String? txHash,  String? errorMessage,  double progress,  DateTime? startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _AssetMigrationProgress() when $default != null:
return $default(_that.assetId,_that.status,_that.txHash,_that.errorMessage,_that.progress,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _AssetMigrationProgress extends AssetMigrationProgress {
  const _AssetMigrationProgress({@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) required this.assetId, required this.status, this.txHash, this.errorMessage, this.progress = 0.0, this.startedAt, this.completedAt}): super._();
  factory _AssetMigrationProgress.fromJson(Map<String, dynamic> json) => _$AssetMigrationProgressFromJson(json);

@override@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) final  AssetId assetId;
@override final  AssetMigrationStatus status;
@override final  String? txHash;
@override final  String? errorMessage;
@override@JsonKey() final  double progress;
// 0.0 to 1.0
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;

/// Create a copy of AssetMigrationProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetMigrationProgressCopyWith<_AssetMigrationProgress> get copyWith => __$AssetMigrationProgressCopyWithImpl<_AssetMigrationProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetMigrationProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetMigrationProgress&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.status, status) || other.status == status)&&(identical(other.txHash, txHash) || other.txHash == txHash)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,status,txHash,errorMessage,progress,startedAt,completedAt);

@override
String toString() {
  return 'AssetMigrationProgress(assetId: $assetId, status: $status, txHash: $txHash, errorMessage: $errorMessage, progress: $progress, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$AssetMigrationProgressCopyWith<$Res> implements $AssetMigrationProgressCopyWith<$Res> {
  factory _$AssetMigrationProgressCopyWith(_AssetMigrationProgress value, $Res Function(_AssetMigrationProgress) _then) = __$AssetMigrationProgressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId assetId, AssetMigrationStatus status, String? txHash, String? errorMessage, double progress, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$AssetMigrationProgressCopyWithImpl<$Res>
    implements _$AssetMigrationProgressCopyWith<$Res> {
  __$AssetMigrationProgressCopyWithImpl(this._self, this._then);

  final _AssetMigrationProgress _self;
  final $Res Function(_AssetMigrationProgress) _then;

/// Create a copy of AssetMigrationProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetId = null,Object? status = null,Object? txHash = freezed,Object? errorMessage = freezed,Object? progress = null,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_AssetMigrationProgress(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as AssetId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssetMigrationStatus,txHash: freezed == txHash ? _self.txHash : txHash // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MigrationProgress {

 String get migrationId; MigrationStatus get status; List<AssetMigrationProgress> get assetProgress; int get completedCount; int get totalCount; String? get message; DateTime? get startedAt; DateTime? get completedAt;
/// Create a copy of MigrationProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationProgressCopyWith<MigrationProgress> get copyWith => _$MigrationProgressCopyWithImpl<MigrationProgress>(this as MigrationProgress, _$identity);

  /// Serializes this MigrationProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationProgress&&(identical(other.migrationId, migrationId) || other.migrationId == migrationId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.assetProgress, assetProgress)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.message, message) || other.message == message)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,migrationId,status,const DeepCollectionEquality().hash(assetProgress),completedCount,totalCount,message,startedAt,completedAt);

@override
String toString() {
  return 'MigrationProgress(migrationId: $migrationId, status: $status, assetProgress: $assetProgress, completedCount: $completedCount, totalCount: $totalCount, message: $message, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $MigrationProgressCopyWith<$Res>  {
  factory $MigrationProgressCopyWith(MigrationProgress value, $Res Function(MigrationProgress) _then) = _$MigrationProgressCopyWithImpl;
@useResult
$Res call({
 String migrationId, MigrationStatus status, List<AssetMigrationProgress> assetProgress, int completedCount, int totalCount, String? message, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$MigrationProgressCopyWithImpl<$Res>
    implements $MigrationProgressCopyWith<$Res> {
  _$MigrationProgressCopyWithImpl(this._self, this._then);

  final MigrationProgress _self;
  final $Res Function(MigrationProgress) _then;

/// Create a copy of MigrationProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? migrationId = null,Object? status = null,Object? assetProgress = null,Object? completedCount = null,Object? totalCount = null,Object? message = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
migrationId: null == migrationId ? _self.migrationId : migrationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MigrationStatus,assetProgress: null == assetProgress ? _self.assetProgress : assetProgress // ignore: cast_nullable_to_non_nullable
as List<AssetMigrationProgress>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationProgress].
extension MigrationProgressPatterns on MigrationProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationProgress value)  $default,){
final _that = this;
switch (_that) {
case _MigrationProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationProgress value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String migrationId,  MigrationStatus status,  List<AssetMigrationProgress> assetProgress,  int completedCount,  int totalCount,  String? message,  DateTime? startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationProgress() when $default != null:
return $default(_that.migrationId,_that.status,_that.assetProgress,_that.completedCount,_that.totalCount,_that.message,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String migrationId,  MigrationStatus status,  List<AssetMigrationProgress> assetProgress,  int completedCount,  int totalCount,  String? message,  DateTime? startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _MigrationProgress():
return $default(_that.migrationId,_that.status,_that.assetProgress,_that.completedCount,_that.totalCount,_that.message,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String migrationId,  MigrationStatus status,  List<AssetMigrationProgress> assetProgress,  int completedCount,  int totalCount,  String? message,  DateTime? startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _MigrationProgress() when $default != null:
return $default(_that.migrationId,_that.status,_that.assetProgress,_that.completedCount,_that.totalCount,_that.message,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationProgress extends MigrationProgress {
  const _MigrationProgress({required this.migrationId, required this.status, required final  List<AssetMigrationProgress> assetProgress, required this.completedCount, required this.totalCount, this.message, this.startedAt, this.completedAt}): _assetProgress = assetProgress,super._();
  factory _MigrationProgress.fromJson(Map<String, dynamic> json) => _$MigrationProgressFromJson(json);

@override final  String migrationId;
@override final  MigrationStatus status;
 final  List<AssetMigrationProgress> _assetProgress;
@override List<AssetMigrationProgress> get assetProgress {
  if (_assetProgress is EqualUnmodifiableListView) return _assetProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetProgress);
}

@override final  int completedCount;
@override final  int totalCount;
@override final  String? message;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;

/// Create a copy of MigrationProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationProgressCopyWith<_MigrationProgress> get copyWith => __$MigrationProgressCopyWithImpl<_MigrationProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationProgress&&(identical(other.migrationId, migrationId) || other.migrationId == migrationId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._assetProgress, _assetProgress)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.message, message) || other.message == message)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,migrationId,status,const DeepCollectionEquality().hash(_assetProgress),completedCount,totalCount,message,startedAt,completedAt);

@override
String toString() {
  return 'MigrationProgress(migrationId: $migrationId, status: $status, assetProgress: $assetProgress, completedCount: $completedCount, totalCount: $totalCount, message: $message, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$MigrationProgressCopyWith<$Res> implements $MigrationProgressCopyWith<$Res> {
  factory _$MigrationProgressCopyWith(_MigrationProgress value, $Res Function(_MigrationProgress) _then) = __$MigrationProgressCopyWithImpl;
@override @useResult
$Res call({
 String migrationId, MigrationStatus status, List<AssetMigrationProgress> assetProgress, int completedCount, int totalCount, String? message, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$MigrationProgressCopyWithImpl<$Res>
    implements _$MigrationProgressCopyWith<$Res> {
  __$MigrationProgressCopyWithImpl(this._self, this._then);

  final _MigrationProgress _self;
  final $Res Function(_MigrationProgress) _then;

/// Create a copy of MigrationProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? migrationId = null,Object? status = null,Object? assetProgress = null,Object? completedCount = null,Object? totalCount = null,Object? message = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_MigrationProgress(
migrationId: null == migrationId ? _self.migrationId : migrationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MigrationStatus,assetProgress: null == assetProgress ? _self._assetProgress : assetProgress // ignore: cast_nullable_to_non_nullable
as List<AssetMigrationProgress>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
