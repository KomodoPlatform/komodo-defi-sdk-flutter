part of '../address_format.dart';

class AddressFormatAdapter extends TypeAdapter<AddressFormat> {
  @override
  final int typeId = 3;

  @override
  AddressFormat read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
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
