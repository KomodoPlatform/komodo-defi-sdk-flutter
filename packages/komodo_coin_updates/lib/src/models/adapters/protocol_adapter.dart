part of '../protocol.dart';

class ProtocolAdapter extends TypeAdapter<Protocol> {
  @override
  final int typeId = 1;

  @override
  Protocol read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
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
