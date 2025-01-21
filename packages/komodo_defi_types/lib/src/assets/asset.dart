import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.protocol,
  });

  factory Asset.fromJsonWithId(JsonMap json, {required AssetId assetId}) {
    // Create protocol of the type specified in the AssetId
    final protocol = ProtocolClass.fromJson(
      json,
      requestedType: assetId.subClass,
    );

    return Asset(id: assetId, protocol: protocol);
  }

  /// Creates a variant of this asset with a different protocol type
  Asset? createVariant(CoinSubClass protocolType) {
    if (!protocol.supportsProtocolType(protocolType)) return null;

    final variantProtocol = protocol.createProtocolVariant(protocolType);
    if (variantProtocol == null) return null;

    return Asset(
      id: id.copyWith(subClass: protocolType),
      protocol: variantProtocol,
    );
  }

  /// Gets all supported protocol variants of this asset
  Set<Asset> get protocolVariants {
    return protocol.supportedProtocols
        .map(createVariant)
        .whereType<Asset>()
        .toSet();
  }

  // /// Gets the appropriate activation strategy for this asset
  // ActivationStrategy get activationStrategy =>
  //     ActivationStrategyFactory.createForAsset(this);

  final AssetId id;
  final ProtocolClass protocol;

  @override
  List<Object?> get props => [id, protocol];

  @override
  String toString() => 'Asset($id)';
}
