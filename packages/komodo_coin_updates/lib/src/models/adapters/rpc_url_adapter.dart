part of '../rpc_url.dart';

class RpcUrlAdapter extends TypeAdapter<RpcUrl> {
  @override
  final int typeId = 11;

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
