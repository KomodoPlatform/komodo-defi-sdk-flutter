import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Asset extends Equatable {
  const Asset({required this.id, required this.protocol});

  factory Asset.fromJson(JsonMap json, {AssetId? assetId}) {
    final id = assetId ?? AssetId.fromConfig(json);
    final protocol = ProtocolClass.fromJson(json);

    return Asset(id: id, protocol: protocol);
  }

  // TODO: Differentiate between failed parsing and unsupported assets to make
  // debugging new assets easier
  static Asset? tryParse(JsonMap json, {AssetId? assetId}) {
    try {
      return Asset.fromJson(json, assetId: assetId);
    } catch (e) {
      return null;
    }
  }

  PubkeyStrategy pubkeyStrategy({required bool isHdWallet}) {
    return PubkeyStrategyFactory.createStrategy(
      protocol,
      isHdWallet: isHdWallet,
    );
  }

  final AssetId id;
  final ProtocolClass protocol;

  @override
  List<Object?> get props => [id, protocol];

  @override
  String toString() =>
      'Asset(id: ${id.toJson()}, protocol: ${protocol.toJson()})';

  // Override the equality operator to compare the asset ID only
  @override
  bool operator ==(Object other) {
    if (other is Asset) {
      return id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;
}
