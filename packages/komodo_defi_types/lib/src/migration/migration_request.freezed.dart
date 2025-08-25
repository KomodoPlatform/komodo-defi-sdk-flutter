// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MigrationRequest {

/// The wallet ID to migrate assets from
 WalletId get sourceWalletId;/// The wallet ID to migrate assets to
 WalletId get targetWalletId;/// List of asset IDs selected for migration
@JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson) List<AssetId> get selectedAssets;/// Whether to only show/migrate already activated coins
 bool get activateCoinsOnly;/// Custom fee preferences per asset (optional)
@JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson) Map<AssetId, WithdrawalFeeLevel> get feePreferences;
/// Create a copy of MigrationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationRequestCopyWith<MigrationRequest> get copyWith => _$MigrationRequestCopyWithImpl<MigrationRequest>(this as MigrationRequest, _$identity);

  /// Serializes this MigrationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationRequest&&(identical(other.sourceWalletId, sourceWalletId) || other.sourceWalletId == sourceWalletId)&&(identical(other.targetWalletId, targetWalletId) || other.targetWalletId == targetWalletId)&&const DeepCollectionEquality().equals(other.selectedAssets, selectedAssets)&&(identical(other.activateCoinsOnly, activateCoinsOnly) || other.activateCoinsOnly == activateCoinsOnly)&&const DeepCollectionEquality().equals(other.feePreferences, feePreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceWalletId,targetWalletId,const DeepCollectionEquality().hash(selectedAssets),activateCoinsOnly,const DeepCollectionEquality().hash(feePreferences));

@override
String toString() {
  return 'MigrationRequest(sourceWalletId: $sourceWalletId, targetWalletId: $targetWalletId, selectedAssets: $selectedAssets, activateCoinsOnly: $activateCoinsOnly, feePreferences: $feePreferences)';
}


}

/// @nodoc
abstract mixin class $MigrationRequestCopyWith<$Res>  {
  factory $MigrationRequestCopyWith(MigrationRequest value, $Res Function(MigrationRequest) _then) = _$MigrationRequestCopyWithImpl;
@useResult
$Res call({
 WalletId sourceWalletId, WalletId targetWalletId,@JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson) List<AssetId> selectedAssets, bool activateCoinsOnly,@JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson) Map<AssetId, WithdrawalFeeLevel> feePreferences
});




}
/// @nodoc
class _$MigrationRequestCopyWithImpl<$Res>
    implements $MigrationRequestCopyWith<$Res> {
  _$MigrationRequestCopyWithImpl(this._self, this._then);

  final MigrationRequest _self;
  final $Res Function(MigrationRequest) _then;

/// Create a copy of MigrationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceWalletId = null,Object? targetWalletId = null,Object? selectedAssets = null,Object? activateCoinsOnly = null,Object? feePreferences = null,}) {
  return _then(_self.copyWith(
sourceWalletId: null == sourceWalletId ? _self.sourceWalletId : sourceWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,targetWalletId: null == targetWalletId ? _self.targetWalletId : targetWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,selectedAssets: null == selectedAssets ? _self.selectedAssets : selectedAssets // ignore: cast_nullable_to_non_nullable
as List<AssetId>,activateCoinsOnly: null == activateCoinsOnly ? _self.activateCoinsOnly : activateCoinsOnly // ignore: cast_nullable_to_non_nullable
as bool,feePreferences: null == feePreferences ? _self.feePreferences : feePreferences // ignore: cast_nullable_to_non_nullable
as Map<AssetId, WithdrawalFeeLevel>,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationRequest].
extension MigrationRequestPatterns on MigrationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationRequest value)  $default,){
final _that = this;
switch (_that) {
case _MigrationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletId sourceWalletId,  WalletId targetWalletId, @JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson)  List<AssetId> selectedAssets,  bool activateCoinsOnly, @JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson)  Map<AssetId, WithdrawalFeeLevel> feePreferences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationRequest() when $default != null:
return $default(_that.sourceWalletId,_that.targetWalletId,_that.selectedAssets,_that.activateCoinsOnly,_that.feePreferences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletId sourceWalletId,  WalletId targetWalletId, @JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson)  List<AssetId> selectedAssets,  bool activateCoinsOnly, @JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson)  Map<AssetId, WithdrawalFeeLevel> feePreferences)  $default,) {final _that = this;
switch (_that) {
case _MigrationRequest():
return $default(_that.sourceWalletId,_that.targetWalletId,_that.selectedAssets,_that.activateCoinsOnly,_that.feePreferences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletId sourceWalletId,  WalletId targetWalletId, @JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson)  List<AssetId> selectedAssets,  bool activateCoinsOnly, @JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson)  Map<AssetId, WithdrawalFeeLevel> feePreferences)?  $default,) {final _that = this;
switch (_that) {
case _MigrationRequest() when $default != null:
return $default(_that.sourceWalletId,_that.targetWalletId,_that.selectedAssets,_that.activateCoinsOnly,_that.feePreferences);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationRequest implements MigrationRequest {
  const _MigrationRequest({required this.sourceWalletId, required this.targetWalletId, @JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson) required final  List<AssetId> selectedAssets, this.activateCoinsOnly = false, @JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson) final  Map<AssetId, WithdrawalFeeLevel> feePreferences = const {}}): _selectedAssets = selectedAssets,_feePreferences = feePreferences;
  factory _MigrationRequest.fromJson(Map<String, dynamic> json) => _$MigrationRequestFromJson(json);

/// The wallet ID to migrate assets from
@override final  WalletId sourceWalletId;
/// The wallet ID to migrate assets to
@override final  WalletId targetWalletId;
/// List of asset IDs selected for migration
 final  List<AssetId> _selectedAssets;
/// List of asset IDs selected for migration
@override@JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson) List<AssetId> get selectedAssets {
  if (_selectedAssets is EqualUnmodifiableListView) return _selectedAssets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedAssets);
}

