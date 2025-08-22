import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Example demonstrating how to use the new seed nodes functionality
void main() async {
  try {
    // Create a default config for the example
    const config = AssetRuntimeUpdateConfig();

    // Fetch seed nodes from the remote source
    print('Fetching seed nodes from remote source...');
    final (seedNodes: seedNodes, netId: netId) =
        await SeedNodeUpdater.fetchSeedNodes(config: config);

    print('Found ${seedNodes.length} seed nodes on netid $netId:');
    for (final node in seedNodes) {
      print('  - ${node.name}: ${node.host}');
      if (node.contact.isNotEmpty && node.contact.first.email.isNotEmpty) {
        print('    Contact: ${node.contact.first.email}');
      }
    }

    // Convert to string list for use in KDF startup config
    print('\nSeed node hosts for KDF config:');
    final hostList = SeedNodeUpdater.seedNodesToStringList(seedNodes);
    for (final host in hostList) {
      print('  - $host');
    }

    // Example of how this would be used in practice
    print('\nExample usage in KDF startup config:');
    print('// Fetch seed nodes using the service');
    print('final seedNodes = await SeedNodeService.fetchSeedNodes();');
    print('');
    print('// Use them in startup config');
    print('KdfStartupConfig.generateWithDefaults(');
    print('  walletName: "MyWallet",');
    print('  walletPassword: "password",');
    print('  enableHd: true,');
    print('  seedNodes: seedNodes, // Pass the fetched seed nodes');
    print(');');
  } catch (e) {
    print('Error: $e');
  }
}
