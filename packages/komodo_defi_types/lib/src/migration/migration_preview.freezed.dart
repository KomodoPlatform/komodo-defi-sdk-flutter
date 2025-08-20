// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MigrationPreview {

 WalletId get fromWalletId; WalletId get toWalletId; String get pubkeyHash; List<WithdrawalPreview> get withdrawals;
/// Create a copy of MigrationPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationPreviewCopyWith<MigrationPreview> get copyWith => _$MigrationPreviewCopyWithImpl<MigrationPreview>(this as MigrationPreview, _$identity);

  /// Serializes this MigrationPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationPreview&&(identical(other.fromWalletId, fromWalletId) || other.fromWalletId == fromWalletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.pubkeyHash, pubkeyHash) || other.pubkeyHash == pubkeyHash)&&const DeepCollectionEquality().equals(other.withdrawals, withdrawals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromWalletId,toWalletId,pubkeyHash,const DeepCollectionEquality().hash(withdrawals));

@override
String toString() {
  return 'MigrationPreview(fromWalletId: $fromWalletId, toWalletId: $toWalletId, pubkeyHash: $pubkeyHash, withdrawals: $withdrawals)';
}


}

/// @nodoc
abstract mixin class $MigrationPreviewCopyWith<$Res>  {
  factory $MigrationPreviewCopyWith(MigrationPreview value, $Res Function(MigrationPreview) _then) = _$MigrationPreviewCopyWithImpl;
@useResult
$Res call({
 WalletId fromWalletId, WalletId toWalletId, String pubkeyHash, List<WithdrawalPreview> withdrawals
});




}
/// @nodoc
class _$MigrationPreviewCopyWithImpl<$Res>
    implements $MigrationPreviewCopyWith<$Res> {
  _$MigrationPreviewCopyWithImpl(this._self, this._then);

  final MigrationPreview _self;
  final $Res Function(MigrationPreview) _then;

/// Create a copy of MigrationPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromWalletId = null,Object? toWalletId = null,Object? pubkeyHash = null,Object? withdrawals = null,}) {
  return _then(_self.copyWith(
fromWalletId: null == fromWalletId ? _self.fromWalletId : fromWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,toWalletId: null == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,pubkeyHash: null == pubkeyHash ? _self.pubkeyHash : pubkeyHash // ignore: cast_nullable_to_non_nullable
as String,withdrawals: null == withdrawals ? _self.withdrawals : withdrawals // ignore: cast_nullable_to_non_nullable
as List<WithdrawalPreview>,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationPreview].
extension MigrationPreviewPatterns on MigrationPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationPreview value)  $default,){
final _that = this;
switch (_that) {
case _MigrationPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationPreview value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletId fromWalletId,  WalletId toWalletId,  String pubkeyHash,  List<WithdrawalPreview> withdrawals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationPreview() when $default != null:
return $default(_that.fromWalletId,_that.toWalletId,_that.pubkeyHash,_that.withdrawals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletId fromWalletId,  WalletId toWalletId,  String pubkeyHash,  List<WithdrawalPreview> withdrawals)  $default,) {final _that = this;
switch (_that) {
case _MigrationPreview():
return $default(_that.fromWalletId,_that.toWalletId,_that.pubkeyHash,_that.withdrawals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletId fromWalletId,  WalletId toWalletId,  String pubkeyHash,  List<WithdrawalPreview> withdrawals)?  $default,) {final _that = this;
switch (_that) {
case _MigrationPreview() when $default != null:
return $default(_that.fromWalletId,_that.toWalletId,_that.pubkeyHash,_that.withdrawals);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationPreview implements MigrationPreview {
  const _MigrationPreview({required this.fromWalletId, required this.toWalletId, required this.pubkeyHash, required final  List<WithdrawalPreview> withdrawals}): _withdrawals = withdrawals;
  factory _MigrationPreview.fromJson(Map<String, dynamic> json) => _$MigrationPreviewFromJson(json);

@override final  WalletId fromWalletId;
@override final  WalletId toWalletId;
@override final  String pubkeyHash;
 final  List<WithdrawalPreview> _withdrawals;
@override List<WithdrawalPreview> get withdrawals {
  if (_withdrawals is EqualUnmodifiableListView) return _withdrawals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_withdrawals);
}


/// Create a copy of MigrationPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationPreviewCopyWith<_MigrationPreview> get copyWith => __$MigrationPreviewCopyWithImpl<_MigrationPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationPreview&&(identical(other.fromWalletId, fromWalletId) || other.fromWalletId == fromWalletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.pubkeyHash, pubkeyHash) || other.pubkeyHash == pubkeyHash)&&const DeepCollectionEquality().equals(other._withdrawals, _withdrawals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromWalletId,toWalletId,pubkeyHash,const DeepCollectionEquality().hash(_withdrawals));

@override
String toString() {
  return 'MigrationPreview(fromWalletId: $fromWalletId, toWalletId: $toWalletId, pubkeyHash: $pubkeyHash, withdrawals: $withdrawals)';
}


}

/// @nodoc
abstract mixin class _$MigrationPreviewCopyWith<$Res> implements $MigrationPreviewCopyWith<$Res> {
  factory _$MigrationPreviewCopyWith(_MigrationPreview value, $Res Function(_MigrationPreview) _then) = __$MigrationPreviewCopyWithImpl;
@override @useResult
$Res call({
 WalletId fromWalletId, WalletId toWalletId, String pubkeyHash, List<WithdrawalPreview> withdrawals
});




}
/// @nodoc
class __$MigrationPreviewCopyWithImpl<$Res>
    implements _$MigrationPreviewCopyWith<$Res> {
  __$MigrationPreviewCopyWithImpl(this._self, this._then);

  final _MigrationPreview _self;
  final $Res Function(_MigrationPreview) _then;

/// Create a copy of MigrationPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromWalletId = null,Object? toWalletId = null,Object? pubkeyHash = null,Object? withdrawals = null,}) {
  return _then(_MigrationPreview(
fromWalletId: null == fromWalletId ? _self.fromWalletId : fromWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,toWalletId: null == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,pubkeyHash: null == pubkeyHash ? _self.pubkeyHash : pubkeyHash // ignore: cast_nullable_to_non_nullable
as String,withdrawals: null == withdrawals ? _self._withdrawals : withdrawals // ignore: cast_nullable_to_non_nullable
as List<WithdrawalPreview>,
  ));
}


}

// dart format on
