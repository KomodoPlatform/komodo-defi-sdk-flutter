// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consensus_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsensusParams {

 num? get overwinterActivationHeight; num? get saplingActivationHeight; num? get blossomActivationHeight; num? get heartwoodActivationHeight; num? get canopyActivationHeight; num? get coinType; String? get hrpSaplingExtendedSpendingKey; String? get hrpSaplingExtendedFullViewingKey; String? get hrpSaplingPaymentAddress; List<num>? get b58PubkeyAddressPrefix; List<num>? get b58ScriptAddressPrefix;
/// Create a copy of ConsensusParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsensusParamsCopyWith<ConsensusParams> get copyWith => _$ConsensusParamsCopyWithImpl<ConsensusParams>(this as ConsensusParams, _$identity);

  /// Serializes this ConsensusParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsensusParams&&(identical(other.overwinterActivationHeight, overwinterActivationHeight) || other.overwinterActivationHeight == overwinterActivationHeight)&&(identical(other.saplingActivationHeight, saplingActivationHeight) || other.saplingActivationHeight == saplingActivationHeight)&&(identical(other.blossomActivationHeight, blossomActivationHeight) || other.blossomActivationHeight == blossomActivationHeight)&&(identical(other.heartwoodActivationHeight, heartwoodActivationHeight) || other.heartwoodActivationHeight == heartwoodActivationHeight)&&(identical(other.canopyActivationHeight, canopyActivationHeight) || other.canopyActivationHeight == canopyActivationHeight)&&(identical(other.coinType, coinType) || other.coinType == coinType)&&(identical(other.hrpSaplingExtendedSpendingKey, hrpSaplingExtendedSpendingKey) || other.hrpSaplingExtendedSpendingKey == hrpSaplingExtendedSpendingKey)&&(identical(other.hrpSaplingExtendedFullViewingKey, hrpSaplingExtendedFullViewingKey) || other.hrpSaplingExtendedFullViewingKey == hrpSaplingExtendedFullViewingKey)&&(identical(other.hrpSaplingPaymentAddress, hrpSaplingPaymentAddress) || other.hrpSaplingPaymentAddress == hrpSaplingPaymentAddress)&&const DeepCollectionEquality().equals(other.b58PubkeyAddressPrefix, b58PubkeyAddressPrefix)&&const DeepCollectionEquality().equals(other.b58ScriptAddressPrefix, b58ScriptAddressPrefix));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overwinterActivationHeight,saplingActivationHeight,blossomActivationHeight,heartwoodActivationHeight,canopyActivationHeight,coinType,hrpSaplingExtendedSpendingKey,hrpSaplingExtendedFullViewingKey,hrpSaplingPaymentAddress,const DeepCollectionEquality().hash(b58PubkeyAddressPrefix),const DeepCollectionEquality().hash(b58ScriptAddressPrefix));

@override
String toString() {
  return 'ConsensusParams(overwinterActivationHeight: $overwinterActivationHeight, saplingActivationHeight: $saplingActivationHeight, blossomActivationHeight: $blossomActivationHeight, heartwoodActivationHeight: $heartwoodActivationHeight, canopyActivationHeight: $canopyActivationHeight, coinType: $coinType, hrpSaplingExtendedSpendingKey: $hrpSaplingExtendedSpendingKey, hrpSaplingExtendedFullViewingKey: $hrpSaplingExtendedFullViewingKey, hrpSaplingPaymentAddress: $hrpSaplingPaymentAddress, b58PubkeyAddressPrefix: $b58PubkeyAddressPrefix, b58ScriptAddressPrefix: $b58ScriptAddressPrefix)';
}


}

