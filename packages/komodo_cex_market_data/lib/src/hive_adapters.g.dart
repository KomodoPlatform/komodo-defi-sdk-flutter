// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class SparklineDataAdapter extends TypeAdapter<SparklineData> {
  @override
  final typeId = 0;

  @override
  SparklineData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SparklineData(
      data: (fields[0] as List?)?.cast<double>(),
      timestamp: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SparklineData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SparklineDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
