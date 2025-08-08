import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Abstract interface for balance strategies
abstract class BalanceStrategy {
  /// Get the balance for an asset
  Future<BalanceInfo> getBalance(AssetId assetId, ApiClient client);

  /// Watch for balance changes
  Stream<BalanceInfo> watchBalance(
    AssetId assetId,
    ApiClient client, {
    Duration pollingInterval = const Duration(seconds: 30),
  });

  /// Check if this strategy supports the given protocol
  bool protocolSupported(ProtocolClass protocol);
}

/// Factory to create appropriate strategy based on Wallet type and protocol
class BalanceStrategyFactory {
  static BalanceStrategy createStrategy({
    required bool isHdWallet,
    ProtocolClass? protocol,
  }) {
    // For HD wallets, check if the protocol supports multiple addresses
    if (isHdWallet && protocol?.supportsMultipleAddresses == true) {
      return HDWalletBalanceStrategy();
    }

    // Fall back to single address strategy for non-HD wallets or
    // protocols that don't support multiple addresses
    return IguananaWalletBalanceStrategy();
  }
}
