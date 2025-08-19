import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manual adapter for Asset. We do not use codegen here to avoid generating
/// adapters for nested protocol types.
class AssetAdapter extends TypeAdapter<Asset> {
  @override
  final int typeId = 15; // next free id per existing registry

  @override
  Asset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final stored = (fields[0] as Map).cast<String, dynamic>();
    // With the fixed Asset.toJson() method, the stored format now matches
    // exactly what Asset.fromJson() expects, so no flattening is needed.
    return Asset.fromJson(stored);
  }

  @override
  void write(BinaryWriter writer, Asset obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.toJson());
  }
}
