# Design Patterns and SOLID Principles Applied

## Overview

The streaming data manager solution demonstrates several OOP and SOLID principles through a generic, reusable architecture for managing streaming data in the Komodo DeFi SDK.

## SOLID Principles Applied

### 1. Single Responsibility Principle (SRP)
Each class has a single, well-defined responsibility:
- `StreamingDataManager<TKey, TData>`: Manages streaming data lifecycle
- `MarketDataKey`: Identifies market data sources
- `BalanceKey`: Identifies balance data sources
- `StreamingConfig`: Holds configuration settings
- `AuthAwareStreamingMixin`: Handles authentication state changes

### 2. Open/Closed Principle (OCP)
The base `StreamingDataManager` is:
- **Open for extension**: Subclasses can override `fetchData()`, `onInitialize()`, and `onDispose()`
- **Closed for modification**: Core streaming logic doesn't need changes for new data types

```dart
// Easy to extend for new data types
class OrderBookManager extends StreamingDataManager<OrderBookKey, OrderBook> {
  @override
  Future<OrderBook> fetchData(OrderBookKey key) async {
    // Custom implementation
  }
}
```

### 3. Liskov Substitution Principle (LSP)
All implementations can be used interchangeably through their interfaces:
```dart
// Both implementations satisfy the contract
StreamingMarketDataManager manager = CexStreamingMarketDataManager(...);
// or
StreamingMarketDataManager manager = AnotherMarketDataImplementation(...);
```

### 4. Interface Segregation Principle (ISP)
Interfaces are focused and specific:
- `StreamingMarketDataManager`: Market data specific methods
- `IBalanceManager`: Balance specific methods
- `DataSourceId`: Minimal interface for data source identification

### 5. Dependency Inversion Principle (DIP)
High-level modules depend on abstractions:
- `StreamingDataManager` depends on abstract `DataSourceId`, not concrete implementations
- Managers depend on repository interfaces, not concrete implementations

## Design Patterns Used

### 1. Template Method Pattern
`StreamingDataManager` defines the algorithm skeleton:
```dart
abstract class StreamingDataManager<TKey, TData> {
  // Template method defining the algorithm
  Stream<TData> watchData(TKey key) {
    // 1. Check cache
    // 2. Start polling
    // 3. Handle retries
    // 4. Emit updates
  }
  
  // Abstract method for subclasses
  Future<TData> fetchData(TKey key);
}
```

### 2. Strategy Pattern
Different fetching strategies can be plugged in:
```dart
class CexStreamingMarketDataManager {
  final CexRepository _priceRepository; // Strategy for price fetching
  final KomodoPriceRepository _komodoPriceRepository; // Alternative strategy
}
```

### 3. Observer Pattern
Stream-based architecture for reactive updates:
```dart
// Observers subscribe to data changes
sdk.marketData.watchMarketData(assetId).listen((data) {
  // React to updates
});
```

### 4. Factory Pattern
`MarketDataManagerFactory` encapsulates object creation:
```dart
class MarketDataManagerFactory {
  static StreamingMarketDataManager create({...}) {
    // Encapsulates creation logic
  }
}
```

### 5. Mixin Pattern
`AuthAwareStreamingMixin` adds authentication awareness:
```dart
class StreamingBalanceManager extends StreamingDataManager<...>
    with AuthAwareStreamingMixin<...> {
  // Gets auth handling capabilities
}
```

## Key Benefits

### 1. Reusability
- Generic base class can be used for any streaming data type
- Common patterns (caching, polling, retry) are implemented once

### 2. Maintainability
- Clear separation of concerns
- Easy to understand and modify individual components
- Consistent patterns across different data managers

### 3. Testability
- Dependencies can be mocked through interfaces
- Each component can be tested in isolation
- Stream-based architecture is easy to test

### 4. Extensibility
- New data types can be added without modifying existing code
- Configuration can be customized per use case
- Mixins allow adding cross-cutting concerns

### 5. Type Safety
- Generic types ensure compile-time safety
- Strong typing prevents runtime errors
- Clear contracts through interfaces

## Usage Patterns

### Basic Usage
```dart
// Simple price watching
final priceStream = sdk.marketData.watchMarketData(btcAsset.id);
```

### Advanced Usage
```dart
// Custom configuration
final manager = MarketDataManagerFactory.create(
  config: StreamingConfig(
    pollingInterval: Duration(seconds: 10),
    maxRetries: 5,
  ),
);

// Combine multiple streams
final portfolio = StreamZip([
  sdk.balances.watchBalance(btc.id),
  sdk.marketData.watchMarketData(btc.id),
]).map((data) => calculateValue(data));
```

### Error Handling
```dart
sdk.marketData.watchMarketData(asset.id).handleError((error) {
  if (error is StateError) {
    // Handle initialization errors
  } else {
    // Handle data fetching errors
  }
});
```
