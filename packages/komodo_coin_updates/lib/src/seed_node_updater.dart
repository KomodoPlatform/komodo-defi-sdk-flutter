import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Service responsible for fetching and managing seed nodes from remote sources.
///
/// This service handles the downloading and parsing of seed node configurations
/// from the Komodo Platform repository.
class SeedNodeUpdater {
  // TODO(@takenagain): Bring in line with coins config wrt how the file is
  // fetched, persisted and handles fallback to local asset.
  /// Fetches and parses the seed nodes configuration from the Komodo Platform repository.
  ///
  /// Returns a list of [SeedNode] objects that can be used for P2P networking.
  ///
  /// Throws an exception if the seed nodes cannot be fetched or parsed.
  static Future<({List<SeedNode> seedNodes, int netId})> fetchSeedNodes({
    bool filterForWeb = kIsWeb,
  }) async {
    const seedNodesUrl =
        'https://komodoplatform.github.io/coins/seed-nodes.json';

    try {
      final response = await http.get(Uri.parse(seedNodesUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch seed nodes. Status code: ${response.statusCode}',
        );
      }

      final seedNodesJson = jsonListFromString(response.body);
      var seedNodes = SeedNode.fromJsonList(seedNodesJson);

      // Extract netid from the first node if available
      final netId = seedNodes.isNotEmpty ? seedNodes.first.netId : 8762;

      if (filterForWeb && kIsWeb) {
        seedNodes = seedNodes.where((e) => e.wss).toList();
      }

      return (seedNodes: seedNodes, netId: netId);
    } catch (e) {
      debugPrint('Error fetching seed nodes: $e');
      throw Exception('Failed to fetch or process seed nodes: $e');
    }
  }

  /// Converts a list of [SeedNode] objects to a list of strings in the format
  /// expected by the KDF startup configuration.
  ///
  /// This method extracts the host addresses from the seed nodes to create
  /// a simple string list that can be used in the startup configuration.
  static List<String> seedNodesToStringList(List<SeedNode> seedNodes) {
    return seedNodes.map((node) => node.host).toList();
  }
}
