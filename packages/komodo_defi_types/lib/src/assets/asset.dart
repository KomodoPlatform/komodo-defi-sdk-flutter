import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.protocol,
    required this.isWalletOnly,
  });

  factory Asset.fromJsonWithId(JsonMap json, {required AssetId assetId}) {
    // Create protocol of the type specified in the AssetId
    final protocol = ProtocolClass.fromJson(
      json,
      requestedType: assetId.subClass,
    );

    return Asset(
      id: assetId,
      protocol: protocol,
      isWalletOnly: json.valueOrNull<bool>('wallet_only') ?? false,
    );
  }

  factory Asset.fromJson(JsonMap json) {
    final assetId = AssetId.parse(json, knownIds: const {});
    final protocol = ProtocolClass.fromJson(json);
    return Asset(
      id: assetId,
      protocol: protocol,
      isWalletOnly: json.valueOrNull<bool>('wallet_only') ?? false,
    );
  }

  /// Creates a variant of this asset with a different protocol type
  Asset? createVariant(CoinSubClass protocolType) {
    if (!protocol.supportsProtocolType(protocolType)) return null;

    final variantProtocol = protocol.createProtocolVariant(protocolType);
    if (variantProtocol == null) return null;

    return Asset(
      id: id.copyWith(subClass: protocolType),
      protocol: variantProtocol,
      isWalletOnly: isWalletOnly,
    );
  }

  /// Gets all supported protocol variants of this asset
  Set<Asset> get protocolVariants {
    return protocol.supportedProtocols
        .map(createVariant)
        .whereType<Asset>()
        .toSet();
  }

  final AssetId id;
  final ProtocolClass protocol;
  final bool isWalletOnly;

  JsonMap toJson() => {
    ...protocol.toJson(),
    ...id.toJson(),
    'wallet_only': isWalletOnly,
  };

  @override
  List<Object?> get props => [id, protocol, isWalletOnly];

  @override
  String toString() => 'Asset($id, isWalletOnly: $isWalletOnly)';
}
