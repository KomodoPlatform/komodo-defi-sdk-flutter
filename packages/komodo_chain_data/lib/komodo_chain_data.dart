/// Komodo chain data library for managing blockchain chain information.
///
/// This library provides comprehensive support for blockchain chain information
/// management including Cosmos and EVM chain data. It features:
///
/// * Abstract ChainInfo base class for common chain properties
/// * CosmosChainInfo model with Cosmos ecosystem-specific properties
/// * EvmChainInfo model with EVM ecosystem-specific properties
/// * ChainRepository interface for data access abstraction
/// * Factory constructors for popular chains (Ethereum, Polygon, Cosmos Hub,
///   etc.)
/// * WalletConnect chain ID formatting support
/// * Testnet/mainnet detection logic
/// * JSON serialization with Freezed integration
///
/// ## Usage
///
/// The library is designed to work with the broader Komodo DeFi SDK ecosystem
/// and provides a unified interface for accessing blockchain chain information
/// across different blockchain ecosystems.
///
/// ## Chain Types
///
/// * **Cosmos**: Cosmos SDK-based chains with bech32 addresses and IBC support
/// * **EVM**: Ethereum Virtual Machine compatible chains with hex addresses
///
/// ## Features
///
/// * **Factory Constructors**: Pre-configured popular chains
/// * **WalletConnect Integration**: Proper chain ID formatting for
///   WalletConnect
/// * **Network Detection**: Automatic testnet/mainnet detection
/// * **JSON Serialization**: Full Freezed integration for API compatibility
/// * **Repository Pattern**: Abstract interfaces for flexible data access
library;

// Export all generated indices for comprehensive API coverage
export 'src/_core_index.dart';
export 'src/_internal_exports.dart';
