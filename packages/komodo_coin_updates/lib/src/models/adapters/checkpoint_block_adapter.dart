part of '../checkpoint_block.dart';

class CheckPointBlockAdapter extends TypeAdapter<CheckPointBlock> {
  @override
  final int typeId = 6;

  @override
  CheckPointBlock read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
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
