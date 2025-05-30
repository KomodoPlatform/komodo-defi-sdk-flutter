part of '../coin.dart';

class CoinAdapter extends TypeAdapter<Coin> {
  @override
  final int typeId = 0;

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
