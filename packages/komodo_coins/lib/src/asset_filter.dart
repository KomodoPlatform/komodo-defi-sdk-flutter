import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

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

/// Filters assets that do not specify a `trezor_coin` field.
class TrezorAssetFilterStrategy implements AssetFilterStrategy {
  const TrezorAssetFilterStrategy();

  @override
  bool shouldInclude(Asset asset, JsonMap coinConfig) {
    final field = coinConfig.valueOrNull<String>('trezor_coin');
    return field != null && field.isNotEmpty;
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
