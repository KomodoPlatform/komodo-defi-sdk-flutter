import 'dart:async';

/// Abstract base class for blockchain chain repositories.
///
/// Provides a common interface for fetching, caching, and managing
/// blockchain chain information from external sources.
abstract class ChainRepository {
  /// Gets the list of chains, fetching from remote if cache is stale.
  Future<List<ChainInfo>> getChains();

  /// Forces a refresh of chain data from the remote source.
  Future<void> refreshChains();

  /// Returns cached chain data without making network requests.
  List<ChainInfo> getCachedChains();

  /// Checks if the cached data is still valid.
  bool get isCacheValid;

  /// Disposes of any resources used by the repository.
  void dispose();
}

/// Base class for blockchain chain information.
abstract class ChainInfo {
  const ChainInfo({
    required this.chainId,
    required this.name,
    this.rpc,
    this.nativeCurrency,
  });

  /// The unique identifier for this chain.
  final String chainId;

  /// The human-readable name of the chain.
  final String name;

  /// Optional RPC endpoint URL.
  final String? rpc;

  /// Optional native currency information.
  final String? nativeCurrency;

  /// Converts this chain info to a JSON map.
  Map<String, dynamic> toJson();

  /// Creates a chain info instance from a JSON map.
  static ChainInfo fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }

  @override
  String toString() => 'ChainInfo(chainId: $chainId, name: $name)';
}
