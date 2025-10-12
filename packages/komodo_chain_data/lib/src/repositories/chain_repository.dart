import 'dart:async';

import 'package:komodo_chain_data/src/models/chain_info.dart';

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
