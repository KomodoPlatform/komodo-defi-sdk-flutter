// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coin_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoinConfig {

 String get coin; String? get type; String? get name; String? get coingeckoId; String? get livecoinwatchId; String? get explorerUrl; String? get explorerTxUrl; String? get explorerAddressUrl; List<String>? get supported; bool? get active; bool? get isTestnet; bool? get currentlyEnabled; bool? get walletOnly; String? get fname; num? get rpcport; num? get mm2; num? get chainId; num? get requiredConfirmations; num? get avgBlocktime; num? get decimals; Protocol? get protocol; String? get derivationPath; String? get contractAddress; String? get parentCoin; String? get swapContractAddress; String? get fallbackSwapContract; List<Node>? get nodes; String? get explorerBlockUrl; String? get tokenAddressUrl; String? get trezorCoin; Links? get links; num? get pubtype; num? get p2shtype; num? get wiftype; num? get txfee; num? get dust; bool? get segwit; List<Electrum>? get electrum; String? get signMessagePrefix; List<String>? get lightWalletDServers; String? get asset; num? get txversion; num? get overwintered; bool? get requiresNotarization; num? get checkpointHeight; num? get checkpointBlocktime; String? get binanceId; String? get bech32Hrp; String? get forkId; String? get signatureVersion; String? get confpath; num? get matureConfirmations; List<String>? get bchdUrls; List<String>? get otherTypes; AddressFormat? get addressFormat; bool? get allowSlpUnsafeConf; String? get slpPrefix; String? get tokenId; String? get forexId; num? get isPoS; String? get aliasTicker; String? get estimateFeeMode; String? get orderbookTicker; num? get taddr; bool? get forceMinRelayFee; bool? get isClaimable; String? get minimalClaimAmount; num? get isPoSV; String? get versionGroupId; String? get consensusBranchId; num? get estimateFeeBlocks; List<RpcUrl>? get rpcUrls;
/// Create a copy of CoinConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoinConfigCopyWith<CoinConfig> get copyWith => _$CoinConfigCopyWithImpl<CoinConfig>(this as CoinConfig, _$identity);

  /// Serializes this CoinConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoinConfig&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.coingeckoId, coingeckoId) || other.coingeckoId == coingeckoId)&&(identical(other.livecoinwatchId, livecoinwatchId) || other.livecoinwatchId == livecoinwatchId)&&(identical(other.explorerUrl, explorerUrl) || other.explorerUrl == explorerUrl)&&(identical(other.explorerTxUrl, explorerTxUrl) || other.explorerTxUrl == explorerTxUrl)&&(identical(other.explorerAddressUrl, explorerAddressUrl) || other.explorerAddressUrl == explorerAddressUrl)&&const DeepCollectionEquality().equals(other.supported, supported)&&(identical(other.active, active) || other.active == active)&&(identical(other.isTestnet, isTestnet) || other.isTestnet == isTestnet)&&(identical(other.currentlyEnabled, currentlyEnabled) || other.currentlyEnabled == currentlyEnabled)&&(identical(other.walletOnly, walletOnly) || other.walletOnly == walletOnly)&&(identical(other.fname, fname) || other.fname == fname)&&(identical(other.rpcport, rpcport) || other.rpcport == rpcport)&&(identical(other.mm2, mm2) || other.mm2 == mm2)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.requiredConfirmations, requiredConfirmations) || other.requiredConfirmations == requiredConfirmations)&&(identical(other.avgBlocktime, avgBlocktime) || other.avgBlocktime == avgBlocktime)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.derivationPath, derivationPath) || other.derivationPath == derivationPath)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.parentCoin, parentCoin) || other.parentCoin == parentCoin)&&(identical(other.swapContractAddress, swapContractAddress) || other.swapContractAddress == swapContractAddress)&&(identical(other.fallbackSwapContract, fallbackSwapContract) || other.fallbackSwapContract == fallbackSwapContract)&&const DeepCollectionEquality().equals(other.nodes, nodes)&&(identical(other.explorerBlockUrl, explorerBlockUrl) || other.explorerBlockUrl == explorerBlockUrl)&&(identical(other.tokenAddressUrl, tokenAddressUrl) || other.tokenAddressUrl == tokenAddressUrl)&&(identical(other.trezorCoin, trezorCoin) || other.trezorCoin == trezorCoin)&&(identical(other.links, links) || other.links == links)&&(identical(other.pubtype, pubtype) || other.pubtype == pubtype)&&(identical(other.p2shtype, p2shtype) || other.p2shtype == p2shtype)&&(identical(other.wiftype, wiftype) || other.wiftype == wiftype)&&(identical(other.txfee, txfee) || other.txfee == txfee)&&(identical(other.dust, dust) || other.dust == dust)&&(identical(other.segwit, segwit) || other.segwit == segwit)&&const DeepCollectionEquality().equals(other.electrum, electrum)&&(identical(other.signMessagePrefix, signMessagePrefix) || other.signMessagePrefix == signMessagePrefix)&&const DeepCollectionEquality().equals(other.lightWalletDServers, lightWalletDServers)&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.txversion, txversion) || other.txversion == txversion)&&(identical(other.overwintered, overwintered) || other.overwintered == overwintered)&&(identical(other.requiresNotarization, requiresNotarization) || other.requiresNotarization == requiresNotarization)&&(identical(other.checkpointHeight, checkpointHeight) || other.checkpointHeight == checkpointHeight)&&(identical(other.checkpointBlocktime, checkpointBlocktime) || other.checkpointBlocktime == checkpointBlocktime)&&(identical(other.binanceId, binanceId) || other.binanceId == binanceId)&&(identical(other.bech32Hrp, bech32Hrp) || other.bech32Hrp == bech32Hrp)&&(identical(other.forkId, forkId) || other.forkId == forkId)&&(identical(other.signatureVersion, signatureVersion) || other.signatureVersion == signatureVersion)&&(identical(other.confpath, confpath) || other.confpath == confpath)&&(identical(other.matureConfirmations, matureConfirmations) || other.matureConfirmations == matureConfirmations)&&const DeepCollectionEquality().equals(other.bchdUrls, bchdUrls)&&const DeepCollectionEquality().equals(other.otherTypes, otherTypes)&&(identical(other.addressFormat, addressFormat) || other.addressFormat == addressFormat)&&(identical(other.allowSlpUnsafeConf, allowSlpUnsafeConf) || other.allowSlpUnsafeConf == allowSlpUnsafeConf)&&(identical(other.slpPrefix, slpPrefix) || other.slpPrefix == slpPrefix)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.forexId, forexId) || other.forexId == forexId)&&(identical(other.isPoS, isPoS) || other.isPoS == isPoS)&&(identical(other.aliasTicker, aliasTicker) || other.aliasTicker == aliasTicker)&&(identical(other.estimateFeeMode, estimateFeeMode) || other.estimateFeeMode == estimateFeeMode)&&(identical(other.orderbookTicker, orderbookTicker) || other.orderbookTicker == orderbookTicker)&&(identical(other.taddr, taddr) || other.taddr == taddr)&&(identical(other.forceMinRelayFee, forceMinRelayFee) || other.forceMinRelayFee == forceMinRelayFee)&&(identical(other.isClaimable, isClaimable) || other.isClaimable == isClaimable)&&(identical(other.minimalClaimAmount, minimalClaimAmount) || other.minimalClaimAmount == minimalClaimAmount)&&(identical(other.isPoSV, isPoSV) || other.isPoSV == isPoSV)&&(identical(other.versionGroupId, versionGroupId) || other.versionGroupId == versionGroupId)&&(identical(other.consensusBranchId, consensusBranchId) || other.consensusBranchId == consensusBranchId)&&(identical(other.estimateFeeBlocks, estimateFeeBlocks) || other.estimateFeeBlocks == estimateFeeBlocks)&&const DeepCollectionEquality().equals(other.rpcUrls, rpcUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,coin,type,name,coingeckoId,livecoinwatchId,explorerUrl,explorerTxUrl,explorerAddressUrl,const DeepCollectionEquality().hash(supported),active,isTestnet,currentlyEnabled,walletOnly,fname,rpcport,mm2,chainId,requiredConfirmations,avgBlocktime,decimals,protocol,derivationPath,contractAddress,parentCoin,swapContractAddress,fallbackSwapContract,const DeepCollectionEquality().hash(nodes),explorerBlockUrl,tokenAddressUrl,trezorCoin,links,pubtype,p2shtype,wiftype,txfee,dust,segwit,const DeepCollectionEquality().hash(electrum),signMessagePrefix,const DeepCollectionEquality().hash(lightWalletDServers),asset,txversion,overwintered,requiresNotarization,checkpointHeight,checkpointBlocktime,binanceId,bech32Hrp,forkId,signatureVersion,confpath,matureConfirmations,const DeepCollectionEquality().hash(bchdUrls),const DeepCollectionEquality().hash(otherTypes),addressFormat,allowSlpUnsafeConf,slpPrefix,tokenId,forexId,isPoS,aliasTicker,estimateFeeMode,orderbookTicker,taddr,forceMinRelayFee,isClaimable,minimalClaimAmount,isPoSV,versionGroupId,consensusBranchId,estimateFeeBlocks,const DeepCollectionEquality().hash(rpcUrls)]);

