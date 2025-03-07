part of '../electrum.dart';

class ElectrumAdapter extends TypeAdapter<Electrum> {
  @override
  final int typeId = 8;

  @override
  Electrum read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Electrum(
      url: fields[0] as String?,
      protocol: fields[1] as String?,
      contact: (fields[2] as List<dynamic>?)?.cast<Contact>(),
    );
  }

  @override
  void write(BinaryWriter writer, Electrum obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.protocol)
      ..writeByte(2)
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
