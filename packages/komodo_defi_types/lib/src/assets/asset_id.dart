import 'package:komodo_defi_types/src/utils/json_type_utils.dart';

class AssetId {
  const AssetId({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
  });

  // FromJSON
  factory AssetId.fromJson(Map<String, dynamic> json) {
    return AssetId(
      id: json.value<String>('id'),
      name: json.value<String>('name'),
      symbol: json.value<String>('symbol'),
      chainId: json.value<String>('chain_id'),
    );
  }

  final String id;
  final String name;
  final String symbol;

  // TODO! Replace with `Chain` type
  final String chainId;
}