@override
String toString() {
  return 'CoinConfig(coin: $coin, type: $type, name: $name, coingeckoId: $coingeckoId, livecoinwatchId: $livecoinwatchId, explorerUrl: $explorerUrl, explorerTxUrl: $explorerTxUrl, explorerAddressUrl: $explorerAddressUrl, supported: $supported, active: $active, isTestnet: $isTestnet, currentlyEnabled: $currentlyEnabled, walletOnly: $walletOnly, fname: $fname, rpcport: $rpcport, mm2: $mm2, chainId: $chainId, requiredConfirmations: $requiredConfirmations, avgBlocktime: $avgBlocktime, decimals: $decimals, protocol: $protocol, derivationPath: $derivationPath, contractAddress: $contractAddress, parentCoin: $parentCoin, swapContractAddress: $swapContractAddress, fallbackSwapContract: $fallbackSwapContract, nodes: $nodes, explorerBlockUrl: $explorerBlockUrl, tokenAddressUrl: $tokenAddressUrl, trezorCoin: $trezorCoin, links: $links, pubtype: $pubtype, p2shtype: $p2shtype, wiftype: $wiftype, txfee: $txfee, dust: $dust, segwit: $segwit, electrum: $electrum, signMessagePrefix: $signMessagePrefix, lightWalletDServers: $lightWalletDServers, asset: $asset, txversion: $txversion, overwintered: $overwintered, requiresNotarization: $requiresNotarization, checkpointHeight: $checkpointHeight, checkpointBlocktime: $checkpointBlocktime, binanceId: $binanceId, bech32Hrp: $bech32Hrp, forkId: $forkId, signatureVersion: $signatureVersion, confpath: $confpath, matureConfirmations: $matureConfirmations, bchdUrls: $bchdUrls, otherTypes: $otherTypes, addressFormat: $addressFormat, allowSlpUnsafeConf: $allowSlpUnsafeConf, slpPrefix: $slpPrefix, tokenId: $tokenId, forexId: $forexId, isPoS: $isPoS, aliasTicker: $aliasTicker, estimateFeeMode: $estimateFeeMode, orderbookTicker: $orderbookTicker, taddr: $taddr, forceMinRelayFee: $forceMinRelayFee, isClaimable: $isClaimable, minimalClaimAmount: $minimalClaimAmount, isPoSV: $isPoSV, versionGroupId: $versionGroupId, consensusBranchId: $consensusBranchId, estimateFeeBlocks: $estimateFeeBlocks, rpcUrls: $rpcUrls)';
}


}

