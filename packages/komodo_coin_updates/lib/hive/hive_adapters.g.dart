// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class CoinAdapter extends TypeAdapter<Coin> {
  @override
  final typeId = 0;

  @override
  Coin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Coin(
      coin: fields[0] as String,
      name: fields[1] as String?,
      fname: fields[2] as String?,
      rpcport: fields[3] as num?,
      mm2: fields[4] as num?,
      chainId: fields[5] as num?,
      requiredConfirmations: fields[6] as num?,
      avgBlocktime: fields[7] as num?,
      decimals: fields[8] as num?,
      protocol: fields[9] as Protocol?,
      derivationPath: fields[10] as String?,
      trezorCoin: fields[11] as String?,
      links: fields[12] as Links?,
      isPoS: fields[13] as num?,
      pubtype: fields[14] as num?,
      p2shtype: fields[15] as num?,
      wiftype: fields[16] as num?,
      txfee: fields[17] as num?,
      dust: fields[18] as num?,
      matureConfirmations: fields[19] as num?,
      segwit: fields[20] as bool?,
      signMessagePrefix: fields[21] as String?,
      asset: fields[22] as String?,
      txversion: fields[23] as num?,
      overwintered: fields[24] as num?,
      requiresNotarization: fields[25] as bool?,
      walletOnly: fields[26] as bool?,
      bech32Hrp: fields[27] as String?,
      isTestnet: fields[28] as bool?,
      forkId: fields[29] as String?,
      signatureVersion: fields[30] as String?,
      confpath: fields[31] as String?,
      addressFormat: fields[32] as AddressFormat?,
      aliasTicker: fields[33] as String?,
      estimateFeeMode: fields[34] as String?,
      orderbookTicker: fields[35] as String?,
      taddr: fields[36] as num?,
      forceMinRelayFee: fields[37] as bool?,
      p2p: fields[38] as num?,
      magic: fields[39] as String?,
      nSPV: fields[40] as String?,
      isPoSV: fields[41] as num?,
      versionGroupId: fields[42] as String?,
      consensusBranchId: fields[43] as String?,
      estimateFeeBlocks: fields[44] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, Coin obj) {
    writer
      ..writeByte(45)
      ..writeByte(0)
      ..write(obj.coin)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fname)
      ..writeByte(3)
      ..write(obj.rpcport)
      ..writeByte(4)
      ..write(obj.mm2)
      ..writeByte(5)
      ..write(obj.chainId)
      ..writeByte(6)
      ..write(obj.requiredConfirmations)
      ..writeByte(7)
      ..write(obj.avgBlocktime)
      ..writeByte(8)
      ..write(obj.decimals)
      ..writeByte(9)
      ..write(obj.protocol)
      ..writeByte(10)
      ..write(obj.derivationPath)
      ..writeByte(11)
      ..write(obj.trezorCoin)
      ..writeByte(12)
      ..write(obj.links)
      ..writeByte(13)
      ..write(obj.isPoS)
      ..writeByte(14)
      ..write(obj.pubtype)
      ..writeByte(15)
      ..write(obj.p2shtype)
      ..writeByte(16)
      ..write(obj.wiftype)
      ..writeByte(17)
      ..write(obj.txfee)
      ..writeByte(18)
      ..write(obj.dust)
      ..writeByte(19)
      ..write(obj.matureConfirmations)
      ..writeByte(20)
      ..write(obj.segwit)
      ..writeByte(21)
      ..write(obj.signMessagePrefix)
      ..writeByte(22)
      ..write(obj.asset)
      ..writeByte(23)
      ..write(obj.txversion)
      ..writeByte(24)
      ..write(obj.overwintered)
      ..writeByte(25)
      ..write(obj.requiresNotarization)
      ..writeByte(26)
      ..write(obj.walletOnly)
      ..writeByte(27)
      ..write(obj.bech32Hrp)
      ..writeByte(28)
      ..write(obj.isTestnet)
      ..writeByte(29)
      ..write(obj.forkId)
      ..writeByte(30)
      ..write(obj.signatureVersion)
      ..writeByte(31)
      ..write(obj.confpath)
      ..writeByte(32)
      ..write(obj.addressFormat)
      ..writeByte(33)
      ..write(obj.aliasTicker)
      ..writeByte(34)
      ..write(obj.estimateFeeMode)
      ..writeByte(35)
      ..write(obj.orderbookTicker)
      ..writeByte(36)
      ..write(obj.taddr)
      ..writeByte(37)
      ..write(obj.forceMinRelayFee)
      ..writeByte(38)
      ..write(obj.p2p)
      ..writeByte(39)
      ..write(obj.magic)
      ..writeByte(40)
      ..write(obj.nSPV)
      ..writeByte(41)
      ..write(obj.isPoSV)
      ..writeByte(42)
      ..write(obj.versionGroupId)
      ..writeByte(43)
      ..write(obj.consensusBranchId)
      ..writeByte(44)
      ..write(obj.estimateFeeBlocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtocolAdapter extends TypeAdapter<Protocol> {
  @override
  final typeId = 1;

  @override
  Protocol read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Protocol(
      type: fields[0] as String?,
      protocolData: fields[1] as ProtocolData?,
      bip44: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Protocol obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.protocolData)
      ..writeByte(2)
      ..write(obj.bip44);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtocolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtocolDataAdapter extends TypeAdapter<ProtocolData> {
  @override
  final typeId = 2;

  @override
  ProtocolData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProtocolData(
      platform: fields[0] as String?,
      contractAddress: fields[1] as String?,
      consensusParams: fields[2] as ConsensusParams?,
      checkPointBlock: fields[3] as CheckPointBlock?,
      slpPrefix: fields[4] as String?,
      decimals: fields[5] as num?,
      tokenId: fields[6] as String?,
      requiredConfirmations: fields[7] as num?,
      denom: fields[8] as String?,
      accountPrefix: fields[9] as String?,
      chainId: fields[10] as String?,
      gasPrice: fields[11] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, ProtocolData obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.platform)
      ..writeByte(1)
      ..write(obj.contractAddress)
      ..writeByte(2)
      ..write(obj.consensusParams)
      ..writeByte(3)
      ..write(obj.checkPointBlock)
      ..writeByte(4)
      ..write(obj.slpPrefix)
      ..writeByte(5)
      ..write(obj.decimals)
      ..writeByte(6)
      ..write(obj.tokenId)
      ..writeByte(7)
      ..write(obj.requiredConfirmations)
      ..writeByte(8)
      ..write(obj.denom)
      ..writeByte(9)
      ..write(obj.accountPrefix)
      ..writeByte(10)
      ..write(obj.chainId)
      ..writeByte(11)
      ..write(obj.gasPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtocolDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddressFormatAdapter extends TypeAdapter<AddressFormat> {
  @override
  final typeId = 3;

  @override
  AddressFormat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressFormat(
      format: fields[0] as String?,
      network: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AddressFormat obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.format)
      ..writeByte(1)
      ..write(obj.network);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LinksAdapter extends TypeAdapter<Links> {
  @override
  final typeId = 4;

  @override
  Links read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Links(github: fields[0] as String?, homepage: fields[1] as String?);
  }

  @override
  void write(BinaryWriter writer, Links obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.github)
      ..writeByte(1)
      ..write(obj.homepage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinksAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConsensusParamsAdapter extends TypeAdapter<ConsensusParams> {
  @override
  final typeId = 5;

  @override
  ConsensusParams read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsensusParams(
      overwinterActivationHeight: fields[0] as num?,
      saplingActivationHeight: fields[1] as num?,
      blossomActivationHeight: fields[2] as num?,
      heartwoodActivationHeight: fields[3] as num?,
      canopyActivationHeight: fields[4] as num?,
      coinType: fields[5] as num?,
      hrpSaplingExtendedSpendingKey: fields[6] as String?,
      hrpSaplingExtendedFullViewingKey: fields[7] as String?,
      hrpSaplingPaymentAddress: fields[8] as String?,
      b58PubkeyAddressPrefix: (fields[9] as List?)?.cast<num>(),
      b58ScriptAddressPrefix: (fields[10] as List?)?.cast<num>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConsensusParams obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.overwinterActivationHeight)
      ..writeByte(1)
      ..write(obj.saplingActivationHeight)
      ..writeByte(2)
      ..write(obj.blossomActivationHeight)
      ..writeByte(3)
      ..write(obj.heartwoodActivationHeight)
      ..writeByte(4)
      ..write(obj.canopyActivationHeight)
      ..writeByte(5)
      ..write(obj.coinType)
      ..writeByte(6)
      ..write(obj.hrpSaplingExtendedSpendingKey)
      ..writeByte(7)
      ..write(obj.hrpSaplingExtendedFullViewingKey)
      ..writeByte(8)
      ..write(obj.hrpSaplingPaymentAddress)
      ..writeByte(9)
      ..write(obj.b58PubkeyAddressPrefix)
      ..writeByte(10)
      ..write(obj.b58ScriptAddressPrefix);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsensusParamsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CheckPointBlockAdapter extends TypeAdapter<CheckPointBlock> {
  @override
  final typeId = 6;

  @override
  CheckPointBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckPointBlock(
      height: fields[0] as num?,
      time: fields[1] as num?,
      hash: fields[2] as String?,
      saplingTree: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CheckPointBlock obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.hash)
      ..writeByte(3)
      ..write(obj.saplingTree);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckPointBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoinConfigAdapter extends TypeAdapter<CoinConfig> {
  @override
  final typeId = 7;

  @override
  CoinConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
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
      supported: (fields[8] as List?)?.cast<String>(),
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
      nodes: (fields[26] as List?)?.cast<Node>(),
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
      electrum: (fields[37] as List?)?.cast<Electrum>(),
      signMessagePrefix: fields[38] as String?,
      lightWalletDServers: (fields[39] as List?)?.cast<String>(),
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
      bchdUrls: (fields[52] as List?)?.cast<String>(),
      otherTypes: (fields[53] as List?)?.cast<String>(),
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
      rpcUrls: (fields[71] as List?)?.cast<RpcUrl>(),
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

class ElectrumAdapter extends TypeAdapter<Electrum> {
  @override
  final typeId = 8;

  @override
  Electrum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Electrum(
      url: fields[0] as String?,
      wsUrl: fields[1] as String?,
      protocol: fields[2] as String?,
      contact: (fields[3] as List?)?.cast<Contact>(),
    );
  }

  @override
  void write(BinaryWriter writer, Electrum obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.wsUrl)
      ..writeByte(2)
      ..write(obj.protocol)
      ..writeByte(3)
      ..write(obj.contact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElectrumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NodeAdapter extends TypeAdapter<Node> {
  @override
  final typeId = 9;

  @override
  Node read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Node(
      url: fields[0] as String?,
      wsUrl: fields[1] as String?,
      guiAuth: fields[2] as bool?,
      contact: fields[3] as Contact?,
    );
  }

  @override
  void write(BinaryWriter writer, Node obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.wsUrl)
      ..writeByte(2)
      ..write(obj.guiAuth)
      ..writeByte(3)
      ..write(obj.contact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final typeId = 10;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(email: fields[0] as String?, github: fields[1] as String?);
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.github);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RpcUrlAdapter extends TypeAdapter<RpcUrl> {
  @override
  final typeId = 11;

  @override
  RpcUrl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RpcUrl(url: fields[0] as String?);
  }

  @override
  void write(BinaryWriter writer, RpcUrl obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RpcUrlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoinInfoAdapter extends TypeAdapter<CoinInfo> {
  @override
  final typeId = 13;

  @override
  CoinInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinInfo(
      coin: fields[0] as Coin,
      coinConfig: fields[1] as CoinConfig?,
    );
  }

  @override
  void write(BinaryWriter writer, CoinInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.coin)
      ..writeByte(1)
      ..write(obj.coinConfig);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