/// @nodoc
abstract mixin class $ConsensusParamsCopyWith<$Res>  {
  factory $ConsensusParamsCopyWith(ConsensusParams value, $Res Function(ConsensusParams) _then) = _$ConsensusParamsCopyWithImpl;
@useResult
$Res call({
 num? overwinterActivationHeight, num? saplingActivationHeight, num? blossomActivationHeight, num? heartwoodActivationHeight, num? canopyActivationHeight, num? coinType, String? hrpSaplingExtendedSpendingKey, String? hrpSaplingExtendedFullViewingKey, String? hrpSaplingPaymentAddress, List<num>? b58PubkeyAddressPrefix, List<num>? b58ScriptAddressPrefix
});




}
/// @nodoc
class _$ConsensusParamsCopyWithImpl<$Res>
    implements $ConsensusParamsCopyWith<$Res> {
  _$ConsensusParamsCopyWithImpl(this._self, this._then);

  final ConsensusParams _self;
  final $Res Function(ConsensusParams) _then;

/// Create a copy of ConsensusParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overwinterActivationHeight = freezed,Object? saplingActivationHeight = freezed,Object? blossomActivationHeight = freezed,Object? heartwoodActivationHeight = freezed,Object? canopyActivationHeight = freezed,Object? coinType = freezed,Object? hrpSaplingExtendedSpendingKey = freezed,Object? hrpSaplingExtendedFullViewingKey = freezed,Object? hrpSaplingPaymentAddress = freezed,Object? b58PubkeyAddressPrefix = freezed,Object? b58ScriptAddressPrefix = freezed,}) {
  return _then(_self.copyWith(
overwinterActivationHeight: freezed == overwinterActivationHeight ? _self.overwinterActivationHeight : overwinterActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,saplingActivationHeight: freezed == saplingActivationHeight ? _self.saplingActivationHeight : saplingActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,blossomActivationHeight: freezed == blossomActivationHeight ? _self.blossomActivationHeight : blossomActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,heartwoodActivationHeight: freezed == heartwoodActivationHeight ? _self.heartwoodActivationHeight : heartwoodActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,canopyActivationHeight: freezed == canopyActivationHeight ? _self.canopyActivationHeight : canopyActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,coinType: freezed == coinType ? _self.coinType : coinType // ignore: cast_nullable_to_non_nullable
as num?,hrpSaplingExtendedSpendingKey: freezed == hrpSaplingExtendedSpendingKey ? _self.hrpSaplingExtendedSpendingKey : hrpSaplingExtendedSpendingKey // ignore: cast_nullable_to_non_nullable
as String?,hrpSaplingExtendedFullViewingKey: freezed == hrpSaplingExtendedFullViewingKey ? _self.hrpSaplingExtendedFullViewingKey : hrpSaplingExtendedFullViewingKey // ignore: cast_nullable_to_non_nullable
as String?,hrpSaplingPaymentAddress: freezed == hrpSaplingPaymentAddress ? _self.hrpSaplingPaymentAddress : hrpSaplingPaymentAddress // ignore: cast_nullable_to_non_nullable
as String?,b58PubkeyAddressPrefix: freezed == b58PubkeyAddressPrefix ? _self.b58PubkeyAddressPrefix : b58PubkeyAddressPrefix // ignore: cast_nullable_to_non_nullable
as List<num>?,b58ScriptAddressPrefix: freezed == b58ScriptAddressPrefix ? _self.b58ScriptAddressPrefix : b58ScriptAddressPrefix // ignore: cast_nullable_to_non_nullable
as List<num>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ConsensusParams implements ConsensusParams {
  const _ConsensusParams({this.overwinterActivationHeight, this.saplingActivationHeight, this.blossomActivationHeight, this.heartwoodActivationHeight, this.canopyActivationHeight, this.coinType, this.hrpSaplingExtendedSpendingKey, this.hrpSaplingExtendedFullViewingKey, this.hrpSaplingPaymentAddress, final  List<num>? b58PubkeyAddressPrefix, final  List<num>? b58ScriptAddressPrefix}): _b58PubkeyAddressPrefix = b58PubkeyAddressPrefix,_b58ScriptAddressPrefix = b58ScriptAddressPrefix;
  factory _ConsensusParams.fromJson(Map<String, dynamic> json) => _$ConsensusParamsFromJson(json);

@override final  num? overwinterActivationHeight;
@override final  num? saplingActivationHeight;
@override final  num? blossomActivationHeight;
@override final  num? heartwoodActivationHeight;
@override final  num? canopyActivationHeight;
@override final  num? coinType;
@override final  String? hrpSaplingExtendedSpendingKey;
@override final  String? hrpSaplingExtendedFullViewingKey;
@override final  String? hrpSaplingPaymentAddress;
 final  List<num>? _b58PubkeyAddressPrefix;
@override List<num>? get b58PubkeyAddressPrefix {
  final value = _b58PubkeyAddressPrefix;
  if (value == null) return null;
  if (_b58PubkeyAddressPrefix is EqualUnmodifiableListView) return _b58PubkeyAddressPrefix;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<num>? _b58ScriptAddressPrefix;
@override List<num>? get b58ScriptAddressPrefix {
  final value = _b58ScriptAddressPrefix;
  if (value == null) return null;
  if (_b58ScriptAddressPrefix is EqualUnmodifiableListView) return _b58ScriptAddressPrefix;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ConsensusParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsensusParamsCopyWith<_ConsensusParams> get copyWith => __$ConsensusParamsCopyWithImpl<_ConsensusParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsensusParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsensusParams&&(identical(other.overwinterActivationHeight, overwinterActivationHeight) || other.overwinterActivationHeight == overwinterActivationHeight)&&(identical(other.saplingActivationHeight, saplingActivationHeight) || other.saplingActivationHeight == saplingActivationHeight)&&(identical(other.blossomActivationHeight, blossomActivationHeight) || other.blossomActivationHeight == blossomActivationHeight)&&(identical(other.heartwoodActivationHeight, heartwoodActivationHeight) || other.heartwoodActivationHeight == heartwoodActivationHeight)&&(identical(other.canopyActivationHeight, canopyActivationHeight) || other.canopyActivationHeight == canopyActivationHeight)&&(identical(other.coinType, coinType) || other.coinType == coinType)&&(identical(other.hrpSaplingExtendedSpendingKey, hrpSaplingExtendedSpendingKey) || other.hrpSaplingExtendedSpendingKey == hrpSaplingExtendedSpendingKey)&&(identical(other.hrpSaplingExtendedFullViewingKey, hrpSaplingExtendedFullViewingKey) || other.hrpSaplingExtendedFullViewingKey == hrpSaplingExtendedFullViewingKey)&&(identical(other.hrpSaplingPaymentAddress, hrpSaplingPaymentAddress) || other.hrpSaplingPaymentAddress == hrpSaplingPaymentAddress)&&const DeepCollectionEquality().equals(other._b58PubkeyAddressPrefix, _b58PubkeyAddressPrefix)&&const DeepCollectionEquality().equals(other._b58ScriptAddressPrefix, _b58ScriptAddressPrefix));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overwinterActivationHeight,saplingActivationHeight,blossomActivationHeight,heartwoodActivationHeight,canopyActivationHeight,coinType,hrpSaplingExtendedSpendingKey,hrpSaplingExtendedFullViewingKey,hrpSaplingPaymentAddress,const DeepCollectionEquality().hash(_b58PubkeyAddressPrefix),const DeepCollectionEquality().hash(_b58ScriptAddressPrefix));

@override
String toString() {
  return 'ConsensusParams(overwinterActivationHeight: $overwinterActivationHeight, saplingActivationHeight: $saplingActivationHeight, blossomActivationHeight: $blossomActivationHeight, heartwoodActivationHeight: $heartwoodActivationHeight, canopyActivationHeight: $canopyActivationHeight, coinType: $coinType, hrpSaplingExtendedSpendingKey: $hrpSaplingExtendedSpendingKey, hrpSaplingExtendedFullViewingKey: $hrpSaplingExtendedFullViewingKey, hrpSaplingPaymentAddress: $hrpSaplingPaymentAddress, b58PubkeyAddressPrefix: $b58PubkeyAddressPrefix, b58ScriptAddressPrefix: $b58ScriptAddressPrefix)';
}


}

/// @nodoc
abstract mixin class _$ConsensusParamsCopyWith<$Res> implements $ConsensusParamsCopyWith<$Res> {
  factory _$ConsensusParamsCopyWith(_ConsensusParams value, $Res Function(_ConsensusParams) _then) = __$ConsensusParamsCopyWithImpl;
@override @useResult
$Res call({
 num? overwinterActivationHeight, num? saplingActivationHeight, num? blossomActivationHeight, num? heartwoodActivationHeight, num? canopyActivationHeight, num? coinType, String? hrpSaplingExtendedSpendingKey, String? hrpSaplingExtendedFullViewingKey, String? hrpSaplingPaymentAddress, List<num>? b58PubkeyAddressPrefix, List<num>? b58ScriptAddressPrefix
});




}
/// @nodoc
class __$ConsensusParamsCopyWithImpl<$Res>
    implements _$ConsensusParamsCopyWith<$Res> {
  __$ConsensusParamsCopyWithImpl(this._self, this._then);

  final _ConsensusParams _self;
  final $Res Function(_ConsensusParams) _then;

/// Create a copy of ConsensusParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overwinterActivationHeight = freezed,Object? saplingActivationHeight = freezed,Object? blossomActivationHeight = freezed,Object? heartwoodActivationHeight = freezed,Object? canopyActivationHeight = freezed,Object? coinType = freezed,Object? hrpSaplingExtendedSpendingKey = freezed,Object? hrpSaplingExtendedFullViewingKey = freezed,Object? hrpSaplingPaymentAddress = freezed,Object? b58PubkeyAddressPrefix = freezed,Object? b58ScriptAddressPrefix = freezed,}) {
  return _then(_ConsensusParams(
overwinterActivationHeight: freezed == overwinterActivationHeight ? _self.overwinterActivationHeight : overwinterActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,saplingActivationHeight: freezed == saplingActivationHeight ? _self.saplingActivationHeight : saplingActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,blossomActivationHeight: freezed == blossomActivationHeight ? _self.blossomActivationHeight : blossomActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,heartwoodActivationHeight: freezed == heartwoodActivationHeight ? _self.heartwoodActivationHeight : heartwoodActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,canopyActivationHeight: freezed == canopyActivationHeight ? _self.canopyActivationHeight : canopyActivationHeight // ignore: cast_nullable_to_non_nullable
as num?,coinType: freezed == coinType ? _self.coinType : coinType // ignore: cast_nullable_to_non_nullable
as num?,hrpSaplingExtendedSpendingKey: freezed == hrpSaplingExtendedSpendingKey ? _self.hrpSaplingExtendedSpendingKey : hrpSaplingExtendedSpendingKey // ignore: cast_nullable_to_non_nullable
as String?,hrpSaplingExtendedFullViewingKey: freezed == hrpSaplingExtendedFullViewingKey ? _self.hrpSaplingExtendedFullViewingKey : hrpSaplingExtendedFullViewingKey // ignore: cast_nullable_to_non_nullable
as String?,hrpSaplingPaymentAddress: freezed == hrpSaplingPaymentAddress ? _self.hrpSaplingPaymentAddress : hrpSaplingPaymentAddress // ignore: cast_nullable_to_non_nullable
as String?,b58PubkeyAddressPrefix: freezed == b58PubkeyAddressPrefix ? _self._b58PubkeyAddressPrefix : b58PubkeyAddressPrefix // ignore: cast_nullable_to_non_nullable
as List<num>?,b58ScriptAddressPrefix: freezed == b58ScriptAddressPrefix ? _self._b58ScriptAddressPrefix : b58ScriptAddressPrefix // ignore: cast_nullable_to_non_nullable
as List<num>?,
  ));
}


}

// dart format on