/// @nodoc
abstract mixin class $CoinConfigCopyWith<$Res>  {
  factory $CoinConfigCopyWith(CoinConfig value, $Res Function(CoinConfig) _then) = _$CoinConfigCopyWithImpl;
@useResult
$Res call({
 String coin, String? type, String? name, String? coingeckoId, String? livecoinwatchId, String? explorerUrl, String? explorerTxUrl, String? explorerAddressUrl, List<String>? supported, bool? active, bool? isTestnet, bool? currentlyEnabled, bool? walletOnly, String? fname, num? rpcport, num? mm2, num? chainId, num? requiredConfirmations, num? avgBlocktime, num? decimals, Protocol? protocol, String? derivationPath, String? contractAddress, String? parentCoin, String? swapContractAddress, String? fallbackSwapContract, List<Node>? nodes, String? explorerBlockUrl, String? tokenAddressUrl, String? trezorCoin, Links? links, num? pubtype, num? p2shtype, num? wiftype, num? txfee, num? dust, bool? segwit, List<Electrum>? electrum, String? signMessagePrefix, List<String>? lightWalletDServers, String? asset, num? txversion, num? overwintered, bool? requiresNotarization, num? checkpointHeight, num? checkpointBlocktime, String? binanceId, String? bech32Hrp, String? forkId, String? signatureVersion, String? confpath, num? matureConfirmations, List<String>? bchdUrls, List<String>? otherTypes, AddressFormat? addressFormat, bool? allowSlpUnsafeConf, String? slpPrefix, String? tokenId, String? forexId, num? isPoS, String? aliasTicker, String? estimateFeeMode, String? orderbookTicker, num? taddr, bool? forceMinRelayFee, bool? isClaimable, String? minimalClaimAmount, num? isPoSV, String? versionGroupId, String? consensusBranchId, num? estimateFeeBlocks, List<RpcUrl>? rpcUrls
});


$ProtocolCopyWith<$Res>? get protocol;$LinksCopyWith<$Res>? get links;$AddressFormatCopyWith<$Res>? get addressFormat;

}
/// @nodoc
class _$CoinConfigCopyWithImpl<$Res>
    implements $CoinConfigCopyWith<$Res> {
  _$CoinConfigCopyWithImpl(this._self, this._then);

  final CoinConfig _self;
  final $Res Function(CoinConfig) _then;

/// Create a copy of CoinConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? type = freezed,Object? name = freezed,Object? coingeckoId = freezed,Object? livecoinwatchId = freezed,Object? explorerUrl = freezed,Object? explorerTxUrl = freezed,Object? explorerAddressUrl = freezed,Object? supported = freezed,Object? active = freezed,Object? isTestnet = freezed,Object? currentlyEnabled = freezed,Object? walletOnly = freezed,Object? fname = freezed,Object? rpcport = freezed,Object? mm2 = freezed,Object? chainId = freezed,Object? requiredConfirmations = freezed,Object? avgBlocktime = freezed,Object? decimals = freezed,Object? protocol = freezed,Object? derivationPath = freezed,Object? contractAddress = freezed,Object? parentCoin = freezed,Object? swapContractAddress = freezed,Object? fallbackSwapContract = freezed,Object? nodes = freezed,Object? explorerBlockUrl = freezed,Object? tokenAddressUrl = freezed,Object? trezorCoin = freezed,Object? links = freezed,Object? pubtype = freezed,Object? p2shtype = freezed,Object? wiftype = freezed,Object? txfee = freezed,Object? dust = freezed,Object? segwit = freezed,Object? electrum = freezed,Object? signMessagePrefix = freezed,Object? lightWalletDServers = freezed,Object? asset = freezed,Object? txversion = freezed,Object? overwintered = freezed,Object? requiresNotarization = freezed,Object? checkpointHeight = freezed,Object? checkpointBlocktime = freezed,Object? binanceId = freezed,Object? bech32Hrp = freezed,Object? forkId = freezed,Object? signatureVersion = freezed,Object? confpath = freezed,Object? matureConfirmations = freezed,Object? bchdUrls = freezed,Object? otherTypes = freezed,Object? addressFormat = freezed,Object? allowSlpUnsafeConf = freezed,Object? slpPrefix = freezed,Object? tokenId = freezed,Object? forexId = freezed,Object? isPoS = freezed,Object? aliasTicker = freezed,Object? estimateFeeMode = freezed,Object? orderbookTicker = freezed,Object? taddr = freezed,Object? forceMinRelayFee = freezed,Object? isClaimable = freezed,Object? minimalClaimAmount = freezed,Object? isPoSV = freezed,Object? versionGroupId = freezed,Object? consensusBranchId = freezed,Object? estimateFeeBlocks = freezed,Object? rpcUrls = freezed,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,coingeckoId: freezed == coingeckoId ? _self.coingeckoId : coingeckoId // ignore: cast_nullable_to_non_nullable
as String?,livecoinwatchId: freezed == livecoinwatchId ? _self.livecoinwatchId : livecoinwatchId // ignore: cast_nullable_to_non_nullable
as String?,explorerUrl: freezed == explorerUrl ? _self.explorerUrl : explorerUrl // ignore: cast_nullable_to_non_nullable
as String?,explorerTxUrl: freezed == explorerTxUrl ? _self.explorerTxUrl : explorerTxUrl // ignore: cast_nullable_to_non_nullable
as String?,explorerAddressUrl: freezed == explorerAddressUrl ? _self.explorerAddressUrl : explorerAddressUrl // ignore: cast_nullable_to_non_nullable
as String?,supported: freezed == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as List<String>?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,isTestnet: freezed == isTestnet ? _self.isTestnet : isTestnet // ignore: cast_nullable_to_non_nullable
as bool?,currentlyEnabled: freezed == currentlyEnabled ? _self.currentlyEnabled : currentlyEnabled // ignore: cast_nullable_to_non_nullable
as bool?,walletOnly: freezed == walletOnly ? _self.walletOnly : walletOnly // ignore: cast_nullable_to_non_nullable
as bool?,fname: freezed == fname ? _self.fname : fname // ignore: cast_nullable_to_non_nullable
as String?,rpcport: freezed == rpcport ? _self.rpcport : rpcport // ignore: cast_nullable_to_non_nullable
as num?,mm2: freezed == mm2 ? _self.mm2 : mm2 // ignore: cast_nullable_to_non_nullable
as num?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as num?,requiredConfirmations: freezed == requiredConfirmations ? _self.requiredConfirmations : requiredConfirmations // ignore: cast_nullable_to_non_nullable
as num?,avgBlocktime: freezed == avgBlocktime ? _self.avgBlocktime : avgBlocktime // ignore: cast_nullable_to_non_nullable
as num?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as num?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as Protocol?,derivationPath: freezed == derivationPath ? _self.derivationPath : derivationPath // ignore: cast_nullable_to_non_nullable
as String?,contractAddress: freezed == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String?,parentCoin: freezed == parentCoin ? _self.parentCoin : parentCoin // ignore: cast_nullable_to_non_nullable
as String?,swapContractAddress: freezed == swapContractAddress ? _self.swapContractAddress : swapContractAddress // ignore: cast_nullable_to_non_nullable
as String?,fallbackSwapContract: freezed == fallbackSwapContract ? _self.fallbackSwapContract : fallbackSwapContract // ignore: cast_nullable_to_non_nullable
as String?,nodes: freezed == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<Node>?,explorerBlockUrl: freezed == explorerBlockUrl ? _self.explorerBlockUrl : explorerBlockUrl // ignore: cast_nullable_to_non_nullable
as String?,tokenAddressUrl: freezed == tokenAddressUrl ? _self.tokenAddressUrl : tokenAddressUrl // ignore: cast_nullable_to_non_nullable
as String?,trezorCoin: freezed == trezorCoin ? _self.trezorCoin : trezorCoin // ignore: cast_nullable_to_non_nullable
as String?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as Links?,pubtype: freezed == pubtype ? _self.pubtype : pubtype // ignore: cast_nullable_to_non_nullable
as num?,p2shtype: freezed == p2shtype ? _self.p2shtype : p2shtype // ignore: cast_nullable_to_non_nullable
as num?,wiftype: freezed == wiftype ? _self.wiftype : wiftype // ignore: cast_nullable_to_non_nullable
as num?,txfee: freezed == txfee ? _self.txfee : txfee // ignore: cast_nullable_to_non_nullable
as num?,dust: freezed == dust ? _self.dust : dust // ignore: cast_nullable_to_non_nullable
as num?,segwit: freezed == segwit ? _self.segwit : segwit // ignore: cast_nullable_to_non_nullable
as bool?,electrum: freezed == electrum ? _self.electrum : electrum // ignore: cast_nullable_to_non_nullable
as List<Electrum>?,signMessagePrefix: freezed == signMessagePrefix ? _self.signMessagePrefix : signMessagePrefix // ignore: cast_nullable_to_non_nullable
as String?,lightWalletDServers: freezed == lightWalletDServers ? _self.lightWalletDServers : lightWalletDServers // ignore: cast_nullable_to_non_nullable
as List<String>?,asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String?,txversion: freezed == txversion ? _self.txversion : txversion // ignore: cast_nullable_to_non_nullable
as num?,overwintered: freezed == overwintered ? _self.overwintered : overwintered // ignore: cast_nullable_to_non_nullable
as num?,requiresNotarization: freezed == requiresNotarization ? _self.requiresNotarization : requiresNotarization // ignore: cast_nullable_to_non_nullable
as bool?,checkpointHeight: freezed == checkpointHeight ? _self.checkpointHeight : checkpointHeight // ignore: cast_nullable_to_non_nullable
as num?,checkpointBlocktime: freezed == checkpointBlocktime ? _self.checkpointBlocktime : checkpointBlocktime // ignore: cast_nullable_to_non_nullable
as num?,binanceId: freezed == binanceId ? _self.binanceId : binanceId // ignore: cast_nullable_to_non_nullable
as String?,bech32Hrp: freezed == bech32Hrp ? _self.bech32Hrp : bech32Hrp // ignore: cast_nullable_to_non_nullable
as String?,forkId: freezed == forkId ? _self.forkId : forkId // ignore: cast_nullable_to_non_nullable
as String?,signatureVersion: freezed == signatureVersion ? _self.signatureVersion : signatureVersion // ignore: cast_nullable_to_non_nullable
as String?,confpath: freezed == confpath ? _self.confpath : confpath // ignore: cast_nullable_to_non_nullable
as String?,matureConfirmations: freezed == matureConfirmations ? _self.matureConfirmations : matureConfirmations // ignore: cast_nullable_to_non_nullable
as num?,bchdUrls: freezed == bchdUrls ? _self.bchdUrls : bchdUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,otherTypes: freezed == otherTypes ? _self.otherTypes : otherTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,addressFormat: freezed == addressFormat ? _self.addressFormat : addressFormat // ignore: cast_nullable_to_non_nullable
as AddressFormat?,allowSlpUnsafeConf: freezed == allowSlpUnsafeConf ? _self.allowSlpUnsafeConf : allowSlpUnsafeConf // ignore: cast_nullable_to_non_nullable
as bool?,slpPrefix: freezed == slpPrefix ? _self.slpPrefix : slpPrefix // ignore: cast_nullable_to_non_nullable
as String?,tokenId: freezed == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String?,forexId: freezed == forexId ? _self.forexId : forexId // ignore: cast_nullable_to_non_nullable
as String?,isPoS: freezed == isPoS ? _self.isPoS : isPoS // ignore: cast_nullable_to_non_nullable
as num?,aliasTicker: freezed == aliasTicker ? _self.aliasTicker : aliasTicker // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeMode: freezed == estimateFeeMode ? _self.estimateFeeMode : estimateFeeMode // ignore: cast_nullable_to_non_nullable
as String?,orderbookTicker: freezed == orderbookTicker ? _self.orderbookTicker : orderbookTicker // ignore: cast_nullable_to_non_nullable
as String?,taddr: freezed == taddr ? _self.taddr : taddr // ignore: cast_nullable_to_non_nullable
as num?,forceMinRelayFee: freezed == forceMinRelayFee ? _self.forceMinRelayFee : forceMinRelayFee // ignore: cast_nullable_to_non_nullable
as bool?,isClaimable: freezed == isClaimable ? _self.isClaimable : isClaimable // ignore: cast_nullable_to_non_nullable
as bool?,minimalClaimAmount: freezed == minimalClaimAmount ? _self.minimalClaimAmount : minimalClaimAmount // ignore: cast_nullable_to_non_nullable
as String?,isPoSV: freezed == isPoSV ? _self.isPoSV : isPoSV // ignore: cast_nullable_to_non_nullable
as num?,versionGroupId: freezed == versionGroupId ? _self.versionGroupId : versionGroupId // ignore: cast_nullable_to_non_nullable
as String?,consensusBranchId: freezed == consensusBranchId ? _self.consensusBranchId : consensusBranchId // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeBlocks: freezed == estimateFeeBlocks ? _self.estimateFeeBlocks : estimateFeeBlocks // ignore: cast_nullable_to_non_nullable
as num?,rpcUrls: freezed == rpcUrls ? _self.rpcUrls : rpcUrls // ignore: cast_nullable_to_non_nullable
as List<RpcUrl>?,
  ));
}
/// Create a copy of CoinConfig
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
}/// Create a copy of CoinConfig
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
}/// Create a copy of CoinConfig
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

