import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
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
    // Convert the stored map to ensure it's the expected Map<String, dynamic>
    // type before passing to Asset.fromJson to avoid type casting issues
    final convertedMap = convertToJsonMap(stored);
    return Asset.fromJson(convertedMap);
  }

  @override
  void write(BinaryWriter writer, Asset obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      // We use the raw protocol config map to avoid issues with nested types
      // and inconsistent toJson/fromJson behaviour with the Asset class.
      ..write(obj.protocol.config);
  }
}
