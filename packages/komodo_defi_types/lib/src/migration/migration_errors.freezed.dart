// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetMigrationError {

@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId get assetId; MigrationErrorType get errorType; String get message; String? get userFriendlyMessage; String? get originalError; DateTime? get occurredAt;
/// Create a copy of AssetMigrationError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetMigrationErrorCopyWith<AssetMigrationError> get copyWith => _$AssetMigrationErrorCopyWithImpl<AssetMigrationError>(this as AssetMigrationError, _$identity);

  /// Serializes this AssetMigrationError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetMigrationError&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.message, message) || other.message == message)&&(identical(other.userFriendlyMessage, userFriendlyMessage) || other.userFriendlyMessage == userFriendlyMessage)&&(identical(other.originalError, originalError) || other.originalError == originalError)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,errorType,message,userFriendlyMessage,originalError,occurredAt);

@override
String toString() {
  return 'AssetMigrationError(assetId: $assetId, errorType: $errorType, message: $message, userFriendlyMessage: $userFriendlyMessage, originalError: $originalError, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $AssetMigrationErrorCopyWith<$Res>  {
  factory $AssetMigrationErrorCopyWith(AssetMigrationError value, $Res Function(AssetMigrationError) _then) = _$AssetMigrationErrorCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId assetId, MigrationErrorType errorType, String message, String? userFriendlyMessage, String? originalError, DateTime? occurredAt
});




}
/// @nodoc
class _$AssetMigrationErrorCopyWithImpl<$Res>
    implements $AssetMigrationErrorCopyWith<$Res> {
  _$AssetMigrationErrorCopyWithImpl(this._self, this._then);

  final AssetMigrationError _self;
  final $Res Function(AssetMigrationError) _then;

/// Create a copy of AssetMigrationError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetId = null,Object? errorType = null,Object? message = null,Object? userFriendlyMessage = freezed,Object? originalError = freezed,Object? occurredAt = freezed,}) {
  return _then(_self.copyWith(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as AssetId,errorType: null == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as MigrationErrorType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,userFriendlyMessage: freezed == userFriendlyMessage ? _self.userFriendlyMessage : userFriendlyMessage // ignore: cast_nullable_to_non_nullable
as String?,originalError: freezed == originalError ? _self.originalError : originalError // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetMigrationError].
extension AssetMigrationErrorPatterns on AssetMigrationError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetMigrationError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetMigrationError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetMigrationError value)  $default,){
final _that = this;
switch (_that) {
case _AssetMigrationError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetMigrationError value)?  $default,){
final _that = this;
switch (_that) {
case _AssetMigrationError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  MigrationErrorType errorType,  String message,  String? userFriendlyMessage,  String? originalError,  DateTime? occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetMigrationError() when $default != null:
return $default(_that.assetId,_that.errorType,_that.message,_that.userFriendlyMessage,_that.originalError,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  MigrationErrorType errorType,  String message,  String? userFriendlyMessage,  String? originalError,  DateTime? occurredAt)  $default,) {final _that = this;
switch (_that) {
case _AssetMigrationError():
return $default(_that.assetId,_that.errorType,_that.message,_that.userFriendlyMessage,_that.originalError,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  MigrationErrorType errorType,  String message,  String? userFriendlyMessage,  String? originalError,  DateTime? occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _AssetMigrationError() when $default != null:
return $default(_that.assetId,_that.errorType,_that.message,_that.userFriendlyMessage,_that.originalError,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _AssetMigrationError implements AssetMigrationError {
  const _AssetMigrationError({@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) required this.assetId, required this.errorType, required this.message, this.userFriendlyMessage, this.originalError, this.occurredAt});
  factory _AssetMigrationError.fromJson(Map<String, dynamic> json) => _$AssetMigrationErrorFromJson(json);

@override@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) final  AssetId assetId;
@override final  MigrationErrorType errorType;
@override final  String message;
@override final  String? userFriendlyMessage;
@override final  String? originalError;
@override final  DateTime? occurredAt;

/// Create a copy of AssetMigrationError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetMigrationErrorCopyWith<_AssetMigrationError> get copyWith => __$AssetMigrationErrorCopyWithImpl<_AssetMigrationError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetMigrationErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetMigrationError&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.message, message) || other.message == message)&&(identical(other.userFriendlyMessage, userFriendlyMessage) || other.userFriendlyMessage == userFriendlyMessage)&&(identical(other.originalError, originalError) || other.originalError == originalError)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,errorType,message,userFriendlyMessage,originalError,occurredAt);

@override
String toString() {
  return 'AssetMigrationError(assetId: $assetId, errorType: $errorType, message: $message, userFriendlyMessage: $userFriendlyMessage, originalError: $originalError, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$AssetMigrationErrorCopyWith<$Res> implements $AssetMigrationErrorCopyWith<$Res> {
  factory _$AssetMigrationErrorCopyWith(_AssetMigrationError value, $Res Function(_AssetMigrationError) _then) = __$AssetMigrationErrorCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId assetId, MigrationErrorType errorType, String message, String? userFriendlyMessage, String? originalError, DateTime? occurredAt
});




}
/// @nodoc
class __$AssetMigrationErrorCopyWithImpl<$Res>
    implements _$AssetMigrationErrorCopyWith<$Res> {
  __$AssetMigrationErrorCopyWithImpl(this._self, this._then);

  final _AssetMigrationError _self;
  final $Res Function(_AssetMigrationError) _then;

/// Create a copy of AssetMigrationError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetId = null,Object? errorType = null,Object? message = null,Object? userFriendlyMessage = freezed,Object? originalError = freezed,Object? occurredAt = freezed,}) {
  return _then(_AssetMigrationError(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as AssetId,errorType: null == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as MigrationErrorType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,userFriendlyMessage: freezed == userFriendlyMessage ? _self.userFriendlyMessage : userFriendlyMessage // ignore: cast_nullable_to_non_nullable
as String?,originalError: freezed == originalError ? _self.originalError : originalError // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
