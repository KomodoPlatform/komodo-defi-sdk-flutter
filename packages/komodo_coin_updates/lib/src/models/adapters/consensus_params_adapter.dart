part of '../consensus_params.dart';

class ConsensusParamsAdapter extends TypeAdapter<ConsensusParams> {
  @override
  final int typeId = 5;

  @override
  ConsensusParams read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
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
      b58PubkeyAddressPrefix: (fields[9] as List<dynamic>?)?.cast<num>(),
      b58ScriptAddressPrefix: (fields[10] as List<dynamic>?)?.cast<num>(),
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
