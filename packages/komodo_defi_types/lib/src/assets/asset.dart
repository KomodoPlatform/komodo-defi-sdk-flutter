import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Asset extends Equatable {
  const Asset({required this.id, required this.protocol});

  factory Asset.fromJson(Map<String, dynamic> json) {
    final assetId = AssetId.fromConfig(json);
    final protocol = ProtocolClass.fromJson(json);

    return Asset(id: assetId, protocol: protocol);
  }

  static Asset? tryParse(Map<String, dynamic> json) {
    try {
      return Asset.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // // Checks if the coin data represents a supported asset
  // static bool isSupported(JsonMap coinData) {
  //   return ProtocolClass.tryParse(coinData) != null;
  // }

  // TODO: Refactor so that this doesn't need to be passed in if using the
  // main SDK package.
  PubkeyStrategy pubkeyStrategy({
    required bool isHdWallet,
  }) {
    return preferredPubkeyStrategy(protocol, isHdWallet: isHdWallet);
  }

  /// Some assets have multiple supported pubkey strategies. Certain strategies
  /// may be preferred over others as they offer better features or performance.
  // TODO: Consider moving this logic to the Strategy class to keep it
  // encapsulated.
  @Deprecated('Use `PubkeyStrategyFactory` instead.')
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

  @override
  List<Object?> get props => [id, protocol];
}
