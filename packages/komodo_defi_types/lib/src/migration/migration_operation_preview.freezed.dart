// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_operation_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetMigrationPreview {

@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId get assetId; String get sourceAddress; String get targetAddress;@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal get balance;@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal get estimatedFee;@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal get netAmount; MigrationAssetStatus get status; String? get errorMessage;
/// Create a copy of AssetMigrationPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetMigrationPreviewCopyWith<AssetMigrationPreview> get copyWith => _$AssetMigrationPreviewCopyWithImpl<AssetMigrationPreview>(this as AssetMigrationPreview, _$identity);

  /// Serializes this AssetMigrationPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetMigrationPreview&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.sourceAddress, sourceAddress) || other.sourceAddress == sourceAddress)&&(identical(other.targetAddress, targetAddress) || other.targetAddress == targetAddress)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.estimatedFee, estimatedFee) || other.estimatedFee == estimatedFee)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,sourceAddress,targetAddress,balance,estimatedFee,netAmount,status,errorMessage);

@override
String toString() {
  return 'AssetMigrationPreview(assetId: $assetId, sourceAddress: $sourceAddress, targetAddress: $targetAddress, balance: $balance, estimatedFee: $estimatedFee, netAmount: $netAmount, status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AssetMigrationPreviewCopyWith<$Res>  {
  factory $AssetMigrationPreviewCopyWith(AssetMigrationPreview value, $Res Function(AssetMigrationPreview) _then) = _$AssetMigrationPreviewCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId assetId, String sourceAddress, String targetAddress,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal balance,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal estimatedFee,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal netAmount, MigrationAssetStatus status, String? errorMessage
});




}
/// @nodoc
class _$AssetMigrationPreviewCopyWithImpl<$Res>
    implements $AssetMigrationPreviewCopyWith<$Res> {
  _$AssetMigrationPreviewCopyWithImpl(this._self, this._then);

  final AssetMigrationPreview _self;
  final $Res Function(AssetMigrationPreview) _then;

/// Create a copy of AssetMigrationPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetId = null,Object? sourceAddress = null,Object? targetAddress = null,Object? balance = null,Object? estimatedFee = null,Object? netAmount = null,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as AssetId,sourceAddress: null == sourceAddress ? _self.sourceAddress : sourceAddress // ignore: cast_nullable_to_non_nullable
as String,targetAddress: null == targetAddress ? _self.targetAddress : targetAddress // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Decimal,estimatedFee: null == estimatedFee ? _self.estimatedFee : estimatedFee // ignore: cast_nullable_to_non_nullable
as Decimal,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as Decimal,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MigrationAssetStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetMigrationPreview].
extension AssetMigrationPreviewPatterns on AssetMigrationPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetMigrationPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetMigrationPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetMigrationPreview value)  $default,){
final _that = this;
switch (_that) {
case _AssetMigrationPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetMigrationPreview value)?  $default,){
final _that = this;
switch (_that) {
case _AssetMigrationPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  String sourceAddress,  String targetAddress, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal balance, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal estimatedFee, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal netAmount,  MigrationAssetStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetMigrationPreview() when $default != null:
return $default(_that.assetId,_that.sourceAddress,_that.targetAddress,_that.balance,_that.estimatedFee,_that.netAmount,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  String sourceAddress,  String targetAddress, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal balance, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal estimatedFee, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal netAmount,  MigrationAssetStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AssetMigrationPreview():
return $default(_that.assetId,_that.sourceAddress,_that.targetAddress,_that.balance,_that.estimatedFee,_that.netAmount,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)  AssetId assetId,  String sourceAddress,  String targetAddress, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal balance, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal estimatedFee, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal netAmount,  MigrationAssetStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AssetMigrationPreview() when $default != null:
return $default(_that.assetId,_that.sourceAddress,_that.targetAddress,_that.balance,_that.estimatedFee,_that.netAmount,_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _AssetMigrationPreview implements AssetMigrationPreview {
  const _AssetMigrationPreview({@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) required this.assetId, required this.sourceAddress, required this.targetAddress, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required this.balance, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required this.estimatedFee, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required this.netAmount, required this.status, this.errorMessage});
  factory _AssetMigrationPreview.fromJson(Map<String, dynamic> json) => _$AssetMigrationPreviewFromJson(json);

@override@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) final  AssetId assetId;
@override final  String sourceAddress;
@override final  String targetAddress;
@override@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) final  Decimal balance;
@override@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) final  Decimal estimatedFee;
@override@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) final  Decimal netAmount;
@override final  MigrationAssetStatus status;
@override final  String? errorMessage;

