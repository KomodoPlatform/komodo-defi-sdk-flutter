import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy interface for filtering assets based on coin configuration.
abstract class AssetFilterStrategy {
  /// Returns `true` if the asset should be included.
  bool shouldInclude(Asset asset, JsonMap coinConfig);
}

/// Default strategy that includes all assets.
class NoAssetFilterStrategy implements AssetFilterStrategy {
  const NoAssetFilterStrategy();

  @override
  bool shouldInclude(Asset asset, JsonMap coinConfig) => true;
}

/// Filters assets that are not currently supported on Trezor.
/// This includes assets that are not UTXO-based or EVM-based tokens.
/// ETH, AVAX, BNB, FTM, etc. are excluded as they currently fail to
/// activate on Trezor.
/// ERC20, Arbitrum, and MATIC explicitly do not support Trezor via KDF
/// at this time, so they are also excluded.
class TrezorAssetFilterStrategy implements AssetFilterStrategy {
  const TrezorAssetFilterStrategy();

  @override
  bool shouldInclude(Asset asset, JsonMap coinConfig) {
    final subClass = asset.protocol.subClass;

    // AVAX, BNB, ETH, FTM, etc. currently fail to activate on Trezor,
    // so we exclude them from the Trezor asset list.
    return subClass == CoinSubClass.utxo ||
        subClass == CoinSubClass.smartChain ||
        subClass == CoinSubClass.qrc20;
  }
}

/// Filters out assets that are not UTXO-based chains.
class UtxoAssetFilterStrategy implements AssetFilterStrategy {
  const UtxoAssetFilterStrategy();

  @override
  bool shouldInclude(Asset asset, JsonMap coinConfig) {
    final subClass = asset.protocol.subClass;
    return subClass == CoinSubClass.utxo || subClass == CoinSubClass.smartChain;
  }
}

/// Filters assets that are EVM-based tokens.
/// This includes various EVM-compatible chains like Ethereum, Binance, etc.
/// This strategy is necessary for external wallets like Metamask or
/// WalletConnect.
class EvmAssetFilterStrategy implements AssetFilterStrategy {
  const EvmAssetFilterStrategy();

  @override
  bool shouldInclude(Asset asset, JsonMap coinConfig) =>
      evmCoinSubClasses.contains(asset.protocol.subClass);
}