/// Whether to only show/migrate already activated coins
@override@JsonKey() final  bool activateCoinsOnly;
/// Custom fee preferences per asset (optional)
 final  Map<AssetId, WithdrawalFeeLevel> _feePreferences;
/// Custom fee preferences per asset (optional)
@override@JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson) Map<AssetId, WithdrawalFeeLevel> get feePreferences {
  if (_feePreferences is EqualUnmodifiableMapView) return _feePreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_feePreferences);
}


/// Create a copy of MigrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationRequestCopyWith<_MigrationRequest> get copyWith => __$MigrationRequestCopyWithImpl<_MigrationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationRequest&&(identical(other.sourceWalletId, sourceWalletId) || other.sourceWalletId == sourceWalletId)&&(identical(other.targetWalletId, targetWalletId) || other.targetWalletId == targetWalletId)&&const DeepCollectionEquality().equals(other._selectedAssets, _selectedAssets)&&(identical(other.activateCoinsOnly, activateCoinsOnly) || other.activateCoinsOnly == activateCoinsOnly)&&const DeepCollectionEquality().equals(other._feePreferences, _feePreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceWalletId,targetWalletId,const DeepCollectionEquality().hash(_selectedAssets),activateCoinsOnly,const DeepCollectionEquality().hash(_feePreferences));

@override
String toString() {
  return 'MigrationRequest(sourceWalletId: $sourceWalletId, targetWalletId: $targetWalletId, selectedAssets: $selectedAssets, activateCoinsOnly: $activateCoinsOnly, feePreferences: $feePreferences)';
}


}

/// @nodoc
abstract mixin class _$MigrationRequestCopyWith<$Res> implements $MigrationRequestCopyWith<$Res> {
  factory _$MigrationRequestCopyWith(_MigrationRequest value, $Res Function(_MigrationRequest) _then) = __$MigrationRequestCopyWithImpl;
@override @useResult
$Res call({
 WalletId sourceWalletId, WalletId targetWalletId,@JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson) List<AssetId> selectedAssets, bool activateCoinsOnly,@JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson) Map<AssetId, WithdrawalFeeLevel> feePreferences
});




}
/// @nodoc
class __$MigrationRequestCopyWithImpl<$Res>
    implements _$MigrationRequestCopyWith<$Res> {
  __$MigrationRequestCopyWithImpl(this._self, this._then);

  final _MigrationRequest _self;
  final $Res Function(_MigrationRequest) _then;

/// Create a copy of MigrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceWalletId = null,Object? targetWalletId = null,Object? selectedAssets = null,Object? activateCoinsOnly = null,Object? feePreferences = null,}) {
  return _then(_MigrationRequest(
sourceWalletId: null == sourceWalletId ? _self.sourceWalletId : sourceWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,targetWalletId: null == targetWalletId ? _self.targetWalletId : targetWalletId // ignore: cast_nullable_to_non_nullable
as WalletId,selectedAssets: null == selectedAssets ? _self._selectedAssets : selectedAssets // ignore: cast_nullable_to_non_nullable
as List<AssetId>,activateCoinsOnly: null == activateCoinsOnly ? _self.activateCoinsOnly : activateCoinsOnly // ignore: cast_nullable_to_non_nullable
as bool,feePreferences: null == feePreferences ? _self._feePreferences : feePreferences // ignore: cast_nullable_to_non_nullable
as Map<AssetId, WithdrawalFeeLevel>,
  ));
}


}

// dart format on
