import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.protocol,
    required this.pubkeyStrategy,
  });

  factory Asset.fromJson(
    Map<String, dynamic> json,
    // { required bool isHdWallet,}
  ) {
    final assetId = AssetId.fromConfig(json);
    final protocol = ProtocolClass.fromJson(
      // json.value<Map<String, dynamic>>('protocol'),
      json,
    );

    // // TODO: Consider if this logic is more appropriate elsewhere as this feels
    // // like a hack.
    // // TODO! Take into account whether we are runnning HD mode or not.
    // final isHd = assetId.derivationPath != null;
    const isHd = true;

    return Asset(
      id: assetId,
      protocol: protocol,
      pubkeyStrategy: preferredPubkeyStrategy(protocol, isHdWallet: isHd),
    );
  }

  // Checks if the coin data represents a supported asset
  static bool isSupported(JsonMap coinData) {
    return ProtocolClass.tryParse(coinData) != null;
  }

  // Determines if an asset should be filtered out based on its strategy
  bool isFilteredOut() {
    return pubkeyStrategy.supportsMultipleAddresses &&
        id.derivationPath == null;
  }

  /// Some assets have multiple supported pubkey strategies. Certain strategies
  /// may be preferred over others as they offer better features or performance.
  // TODO: Consider moving this logic to the Strategy class to keep it
  // encapsulated.
  static PubkeyStrategy preferredPubkeyStrategy(
    ProtocolClass protocol, {
    required bool isHdWallet,
  }) {
    if (!isHdWallet) {
      return SingleAddressStrategy();
    }
    return switch (protocol) {
      UtxoProtocol() => HDWalletStrategy(),
      QtumProtocol() => HDWalletStrategy(),
      Erc20Protocol() => SingleAddressStrategy(),
      EthProtocol() => SingleAddressStrategy(),
      SlpProtocol() => SingleAddressStrategy(),
      ProtocolClass() => throw UnimplementedError(),
    };
  }

  final AssetId id;
  final ProtocolClass protocol;
  final PubkeyStrategy pubkeyStrategy;

  @override
  List<Object?> get props => [id, protocol];
}
