import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Manual adapter for Asset. We do not use codegen here to avoid generating
// adapters for nested protocol types.

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
    // Reconstruct the top-level config expected by Asset.fromJson by merging
    // the nested 'protocol' and 'id' maps back to the root.
    final idJson = (stored['id'] as Map?)?.cast<String, dynamic>() ?? const {};
    final protocolJson =
        (stored['protocol'] as Map?)?.cast<String, dynamic>() ?? const {};
    final merged = <String, dynamic>{
      ...protocolJson,
      ...idJson,
      if (stored.containsKey('wallet_only'))
        'wallet_only': stored['wallet_only'],
      if (stored.containsKey('sign_message_prefix'))
        'sign_message_prefix': stored['sign_message_prefix'],
    };
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
