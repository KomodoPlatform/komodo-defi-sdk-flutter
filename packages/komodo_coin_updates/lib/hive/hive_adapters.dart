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
    // Stored shape is Asset.toJson(): { 'protocol': {...}, 'id': {...}, ... }
    // Reconstruct the top-level config expected by Asset.fromJson by starting
    // from a full copy of the stored map and flattening nested 'protocol' and
    // 'id' maps so that all other top-level fields are preserved.
    final merged = Map<String, dynamic>.from(stored);
    final idJson =
        (merged.remove('id') as Map?)?.cast<String, dynamic>() ?? const {};
    final protocolJson =
        (merged.remove('protocol') as Map?)?.cast<String, dynamic>() ??
        const {};
    merged
      ..addAll(protocolJson)
      ..addAll(idJson);
    return Asset.fromJson(merged);
  }

  @override
  void write(BinaryWriter writer, Asset obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.toJson());
  }
}
