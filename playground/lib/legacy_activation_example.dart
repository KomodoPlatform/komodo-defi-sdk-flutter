import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/activation/activation_config.dart';

/// Example demonstrating how to use legacy activation mode
/// for compatibility with the Postman collection format
class LegacyActivationExample {
  static Future<void> demonstrateLegacyActivation() async {
    // Create API client
    final client = ApiClient(
      baseUrl: 'http://localhost:7783', // Your MM2 server URL
      rpcPass: 'your_rpc_password',
    );

    // Create activation manager with legacy configuration
    final activationManager = ActivationManager(
      client,
      auth, // Your auth instance
      assetHistory, // Your asset history storage
      customTokenHistory, // Your custom token history storage
      assetLookup, // Your asset lookup
      balanceManager, // Your balance manager
      config: ActivationConfig.legacy, // Use legacy mode
    );

    // Example: Activate KMD using legacy electrum method
    // This will use the format shown in the Postman collection:
    // {
    //   "userpass": "your_rpc_password",
    //   "method": "electrum",
    //   "coin": "KMD",
    //   "servers": [
    //     {"url": "electrum1.cipig.net:10001"},
    //     {"url": "electrum2.cipig.net:10001"},
    //     {"url": "electrum3.cipig.net:10001"}
    //   ]
    // }

    try {
      await for (final progress in activationManager.activateAsset(kmdAsset)) {
        print('Activation progress: ${progress.status}');
        
        if (progress.isComplete) {
          if (progress.isSuccess) {
            print('KMD activated successfully!');
            print('Address: ${progress.additionalInfo?['address']}');
            print('Balance: ${progress.additionalInfo?['balance']}');
          } else {
            print('Activation failed: ${progress.errorMessage}');
          }
          break;
        }
      }
    } catch (e) {
      print('Activation error: $e');
    }
  }

  static Future<void> demonstrateHybridMode() async {
    // Create API client
    final client = ApiClient(
      baseUrl: 'http://localhost:7783',
      rpcPass: 'your_rpc_password',
    );

    // Create activation manager with hybrid configuration
    // This supports both legacy and modern modes but prioritizes modern
    final activationManager = ActivationManager(
      client,
      auth,
      assetHistory,
      customTokenHistory,
      assetLookup,
      balanceManager,
      config: ActivationConfig.hybrid,
    );

    // This will try modern task-based activation first,
    // but fall back to legacy electrum method if needed
    try {
      await for (final progress in activationManager.activateAsset(btcAsset)) {
        print('Activation progress: ${progress.status}');
        
        if (progress.isComplete) {
          if (progress.isSuccess) {
            print('BTC activated successfully!');
            print('Mode used: ${progress.additionalInfo?['activationMode']}');
          } else {
            print('Activation failed: ${progress.errorMessage}');
          }
          break;
        }
      }
    } catch (e) {
      print('Activation error: $e');
    }
  }
}

// Example usage in main function
void main() async {
  // Use legacy mode for compatibility with Postman collection
  await LegacyActivationExample.demonstrateLegacyActivation();
  
  // Or use hybrid mode for best of both worlds
  await LegacyActivationExample.demonstrateHybridMode();
}