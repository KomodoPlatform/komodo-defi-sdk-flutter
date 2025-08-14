// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protocol_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProtocolData {

 String? get platform; String? get contractAddress; ConsensusParams? get consensusParams; CheckPointBlock? get checkPointBlock; String? get slpPrefix; num? get decimals; String? get tokenId; num? get requiredConfirmations; String? get denom; String? get accountPrefix; String? get chainId; num? get gasPrice;
/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProtocolDataCopyWith<ProtocolData> get copyWith => _$ProtocolDataCopyWithImpl<ProtocolData>(this as ProtocolData, _$identity);

  /// Serializes this ProtocolData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProtocolData&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.consensusParams, consensusParams) || other.consensusParams == consensusParams)&&(identical(other.checkPointBlock, checkPointBlock) || other.checkPointBlock == checkPointBlock)&&(identical(other.slpPrefix, slpPrefix) || other.slpPrefix == slpPrefix)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.requiredConfirmations, requiredConfirmations) || other.requiredConfirmations == requiredConfirmations)&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.accountPrefix, accountPrefix) || other.accountPrefix == accountPrefix)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.gasPrice, gasPrice) || other.gasPrice == gasPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,contractAddress,consensusParams,checkPointBlock,slpPrefix,decimals,tokenId,requiredConfirmations,denom,accountPrefix,chainId,gasPrice);

@override
String toString() {
  return 'ProtocolData(platform: $platform, contractAddress: $contractAddress, consensusParams: $consensusParams, checkPointBlock: $checkPointBlock, slpPrefix: $slpPrefix, decimals: $decimals, tokenId: $tokenId, requiredConfirmations: $requiredConfirmations, denom: $denom, accountPrefix: $accountPrefix, chainId: $chainId, gasPrice: $gasPrice)';
}


}

