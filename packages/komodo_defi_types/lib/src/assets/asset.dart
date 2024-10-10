import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/types.dart';

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.protocol,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    final assetId = AssetId.fromConfig(json);
    final protocol = ProtocolClass.fromJson(
      // json.value<Map<String, dynamic>>('protocol'),
      json,
    );

    return Asset(
      id: assetId,
      protocol: protocol!,
    );
  }

  final AssetId id;
  final ProtocolClass protocol;

  @override
  List<Object?> get props => [id, protocol];
}