class _CoinConfig extends CoinConfig {
  const _CoinConfig({required this.coin, this.type, this.name, this.coingeckoId, this.livecoinwatchId, this.explorerUrl, this.explorerTxUrl, this.explorerAddressUrl, final  List<String>? supported, this.active, this.isTestnet, this.currentlyEnabled, this.walletOnly, this.fname, this.rpcport, this.mm2, this.chainId, this.requiredConfirmations, this.avgBlocktime, this.decimals, this.protocol, this.derivationPath, this.contractAddress, this.parentCoin, this.swapContractAddress, this.fallbackSwapContract, final  List<Node>? nodes, this.explorerBlockUrl, this.tokenAddressUrl, this.trezorCoin, this.links, this.pubtype, this.p2shtype, this.wiftype, this.txfee, this.dust, this.segwit, final  List<Electrum>? electrum, this.signMessagePrefix, final  List<String>? lightWalletDServers, this.asset, this.txversion, this.overwintered, this.requiresNotarization, this.checkpointHeight, this.checkpointBlocktime, this.binanceId, this.bech32Hrp, this.forkId, this.signatureVersion, this.confpath, this.matureConfirmations, final  List<String>? bchdUrls, final  List<String>? otherTypes, this.addressFormat, this.allowSlpUnsafeConf, this.slpPrefix, this.tokenId, this.forexId, this.isPoS, this.aliasTicker, this.estimateFeeMode, this.orderbookTicker, this.taddr, this.forceMinRelayFee, this.isClaimable, this.minimalClaimAmount, this.isPoSV, this.versionGroupId, this.consensusBranchId, this.estimateFeeBlocks, final  List<RpcUrl>? rpcUrls}): _supported = supported,_nodes = nodes,_electrum = electrum,_lightWalletDServers = lightWalletDServers,_bchdUrls = bchdUrls,_otherTypes = otherTypes,_rpcUrls = rpcUrls,super._();
  factory _CoinConfig.fromJson(Map<String, dynamic> json) => _$CoinConfigFromJson(json);

@override final  String coin;
@override final  String? type;
@override final  String? name;
@override final  String? coingeckoId;
@override final  String? livecoinwatchId;
@override final  String? explorerUrl;
@override final  String? explorerTxUrl;
@override final  String? explorerAddressUrl;
 final  List<String>? _supported;
@override List<String>? get supported {
  final value = _supported;
  if (value == null) return null;
  if (_supported is EqualUnmodifiableListView) return _supported;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? active;
@override final  bool? isTestnet;
@override final  bool? currentlyEnabled;
@override final  bool? walletOnly;
@override final  String? fname;
@override final  num? rpcport;
@override final  num? mm2;
@override final  num? chainId;
@override final  num? requiredConfirmations;
@override final  num? avgBlocktime;
@override final  num? decimals;
@override final  Protocol? protocol;
@override final  String? derivationPath;
@override final  String? contractAddress;
@override final  String? parentCoin;
@override final  String? swapContractAddress;
@override final  String? fallbackSwapContract;
 final  List<Node>? _nodes;
@override List<Node>? get nodes {
  final value = _nodes;
  if (value == null) return null;
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? explorerBlockUrl;
@override final  String? tokenAddressUrl;
@override final  String? trezorCoin;
@override final  Links? links;
@override final  num? pubtype;
@override final  num? p2shtype;
@override final  num? wiftype;
@override final  num? txfee;
@override final  num? dust;
@override final  bool? segwit;
 final  List<Electrum>? _electrum;
@override List<Electrum>? get electrum {
  final value = _electrum;
  if (value == null) return null;
  if (_electrum is EqualUnmodifiableListView) return _electrum;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? signMessagePrefix;
 final  List<String>? _lightWalletDServers;
@override List<String>? get lightWalletDServers {
  final value = _lightWalletDServers;
  if (value == null) return null;
  if (_lightWalletDServers is EqualUnmodifiableListView) return _lightWalletDServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? asset;
@override final  num? txversion;
@override final  num? overwintered;
@override final  bool? requiresNotarization;
@override final  num? checkpointHeight;
@override final  num? checkpointBlocktime;
@override final  String? binanceId;
@override final  String? bech32Hrp;
@override final  String? forkId;
@override final  String? signatureVersion;
@override final  String? confpath;
@override final  num? matureConfirmations;
 final  List<String>? _bchdUrls;
@override List<String>? get bchdUrls {
  final value = _bchdUrls;
  if (value == null) return null;
  if (_bchdUrls is EqualUnmodifiableListView) return _bchdUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _otherTypes;
@override List<String>? get otherTypes {
  final value = _otherTypes;
  if (value == null) return null;
  if (_otherTypes is EqualUnmodifiableListView) return _otherTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  AddressFormat? addressFormat;
@override final  bool? allowSlpUnsafeConf;
@override final  String? slpPrefix;
@override final  String? tokenId;
@override final  String? forexId;
@override final  num? isPoS;
@override final  String? aliasTicker;
@override final  String? estimateFeeMode;
@override final  String? orderbookTicker;
@override final  num? taddr;
@override final  bool? forceMinRelayFee;
@override final  bool? isClaimable;
@override final  String? minimalClaimAmount;
@override final  num? isPoSV;
@override final  String? versionGroupId;
@override final  String? consensusBranchId;
@override final  num? estimateFeeBlocks;
 final  List<RpcUrl>? _rpcUrls;
@override List<RpcUrl>? get rpcUrls {
  final value = _rpcUrls;
  if (value == null) return null;
  if (_rpcUrls is EqualUnmodifiableListView) return _rpcUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CoinConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoinConfigCopyWith<_CoinConfig> get copyWith => __$CoinConfigCopyWithImpl<_CoinConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoinConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoinConfig&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.coingeckoId, coingeckoId) || other.coingeckoId == coingeckoId)&&(identical(other.livecoinwatchId, livecoinwatchId) || other.livecoinwatchId == livecoinwatchId)&&(identical(other.explorerUrl, explorerUrl) || other.explorerUrl == explorerUrl)&&(identical(other.explorerTxUrl, explorerTxUrl) || other.explorerTxUrl == explorerTxUrl)&&(identical(other.explorerAddressUrl, explorerAddressUrl) || other.explorerAddressUrl == explorerAddressUrl)&&const DeepCollectionEquality().equals(other._supported, _supported)&&(identical(other.active, active) || other.active == active)&&(identical(other.isTestnet, isTestnet) || other.isTestnet == isTestnet)&&(identical(other.currentlyEnabled, currentlyEnabled) || other.currentlyEnabled == currentlyEnabled)&&(identical(other.walletOnly, walletOnly) || other.walletOnly == walletOnly)&&(identical(other.fname, fname) || other.fname == fname)&&(identical(other.rpcport, rpcport) || other.rpcport == rpcport)&&(identical(other.mm2, mm2) || other.mm2 == mm2)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.requiredConfirmations, requiredConfirmations) || other.requiredConfirmations == requiredConfirmations)&&(identical(other.avgBlocktime, avgBlocktime) || other.avgBlocktime == avgBlocktime)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.derivationPath, derivationPath) || other.derivationPath == derivationPath)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.parentCoin, parentCoin) || other.parentCoin == parentCoin)&&(identical(other.swapContractAddress, swapContractAddress) || other.swapContractAddress == swapContractAddress)&&(identical(other.fallbackSwapContract, fallbackSwapContract) || other.fallbackSwapContract == fallbackSwapContract)&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&(identical(other.explorerBlockUrl, explorerBlockUrl) || other.explorerBlockUrl == explorerBlockUrl)&&(identical(other.tokenAddressUrl, tokenAddressUrl) || other.tokenAddressUrl == tokenAddressUrl)&&(identical(other.trezorCoin, trezorCoin) || other.trezorCoin == trezorCoin)&&(identical(other.links, links) || other.links == links)&&(identical(other.pubtype, pubtype) || other.pubtype == pubtype)&&(identical(other.p2shtype, p2shtype) || other.p2shtype == p2shtype)&&(identical(other.wiftype, wiftype) || other.wiftype == wiftype)&&(identical(other.txfee, txfee) || other.txfee == txfee)&&(identical(other.dust, dust) || other.dust == dust)&&(identical(other.segwit, segwit) || other.segwit == segwit)&&const DeepCollectionEquality().equals(other._electrum, _electrum)&&(identical(other.signMessagePrefix, signMessagePrefix) || other.signMessagePrefix == signMessagePrefix)&&const DeepCollectionEquality().equals(other._lightWalletDServers, _lightWalletDServers)&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.txversion, txversion) || other.txversion == txversion)&&(identical(other.overwintered, overwintered) || other.overwintered == overwintered)&&(identical(other.requiresNotarization, requiresNotarization) || other.requiresNotarization == requiresNotarization)&&(identical(other.checkpointHeight, checkpointHeight) || other.checkpointHeight == checkpointHeight)&&(identical(other.checkpointBlocktime, checkpointBlocktime) || other.checkpointBlocktime == checkpointBlocktime)&&(identical(other.binanceId, binanceId) || other.binanceId == binanceId)&&(identical(other.bech32Hrp, bech32Hrp) || other.bech32Hrp == bech32Hrp)&&(identical(other.forkId, forkId) || other.forkId == forkId)&&(identical(other.signatureVersion, signatureVersion) || other.signatureVersion == signatureVersion)&&(identical(other.confpath, confpath) || other.confpath == confpath)&&(identical(other.matureConfirmations, matureConfirmations) || other.matureConfirmations == matureConfirmations)&&const DeepCollectionEquality().equals(other._bchdUrls, _bchdUrls)&&const DeepCollectionEquality().equals(other._otherTypes, _otherTypes)&&(identical(other.addressFormat, addressFormat) || other.addressFormat == addressFormat)&&(identical(other.allowSlpUnsafeConf, allowSlpUnsafeConf) || other.allowSlpUnsafeConf == allowSlpUnsafeConf)&&(identical(other.slpPrefix, slpPrefix) || other.slpPrefix == slpPrefix)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.forexId, forexId) || other.forexId == forexId)&&(identical(other.isPoS, isPoS) || other.isPoS == isPoS)&&(identical(other.aliasTicker, aliasTicker) || other.aliasTicker == aliasTicker)&&(identical(other.estimateFeeMode, estimateFeeMode) || other.estimateFeeMode == estimateFeeMode)&&(identical(other.orderbookTicker, orderbookTicker) || other.orderbookTicker == orderbookTicker)&&(identical(other.taddr, taddr) || other.taddr == taddr)&&(identical(other.forceMinRelayFee, forceMinRelayFee) || other.forceMinRelayFee == forceMinRelayFee)&&(identical(other.isClaimable, isClaimable) || other.isClaimable == isClaimable)&&(identical(other.minimalClaimAmount, minimalClaimAmount) || other.minimalClaimAmount == minimalClaimAmount)&&(identical(other.isPoSV, isPoSV) || other.isPoSV == isPoSV)&&(identical(other.versionGroupId, versionGroupId) || other.versionGroupId == versionGroupId)&&(identical(other.consensusBranchId, consensusBranchId) || other.consensusBranchId == consensusBranchId)&&(identical(other.estimateFeeBlocks, estimateFeeBlocks) || other.estimateFeeBlocks == estimateFeeBlocks)&&const DeepCollectionEquality().equals(other._rpcUrls, _rpcUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,coin,type,name,coingeckoId,livecoinwatchId,explorerUrl,explorerTxUrl,explorerAddressUrl,const DeepCollectionEquality().hash(_supported),active,isTestnet,currentlyEnabled,walletOnly,fname,rpcport,mm2,chainId,requiredConfirmations,avgBlocktime,decimals,protocol,derivationPath,contractAddress,parentCoin,swapContractAddress,fallbackSwapContract,const DeepCollectionEquality().hash(_nodes),explorerBlockUrl,tokenAddressUrl,trezorCoin,links,pubtype,p2shtype,wiftype,txfee,dust,segwit,const DeepCollectionEquality().hash(_electrum),signMessagePrefix,const DeepCollectionEquality().hash(_lightWalletDServers),asset,txversion,overwintered,requiresNotarization,checkpointHeight,checkpointBlocktime,binanceId,bech32Hrp,forkId,signatureVersion,confpath,matureConfirmations,const DeepCollectionEquality().hash(_bchdUrls),const DeepCollectionEquality().hash(_otherTypes),addressFormat,allowSlpUnsafeConf,slpPrefix,tokenId,forexId,isPoS,aliasTicker,estimateFeeMode,orderbookTicker,taddr,forceMinRelayFee,isClaimable,minimalClaimAmount,isPoSV,versionGroupId,consensusBranchId,estimateFeeBlocks,const DeepCollectionEquality().hash(_rpcUrls)]);