/// Create a copy of AssetMigrationPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetMigrationPreviewCopyWith<_AssetMigrationPreview> get copyWith => __$AssetMigrationPreviewCopyWithImpl<_AssetMigrationPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetMigrationPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetMigrationPreview&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.sourceAddress, sourceAddress) || other.sourceAddress == sourceAddress)&&(identical(other.targetAddress, targetAddress) || other.targetAddress == targetAddress)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.estimatedFee, estimatedFee) || other.estimatedFee == estimatedFee)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,sourceAddress,targetAddress,balance,estimatedFee,netAmount,status,errorMessage);

@override
String toString() {
  return 'AssetMigrationPreview(assetId: $assetId, sourceAddress: $sourceAddress, targetAddress: $targetAddress, balance: $balance, estimatedFee: $estimatedFee, netAmount: $netAmount, status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AssetMigrationPreviewCopyWith<$Res> implements $AssetMigrationPreviewCopyWith<$Res> {
  factory _$AssetMigrationPreviewCopyWith(_AssetMigrationPreview value, $Res Function(_AssetMigrationPreview) _then) = __$AssetMigrationPreviewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson) AssetId assetId, String sourceAddress, String targetAddress,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal balance,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal estimatedFee,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal netAmount, MigrationAssetStatus status, String? errorMessage
});




}
/// @nodoc
class __$AssetMigrationPreviewCopyWithImpl<$Res>
    implements _$AssetMigrationPreviewCopyWith<$Res> {
  __$AssetMigrationPreviewCopyWithImpl(this._self, this._then);

  final _AssetMigrationPreview _self;
  final $Res Function(_AssetMigrationPreview) _then;

/// Create a copy of AssetMigrationPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetId = null,Object? sourceAddress = null,Object? targetAddress = null,Object? balance = null,Object? estimatedFee = null,Object? netAmount = null,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_AssetMigrationPreview(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as AssetId,sourceAddress: null == sourceAddress ? _self.sourceAddress : sourceAddress // ignore: cast_nullable_to_non_nullable
as String,targetAddress: null == targetAddress ? _self.targetAddress : targetAddress // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Decimal,estimatedFee: null == estimatedFee ? _self.estimatedFee : estimatedFee // ignore: cast_nullable_to_non_nullable
as Decimal,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as Decimal,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MigrationAssetStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MigrationSummary {

 int get totalAssets; int get readyAssets; int get failedAssets;@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal get totalEstimatedFees;
/// Create a copy of MigrationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationSummaryCopyWith<MigrationSummary> get copyWith => _$MigrationSummaryCopyWithImpl<MigrationSummary>(this as MigrationSummary, _$identity);

  /// Serializes this MigrationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationSummary&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.readyAssets, readyAssets) || other.readyAssets == readyAssets)&&(identical(other.failedAssets, failedAssets) || other.failedAssets == failedAssets)&&(identical(other.totalEstimatedFees, totalEstimatedFees) || other.totalEstimatedFees == totalEstimatedFees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalAssets,readyAssets,failedAssets,totalEstimatedFees);

@override
String toString() {
  return 'MigrationSummary(totalAssets: $totalAssets, readyAssets: $readyAssets, failedAssets: $failedAssets, totalEstimatedFees: $totalEstimatedFees)';
}


}

/// @nodoc
abstract mixin class $MigrationSummaryCopyWith<$Res>  {
  factory $MigrationSummaryCopyWith(MigrationSummary value, $Res Function(MigrationSummary) _then) = _$MigrationSummaryCopyWithImpl;
@useResult
$Res call({
 int totalAssets, int readyAssets, int failedAssets,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal totalEstimatedFees
});




}
/// @nodoc
class _$MigrationSummaryCopyWithImpl<$Res>
    implements $MigrationSummaryCopyWith<$Res> {
  _$MigrationSummaryCopyWithImpl(this._self, this._then);

  final MigrationSummary _self;
  final $Res Function(MigrationSummary) _then;

/// Create a copy of MigrationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalAssets = null,Object? readyAssets = null,Object? failedAssets = null,Object? totalEstimatedFees = null,}) {
  return _then(_self.copyWith(
totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as int,readyAssets: null == readyAssets ? _self.readyAssets : readyAssets // ignore: cast_nullable_to_non_nullable
as int,failedAssets: null == failedAssets ? _self.failedAssets : failedAssets // ignore: cast_nullable_to_non_nullable
as int,totalEstimatedFees: null == totalEstimatedFees ? _self.totalEstimatedFees : totalEstimatedFees // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationSummary].
extension MigrationSummaryPatterns on MigrationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationSummary value)  $default,){
final _that = this;
switch (_that) {
case _MigrationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalAssets,  int readyAssets,  int failedAssets, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal totalEstimatedFees)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationSummary() when $default != null:
return $default(_that.totalAssets,_that.readyAssets,_that.failedAssets,_that.totalEstimatedFees);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalAssets,  int readyAssets,  int failedAssets, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal totalEstimatedFees)  $default,) {final _that = this;
switch (_that) {
case _MigrationSummary():
return $default(_that.totalAssets,_that.readyAssets,_that.failedAssets,_that.totalEstimatedFees);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalAssets,  int readyAssets,  int failedAssets, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)  Decimal totalEstimatedFees)?  $default,) {final _that = this;
switch (_that) {
case _MigrationSummary() when $default != null:
return $default(_that.totalAssets,_that.readyAssets,_that.failedAssets,_that.totalEstimatedFees);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationSummary extends MigrationSummary {
  const _MigrationSummary({required this.totalAssets, required this.readyAssets, required this.failedAssets, @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required this.totalEstimatedFees}): super._();
  factory _MigrationSummary.fromJson(Map<String, dynamic> json) => _$MigrationSummaryFromJson(json);

@override final  int totalAssets;
@override final  int readyAssets;
@override final  int failedAssets;
@override@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) final  Decimal totalEstimatedFees;

/// Create a copy of MigrationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationSummaryCopyWith<_MigrationSummary> get copyWith => __$MigrationSummaryCopyWithImpl<_MigrationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationSummary&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.readyAssets, readyAssets) || other.readyAssets == readyAssets)&&(identical(other.failedAssets, failedAssets) || other.failedAssets == failedAssets)&&(identical(other.totalEstimatedFees, totalEstimatedFees) || other.totalEstimatedFees == totalEstimatedFees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalAssets,readyAssets,failedAssets,totalEstimatedFees);

@override
String toString() {
  return 'MigrationSummary(totalAssets: $totalAssets, readyAssets: $readyAssets, failedAssets: $failedAssets, totalEstimatedFees: $totalEstimatedFees)';
}


}

/// @nodoc
abstract mixin class _$MigrationSummaryCopyWith<$Res> implements $MigrationSummaryCopyWith<$Res> {
  factory _$MigrationSummaryCopyWith(_MigrationSummary value, $Res Function(_MigrationSummary) _then) = __$MigrationSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalAssets, int readyAssets, int failedAssets,@JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) Decimal totalEstimatedFees
});




}
/// @nodoc
class __$MigrationSummaryCopyWithImpl<$Res>
    implements _$MigrationSummaryCopyWith<$Res> {
  __$MigrationSummaryCopyWithImpl(this._self, this._then);

  final _MigrationSummary _self;
  final $Res Function(_MigrationSummary) _then;

/// Create a copy of MigrationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalAssets = null,Object? readyAssets = null,Object? failedAssets = null,Object? totalEstimatedFees = null,}) {
  return _then(_MigrationSummary(
totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as int,readyAssets: null == readyAssets ? _self.readyAssets : readyAssets // ignore: cast_nullable_to_non_nullable
as int,failedAssets: null == failedAssets ? _self.failedAssets : failedAssets // ignore: cast_nullable_to_non_nullable
as int,totalEstimatedFees: null == totalEstimatedFees ? _self.totalEstimatedFees : totalEstimatedFees // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$MigrationOperationPreview {

 String get previewId; WalletId get sourceWallet; WalletId get targetWallet; List<AssetMigrationPreview> get assets; MigrationSummary get summary; DateTime get createdAt;
/// Create a copy of MigrationOperationPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationOperationPreviewCopyWith<MigrationOperationPreview> get copyWith => _$MigrationOperationPreviewCopyWithImpl<MigrationOperationPreview>(this as MigrationOperationPreview, _$identity);

  /// Serializes this MigrationOperationPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationOperationPreview&&(identical(other.previewId, previewId) || other.previewId == previewId)&&(identical(other.sourceWallet, sourceWallet) || other.sourceWallet == sourceWallet)&&(identical(other.targetWallet, targetWallet) || other.targetWallet == targetWallet)&&const DeepCollectionEquality().equals(other.assets, assets)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,previewId,sourceWallet,targetWallet,const DeepCollectionEquality().hash(assets),summary,createdAt);

@override
String toString() {
  return 'MigrationOperationPreview(previewId: $previewId, sourceWallet: $sourceWallet, targetWallet: $targetWallet, assets: $assets, summary: $summary, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MigrationOperationPreviewCopyWith<$Res>  {
  factory $MigrationOperationPreviewCopyWith(MigrationOperationPreview value, $Res Function(MigrationOperationPreview) _then) = _$MigrationOperationPreviewCopyWithImpl;
@useResult
$Res call({
 String previewId, WalletId sourceWallet, WalletId targetWallet, List<AssetMigrationPreview> assets, MigrationSummary summary, DateTime createdAt
});


$MigrationSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$MigrationOperationPreviewCopyWithImpl<$Res>
    implements $MigrationOperationPreviewCopyWith<$Res> {
  _$MigrationOperationPreviewCopyWithImpl(this._self, this._then);

  final MigrationOperationPreview _self;
  final $Res Function(MigrationOperationPreview) _then;

/// Create a copy of MigrationOperationPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? previewId = null,Object? sourceWallet = null,Object? targetWallet = null,Object? assets = null,Object? summary = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
previewId: null == previewId ? _self.previewId : previewId // ignore: cast_nullable_to_non_nullable
as String,sourceWallet: null == sourceWallet ? _self.sourceWallet : sourceWallet // ignore: cast_nullable_to_non_nullable
as WalletId,targetWallet: null == targetWallet ? _self.targetWallet : targetWallet // ignore: cast_nullable_to_non_nullable
as WalletId,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<AssetMigrationPreview>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as MigrationSummary,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of MigrationOperationPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MigrationSummaryCopyWith<$Res> get summary {
  
  return $MigrationSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [MigrationOperationPreview].
extension MigrationOperationPreviewPatterns on MigrationOperationPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationOperationPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationOperationPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationOperationPreview value)  $default,){
final _that = this;
switch (_that) {
case _MigrationOperationPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationOperationPreview value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationOperationPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String previewId,  WalletId sourceWallet,  WalletId targetWallet,  List<AssetMigrationPreview> assets,  MigrationSummary summary,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationOperationPreview() when $default != null:
return $default(_that.previewId,_that.sourceWallet,_that.targetWallet,_that.assets,_that.summary,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String previewId,  WalletId sourceWallet,  WalletId targetWallet,  List<AssetMigrationPreview> assets,  MigrationSummary summary,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MigrationOperationPreview():
return $default(_that.previewId,_that.sourceWallet,_that.targetWallet,_that.assets,_that.summary,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String previewId,  WalletId sourceWallet,  WalletId targetWallet,  List<AssetMigrationPreview> assets,  MigrationSummary summary,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MigrationOperationPreview() when $default != null:
return $default(_that.previewId,_that.sourceWallet,_that.targetWallet,_that.assets,_that.summary,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MigrationOperationPreview extends MigrationOperationPreview {
  const _MigrationOperationPreview({required this.previewId, required this.sourceWallet, required this.targetWallet, required final  List<AssetMigrationPreview> assets, required this.summary, required this.createdAt}): _assets = assets,super._();
  factory _MigrationOperationPreview.fromJson(Map<String, dynamic> json) => _$MigrationOperationPreviewFromJson(json);

@override final  String previewId;
@override final  WalletId sourceWallet;
@override final  WalletId targetWallet;
 final  List<AssetMigrationPreview> _assets;
@override List<AssetMigrationPreview> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}

@override final  MigrationSummary summary;
@override final  DateTime createdAt;

/// Create a copy of MigrationOperationPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationOperationPreviewCopyWith<_MigrationOperationPreview> get copyWith => __$MigrationOperationPreviewCopyWithImpl<_MigrationOperationPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationOperationPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationOperationPreview&&(identical(other.previewId, previewId) || other.previewId == previewId)&&(identical(other.sourceWallet, sourceWallet) || other.sourceWallet == sourceWallet)&&(identical(other.targetWallet, targetWallet) || other.targetWallet == targetWallet)&&const DeepCollectionEquality().equals(other._assets, _assets)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,previewId,sourceWallet,targetWallet,const DeepCollectionEquality().hash(_assets),summary,createdAt);

@override
String toString() {
  return 'MigrationOperationPreview(previewId: $previewId, sourceWallet: $sourceWallet, targetWallet: $targetWallet, assets: $assets, summary: $summary, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MigrationOperationPreviewCopyWith<$Res> implements $MigrationOperationPreviewCopyWith<$Res> {
  factory _$MigrationOperationPreviewCopyWith(_MigrationOperationPreview value, $Res Function(_MigrationOperationPreview) _then) = __$MigrationOperationPreviewCopyWithImpl;
@override @useResult
$Res call({
 String previewId, WalletId sourceWallet, WalletId targetWallet, List<AssetMigrationPreview> assets, MigrationSummary summary, DateTime createdAt
});


@override $MigrationSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$MigrationOperationPreviewCopyWithImpl<$Res>
    implements _$MigrationOperationPreviewCopyWith<$Res> {
  __$MigrationOperationPreviewCopyWithImpl(this._self, this._then);

  final _MigrationOperationPreview _self;
  final $Res Function(_MigrationOperationPreview) _then;

/// Create a copy of MigrationOperationPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? previewId = null,Object? sourceWallet = null,Object? targetWallet = null,Object? assets = null,Object? summary = null,Object? createdAt = null,}) {
  return _then(_MigrationOperationPreview(
previewId: null == previewId ? _self.previewId : previewId // ignore: cast_nullable_to_non_nullable
as String,sourceWallet: null == sourceWallet ? _self.sourceWallet : sourceWallet // ignore: cast_nullable_to_non_nullable
as WalletId,targetWallet: null == targetWallet ? _self.targetWallet : targetWallet // ignore: cast_nullable_to_non_nullable
as WalletId,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<AssetMigrationPreview>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as MigrationSummary,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of MigrationOperationPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MigrationSummaryCopyWith<$Res> get summary {
  
  return $MigrationSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
