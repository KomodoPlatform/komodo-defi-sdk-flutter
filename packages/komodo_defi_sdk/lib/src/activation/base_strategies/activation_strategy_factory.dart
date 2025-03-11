import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Factory for creating the complete activation strategy stack
class ActivationStrategyFactory {
  static SmartAssetActivator createStrategy(ApiClient client) {
    return SmartAssetActivator(
      client,
      CompositeAssetActivator(client, [
        // BCH strategy needs to be before UTXO strategy to handle the special case
        // BchActivationStrategy(client),
        UtxoActivationStrategy(client),
        Erc20ActivationStrategy(client),
        // SlpActivationStrategy(client),
        TendermintActivationStrategy(client),
        QtumActivationStrategy(client),
        ZhtlcActivationStrategy(client),
        CustomErc20ActivationStrategy(client),
      ]),
    );
  }
}
