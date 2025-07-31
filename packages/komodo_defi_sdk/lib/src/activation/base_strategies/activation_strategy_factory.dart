import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Factory for creating the complete activation strategy stack
class ActivationStrategyFactory {
  /// Creates a complete activation strategy stack with all protocols
  /// and returns a [SmartAssetActivator] instance.
  /// [client] The [ApiClient] to use for RPC calls.
  /// [privKeyPolicy] The [PrivateKeyPolicy] to use for private key management.
  /// This is used for external wallet support. E.g. trezor, wallet connect, etc
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
        EthTaskActivationStrategy(client, privKeyPolicy),
        EthWithTokensActivationStrategy(client, privKeyPolicy),
        Erc20ActivationStrategy(client, privKeyPolicy),
        // SlpActivationStrategy(client),
        // Tendermint strategies follow same pattern as ETH: task -> platform -> tokens
        TendermintTaskActivationStrategy(client, privKeyPolicy),
        TendermintWithTokensActivationStrategy(client, privKeyPolicy),
        TendermintTokenActivationStrategy(client, privKeyPolicy),
        QtumActivationStrategy(client, privKeyPolicy),
        ZhtlcActivationStrategy(client, privKeyPolicy),
        CustomErc20ActivationStrategy(client),
      ]),
    );
  }
}
