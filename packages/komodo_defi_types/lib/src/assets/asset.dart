import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/types.dart';

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.protocol,
    required this.pubkeyStrategy,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    final assetId = AssetId.fromConfig(json);
    final protocol = ProtocolClass.fromJson(
      // json.value<Map<String, dynamic>>('protocol'),
      json,
    );

    return Asset(
      id: assetId,
      protocol: protocol,
      pubkeyStrategy: preferredPubkeyStrategy(protocol),
    );
  }

  /// Some assets have multiple supported pubkey strategies. Certain strategies
  /// may be preferred over others as they offer better features or performance.
  // TODO: Consider moving this logic to the Strategy class to keep it
  // encapsulated.
  static PubkeyStrategy preferredPubkeyStrategy(ProtocolClass protocol) {
    return switch (protocol) {
      UtxoProtocol() => HDWalletStrategy(),
      QtumProtocol() => HDWalletStrategy(),
      Erc20Protocol() => SingleAddressStrategy(),
      EthProtocol() => SingleAddressStrategy(),
      SlpProtocol() => SingleAddressStrategy(),
    };
  }

  final AssetId id;
  final ProtocolClass protocol;
  final PubkeyStrategy pubkeyStrategy;

  @override
  List<Object?> get props => [id, protocol];
}