@override
String toString() {
  return 'CoinConfig(coin: $coin, type: $type, name: $name, coingeckoId: $coingeckoId, livecoinwatchId: $livecoinwatchId, explorerUrl: $explorerUrl, explorerTxUrl: $explorerTxUrl, explorerAddressUrl: $explorerAddressUrl, supported: $supported, active: $active, isTestnet: $isTestnet, currentlyEnabled: $currentlyEnabled, walletOnly: $walletOnly, fname: $fname, rpcport: $rpcport, mm2: $mm2, chainId: $chainId, requiredConfirmations: $requiredConfirmations, avgBlocktime: $avgBlocktime, decimals: $decimals, protocol: $protocol, derivationPath: $derivationPath, contractAddress: $contractAddress, parentCoin: $parentCoin, swapContractAddress: $swapContractAddress, fallbackSwapContract: $fallbackSwapContract, nodes: $nodes, explorerBlockUrl: $explorerBlockUrl, tokenAddressUrl: $tokenAddressUrl, trezorCoin: $trezorCoin, links: $links, pubtype: $pubtype, p2shtype: $p2shtype, wiftype: $wiftype, txfee: $txfee, dust: $dust, segwit: $segwit, electrum: $electrum, signMessagePrefix: $signMessagePrefix, lightWalletDServers: $lightWalletDServers, asset: $asset, txversion: $txversion, overwintered: $overwintered, requiresNotarization: $requiresNotarization, checkpointHeight: $checkpointHeight, checkpointBlocktime: $checkpointBlocktime, binanceId: $binanceId, bech32Hrp: $bech32Hrp, forkId: $forkId, signatureVersion: $signatureVersion, confpath: $confpath, matureConfirmations: $matureConfirmations, bchdUrls: $bchdUrls, otherTypes: $otherTypes, addressFormat: $addressFormat, allowSlpUnsafeConf: $allowSlpUnsafeConf, slpPrefix: $slpPrefix, tokenId: $tokenId, forexId: $forexId, isPoS: $isPoS, aliasTicker: $aliasTicker, estimateFeeMode: $estimateFeeMode, orderbookTicker: $orderbookTicker, taddr: $taddr, forceMinRelayFee: $forceMinRelayFee, isClaimable: $isClaimable, minimalClaimAmount: $minimalClaimAmount, isPoSV: $isPoSV, versionGroupId: $versionGroupId, consensusBranchId: $consensusBranchId, estimateFeeBlocks: $estimateFeeBlocks, rpcUrls: $rpcUrls)';
}


}

