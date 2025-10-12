# Komodo Chain Data

A library package that provides blockchain chain information models, repositories, and utilities for the Komodo DeFi ecosystem.

## Features

- **Chain Information Models**: Comprehensive data models for different blockchain types
  - Cosmos chain information with ecosystem-specific properties
  - EVM chain information with Ethereum-compatible properties
  - Abstract base classes for extensibility

- **Repository Interfaces**: Clean abstractions for chain data access
  - Abstract repository pattern for data access
  - Support for caching and refresh strategies
  - Extensible for different data sources

- **Type Safety**: Built with Dart's strong type system
  - Freezed data classes for immutability
  - JSON serialization support
  - Comprehensive validation

## Supported Chain Types

### Cosmos Chains
- Cosmos Hub
- Osmosis
- Juno
- Akash
- Secret Network
- Custom Cosmos chains

### EVM Chains
- Ethereum
- Polygon
- BNB Smart Chain
- Avalanche
- Fantom
- Custom EVM chains

## Usage

```dart
import 'package:komodo_chain_data/komodo_chain_data.dart';

// Access predefined chain configurations
final cosmosHub = CosmosChainInfo.cosmosHub();
final ethereum = EvmChainInfo.ethereum();

// Get WalletConnect chain IDs
final cosmosWcId = cosmosHub.walletConnectChainId; // "cosmos:cosmoshub-4"
final ethWcId = ethereum.walletConnectChainId; // "eip155:1"

// Check network types
final isTestnet = cosmosHub.isTestnet; // false
final isMainnet = ethereum.isMainnet; // true
```

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  komodo_chain_data: ^0.0.1+1
```

## Development

This package uses code generation for Freezed models and JSON serialization:

```bash
# Generate code
dart run build_runner build --delete-conflicting-outputs

# Generate index files
dart run index_generator
```

## Testing

Run tests using Flutter test command:

```bash
flutter test
```

## Contributing

This package is part of the Komodo DeFi SDK monorepo. Please follow the established patterns and conventions when contributing.

## License

This project is licensed under the MIT License - see the LICENSE file for details.