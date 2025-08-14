// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Coin {

 String get coin; String? get name; String? get fname; num? get rpcport; num? get mm2; num? get chainId; num? get requiredConfirmations; num? get avgBlocktime; num? get decimals; Protocol? get protocol; String? get derivationPath; String? get trezorCoin; Links? get links; num? get isPoS; num? get pubtype; num? get p2shtype; num? get wiftype; num? get txfee; num? get dust; num? get matureConfirmations; bool? get segwit; String? get signMessagePrefix; String? get asset; num? get txversion; num? get overwintered; bool? get requiresNotarization; bool? get walletOnly; String? get bech32Hrp; bool? get isTestnet; String? get forkId; String? get signatureVersion; String? get confpath; AddressFormat? get addressFormat; String? get aliasTicker; String? get estimateFeeMode; String? get orderbookTicker; num? get taddr; bool? get forceMinRelayFee; num? get p2p; String? get magic; String? get nSPV; num? get isPoSV; String? get versionGroupId; String? get consensusBranchId; num? get estimateFeeBlocks;
/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoinCopyWith<Coin> get copyWith => _$CoinCopyWithImpl<Coin>(this as Coin, _$identity);

  /// Serializes this Coin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coin&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.name, name) || other.name == name)&&(identical(other.fname, fname) || other.fname == fname)&&(identical(other.rpcport, rpcport) || other.rpcport == rpcport)&&(identical(other.mm2, mm2) || other.mm2 == mm2)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.requiredConfirmations, requiredConfirmations) || other.requiredConfirmations == requiredConfirmations)&&(identical(other.avgBlocktime, avgBlocktime) || other.avgBlocktime == avgBlocktime)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.derivationPath, derivationPath) || other.derivationPath == derivationPath)&&(identical(other.trezorCoin, trezorCoin) || other.trezorCoin == trezorCoin)&&(identical(other.links, links) || other.links == links)&&(identical(other.isPoS, isPoS) || other.isPoS == isPoS)&&(identical(other.pubtype, pubtype) || other.pubtype == pubtype)&&(identical(other.p2shtype, p2shtype) || other.p2shtype == p2shtype)&&(identical(other.wiftype, wiftype) || other.wiftype == wiftype)&&(identical(other.txfee, txfee) || other.txfee == txfee)&&(identical(other.dust, dust) || other.dust == dust)&&(identical(other.matureConfirmations, matureConfirmations) || other.matureConfirmations == matureConfirmations)&&(identical(other.segwit, segwit) || other.segwit == segwit)&&(identical(other.signMessagePrefix, signMessagePrefix) || other.signMessagePrefix == signMessagePrefix)&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.txversion, txversion) || other.txversion == txversion)&&(identical(other.overwintered, overwintered) || other.overwintered == overwintered)&&(identical(other.requiresNotarization, requiresNotarization) || other.requiresNotarization == requiresNotarization)&&(identical(other.walletOnly, walletOnly) || other.walletOnly == walletOnly)&&(identical(other.bech32Hrp, bech32Hrp) || other.bech32Hrp == bech32Hrp)&&(identical(other.isTestnet, isTestnet) || other.isTestnet == isTestnet)&&(identical(other.forkId, forkId) || other.forkId == forkId)&&(identical(other.signatureVersion, signatureVersion) || other.signatureVersion == signatureVersion)&&(identical(other.confpath, confpath) || other.confpath == confpath)&&(identical(other.addressFormat, addressFormat) || other.addressFormat == addressFormat)&&(identical(other.aliasTicker, aliasTicker) || other.aliasTicker == aliasTicker)&&(identical(other.estimateFeeMode, estimateFeeMode) || other.estimateFeeMode == estimateFeeMode)&&(identical(other.orderbookTicker, orderbookTicker) || other.orderbookTicker == orderbookTicker)&&(identical(other.taddr, taddr) || other.taddr == taddr)&&(identical(other.forceMinRelayFee, forceMinRelayFee) || other.forceMinRelayFee == forceMinRelayFee)&&(identical(other.p2p, p2p) || other.p2p == p2p)&&(identical(other.magic, magic) || other.magic == magic)&&(identical(other.nSPV, nSPV) || other.nSPV == nSPV)&&(identical(other.isPoSV, isPoSV) || other.isPoSV == isPoSV)&&(identical(other.versionGroupId, versionGroupId) || other.versionGroupId == versionGroupId)&&(identical(other.consensusBranchId, consensusBranchId) || other.consensusBranchId == consensusBranchId)&&(identical(other.estimateFeeBlocks, estimateFeeBlocks) || other.estimateFeeBlocks == estimateFeeBlocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,coin,name,fname,rpcport,mm2,chainId,requiredConfirmations,avgBlocktime,decimals,protocol,derivationPath,trezorCoin,links,isPoS,pubtype,p2shtype,wiftype,txfee,dust,matureConfirmations,segwit,signMessagePrefix,asset,txversion,overwintered,requiresNotarization,walletOnly,bech32Hrp,isTestnet,forkId,signatureVersion,confpath,addressFormat,aliasTicker,estimateFeeMode,orderbookTicker,taddr,forceMinRelayFee,p2p,magic,nSPV,isPoSV,versionGroupId,consensusBranchId,estimateFeeBlocks]);

