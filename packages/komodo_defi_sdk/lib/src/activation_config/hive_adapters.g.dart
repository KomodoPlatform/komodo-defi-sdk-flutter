// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class HiveActivationConfigWrapperAdapter
    extends TypeAdapter<HiveActivationConfigWrapper> {
  @override
  final typeId = 20;

  @override
  HiveActivationConfigWrapper read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveActivationConfigWrapper(
      walletId: fields[0] as WalletId,
      configs: (fields[1] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveActivationConfigWrapper obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.walletId)
      ..writeByte(1)
      ..write(obj.configs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveActivationConfigWrapperAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
