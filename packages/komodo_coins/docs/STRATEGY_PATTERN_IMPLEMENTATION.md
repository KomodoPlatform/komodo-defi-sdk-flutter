# Strategy Pattern Implementation for Komodo Coins

This document outlines the new strategy pattern architecture implemented for coin configuration management, inspired by the patterns used in `market_data_manager.dart`.

## Overview

The original `KomodoCoins` class has been refactored into a more modular design that separates concerns and provides better extensibility through strategy patterns.

## Architecture

### Core Components

```
StrategicKomodoCoins
├── assets: CoinConfigManager
│   ├── LoadingStrategy (interface)
│   │   ├── StorageFirstLoadingStrategy
│   │   └── AssetBundleFirstLoadingStrategy
│   ├── CoinConfigFallbackMixin
│   └── CoinConfigSource implementations
└── updates: CoinUpdateManager
    ├── UpdateStrategy (interface)
    │   ├── BackgroundUpdateStrategy
    │   ├── ImmediateUpdateStrategy
    │   └── NoUpdateStrategy
    └── Update orchestration logic
```

### Strategy Patterns Applied

#### 1. Loading Strategy Pattern

**Interface**: `LoadingStrategy`
- **Purpose**: Determines how to prioritize different sources for loading coin configurations
- **Implementations**:
  - `StorageFirstLoadingStrategy`: Prefers local storage, falls back to asset bundle
  - `AssetBundleFirstLoadingStrategy`: Prefers asset bundle (useful for testing)

**Sources**: `CoinConfigSource`
- `StorageCoinConfigSource`: Loads from Hive storage
- `AssetBundleCoinConfigSource`: Loads from bundled assets

#### 2. Update Strategy Pattern

**Interface**: `UpdateStrategy` 
- **Purpose**: Controls when and how coin configuration updates are performed
- **Implementations**:
  - `BackgroundUpdateStrategy`: Periodic background updates with configurable intervals
  - `ImmediateUpdateStrategy`: Synchronous updates when requested
  - `NoUpdateStrategy`: Disables updates (useful for offline mode/testing)

#### 3. Fallback Mechanism Pattern

**Mixin**: `CoinConfigFallbackMixin`
- **Purpose**: Provides health tracking, retry logic, and fallback capabilities
- **Features**:
  - Source health monitoring with exponential backoff
  - Automatic failover between sources
  - Retry logic with configurable attempts
  - Source availability checking

## Key Benefits

### 1. Separation of Concerns
- **Asset Management**: `CoinConfigManager` handles fetching, caching, and filtering
- **Update Management**: `CoinUpdateManager` handles synchronization and updates
- **Strategy Selection**: Configurable strategies for different use cases

### 2. Improved Testability
- Strategies can be easily mocked or replaced for testing
- Different behaviors can be tested in isolation
- Clear separation makes unit testing more focused

### 3. Better Error Handling
- Health tracking prevents repeated failures from bad sources
- Fallback mechanisms ensure reliability
- Detailed logging for debugging

### 4. Flexibility
- Easy to add new loading or update strategies
- Runtime strategy selection based on configuration
- Extensible architecture for future enhancements

## Usage Examples

### Basic Usage (Similar to Original API)

```dart
final coins = StrategicKomodoCoins();
await coins.init();

// Access assets (backward compatible)
final allAssets = coins.all;
final filteredAssets = coins.filteredAssets(someStrategy);

// Check for updates
final hasUpdate = await coins.isUpdateAvailable();
if (hasUpdate) {
  await coins.updateNow();
}
```

### Advanced Usage with Custom Strategies

```dart
final coins = StrategicKomodoCoins(
  loadingStrategy: AssetBundleFirstLoadingStrategy(),
  updateStrategy: ImmediateUpdateStrategy(),
  enableAutoUpdate: false,
);
await coins.init();

// Access managers directly
final assets = coins.assets.all;
final updateResult = await coins.updates.updateNow();

// Monitor updates
coins.updateStream.listen((result) {
  if (result.success) {
    print('Update completed: ${result.updatedAssetCount} assets');
  }
});
```

### Disable Updates for Testing

```dart
final coins = StrategicKomodoCoins(
  updateStrategy: NoUpdateStrategy(),
  enableAutoUpdate: false,
);
```

## Migration Guide

### For Existing Code

The new `StrategicKomodoCoins` maintains backward compatibility for most operations:

```dart
// Old way
final coins = KomodoCoins();
await coins.init();
final assets = coins.all;

// New way (same API)
final coins = StrategicKomodoCoins();
await coins.init();
final assets = coins.all;
```

### For Advanced Use Cases

Access to managers provides more granular control:

```dart
// Asset operations
await coins.assets.refreshAssets();
final healthStatus = coins.assets.getSourceHealthStatus();

// Update operations
coins.updates.startBackgroundUpdates();
coins.updates.stopBackgroundUpdates();
final isUpdating = coins.updates.isBackgroundUpdatesActive;
```

## Configuration Options

### LoadingStrategy Options

- `StorageFirstLoadingStrategy()`: Default, prefers storage
- `AssetBundleFirstLoadingStrategy()`: Prefers bundled assets

### UpdateStrategy Options

- `BackgroundUpdateStrategy(updateInterval: Duration(hours: 6))`: Configurable background updates
- `ImmediateUpdateStrategy()`: Immediate synchronous updates
- `NoUpdateStrategy()`: Disable all updates

### Fallback Configuration

The fallback mechanism uses these defaults:
- **Backoff Duration**: 10 minutes
- **Max Failure Count**: 3 attempts
- **Retry Strategy**: Exponential backoff with jitter

## Static Method Compatibility

The static `fetchAndTransformCoinsList()` method remains unchanged for mm2 integration:

```dart
final coinsList = await StrategicKomodoCoins.fetchAndTransformCoinsList();
// Returns JsonList for mm2 initialization
```

## Future Enhancements

The strategy pattern architecture enables future enhancements:

1. **Additional Loading Strategies**:
   - Network-first strategy
   - Hybrid strategies combining multiple sources
   - User preference-based strategies

2. **Additional Update Strategies**:
   - Smart update strategy based on usage patterns
   - Conditional update strategy based on network conditions
   - User-triggered update strategy

3. **Enhanced Monitoring**:
   - Metrics collection for strategy performance
   - Health monitoring dashboards
   - Automated strategy selection based on performance

## Testing Strategy

The new architecture enables comprehensive testing:

1. **Unit Tests**: Each strategy can be tested in isolation
2. **Integration Tests**: Manager interactions with different strategies
3. **E2E Tests**: Full workflow with various strategy combinations
4. **Mock Testing**: Easy to mock sources and strategies

## Performance Considerations

- **Caching**: Intelligent caching at multiple levels
- **Lazy Loading**: Sources are only accessed when needed
- **Background Operations**: Non-blocking updates and health checks
- **Resource Management**: Proper cleanup and disposal patterns
