# Coin Activation Request Format Resolution

## Issue Summary

The Komodo DeFi SDK was experiencing issues with coin activation requests not aligning with the required API format as specified in the Postman collection and API documentation. The problem was that the SDK was only implementing the modern task-based activation methods, but the Postman collection showed examples using the legacy `electrum` method format.

## Problem Analysis

### Current Implementation vs. Postman Collection

**Current SDK Implementation (Task-based):**
```json
{
  "userpass": "your_password",
  "method": "task::enable_utxo::init",
  "mmrpc": "2.0",
  "params": {
    "ticker": "KMD",
    "activation_params": {
      "rpc": "Electrum",
      "rpc_data": {
        "servers": [
          {"url": "electrum1.cipig.net:10001"},
          {"url": "electrum2.cipig.net:10001"},
          {"url": "electrum3.cipig.net:10001"}
        ]
      }
    }
  }
}
```

**Postman Collection Format (Legacy):**
```json
{
  "userpass": "your_password",
  "method": "electrum",
  "coin": "KMD",
  "servers": [
    {"url": "electrum1.cipig.net:10001"},
    {"url": "electrum2.cipig.net:10001"},
    {"url": "electrum3.cipig.net:10001"}
  ]
}
```

### Key Differences

1. **Method Name**: Legacy uses `"electrum"`, modern uses `"task::enable_utxo::init"`
2. **Structure**: Legacy has flat structure, modern nests under `params`
3. **Field Names**: Legacy uses `"coin"`, modern uses `"ticker"`
4. **Server Configuration**: Legacy has direct `servers` array, modern nests under `rpc_data`
5. **MMRPC Version**: Legacy doesn't specify, modern uses `"2.0"`

## Solution Implemented

### 1. Legacy Electrum Method Implementation

Created `LegacyEnableElectrumRequest` class that matches the Postman collection format:

```dart
class LegacyEnableElectrumRequest extends BaseRequest<LegacyEnableElectrumResponse, GeneralErrorResponse> {
  LegacyEnableElectrumRequest({
    required super.rpcPass,
    required this.coin,
    required this.servers,
    // ... other optional parameters
  }) : super(method: 'electrum', mmrpc: null);

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'coin': coin,
    'servers': servers.map((s) => s.toJson()).toList(),
    // ... other fields
  };
}
```

### 2. Legacy Activation Strategy

Created `LegacyUtxoActivationStrategy` that uses the legacy electrum method:

```dart
class LegacyUtxoActivationStrategy extends ActivationStrategy {
  @override
  Stream<ActivationProgress> activate(Asset asset) async* {
    // Convert protocol servers to legacy format
    final legacyServers = protocol.requiredServers
        .map((server) => LegacyElectrumServer(
              url: server.url,
              protocol: server.protocol,
              disableCertVerification: server.disableCertVerification,
            ))
        .toList();

    // Execute legacy electrum activation
    final response = await _client.rpc.legacyActivation.enableElectrum(
      coin: asset.id.id,
      servers: legacyServers,
      // ... other parameters
    );
  }
}
```

### 3. Configuration System

Created `ActivationConfig` to control activation behavior:

```dart
class ActivationConfig {
  const ActivationConfig({
    this.useLegacyMode = false,
    this.legacyModePriority = false,
  });

  static const ActivationConfig modern = ActivationConfig(
    useLegacyMode: false,
    legacyModePriority: false,
  );

  static const ActivationConfig legacy = ActivationConfig(
    useLegacyMode: true,
    legacyModePriority: true,
  );

  static const ActivationConfig hybrid = ActivationConfig(
    useLegacyMode: true,
    legacyModePriority: false,
  );
}
```

### 4. Updated Factory Pattern

Modified `ActivationStrategyFactory` to support both modes:

```dart
static SmartAssetActivator createStrategy(
  ApiClient client,
  PrivateKeyPolicy privKeyPolicy, {
  ActivationConfig config = ActivationConfig.modern,
}) {
  final strategies = <ActivationStrategy>[];

  // Add legacy strategies if enabled
  if (config.useLegacyMode) {
    strategies.add(LegacyUtxoActivationStrategy(client, privKeyPolicy));
  }

  // Add modern strategies
  strategies.addAll([
    UtxoActivationStrategy(client, privKeyPolicy),
    // ... other strategies
  ]);

  return SmartAssetActivator(client, CompositeAssetActivator(client, strategies));
}
```

## Usage Examples

### Legacy Mode (Postman Collection Compatible)

```dart
final activationManager = ActivationManager(
  client,
  auth,
  assetHistory,
  customTokenHistory,
  assetLookup,
  balanceManager,
  config: ActivationConfig.legacy, // Use legacy mode
);

await for (final progress in activationManager.activateAsset(kmdAsset)) {
  // Uses legacy electrum method format
}
```

### Hybrid Mode (Best of Both Worlds)

```dart
final activationManager = ActivationManager(
  client,
  auth,
  assetHistory,
  customTokenHistory,
  assetLookup,
  balanceManager,
  config: ActivationConfig.hybrid, // Supports both modes
);

await for (final progress in activationManager.activateAsset(btcAsset)) {
  // Tries modern first, falls back to legacy if needed
}
```

### Modern Mode (Default)

```dart
final activationManager = ActivationManager(
  client,
  auth,
  assetHistory,
  customTokenHistory,
  assetLookup,
  balanceManager,
  config: ActivationConfig.modern, // Default - modern only
);

await for (final progress in activationManager.activateAsset(btcAsset)) {
  // Uses modern task-based activation
}
```

## Files Modified/Created

### New Files
- `packages/komodo_defi_rpc_methods/lib/src/rpc_methods/activation/legacy_enable_electrum.dart`
- `packages/komodo_defi_rpc_methods/lib/src/rpc_methods/activation/legacy_activation_namespace.dart`
- `packages/komodo_defi_sdk/lib/src/activation/activation_config.dart`
- `packages/komodo_defi_sdk/lib/src/activation/protocol_strategies/legacy_utxo_activation_strategy.dart`
- `playground/lib/legacy_activation_example.dart`

### Modified Files
- `packages/komodo_defi_rpc_methods/lib/src/rpc_methods/rpc_methods.dart`
- `packages/komodo_defi_rpc_methods/lib/src/rpc_methods_library.dart`
- `packages/komodo_defi_sdk/lib/src/activation/base_strategies/activation_strategy_factory.dart`
- `packages/komodo_defi_sdk/lib/src/activation/activation_manager.dart`

## Benefits

1. **Backward Compatibility**: Supports the exact format shown in Postman collection
2. **Flexibility**: Can use legacy, modern, or hybrid modes
3. **Maintainability**: Clean separation between legacy and modern implementations
4. **Extensibility**: Easy to add more legacy methods in the future
5. **Documentation**: Clear examples and configuration options

## Testing

The solution can be tested by:

1. Using `ActivationConfig.legacy` to ensure requests match Postman collection format
2. Comparing request/response formats with the Postman collection examples
3. Verifying that both legacy and modern modes work correctly
4. Testing hybrid mode to ensure proper fallback behavior

## Future Considerations

1. **Deprecation Strategy**: Legacy mode can be deprecated gradually
2. **Additional Legacy Methods**: Can add support for other legacy methods (enable, etc.)
3. **Performance**: Monitor if legacy mode has any performance implications
4. **Documentation**: Update API documentation to reflect both formats