@override
String toString() {
  return 'Coin(coin: $coin, name: $name, fname: $fname, rpcport: $rpcport, mm2: $mm2, chainId: $chainId, requiredConfirmations: $requiredConfirmations, avgBlocktime: $avgBlocktime, decimals: $decimals, protocol: $protocol, derivationPath: $derivationPath, trezorCoin: $trezorCoin, links: $links, isPoS: $isPoS, pubtype: $pubtype, p2shtype: $p2shtype, wiftype: $wiftype, txfee: $txfee, dust: $dust, matureConfirmations: $matureConfirmations, segwit: $segwit, signMessagePrefix: $signMessagePrefix, asset: $asset, txversion: $txversion, overwintered: $overwintered, requiresNotarization: $requiresNotarization, walletOnly: $walletOnly, bech32Hrp: $bech32Hrp, isTestnet: $isTestnet, forkId: $forkId, signatureVersion: $signatureVersion, confpath: $confpath, addressFormat: $addressFormat, aliasTicker: $aliasTicker, estimateFeeMode: $estimateFeeMode, orderbookTicker: $orderbookTicker, taddr: $taddr, forceMinRelayFee: $forceMinRelayFee, p2p: $p2p, magic: $magic, nSPV: $nSPV, isPoSV: $isPoSV, versionGroupId: $versionGroupId, consensusBranchId: $consensusBranchId, estimateFeeBlocks: $estimateFeeBlocks)';
}


}

