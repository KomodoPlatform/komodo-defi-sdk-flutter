import 'package:json_annotation/json_annotation.dart';
import 'package:komodo_defi_types/src/assets/asset_id.dart';

/// Converts [AssetId] values to and from JSON.
///
/// This converter handles the serialization of AssetId objects which require
/// complex parsing logic. For serialization, it uses the AssetId's id field.
/// For deserialization, it creates a minimal AssetId from just the coin id.
class AssetIdConverter implements JsonConverter<AssetId, String> {
  const AssetIdConverter();

  @override
  AssetId fromJson(String json) {
    // Create a minimal JSON map with just the coin identifier
    // This is a simplified approach for cases where we only have the coin ID
    final minimalJson = <String, dynamic>{
      'coin': json,
      'fname': json,
      'type': 'UTXO',
    };
    return AssetId.parse(minimalJson, knownIds: null);
  }

  @override
  String toJson(AssetId object) => object.id;
}
