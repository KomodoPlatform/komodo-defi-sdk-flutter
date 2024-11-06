import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// lib/src/activation/strategy/activation_strategy.dart (update)

abstract class ActivationStrategyFactory {
  static ActivationStrategy createForAsset(
    Asset asset, {
    bool withBatchSupport = false,
  }) {
    // Create appropriate strategy based on protocol
    return switch (asset.protocol) {
      // ERC20/ETH
      Erc20Protocol() when withBatchSupport =>
        const Erc20BatchActivationStrategy(),
      Erc20Protocol() => const Erc20SingleActivationStrategy(),

      // UTXO
      UtxoProtocol() => const UtxoActivationStrategy(),

      // SLP/BCH
      SlpProtocol() when withBatchSupport => const SlpBatchActivationStrategy(),
      SlpProtocol() => const SlpSingleActivationStrategy(),

      // // QTUM/QRC20
      // QtumProtocol() => const QtumActivationStrategy(),

      // Tendermint
      // TendermintProtocol() ||
      // TendermintTokenProtocol() =>
      //   const TendermintTokenActivationStrategy(),
      _ => throw UnsupportedError(
          'No activation strategy for ${asset.protocol.runtimeType}',
        )
    };
  }
}