/// @nodoc
abstract mixin class $CoinCopyWith<$Res>  {
  factory $CoinCopyWith(Coin value, $Res Function(Coin) _then) = _$CoinCopyWithImpl;
@useResult
$Res call({
 String coin, String? name, String? fname, num? rpcport, num? mm2, num? chainId, num? requiredConfirmations, num? avgBlocktime, num? decimals, Protocol? protocol, String? derivationPath, String? trezorCoin, Links? links, num? isPoS, num? pubtype, num? p2shtype, num? wiftype, num? txfee, num? dust, num? matureConfirmations, bool? segwit, String? signMessagePrefix, String? asset, num? txversion, num? overwintered, bool? requiresNotarization, bool? walletOnly, String? bech32Hrp, bool? isTestnet, String? forkId, String? signatureVersion, String? confpath, AddressFormat? addressFormat, String? aliasTicker, String? estimateFeeMode, String? orderbookTicker, num? taddr, bool? forceMinRelayFee, num? p2p, String? magic, String? nSPV, num? isPoSV, String? versionGroupId, String? consensusBranchId, num? estimateFeeBlocks
});


$ProtocolCopyWith<$Res>? get protocol;$LinksCopyWith<$Res>? get links;$AddressFormatCopyWith<$Res>? get addressFormat;

}
/// @nodoc
class _$CoinCopyWithImpl<$Res>
    implements $CoinCopyWith<$Res> {
  _$CoinCopyWithImpl(this._self, this._then);

  final Coin _self;
  final $Res Function(Coin) _then;

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? name = freezed,Object? fname = freezed,Object? rpcport = freezed,Object? mm2 = freezed,Object? chainId = freezed,Object? requiredConfirmations = freezed,Object? avgBlocktime = freezed,Object? decimals = freezed,Object? protocol = freezed,Object? derivationPath = freezed,Object? trezorCoin = freezed,Object? links = freezed,Object? isPoS = freezed,Object? pubtype = freezed,Object? p2shtype = freezed,Object? wiftype = freezed,Object? txfee = freezed,Object? dust = freezed,Object? matureConfirmations = freezed,Object? segwit = freezed,Object? signMessagePrefix = freezed,Object? asset = freezed,Object? txversion = freezed,Object? overwintered = freezed,Object? requiresNotarization = freezed,Object? walletOnly = freezed,Object? bech32Hrp = freezed,Object? isTestnet = freezed,Object? forkId = freezed,Object? signatureVersion = freezed,Object? confpath = freezed,Object? addressFormat = freezed,Object? aliasTicker = freezed,Object? estimateFeeMode = freezed,Object? orderbookTicker = freezed,Object? taddr = freezed,Object? forceMinRelayFee = freezed,Object? p2p = freezed,Object? magic = freezed,Object? nSPV = freezed,Object? isPoSV = freezed,Object? versionGroupId = freezed,Object? consensusBranchId = freezed,Object? estimateFeeBlocks = freezed,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,fname: freezed == fname ? _self.fname : fname // ignore: cast_nullable_to_non_nullable
as String?,rpcport: freezed == rpcport ? _self.rpcport : rpcport // ignore: cast_nullable_to_non_nullable
as num?,mm2: freezed == mm2 ? _self.mm2 : mm2 // ignore: cast_nullable_to_non_nullable
as num?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as num?,requiredConfirmations: freezed == requiredConfirmations ? _self.requiredConfirmations : requiredConfirmations // ignore: cast_nullable_to_non_nullable
as num?,avgBlocktime: freezed == avgBlocktime ? _self.avgBlocktime : avgBlocktime // ignore: cast_nullable_to_non_nullable
as num?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as num?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as Protocol?,derivationPath: freezed == derivationPath ? _self.derivationPath : derivationPath // ignore: cast_nullable_to_non_nullable
as String?,trezorCoin: freezed == trezorCoin ? _self.trezorCoin : trezorCoin // ignore: cast_nullable_to_non_nullable
as String?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as Links?,isPoS: freezed == isPoS ? _self.isPoS : isPoS // ignore: cast_nullable_to_non_nullable
as num?,pubtype: freezed == pubtype ? _self.pubtype : pubtype // ignore: cast_nullable_to_non_nullable
as num?,p2shtype: freezed == p2shtype ? _self.p2shtype : p2shtype // ignore: cast_nullable_to_non_nullable
as num?,wiftype: freezed == wiftype ? _self.wiftype : wiftype // ignore: cast_nullable_to_non_nullable
as num?,txfee: freezed == txfee ? _self.txfee : txfee // ignore: cast_nullable_to_non_nullable
as num?,dust: freezed == dust ? _self.dust : dust // ignore: cast_nullable_to_non_nullable
as num?,matureConfirmations: freezed == matureConfirmations ? _self.matureConfirmations : matureConfirmations // ignore: cast_nullable_to_non_nullable
as num?,segwit: freezed == segwit ? _self.segwit : segwit // ignore: cast_nullable_to_non_nullable
as bool?,signMessagePrefix: freezed == signMessagePrefix ? _self.signMessagePrefix : signMessagePrefix // ignore: cast_nullable_to_non_nullable
as String?,asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String?,txversion: freezed == txversion ? _self.txversion : txversion // ignore: cast_nullable_to_non_nullable
as num?,overwintered: freezed == overwintered ? _self.overwintered : overwintered // ignore: cast_nullable_to_non_nullable
as num?,requiresNotarization: freezed == requiresNotarization ? _self.requiresNotarization : requiresNotarization // ignore: cast_nullable_to_non_nullable
as bool?,walletOnly: freezed == walletOnly ? _self.walletOnly : walletOnly // ignore: cast_nullable_to_non_nullable
as bool?,bech32Hrp: freezed == bech32Hrp ? _self.bech32Hrp : bech32Hrp // ignore: cast_nullable_to_non_nullable
as String?,isTestnet: freezed == isTestnet ? _self.isTestnet : isTestnet // ignore: cast_nullable_to_non_nullable
as bool?,forkId: freezed == forkId ? _self.forkId : forkId // ignore: cast_nullable_to_non_nullable
as String?,signatureVersion: freezed == signatureVersion ? _self.signatureVersion : signatureVersion // ignore: cast_nullable_to_non_nullable
as String?,confpath: freezed == confpath ? _self.confpath : confpath // ignore: cast_nullable_to_non_nullable
as String?,addressFormat: freezed == addressFormat ? _self.addressFormat : addressFormat // ignore: cast_nullable_to_non_nullable
as AddressFormat?,aliasTicker: freezed == aliasTicker ? _self.aliasTicker : aliasTicker // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeMode: freezed == estimateFeeMode ? _self.estimateFeeMode : estimateFeeMode // ignore: cast_nullable_to_non_nullable
as String?,orderbookTicker: freezed == orderbookTicker ? _self.orderbookTicker : orderbookTicker // ignore: cast_nullable_to_non_nullable
as String?,taddr: freezed == taddr ? _self.taddr : taddr // ignore: cast_nullable_to_non_nullable
as num?,forceMinRelayFee: freezed == forceMinRelayFee ? _self.forceMinRelayFee : forceMinRelayFee // ignore: cast_nullable_to_non_nullable
as bool?,p2p: freezed == p2p ? _self.p2p : p2p // ignore: cast_nullable_to_non_nullable
as num?,magic: freezed == magic ? _self.magic : magic // ignore: cast_nullable_to_non_nullable
as String?,nSPV: freezed == nSPV ? _self.nSPV : nSPV // ignore: cast_nullable_to_non_nullable
as String?,isPoSV: freezed == isPoSV ? _self.isPoSV : isPoSV // ignore: cast_nullable_to_non_nullable
as num?,versionGroupId: freezed == versionGroupId ? _self.versionGroupId : versionGroupId // ignore: cast_nullable_to_non_nullable
as String?,consensusBranchId: freezed == consensusBranchId ? _self.consensusBranchId : consensusBranchId // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeBlocks: freezed == estimateFeeBlocks ? _self.estimateFeeBlocks : estimateFeeBlocks // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}
/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolCopyWith<$Res>? get protocol {
    if (_self.protocol == null) {
    return null;
  }

  return $ProtocolCopyWith<$Res>(_self.protocol!, (value) {
    return _then(_self.copyWith(protocol: value));
  });
}/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinksCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $LinksCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressFormatCopyWith<$Res>? get addressFormat {
    if (_self.addressFormat == null) {
    return null;
  }

  return $AddressFormatCopyWith<$Res>(_self.addressFormat!, (value) {
    return _then(_self.copyWith(addressFormat: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Coin extends Coin {
  const _Coin({required this.coin, this.name, this.fname, this.rpcport, this.mm2, this.chainId, this.requiredConfirmations, this.avgBlocktime, this.decimals, this.protocol, this.derivationPath, this.trezorCoin, this.links, this.isPoS, this.pubtype, this.p2shtype, this.wiftype, this.txfee, this.dust, this.matureConfirmations, this.segwit, this.signMessagePrefix, this.asset, this.txversion, this.overwintered, this.requiresNotarization, this.walletOnly, this.bech32Hrp, this.isTestnet, this.forkId, this.signatureVersion, this.confpath, this.addressFormat, this.aliasTicker, this.estimateFeeMode, this.orderbookTicker, this.taddr, this.forceMinRelayFee, this.p2p, this.magic, this.nSPV, this.isPoSV, this.versionGroupId, this.consensusBranchId, this.estimateFeeBlocks}): super._();
  factory _Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);

@override final  String coin;
@override final  String? name;
@override final  String? fname;
@override final  num? rpcport;
@override final  num? mm2;
@override final  num? chainId;
@override final  num? requiredConfirmations;
@override final  num? avgBlocktime;
@override final  num? decimals;
@override final  Protocol? protocol;
@override final  String? derivationPath;
@override final  String? trezorCoin;
@override final  Links? links;
@override final  num? isPoS;
@override final  num? pubtype;
@override final  num? p2shtype;
@override final  num? wiftype;
@override final  num? txfee;
@override final  num? dust;
@override final  num? matureConfirmations;
@override final  bool? segwit;
@override final  String? signMessagePrefix;
@override final  String? asset;
@override final  num? txversion;
@override final  num? overwintered;
@override final  bool? requiresNotarization;
@override final  bool? walletOnly;
@override final  String? bech32Hrp;
@override final  bool? isTestnet;
@override final  String? forkId;
@override final  String? signatureVersion;
@override final  String? confpath;
@override final  AddressFormat? addressFormat;
@override final  String? aliasTicker;
@override final  String? estimateFeeMode;
@override final  String? orderbookTicker;
@override final  num? taddr;
@override final  bool? forceMinRelayFee;
@override final  num? p2p;
@override final  String? magic;
@override final  String? nSPV;
@override final  num? isPoSV;
@override final  String? versionGroupId;
@override final  String? consensusBranchId;
@override final  num? estimateFeeBlocks;

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoinCopyWith<_Coin> get copyWith => __$CoinCopyWithImpl<_Coin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoinToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coin&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.name, name) || other.name == name)&&(identical(other.fname, fname) || other.fname == fname)&&(identical(other.rpcport, rpcport) || other.rpcport == rpcport)&&(identical(other.mm2, mm2) || other.mm2 == mm2)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.requiredConfirmations, requiredConfirmations) || other.requiredConfirmations == requiredConfirmations)&&(identical(other.avgBlocktime, avgBlocktime) || other.avgBlocktime == avgBlocktime)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.derivationPath, derivationPath) || other.derivationPath == derivationPath)&&(identical(other.trezorCoin, trezorCoin) || other.trezorCoin == trezorCoin)&&(identical(other.links, links) || other.links == links)&&(identical(other.isPoS, isPoS) || other.isPoS == isPoS)&&(identical(other.pubtype, pubtype) || other.pubtype == pubtype)&&(identical(other.p2shtype, p2shtype) || other.p2shtype == p2shtype)&&(identical(other.wiftype, wiftype) || other.wiftype == wiftype)&&(identical(other.txfee, txfee) || other.txfee == txfee)&&(identical(other.dust, dust) || other.dust == dust)&&(identical(other.matureConfirmations, matureConfirmations) || other.matureConfirmations == matureConfirmations)&&(identical(other.segwit, segwit) || other.segwit == segwit)&&(identical(other.signMessagePrefix, signMessagePrefix) || other.signMessagePrefix == signMessagePrefix)&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.txversion, txversion) || other.txversion == txversion)&&(identical(other.overwintered, overwintered) || other.overwintered == overwintered)&&(identical(other.requiresNotarization, requiresNotarization) || other.requiresNotarization == requiresNotarization)&&(identical(other.walletOnly, walletOnly) || other.walletOnly == walletOnly)&&(identical(other.bech32Hrp, bech32Hrp) || other.bech32Hrp == bech32Hrp)&&(identical(other.isTestnet, isTestnet) || other.isTestnet == isTestnet)&&(identical(other.forkId, forkId) || other.forkId == forkId)&&(identical(other.signatureVersion, signatureVersion) || other.signatureVersion == signatureVersion)&&(identical(other.confpath, confpath) || other.confpath == confpath)&&(identical(other.addressFormat, addressFormat) || other.addressFormat == addressFormat)&&(identical(other.aliasTicker, aliasTicker) || other.aliasTicker == aliasTicker)&&(identical(other.estimateFeeMode, estimateFeeMode) || other.estimateFeeMode == estimateFeeMode)&&(identical(other.orderbookTicker, orderbookTicker) || other.orderbookTicker == orderbookTicker)&&(identical(other.taddr, taddr) || other.taddr == taddr)&&(identical(other.forceMinRelayFee, forceMinRelayFee) || other.forceMinRelayFee == forceMinRelayFee)&&(identical(other.p2p, p2p) || other.p2p == p2p)&&(identical(other.magic, magic) || other.magic == magic)&&(identical(other.nSPV, nSPV) || other.nSPV == nSPV)&&(identical(other.isPoSV, isPoSV) || other.isPoSV == isPoSV)&&(identical(other.versionGroupId, versionGroupId) || other.versionGroupId == versionGroupId)&&(identical(other.consensusBranchId, consensusBranchId) || other.consensusBranchId == consensusBranchId)&&(identical(other.estimateFeeBlocks, estimateFeeBlocks) || other.estimateFeeBlocks == estimateFeeBlocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,coin,name,fname,rpcport,mm2,chainId,requiredConfirmations,avgBlocktime,decimals,protocol,derivationPath,trezorCoin,links,isPoS,pubtype,p2shtype,wiftype,txfee,dust,matureConfirmations,segwit,signMessagePrefix,asset,txversion,overwintered,requiresNotarization,walletOnly,bech32Hrp,isTestnet,forkId,signatureVersion,confpath,addressFormat,aliasTicker,estimateFeeMode,orderbookTicker,taddr,forceMinRelayFee,p2p,magic,nSPV,isPoSV,versionGroupId,consensusBranchId,estimateFeeBlocks]);

