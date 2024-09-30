import 'package:komodo_defi_types/src/assets/asset_id.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';

class Asset {
  const Asset({
    required this.id,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: AssetId.fromJson(json.value<Map<String, dynamic>>('id')),
    );
  }

  final AssetId id;
}
