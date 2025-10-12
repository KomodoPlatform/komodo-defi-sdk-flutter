/// Base class for blockchain chain information.
///
/// Provides a common interface for different blockchain ecosystems
/// (EVM, Cosmos, etc.) to expose chain information in a unified way.
abstract class ChainInfo {
  /// The human-readable name of the chain.
  String get name;

  /// Returns the WalletConnect format chain ID.
  String get walletConnectChainId;

  /// Returns true if this is a testnet chain.
  bool get isTestnet;

  /// Returns true if this is a mainnet chain.
  bool get isMainnet;
}
