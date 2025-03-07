part of '../coin_config.dart';

class CoinConfigAdapter extends TypeAdapter<CoinConfig> {
  @override
  final int typeId = 7;

  @override
  CoinConfig read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinConfig(
      coin: fields[0] as String,
      type: fields[1] as String?,
      name: fields[2] as String?,
      coingeckoId: fields[3] as String?,
      livecoinwatchId: fields[4] as String?,
      explorerUrl: fields[5] as String?,
      explorerTxUrl: fields[6] as String?,
      explorerAddressUrl: fields[7] as String?,
      supported: (fields[8] as List<dynamic>?)?.cast<String>(),
      active: fields[9] as bool?,
      isTestnet: fields[10] as bool?,
      currentlyEnabled: fields[11] as bool?,
      walletOnly: fields[12] as bool?,
      fname: fields[13] as String?,
      rpcport: fields[14] as num?,
      mm2: fields[15] as num?,
      chainId: fields[16] as num?,
      requiredConfirmations: fields[17] as num?,
      avgBlocktime: fields[18] as num?,
      decimals: fields[19] as num?,
      protocol: fields[20] as Protocol?,
      derivationPath: fields[21] as String?,
      contractAddress: fields[22] as String?,
      parentCoin: fields[23] as String?,
      swapContractAddress: fields[24] as String?,
      fallbackSwapContract: fields[25] as String?,
      nodes: (fields[26] as List<dynamic>?)?.cast<Node>(),
      explorerBlockUrl: fields[27] as String?,
      tokenAddressUrl: fields[28] as String?,
      trezorCoin: fields[29] as String?,
      links: fields[30] as Links?,
      pubtype: fields[31] as num?,
      p2shtype: fields[32] as num?,
      wiftype: fields[33] as num?,
      txfee: fields[34] as num?,
      dust: fields[35] as num?,
      segwit: fields[36] as bool?,
      electrum: (fields[37] as List<dynamic>?)?.cast<Electrum>(),
      signMessagePrefix: fields[38] as String?,
      lightWalletDServers: (fields[39] as List<dynamic>?)?.cast<String>(),
      asset: fields[40] as String?,
      txversion: fields[41] as num?,
      overwintered: fields[42] as num?,
      requiresNotarization: fields[43] as bool?,
      checkpointHeight: fields[44] as num?,
      checkpointBlocktime: fields[45] as num?,
      binanceId: fields[46] as String?,
      bech32Hrp: fields[47] as String?,
      forkId: fields[48] as String?,
      signatureVersion: fields[49] as String?,
      confpath: fields[50] as String?,
      matureConfirmations: fields[51] as num?,
      bchdUrls: (fields[52] as List<dynamic>?)?.cast<String>(),
      otherTypes: (fields[53] as List<dynamic>?)?.cast<String>(),
      addressFormat: fields[54] as AddressFormat?,
      allowSlpUnsafeConf: fields[55] as bool?,
      slpPrefix: fields[56] as String?,
      tokenId: fields[57] as String?,
      forexId: fields[58] as String?,
      isPoS: fields[59] as num?,
      aliasTicker: fields[60] as String?,
      estimateFeeMode: fields[61] as String?,
      orderbookTicker: fields[62] as String?,
      taddr: fields[63] as num?,
      forceMinRelayFee: fields[64] as bool?,
      isClaimable: fields[65] as bool?,
      minimalClaimAmount: fields[66] as String?,
      isPoSV: fields[67] as num?,
      versionGroupId: fields[68] as String?,
      consensusBranchId: fields[69] as String?,
      estimateFeeBlocks: fields[70] as num?,
      rpcUrls: (fields[71] as List<dynamic>?)?.cast<RpcUrl>(),
    );
  }

  @override
  void write(BinaryWriter writer, CoinConfig obj) {
    writer
      ..writeByte(72)
      ..writeByte(0)
      ..write(obj.coin)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.coingeckoId)
      ..writeByte(4)
      ..write(obj.livecoinwatchId)
      ..writeByte(5)
      ..write(obj.explorerUrl)
      ..writeByte(6)
      ..write(obj.explorerTxUrl)
      ..writeByte(7)
      ..write(obj.explorerAddressUrl)
      ..writeByte(8)
      ..write(obj.supported)
      ..writeByte(9)
      ..write(obj.active)
      ..writeByte(10)
      ..write(obj.isTestnet)
      ..writeByte(11)
      ..write(obj.currentlyEnabled)
      ..writeByte(12)
      ..write(obj.walletOnly)
      ..writeByte(13)
      ..write(obj.fname)
      ..writeByte(14)
      ..write(obj.rpcport)
      ..writeByte(15)
      ..write(obj.mm2)
      ..writeByte(16)
      ..write(obj.chainId)
      ..writeByte(17)
      ..write(obj.requiredConfirmations)
      ..writeByte(18)
      ..write(obj.avgBlocktime)
      ..writeByte(19)
      ..write(obj.decimals)
      ..writeByte(20)
      ..write(obj.protocol)
      ..writeByte(21)
      ..write(obj.derivationPath)
      ..writeByte(22)
      ..write(obj.contractAddress)
      ..writeByte(23)
      ..write(obj.parentCoin)
      ..writeByte(24)
      ..write(obj.swapContractAddress)
      ..writeByte(25)
      ..write(obj.fallbackSwapContract)
      ..writeByte(26)
      ..write(obj.nodes)
      ..writeByte(27)
      ..write(obj.explorerBlockUrl)
      ..writeByte(28)
      ..write(obj.tokenAddressUrl)
      ..writeByte(29)
      ..write(obj.trezorCoin)
      ..writeByte(30)
      ..write(obj.links)
      ..writeByte(31)
      ..write(obj.pubtype)
      ..writeByte(32)
      ..write(obj.p2shtype)
      ..writeByte(33)
      ..write(obj.wiftype)
      ..writeByte(34)
      ..write(obj.txfee)
      ..writeByte(35)
      ..write(obj.dust)
      ..writeByte(36)
      ..write(obj.segwit)
      ..writeByte(37)
      ..write(obj.electrum)
      ..writeByte(38)
      ..write(obj.signMessagePrefix)
      ..writeByte(39)
      ..write(obj.lightWalletDServers)
      ..writeByte(40)
      ..write(obj.asset)
      ..writeByte(41)
      ..write(obj.txversion)
      ..writeByte(42)
      ..write(obj.overwintered)
      ..writeByte(43)
      ..write(obj.requiresNotarization)
      ..writeByte(44)
      ..write(obj.checkpointHeight)
      ..writeByte(45)
      ..write(obj.checkpointBlocktime)
      ..writeByte(46)
      ..write(obj.binanceId)
      ..writeByte(47)
      ..write(obj.bech32Hrp)
      ..writeByte(48)
      ..write(obj.forkId)
      ..writeByte(49)
      ..write(obj.signatureVersion)
      ..writeByte(50)
      ..write(obj.confpath)
      ..writeByte(51)
      ..write(obj.matureConfirmations)
      ..writeByte(52)
      ..write(obj.bchdUrls)
      ..writeByte(53)
      ..write(obj.otherTypes)
      ..writeByte(54)
      ..write(obj.addressFormat)
      ..writeByte(55)
      ..write(obj.allowSlpUnsafeConf)
      ..writeByte(56)
      ..write(obj.slpPrefix)
      ..writeByte(57)
      ..write(obj.tokenId)
      ..writeByte(58)
      ..write(obj.forexId)
      ..writeByte(59)
      ..write(obj.isPoS)
      ..writeByte(60)
      ..write(obj.aliasTicker)
      ..writeByte(61)
      ..write(obj.estimateFeeMode)
      ..writeByte(62)
      ..write(obj.orderbookTicker)
      ..writeByte(63)
      ..write(obj.taddr)
      ..writeByte(64)
      ..write(obj.forceMinRelayFee)
      ..writeByte(65)
      ..write(obj.isClaimable)
      ..writeByte(66)
      ..write(obj.minimalClaimAmount)
      ..writeByte(67)
      ..write(obj.isPoSV)
      ..writeByte(68)
      ..write(obj.versionGroupId)
      ..writeByte(69)
      ..write(obj.consensusBranchId)
      ..writeByte(70)
      ..write(obj.estimateFeeBlocks)
      ..writeByte(71)
      ..write(obj.rpcUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
