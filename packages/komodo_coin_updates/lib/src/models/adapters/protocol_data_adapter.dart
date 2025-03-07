part of '../protocol_data.dart';

class ProtocolDataAdapter extends TypeAdapter<ProtocolData> {
  @override
  final int typeId = 2;

  @override
  ProtocolData read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
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
      ..write(obj.consensusParams ?? const ConsensusParams())
      ..writeByte(3)
      ..write(obj.checkPointBlock ?? const CheckPointBlock())
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