@override
String toString() {
  return 'Coin(coin: $coin, name: $name, fname: $fname, rpcport: $rpcport, mm2: $mm2, chainId: $chainId, requiredConfirmations: $requiredConfirmations, avgBlocktime: $avgBlocktime, decimals: $decimals, protocol: $protocol, derivationPath: $derivationPath, trezorCoin: $trezorCoin, links: $links, isPoS: $isPoS, pubtype: $pubtype, p2shtype: $p2shtype, wiftype: $wiftype, txfee: $txfee, dust: $dust, matureConfirmations: $matureConfirmations, segwit: $segwit, signMessagePrefix: $signMessagePrefix, asset: $asset, txversion: $txversion, overwintered: $overwintered, requiresNotarization: $requiresNotarization, walletOnly: $walletOnly, bech32Hrp: $bech32Hrp, isTestnet: $isTestnet, forkId: $forkId, signatureVersion: $signatureVersion, confpath: $confpath, addressFormat: $addressFormat, aliasTicker: $aliasTicker, estimateFeeMode: $estimateFeeMode, orderbookTicker: $orderbookTicker, taddr: $taddr, forceMinRelayFee: $forceMinRelayFee, p2p: $p2p, magic: $magic, nSPV: $nSPV, isPoSV: $isPoSV, versionGroupId: $versionGroupId, consensusBranchId: $consensusBranchId, estimateFeeBlocks: $estimateFeeBlocks)';
}


}