/// @nodoc
abstract mixin class $ProtocolDataCopyWith<$Res>  {
  factory $ProtocolDataCopyWith(ProtocolData value, $Res Function(ProtocolData) _then) = _$ProtocolDataCopyWithImpl;
@useResult
$Res call({
 String? platform, String? contractAddress, ConsensusParams? consensusParams, CheckPointBlock? checkPointBlock, String? slpPrefix, num? decimals, String? tokenId, num? requiredConfirmations, String? denom, String? accountPrefix, String? chainId, num? gasPrice
});


$ConsensusParamsCopyWith<$Res>? get consensusParams;$CheckPointBlockCopyWith<$Res>? get checkPointBlock;

}
/// @nodoc
class _$ProtocolDataCopyWithImpl<$Res>
    implements $ProtocolDataCopyWith<$Res> {
  _$ProtocolDataCopyWithImpl(this._self, this._then);

  final ProtocolData _self;
  final $Res Function(ProtocolData) _then;

/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = freezed,Object? contractAddress = freezed,Object? consensusParams = freezed,Object? checkPointBlock = freezed,Object? slpPrefix = freezed,Object? decimals = freezed,Object? tokenId = freezed,Object? requiredConfirmations = freezed,Object? denom = freezed,Object? accountPrefix = freezed,Object? chainId = freezed,Object? gasPrice = freezed,}) {
  return _then(_self.copyWith(
platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,contractAddress: freezed == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String?,consensusParams: freezed == consensusParams ? _self.consensusParams : consensusParams // ignore: cast_nullable_to_non_nullable
as ConsensusParams?,checkPointBlock: freezed == checkPointBlock ? _self.checkPointBlock : checkPointBlock // ignore: cast_nullable_to_non_nullable
as CheckPointBlock?,slpPrefix: freezed == slpPrefix ? _self.slpPrefix : slpPrefix // ignore: cast_nullable_to_non_nullable
as String?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as num?,tokenId: freezed == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String?,requiredConfirmations: freezed == requiredConfirmations ? _self.requiredConfirmations : requiredConfirmations // ignore: cast_nullable_to_non_nullable
as num?,denom: freezed == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String?,accountPrefix: freezed == accountPrefix ? _self.accountPrefix : accountPrefix // ignore: cast_nullable_to_non_nullable
as String?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String?,gasPrice: freezed == gasPrice ? _self.gasPrice : gasPrice // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}
/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsensusParamsCopyWith<$Res>? get consensusParams {
    if (_self.consensusParams == null) {
    return null;
  }

  return $ConsensusParamsCopyWith<$Res>(_self.consensusParams!, (value) {
    return _then(_self.copyWith(consensusParams: value));
  });
}/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckPointBlockCopyWith<$Res>? get checkPointBlock {
    if (_self.checkPointBlock == null) {
    return null;
  }

  return $CheckPointBlockCopyWith<$Res>(_self.checkPointBlock!, (value) {
    return _then(_self.copyWith(checkPointBlock: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _ProtocolData implements ProtocolData {
  const _ProtocolData({this.platform, this.contractAddress, this.consensusParams, this.checkPointBlock, this.slpPrefix, this.decimals, this.tokenId, this.requiredConfirmations, this.denom, this.accountPrefix, this.chainId, this.gasPrice});
  factory _ProtocolData.fromJson(Map<String, dynamic> json) => _$ProtocolDataFromJson(json);

@override final  String? platform;
@override final  String? contractAddress;
@override final  ConsensusParams? consensusParams;
@override final  CheckPointBlock? checkPointBlock;
@override final  String? slpPrefix;
@override final  num? decimals;
@override final  String? tokenId;
@override final  num? requiredConfirmations;
@override final  String? denom;
@override final  String? accountPrefix;
@override final  String? chainId;
@override final  num? gasPrice;

/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProtocolDataCopyWith<_ProtocolData> get copyWith => __$ProtocolDataCopyWithImpl<_ProtocolData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProtocolDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProtocolData&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.consensusParams, consensusParams) || other.consensusParams == consensusParams)&&(identical(other.checkPointBlock, checkPointBlock) || other.checkPointBlock == checkPointBlock)&&(identical(other.slpPrefix, slpPrefix) || other.slpPrefix == slpPrefix)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.requiredConfirmations, requiredConfirmations) || other.requiredConfirmations == requiredConfirmations)&&(identical(other.denom, denom) || other.denom == denom)&&(identical(other.accountPrefix, accountPrefix) || other.accountPrefix == accountPrefix)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.gasPrice, gasPrice) || other.gasPrice == gasPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,contractAddress,consensusParams,checkPointBlock,slpPrefix,decimals,tokenId,requiredConfirmations,denom,accountPrefix,chainId,gasPrice);

@override
String toString() {
  return 'ProtocolData(platform: $platform, contractAddress: $contractAddress, consensusParams: $consensusParams, checkPointBlock: $checkPointBlock, slpPrefix: $slpPrefix, decimals: $decimals, tokenId: $tokenId, requiredConfirmations: $requiredConfirmations, denom: $denom, accountPrefix: $accountPrefix, chainId: $chainId, gasPrice: $gasPrice)';
}


}

/// @nodoc
abstract mixin class _$ProtocolDataCopyWith<$Res> implements $ProtocolDataCopyWith<$Res> {
  factory _$ProtocolDataCopyWith(_ProtocolData value, $Res Function(_ProtocolData) _then) = __$ProtocolDataCopyWithImpl;
@override @useResult
$Res call({
 String? platform, String? contractAddress, ConsensusParams? consensusParams, CheckPointBlock? checkPointBlock, String? slpPrefix, num? decimals, String? tokenId, num? requiredConfirmations, String? denom, String? accountPrefix, String? chainId, num? gasPrice
});


@override $ConsensusParamsCopyWith<$Res>? get consensusParams;@override $CheckPointBlockCopyWith<$Res>? get checkPointBlock;

}
/// @nodoc
class __$ProtocolDataCopyWithImpl<$Res>
    implements _$ProtocolDataCopyWith<$Res> {
  __$ProtocolDataCopyWithImpl(this._self, this._then);

  final _ProtocolData _self;
  final $Res Function(_ProtocolData) _then;

/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = freezed,Object? contractAddress = freezed,Object? consensusParams = freezed,Object? checkPointBlock = freezed,Object? slpPrefix = freezed,Object? decimals = freezed,Object? tokenId = freezed,Object? requiredConfirmations = freezed,Object? denom = freezed,Object? accountPrefix = freezed,Object? chainId = freezed,Object? gasPrice = freezed,}) {
  return _then(_ProtocolData(
platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,contractAddress: freezed == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String?,consensusParams: freezed == consensusParams ? _self.consensusParams : consensusParams // ignore: cast_nullable_to_non_nullable
as ConsensusParams?,checkPointBlock: freezed == checkPointBlock ? _self.checkPointBlock : checkPointBlock // ignore: cast_nullable_to_non_nullable
as CheckPointBlock?,slpPrefix: freezed == slpPrefix ? _self.slpPrefix : slpPrefix // ignore: cast_nullable_to_non_nullable
as String?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as num?,tokenId: freezed == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String?,requiredConfirmations: freezed == requiredConfirmations ? _self.requiredConfirmations : requiredConfirmations // ignore: cast_nullable_to_non_nullable
as num?,denom: freezed == denom ? _self.denom : denom // ignore: cast_nullable_to_non_nullable
as String?,accountPrefix: freezed == accountPrefix ? _self.accountPrefix : accountPrefix // ignore: cast_nullable_to_non_nullable
as String?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String?,gasPrice: freezed == gasPrice ? _self.gasPrice : gasPrice // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsensusParamsCopyWith<$Res>? get consensusParams {
    if (_self.consensusParams == null) {
    return null;
  }

  return $ConsensusParamsCopyWith<$Res>(_self.consensusParams!, (value) {
    return _then(_self.copyWith(consensusParams: value));
  });
}/// Create a copy of ProtocolData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckPointBlockCopyWith<$Res>? get checkPointBlock {
    if (_self.checkPointBlock == null) {
    return null;
  }

  return $CheckPointBlockCopyWith<$Res>(_self.checkPointBlock!, (value) {
    return _then(_self.copyWith(checkPointBlock: value));
  });
}
}

// dart format on
