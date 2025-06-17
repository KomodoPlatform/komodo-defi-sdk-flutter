import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/src/config/kdf_logging_config.dart';
import 'package:komodo_defi_framework/src/config/seed_node_validator.dart';

/// Service class responsible for fetching and managing seed nodes.
///
/// This class follows the Single Responsibility Principle by focusing
/// solely on seed node acquisition and management.
class SeedNodeService {
  /// Fetches seed nodes from the remote configuration with fallback to defaults.
  ///
  /// This method attempts to fetch the latest seed nodes from the Komodo Platform
  /// repository and converts them to the string format expected by the KDF startup
  /// configuration.
  ///
  /// Returns a list of seed node host addresses. If fetching fails, returns
  /// the hardcoded default seed nodes as a fallback.
  static Future<({List<String> seedNodes, int netId})> fetchSeedNodes({
    bool filterForWeb = kIsWeb,
  }) async {
    try {
      final (
        seedNodes: nodes,
        netId: netId,
      ) = await SeedNodeUpdater.fetchSeedNodes(filterForWeb: filterForWeb);

      return (
        seedNodes: SeedNodeUpdater.seedNodesToStringList(nodes),
        netId: netId,
      );
    } catch (e) {
      if (KdfLoggingConfig.verboseLogging) {
        print('WARN Failed to fetch seed nodes from remote: $e');
        print('WARN Falling back to default seed nodes');
      }
      return (
        seedNodes: getDefaultSeedNodes(),
        netId: 8762,
      );
    }
  }

  /// Gets the default seed nodes if remote fetching fails.
  ///
  /// Note: From v2.5.0-beta, there will be no default seed nodes,
  /// and the seednodes parameter will be required unless disable_p2p is set to true.
  static List<String> getDefaultSeedNodes() {
    return SeedNodeValidator.getDefaultSeedNodes();
  }

  /// Gets seed nodes based on configuration preferences.
  ///
  /// This is a convenience method that determines the appropriate seed nodes
  /// based on P2P settings and provided seed nodes.
  ///
  /// Returns:
  /// - `null` if P2P is disabled
  /// - Provided [seedNodes] if they are specified
  /// - Remote seed nodes if [fetchRemote] is true
  /// - Default seed nodes as fallback
  static Future<List<String>?> getSeedNodes({
    List<String>? seedNodes,
    bool? disableP2p,
    bool fetchRemote = true,
  }) async {
    // If P2P is disabled, no seed nodes are needed
    if (disableP2p == true) {
      return null;
    }

    // Use explicitly provided seed nodes if available
    if (seedNodes != null && seedNodes.isNotEmpty) {
      return seedNodes;
    }

    // Fetch remote seed nodes or use defaults
    if (fetchRemote) {
      final result = await fetchSeedNodes();
      return result.seedNodes;
    } else {
      return getDefaultSeedNodes();
    }
  }
}
