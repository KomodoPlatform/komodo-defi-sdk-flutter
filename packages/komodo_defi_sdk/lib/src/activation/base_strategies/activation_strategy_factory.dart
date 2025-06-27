import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/src/activation/protocol_strategies/sia_activation_strategy.dart';

/// Factory for creating the complete activation strategy stack
class ActivationStrategyFactory {
  static SmartAssetActivator createStrategy(
    ApiClient client,
    PrivateKeyPolicy privKeyPolicy,
  ) {
    return SmartAssetActivator(
      client,
      CompositeAssetActivator(client, [
        // BCH strategy needs to be before UTXO strategy to handle the special case
        // BchActivationStrategy(client),
        UtxoActivationStrategy(client, privKeyPolicy),
        Erc20ActivationStrategy(client),
        // SlpActivationStrategy(client),
        TendermintActivationStrategy(client),
        QtumActivationStrategy(client, privKeyPolicy),
        ZhtlcActivationStrategy(client),
        SiaActivationStrategy(client),
        CustomErc20ActivationStrategy(client),
      ]),
    );
  }
}
