import 'package:komodo_defi_types/src/common_structures/general/balance_info.dart';
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

/// Factory to create appropriate strategy based on Wallet type
class BalanceStrategyFactory {
  static BalanceStrategy createStrategy({required bool isHdWallet}) {
    if (isHdWallet) {
      return HDWalletBalanceStrategy();
    }

    return IguananaWalletBalanceStrategy();
  }
}
