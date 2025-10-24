import 'package:http/http.dart' as http;
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Example demonstrating the improved testability of the seed nodes functionality
/// with injectable HTTP client and timeout handling.
void main() async {
  print('=== Testing SeedNodeUpdater improvements ===\n');

  // Create a default config for the example
  const config = AssetRuntimeUpdateConfig();

  await demonstrateDefaultBehavior(config);
  await demonstrateTimeoutHandling(config);
  await demonstrateCustomClient(config);
}

/// Shows the default behavior (same as before, but now with timeout protection)
Future<void> demonstrateDefaultBehavior(AssetRuntimeUpdateConfig config) async {
  try {
    print('1. Default behavior with automatic timeout:');
    final (seedNodes: seedNodes, netId: netId) =
        await SeedNodeUpdater.fetchSeedNodes(config: config);

    print('   Found ${seedNodes.length} seed nodes on netid $netId');
    print('   ✓ Request completed with default 15-second timeout\n');
  } catch (e) {
    print('   Error: $e\n');
  }
}

/// Shows custom timeout handling
Future<void> demonstrateTimeoutHandling(AssetRuntimeUpdateConfig config) async {
  try {
    print('2. Custom timeout (5 seconds):');
    final (
      seedNodes: seedNodes,
      netId: netId,
    ) = await SeedNodeUpdater.fetchSeedNodes(
      config: config,
      timeout: const Duration(seconds: 5),
    );

    print('   Found ${seedNodes.length} seed nodes on netid $netId');
    print('   ✓ Request completed within custom 5-second timeout\n');
  } catch (e) {
    print('   Error (expected if network is slow): $e\n');
  }
}

/// Shows how to inject a custom HTTP client for testing or special configurations
Future<void> demonstrateCustomClient(AssetRuntimeUpdateConfig config) async {
  try {
    print('3. Custom HTTP client with specific configuration:');

    // Create a custom client with specific settings
    final customClient = http.Client();

    final (
      seedNodes: seedNodes,
      netId: netId,
    ) = await SeedNodeUpdater.fetchSeedNodes(
      config: config,
      httpClient: customClient,
      timeout: const Duration(seconds: 10),
    );

    print('   Found ${seedNodes.length} seed nodes on netid $netId');
    print('   ✓ Request completed with injected HTTP client');

    // The client is automatically managed (not closed) when provided
    customClient.close(); // We close it manually since we created it
    print('   ✓ Custom client properly closed\n');
  } catch (e) {
    print('   Error: $e\n');
  }
}
