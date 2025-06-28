import 'evm_provider.dart';

/// {@template multi_chain_switcher}
/// Handles chain switching logic for injected providers.
/// {@endtemplate}
class MultiChainSwitcher {
  /// {@macro multi_chain_switcher}
  MultiChainSwitcher({required this.evmProvider});

  /// The injected EVM provider.
  final EvmProvider evmProvider;

  /// Switches to the given EVM chain ID.
  Future<void> switchEthereumChain(String chainId) async {
    await evmProvider.switchChain(chainId);
  }

  /// Returns the current EVM chain ID or `null` if none is set.
  String? get currentEthereumChainId => evmProvider.currentChainId;
}