/// @nodoc
abstract mixin class _$CoinConfigCopyWith<$Res> implements $CoinConfigCopyWith<$Res> {
  factory _$CoinConfigCopyWith(_CoinConfig value, $Res Function(_CoinConfig) _then) = __$CoinConfigCopyWithImpl;
@override @useResult
$Res call({
 String coin, String? type, String? name, String? coingeckoId, String? livecoinwatchId, String? explorerUrl, String? explorerTxUrl, String? explorerAddressUrl, List<String>? supported, bool? active, bool? isTestnet, bool? currentlyEnabled, bool? walletOnly, String? fname, num? rpcport, num? mm2, num? chainId, num? requiredConfirmations, num? avgBlocktime, num? decimals, Protocol? protocol, String? derivationPath, String? contractAddress, String? parentCoin, String? swapContractAddress, String? fallbackSwapContract, List<Node>? nodes, String? explorerBlockUrl, String? tokenAddressUrl, String? trezorCoin, Links? links, num? pubtype, num? p2shtype, num? wiftype, num? txfee, num? dust, bool? segwit, List<Electrum>? electrum, String? signMessagePrefix, List<String>? lightWalletDServers, String? asset, num? txversion, num? overwintered, bool? requiresNotarization, num? checkpointHeight, num? checkpointBlocktime, String? binanceId, String? bech32Hrp, String? forkId, String? signatureVersion, String? confpath, num? matureConfirmations, List<String>? bchdUrls, List<String>? otherTypes, AddressFormat? addressFormat, bool? allowSlpUnsafeConf, String? slpPrefix, String? tokenId, String? forexId, num? isPoS, String? aliasTicker, String? estimateFeeMode, String? orderbookTicker, num? taddr, bool? forceMinRelayFee, bool? isClaimable, String? minimalClaimAmount, num? isPoSV, String? versionGroupId, String? consensusBranchId, num? estimateFeeBlocks, List<RpcUrl>? rpcUrls
});


@override $ProtocolCopyWith<$Res>? get protocol;@override $LinksCopyWith<$Res>? get links;@override $AddressFormatCopyWith<$Res>? get addressFormat;

}
/// @nodoc
class __$CoinConfigCopyWithImpl<$Res>
    implements _$CoinConfigCopyWith<$Res> {
  __$CoinConfigCopyWithImpl(this._self, this._then);

  final _CoinConfig _self;
  final $Res Function(_CoinConfig) _then;

/// Create a copy of CoinConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? type = freezed,Object? name = freezed,Object? coingeckoId = freezed,Object? livecoinwatchId = freezed,Object? explorerUrl = freezed,Object? explorerTxUrl = freezed,Object? explorerAddressUrl = freezed,Object? supported = freezed,Object? active = freezed,Object? isTestnet = freezed,Object? currentlyEnabled = freezed,Object? walletOnly = freezed,Object? fname = freezed,Object? rpcport = freezed,Object? mm2 = freezed,Object? chainId = freezed,Object? requiredConfirmations = freezed,Object? avgBlocktime = freezed,Object? decimals = freezed,Object? protocol = freezed,Object? derivationPath = freezed,Object? contractAddress = freezed,Object? parentCoin = freezed,Object? swapContractAddress = freezed,Object? fallbackSwapContract = freezed,Object? nodes = freezed,Object? explorerBlockUrl = freezed,Object? tokenAddressUrl = freezed,Object? trezorCoin = freezed,Object? links = freezed,Object? pubtype = freezed,Object? p2shtype = freezed,Object? wiftype = freezed,Object? txfee = freezed,Object? dust = freezed,Object? segwit = freezed,Object? electrum = freezed,Object? signMessagePrefix = freezed,Object? lightWalletDServers = freezed,Object? asset = freezed,Object? txversion = freezed,Object? overwintered = freezed,Object? requiresNotarization = freezed,Object? checkpointHeight = freezed,Object? checkpointBlocktime = freezed,Object? binanceId = freezed,Object? bech32Hrp = freezed,Object? forkId = freezed,Object? signatureVersion = freezed,Object? confpath = freezed,Object? matureConfirmations = freezed,Object? bchdUrls = freezed,Object? otherTypes = freezed,Object? addressFormat = freezed,Object? allowSlpUnsafeConf = freezed,Object? slpPrefix = freezed,Object? tokenId = freezed,Object? forexId = freezed,Object? isPoS = freezed,Object? aliasTicker = freezed,Object? estimateFeeMode = freezed,Object? orderbookTicker = freezed,Object? taddr = freezed,Object? forceMinRelayFee = freezed,Object? isClaimable = freezed,Object? minimalClaimAmount = freezed,Object? isPoSV = freezed,Object? versionGroupId = freezed,Object? consensusBranchId = freezed,Object? estimateFeeBlocks = freezed,Object? rpcUrls = freezed,}) {
  return _then(_CoinConfig(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,coingeckoId: freezed == coingeckoId ? _self.coingeckoId : coingeckoId // ignore: cast_nullable_to_non_nullable
as String?,livecoinwatchId: freezed == livecoinwatchId ? _self.livecoinwatchId : livecoinwatchId // ignore: cast_nullable_to_non_nullable
as String?,explorerUrl: freezed == explorerUrl ? _self.explorerUrl : explorerUrl // ignore: cast_nullable_to_non_nullable
as String?,explorerTxUrl: freezed == explorerTxUrl ? _self.explorerTxUrl : explorerTxUrl // ignore: cast_nullable_to_non_nullable
as String?,explorerAddressUrl: freezed == explorerAddressUrl ? _self.explorerAddressUrl : explorerAddressUrl // ignore: cast_nullable_to_non_nullable
as String?,supported: freezed == supported ? _self._supported : supported // ignore: cast_nullable_to_non_nullable
as List<String>?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,isTestnet: freezed == isTestnet ? _self.isTestnet : isTestnet // ignore: cast_nullable_to_non_nullable
as bool?,currentlyEnabled: freezed == currentlyEnabled ? _self.currentlyEnabled : currentlyEnabled // ignore: cast_nullable_to_non_nullable
as bool?,walletOnly: freezed == walletOnly ? _self.walletOnly : walletOnly // ignore: cast_nullable_to_non_nullable
as bool?,fname: freezed == fname ? _self.fname : fname // ignore: cast_nullable_to_non_nullable
as String?,rpcport: freezed == rpcport ? _self.rpcport : rpcport // ignore: cast_nullable_to_non_nullable
as num?,mm2: freezed == mm2 ? _self.mm2 : mm2 // ignore: cast_nullable_to_non_nullable
as num?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as num?,requiredConfirmations: freezed == requiredConfirmations ? _self.requiredConfirmations : requiredConfirmations // ignore: cast_nullable_to_non_nullable
as num?,avgBlocktime: freezed == avgBlocktime ? _self.avgBlocktime : avgBlocktime // ignore: cast_nullable_to_non_nullable
as num?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as num?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as Protocol?,derivationPath: freezed == derivationPath ? _self.derivationPath : derivationPath // ignore: cast_nullable_to_non_nullable
as String?,contractAddress: freezed == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String?,parentCoin: freezed == parentCoin ? _self.parentCoin : parentCoin // ignore: cast_nullable_to_non_nullable
as String?,swapContractAddress: freezed == swapContractAddress ? _self.swapContractAddress : swapContractAddress // ignore: cast_nullable_to_non_nullable
as String?,fallbackSwapContract: freezed == fallbackSwapContract ? _self.fallbackSwapContract : fallbackSwapContract // ignore: cast_nullable_to_non_nullable
as String?,nodes: freezed == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<Node>?,explorerBlockUrl: freezed == explorerBlockUrl ? _self.explorerBlockUrl : explorerBlockUrl // ignore: cast_nullable_to_non_nullable
as String?,tokenAddressUrl: freezed == tokenAddressUrl ? _self.tokenAddressUrl : tokenAddressUrl // ignore: cast_nullable_to_non_nullable
as String?,trezorCoin: freezed == trezorCoin ? _self.trezorCoin : trezorCoin // ignore: cast_nullable_to_non_nullable
as String?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as Links?,pubtype: freezed == pubtype ? _self.pubtype : pubtype // ignore: cast_nullable_to_non_nullable
as num?,p2shtype: freezed == p2shtype ? _self.p2shtype : p2shtype // ignore: cast_nullable_to_non_nullable
as num?,wiftype: freezed == wiftype ? _self.wiftype : wiftype // ignore: cast_nullable_to_non_nullable
as num?,txfee: freezed == txfee ? _self.txfee : txfee // ignore: cast_nullable_to_non_nullable
as num?,dust: freezed == dust ? _self.dust : dust // ignore: cast_nullable_to_non_nullable
as num?,segwit: freezed == segwit ? _self.segwit : segwit // ignore: cast_nullable_to_non_nullable
as bool?,electrum: freezed == electrum ? _self._electrum : electrum // ignore: cast_nullable_to_non_nullable
as List<Electrum>?,signMessagePrefix: freezed == signMessagePrefix ? _self.signMessagePrefix : signMessagePrefix // ignore: cast_nullable_to_non_nullable
as String?,lightWalletDServers: freezed == lightWalletDServers ? _self._lightWalletDServers : lightWalletDServers // ignore: cast_nullable_to_non_nullable
as List<String>?,asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String?,txversion: freezed == txversion ? _self.txversion : txversion // ignore: cast_nullable_to_non_nullable
as num?,overwintered: freezed == overwintered ? _self.overwintered : overwintered // ignore: cast_nullable_to_non_nullable
as num?,requiresNotarization: freezed == requiresNotarization ? _self.requiresNotarization : requiresNotarization // ignore: cast_nullable_to_non_nullable
as bool?,checkpointHeight: freezed == checkpointHeight ? _self.checkpointHeight : checkpointHeight // ignore: cast_nullable_to_non_nullable
as num?,checkpointBlocktime: freezed == checkpointBlocktime ? _self.checkpointBlocktime : checkpointBlocktime // ignore: cast_nullable_to_non_nullable
as num?,binanceId: freezed == binanceId ? _self.binanceId : binanceId // ignore: cast_nullable_to_non_nullable
as String?,bech32Hrp: freezed == bech32Hrp ? _self.bech32Hrp : bech32Hrp // ignore: cast_nullable_to_non_nullable
as String?,forkId: freezed == forkId ? _self.forkId : forkId // ignore: cast_nullable_to_non_nullable
as String?,signatureVersion: freezed == signatureVersion ? _self.signatureVersion : signatureVersion // ignore: cast_nullable_to_non_nullable
as String?,confpath: freezed == confpath ? _self.confpath : confpath // ignore: cast_nullable_to_non_nullable
as String?,matureConfirmations: freezed == matureConfirmations ? _self.matureConfirmations : matureConfirmations // ignore: cast_nullable_to_non_nullable
as num?,bchdUrls: freezed == bchdUrls ? _self._bchdUrls : bchdUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,otherTypes: freezed == otherTypes ? _self._otherTypes : otherTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,addressFormat: freezed == addressFormat ? _self.addressFormat : addressFormat // ignore: cast_nullable_to_non_nullable
as AddressFormat?,allowSlpUnsafeConf: freezed == allowSlpUnsafeConf ? _self.allowSlpUnsafeConf : allowSlpUnsafeConf // ignore: cast_nullable_to_non_nullable
as bool?,slpPrefix: freezed == slpPrefix ? _self.slpPrefix : slpPrefix // ignore: cast_nullable_to_non_nullable
as String?,tokenId: freezed == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String?,forexId: freezed == forexId ? _self.forexId : forexId // ignore: cast_nullable_to_non_nullable
as String?,isPoS: freezed == isPoS ? _self.isPoS : isPoS // ignore: cast_nullable_to_non_nullable
as num?,aliasTicker: freezed == aliasTicker ? _self.aliasTicker : aliasTicker // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeMode: freezed == estimateFeeMode ? _self.estimateFeeMode : estimateFeeMode // ignore: cast_nullable_to_non_nullable
as String?,orderbookTicker: freezed == orderbookTicker ? _self.orderbookTicker : orderbookTicker // ignore: cast_nullable_to_non_nullable
as String?,taddr: freezed == taddr ? _self.taddr : taddr // ignore: cast_nullable_to_non_nullable
as num?,forceMinRelayFee: freezed == forceMinRelayFee ? _self.forceMinRelayFee : forceMinRelayFee // ignore: cast_nullable_to_non_nullable
as bool?,isClaimable: freezed == isClaimable ? _self.isClaimable : isClaimable // ignore: cast_nullable_to_non_nullable
as bool?,minimalClaimAmount: freezed == minimalClaimAmount ? _self.minimalClaimAmount : minimalClaimAmount // ignore: cast_nullable_to_non_nullable
as String?,isPoSV: freezed == isPoSV ? _self.isPoSV : isPoSV // ignore: cast_nullable_to_non_nullable
as num?,versionGroupId: freezed == versionGroupId ? _self.versionGroupId : versionGroupId // ignore: cast_nullable_to_non_nullable
as String?,consensusBranchId: freezed == consensusBranchId ? _self.consensusBranchId : consensusBranchId // ignore: cast_nullable_to_non_nullable
as String?,estimateFeeBlocks: freezed == estimateFeeBlocks ? _self.estimateFeeBlocks : estimateFeeBlocks // ignore: cast_nullable_to_non_nullable
as num?,rpcUrls: freezed == rpcUrls ? _self._rpcUrls : rpcUrls // ignore: cast_nullable_to_non_nullable
as List<RpcUrl>?,
  ));
}

/// Create a copy of CoinConfig
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
}/// Create a copy of CoinConfig
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
}/// Create a copy of CoinConfig
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
