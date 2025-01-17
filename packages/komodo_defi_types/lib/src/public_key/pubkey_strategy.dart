import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// TODO: Refactor strategy consumption so that API client does not need to be
// passed in. See the activation strategy for an example of how this can
// be done.
/// Abstract interface for pubkey strategies
abstract class PubkeyStrategy {
  /// Get all pubkeys for an asset
  Future<AssetPubkeys> getPubkeys(AssetId assetId, ApiClient client);

  /// Get a new address for an asset if supported
  Future<PubkeyInfo> getNewAddress(AssetId assetId, ApiClient client);

  /// Scan for any new addresses
  Future<void> scanForNewAddresses(AssetId assetId, ApiClient client);

  /// Check if this strategy supports the given protocol
  bool protocolSupported(ProtocolClass protocol);

  /// Whether this strategy supports multiple addresses per asset
  bool get supportsMultipleAddresses;
}

/// Factory to create appropriate strategy based on protocol and HD status
class PubkeyStrategyFactory {
  static PubkeyStrategy createStrategy(
    ProtocolClass protocol, {
    required bool isHdWallet,
  }) {
    if (!isHdWallet && protocol.requiresHdWallet) {
      throw UnsupportedProtocolException(
        'Protocol ${protocol.runtimeType} '
        'requires HD wallet but wallet is not in HD mode',
      );
    }

    if (isHdWallet && protocol.supportsMultipleAddresses) {
      return HDWalletStrategy();
    }

    return SingleAddressStrategy();
  }
}

extension AssetPubkeyStrategy on Asset {
  PubkeyStrategy pubkeyStrategy({required bool isHdWallet}) {
    return PubkeyStrategyFactory.createStrategy(
      protocol,
      isHdWallet: isHdWallet,
    );
  }
}