/// @nodoc
abstract mixin class _$CoinCopyWith<$Res> implements $CoinCopyWith<$Res> {
  factory _$CoinCopyWith(_Coin value, $Res Function(_Coin) _then) = __$CoinCopyWithImpl;
@override @useResult
$Res call({
 String coin, String? name, String? fname, num? rpcport, num? mm2, num? chainId, num? requiredConfirmations, num? avgBlocktime, num? decimals, Protocol? protocol, String? derivationPath, String? trezorCoin, Links? links, num? isPoS, num? pubtype, num? p2shtype, num? wiftype, num? txfee, num? dust, num? matureConfirmations, bool? segwit, String? signMessagePrefix, String? asset, num? txversion, num? overwintered, bool? requiresNotarization, bool? walletOnly, String? bech32Hrp, bool? isTestnet, String? forkId, String? signatureVersion, String? confpath, AddressFormat? addressFormat, String? aliasTicker, String? estimateFeeMode, String? orderbookTicker, num? taddr, bool? forceMinRelayFee, num? p2p, String? magic, String? nSPV, num? isPoSV, String? versionGroupId, String? consensusBranchId, num? estimateFeeBlocks
});


@override $ProtocolCopyWith<$Res>? get protocol;@override $LinksCopyWith<$Res>? get links;@override $AddressFormatCopyWith<$Res>? get addressFormat;

}
/// @nodoc
class __$CoinCopyWithImpl<$Res>
    implements _$CoinCopyWith<$Res> {
  __$CoinCopyWithImpl(this._self, this._then);

  final _Coin _self;
  final $Res Function(_Coin) _then;

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? name = freezed,Object? fname = freezed,Object? rpcport = freezed,Object? mm2 = freezed,Object? chainId = freezed,Object? requiredConfirmations = freezed,Object? avgBlocktime = freezed,Object? decimals = freezed,Object? protocol = freezed,Object? derivationPath = freezed,Object? trezorCoin = freezed,Object? links = freezed,Object? isPoS = freezed,Object? pubtype = freezed,Object? p2shtype = freezed,Object? wiftype = freezed,Object? txfee = freezed,Object? dust = freezed,Object? matureConfirmations = freezed,Object? segwit = freezed,Object? signMessagePrefix = freezed,Object? asset = freezed,Object? txversion = freezed,Object? overwintered = freezed,Object? requiresNotarization = freezed,Object? walletOnly = freezed,Object? bech32Hrp = freezed,Object? isTestnet = freezed,Object? forkId = freezed,Object? signatureVersion = freezed,Object? confpath = freezed,Object? addressFormat = freezed,Object? aliasTicker = freezed,Object? estimateFeeMode = freezed,Object? orderbookTicker = freezed,Object? taddr = freezed,Object? forceMinRelayFee = freezed,Object? p2p = freezed,Object? magic = freezed,Object? nSPV = freezed,Object? isPoSV = freezed,Object? versionGroupId = freezed,Object? consensusBranchId = freezed,Object? estimateFeeBlocks = freezed,}) {
  return _then(_Coin(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,fname: freezed == fname ? _self.fname : fname // ignore: cast_nullable_to_non_nullable
as String?,rpcport: freezed == rpcport ? _self.rpcport : rpcport // ignore: cast_nullable_to_non_nullable
as num?,mm2: freezed == mm2 ? _self.mm2 : mm2 // ignore: cast_nullable_to_non_nullable
as num?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as num?,requiredConfirmations: freezed == requiredConfirmations ? _self.requiredConfirmations : requiredConfirmations // ignore: cast_nullable_to_non_nullable
as num?,avgBlocktime: freezed == avgBlocktime ? _self.avgBlocktime : avgBlocktime // ignore: cast_nullable_to_non_nullable
as num?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as num?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as Protocol?,derivationPath: freezed == derivationPath ? _self.derivationPath : derivationPath // ignore: cast_nullable_to_non_nullable
as String?,trezorCoin: freezed == trezorCoin ? _self.trezorCoin : trezorCoin // ignore: cast_nullable_to_non_nullable
as String?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as Links?,isPoS: freezed == isPoS ? _self.isPoS : isPoS // ignore: cast_nullable_to_non_nullable
as num?,pubtype: freezed == pubtype ? _self.pubtype : pubtype // ignore: cast_nullable_to_non_nullable
as num?,p2shtype: freezed == p2shtype ? _self.p2shtype : p2shtype // ignore: cast_nullable_to_non_nullable
as num?,wiftype: freezed == wiftype ? _self.wiftype : wiftype // ignore: cast_nullable_to_non_nullable
as num?,txfee: freezed == txfee ? _self.txfee : txfee // ignore: cast_nullable_to_non_nullable
as num?,dust: freezed == dust ? _self.dust : dust // ignore: cast_nullable_to_non_nullable
as num?,matureConfirmations: freezed == matureConfirmations ? _self.matureConfirmations : matureConfirmations // ignore: cast_nullable_to_non_nullable
as num?,segwit: freezed == segwit ? _self.segwit : segwit // ignore: cast_nullable_to_non_nullable
as bool?,signMessagePrefix: freezed == signMessagePrefix ? _self.signMessagePrefix : signMessagePrefix // ignore: cast_nullable_to_non_nullable
as String?,asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String?,txversion: freezed == txversion ? _self.txversion : txversion // ignore: cast_nullable_to_non_nullable
as num?,overwintered: freezed == overwintered ? _self.overwintered : overwintered // ignore: cast_nullable_to_non_nullable
as num?,requiresNotarization: freezed == requiresNotarization ? _self.requiresNotarization : requiresNotarization // ignore: cast_nullable_to_non_nullable
as bool?,walletOnly: freezed == walletOnly ? _self.walletOnly : walletOnly // ignore: cast_nullable_to_non_nullable
as bool?,bech32Hrp: freezed == bech32Hrp ? _self.bech32Hrp : bech32Hrp // ignore: cast_nullable_to_non_nullable
as String?,isTestnet: freezed == isTestnet ? _self.isTestnet : isTestnet // ignore: cast_nullable_to_non_nullable
as bool?,forkId: freezed == forkId ? _self.forkId : forkId // ignore: cast_nullable_to_non_nullable
as String?,signatureVersion: freezed == signatureVersion ? _self.signatureVersion : signatureVersion // ignore: cast_nullable_to_non_nullable
as String?,confpath: freezed == confpath ? _self.confpath : confpath // ignore: cast_nullable_to_non_nullable
as String?,addressFormat: freezed == addressFormat ? _self.addressFormat : addressFormat // ignore: cast_nullable_to_non_nullable
as AddressFormat?,aliasTicker: freezed == aliasTicker ? _self.aliasTicker : aliasTicker // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeMode: freezed == estimateFeeMode ? _self.estimateFeeMode : estimateFeeMode // ignore: cast_nullable_to_non_nullable
as String?,orderbookTicker: freezed == orderbookTicker ? _self.orderbookTicker : orderbookTicker // ignore: cast_nullable_to_non_nullable
as String?,taddr: freezed == taddr ? _self.taddr : taddr // ignore: cast_nullable_to_non_nullable
as num?,forceMinRelayFee: freezed == forceMinRelayFee ? _self.forceMinRelayFee : forceMinRelayFee // ignore: cast_nullable_to_non_nullable
as bool?,p2p: freezed == p2p ? _self.p2p : p2p // ignore: cast_nullable_to_non_nullable
as num?,magic: freezed == magic ? _self.magic : magic // ignore: cast_nullable_to_non_nullable
as String?,nSPV: freezed == nSPV ? _self.nSPV : nSPV // ignore: cast_nullable_to_non_nullable
as String?,isPoSV: freezed == isPoSV ? _self.isPoSV : isPoSV // ignore: cast_nullable_to_non_nullable
as num?,versionGroupId: freezed == versionGroupId ? _self.versionGroupId : versionGroupId // ignore: cast_nullable_to_non_nullable
as String?,consensusBranchId: freezed == consensusBranchId ? _self.consensusBranchId : consensusBranchId // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeBlocks: freezed == estimateFeeBlocks ? _self.estimateFeeBlocks : estimateFeeBlocks // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProtocolCopyWith<$Res>? get protocol {
    if (_self.protocol == null) {
    return null;
  }

  return $ProtocolCopyWith<$Res>(_self.protocol!, (value) {
    return _then(_self.copyWith(protocol: value));
  });
}/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinksCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $LinksCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressFormatCopyWith<$Res>? get addressFormat {
    if (_self.addressFormat == null) {
    return null;
  }

  return $AddressFormatCopyWith<$Res>(_self.addressFormat!, (value) {
    return _then(_self.copyWith(addressFormat: value));
  });
}
}

// dart format on
