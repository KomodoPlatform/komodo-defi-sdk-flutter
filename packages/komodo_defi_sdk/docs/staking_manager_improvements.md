# StakingManager Improvement Guide

This document outlines proposed improvements to make the `StakingManager` class more developer-friendly and abstracted, following patterns established by other SDK managers like `BalanceManager`, `PubkeyManager`, and `TransactionHistoryManager`.

## Overview

The current `StakingManager` is a thin wrapper around API methods. This guide proposes higher-level abstractions that:

- Hide complexity from developers who don't have deep staking knowledge
- Provide smart defaults and automated features
- Offer real-time state management and monitoring
- Include convenience methods for common use cases

### Important Note on AssetId

Throughout this document, `AssetId` refers to the full asset identifier object (as defined in `packages/komodo_defi_types/lib/src/assets/asset_id.dart`), not just a string ticker. The `AssetId` class contains:

- `id` - The coin ticker (e.g., "ATOM")
- `name` - The full name (e.g., "Cosmos Hub")
- `symbol` - The asset symbol information
- `chainId` - Chain-specific identifier
- `subClass` - The coin type (e.g., Tendermint, UTXO)
- Other metadata

When interfacing with the underlying RPC API (which expects string coin tickers), methods should use `assetId.id` to extract the ticker string.

## Proposed Improvements

### 1. Simplified Staking Methods

Replace low-level API wrappers with high-level, intuitive methods:

```dart
/// Simple one-call staking with smart defaults
Future<StakingResult> stake({
  required AssetId assetId,
  required Amount amount,
  String? validatorAddress, // Optional - auto-selects best if not provided
  StakingStrategy strategy = StakingStrategy.balanced,
}) async {
  // Ensure asset is activated using the coordinator
  final asset = _assetProvider.fromId(assetId);
  if (asset == null) {
    throw ArgumentError('Asset not found: ${assetId.name}');
  }

  final activationResult = await _activationCoordinator.activateAsset(asset);
  if (activationResult.isFailure) {
    throw StakingException.activationFailed(
      assetId,
      activationResult.errorMessage!,
    );
  }

  // Auto-select validator(s) based on strategy
  // Handle minimum staking amounts
  // Return comprehensive result with tx info
}

/// Unstake with convenience options
Future<UnstakingResult> unstake({
  required AssetId assetId,
  Amount? amount, // null = unstake all
  String? validatorAddress, // null = unstake from all
  bool claimRewards = true, // Auto-claim rewards before unstaking
}) async {
  // Handle multiple validators
  // Manage unbonding periods
  // Return result with expected completion time
}

/// One-click optimal staking
Future<QuickStakeResult> quickStake({
  required AssetId assetId,
  required Amount amount,
}) async {
  // Auto-select best validators
  // Split across multiple for decentralization
  // Handle all complexity internally
}
```

### 2. Real-time Staking State Management

Provide streaming updates and comprehensive state tracking:

```dart
/// Watch staking state with automatic updates
Stream<StakingState> watchStakingState(AssetId assetId) {
  // Combines delegations, rewards, and undelegations
  // Updates on new blocks/events
  // Includes calculated APY and other metrics
}

/// Get comprehensive staking info
Future<StakingInfo> getStakingInfo(AssetId assetId) async {
  return StakingInfo(
    totalStaked: totalAmount,
    availableBalance: availableForStaking,
    pendingRewards: totalRewards,
    validators: validatorInfoList,
    unbondingAmount: totalUnbonding,
    estimatedAPY: calculatedAPY,
    nextRewardTime: estimatedTime,
  );
}

/// Get last known staking state without refresh
StakingState? lastKnownState(AssetId assetId) {
  // Return cached state immediately
}
```

### 3. Smart Validator Selection

Help developers choose validators without deep knowledge:

```dart
/// Get recommended validators based on criteria
Future<List<ValidatorRecommendation>> getRecommendedValidators({
  required AssetId assetId,
  ValidatorSelectionCriteria criteria = const ValidatorSelectionCriteria(),
}) async {
  // Score validators based on:
  // - Commission rates
  // - Uptime/reliability
  // - Decentralization (avoid concentration)
  // - Current delegation amounts
}

/// Rebalance staking across validators
Future<RebalanceResult> rebalanceStaking({
  required AssetId assetId,
  StakingStrategy strategy = StakingStrategy.balanced,
}) async {
  // Analyze current distribution
  // Calculate optimal distribution
  // Execute rebalancing transactions
}

/// Get staking suggestions
Future<StakingSuggestions> getStakingSuggestions(AssetId assetId) async {
  return StakingSuggestions(
    recommendedAmount: optimalStakingAmount,
    expectedReturns: projectedRewards,
    riskLevel: StakingRisk.low,
    suggestedValidators: topValidators,
    warnings: [/* e.g., "High concentration with validator X" */],
  );
}
```

### 4. Automated Reward Management

Simplify reward claiming and provide automation options:

```dart
/// Claim all rewards with options
Future<ClaimResult> claimAllRewards({
  required AssetId assetId,
  bool autoRestake = false, // Auto-compound rewards
  Amount? minClaimAmount, // Skip if rewards below threshold
}) async {
  // Aggregate rewards from all validators
  // Handle gas optimization
  // Optional auto-restaking
}

/// Watch rewards accumulation
Stream<RewardUpdate> watchRewards(AssetId assetId) {
  // Real-time reward tracking
  // Includes estimated next reward
  // APY calculations
}

/// Set up auto-claiming
Future<void> enableAutoClaim({
  required AssetId assetId,
  Duration interval = const Duration(days: 7),
  bool autoCompound = true,
  Amount? minAmount,
}) async {
  // Schedule automatic reward claiming
  // Handle compound staking
}
```

### 5. Enhanced State Types

Define rich data types that provide all needed information:

```dart
/// Comprehensive staking state
class StakingState {
  final List<StakingPosition> positions; // All delegations
  final Amount totalStaked;
  final Amount pendingRewards;
  final List<UnbondingPosition> unbonding;
  final double currentAPY;
  final DateTime lastUpdated;
  final StakingHealth health; // Good, Warning, Critical

  /// Convenience getters
  bool get hasRewardsToClaim => pendingRewards > minClaimThreshold;
  Duration get timeToNextReward => ...;
  Amount get totalValue => totalStaked + pendingRewards;
  bool get isFullyUnbonding => positions.isEmpty && unbonding.isNotEmpty;
}

/// Staking position details
class StakingPosition {
  final String validatorAddress;
  final ValidatorInfo validator;
  final Amount stakedAmount;
  final Amount rewards;
  final DateTime stakedAt;
  final double validatorAPY;

  /// Convenience methods
  bool get isActive => validator.isActive;
  Duration get stakingDuration => DateTime.now().difference(stakedAt);
}

/// Unbonding position
class UnbondingPosition {
  final String validatorAddress;
  final Amount amount;
  final DateTime completionTime;
  final String transactionId;

  Duration get timeRemaining => completionTime.difference(DateTime.now());
  bool get isComplete => DateTime.now().isAfter(completionTime);
}

/// Staking strategies
enum StakingStrategy {
  /// Maximize returns (higher risk)
  aggressive,
  /// Balance returns and safety
  balanced,
  /// Prioritize safety and decentralization
  conservative,
  /// Custom validator selection
  custom,
}
```

### 6. Error Handling & Validation

Provide clear validation and meaningful errors:

```dart
/// Pre-validate staking operations
Future<ValidationResult> validateStaking({
  required AssetId assetId,
  required Amount amount,
  String? validatorAddress,
}) async {
  // Check minimum amounts
  // Verify validator status
  // Check available balance
  // Return detailed validation info
}

/// Enhanced error types
class StakingException implements Exception {
  factory StakingException.belowMinimum(Amount min, Amount provided) = ...;
  factory StakingException.validatorInactive(String address) = ...;
  factory StakingException.validatorJailed(String address) = ...;
  factory StakingException.insufficientBalance() = ...;
  factory StakingException.unbondingPeriodActive() = ...;
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final StakingSuggestion? suggestion;

  bool get hasWarnings => issues.any((i) => i.severity == IssueSeverity.warning);
  bool get hasErrors => issues.any((i) => i.severity == IssueSeverity.error);
}
```

### 7. Performance & Caching

Implement efficient data management:

```dart
class StakingManager {
  /// Cache configuration
  static const _validatorCacheTTL = Duration(minutes: 15);
  static const _stakingStateCacheTTL = Duration(minutes: 5);

  /// Caches
  final _validatorCache = <AssetId, CachedData<List<ValidatorInfo>>>{};
  final _stakingStateCache = <AssetId, StakingState>{};
  final _rewardRateCache = <String, double>{}; // validator -> APY

  /// Pre-cache staking data during asset activation
  Future<void> preCacheStakingData(Asset asset) async {
    // Use asset.id when caching and asset.id.id for RPC calls
    final validators = await _client.rpc.staking.queryValidators(
      coin: asset.id.id, // Extract ticker string for RPC
      infoDetails: defaultInfoDetails,
    );
    _validatorCache[asset.id] = CachedData(validators, DateTime.now());

    // Get initial staking state
    // Calculate reward rates
  }

  /// Batch operations for efficiency
  Future<BatchStakingResult> batchStake({
    required AssetId assetId,
    required List<StakingInstruction> instructions,
  }) async {
    // Execute multiple staking operations efficiently
  }
}
```

### 8. Integration Patterns

Show how the improved manager integrates with other SDK components:

```dart
class StakingManager {
  StakingManager(
    this._client,
    this._assetProvider,
    this._activationCoordinator, // Use SharedActivationCoordinator
    this._balanceManager, // New dependency
    this._transactionManager, // New dependency
  );

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final SharedActivationCoordinator _activationCoordinator;
  final BalanceManager _balanceManager;
  final TransactionHistoryManager _transactionManager;

  /// Ensure asset is activated using the shared coordinator
  Future<void> _ensureActivated(String ticker) async {
    final asset = _assetProvider.findAssetsByConfigId(ticker).firstOrNull;
    if (asset != null) {
      final result = await _activationCoordinator.activateAsset(asset);
      if (result.isFailure) {
        throw Exception('Failed to activate $ticker: ${result.errorMessage}');
      }
    }
  }

  /// Coordinate with BalanceManager
  Stream<StakingState> watchStakingState(AssetId assetId) async* {
    // Ensure asset is activated first
    await _ensureActivated(assetId.id);

    // Watch balance changes
    await for (final balance in _balanceManager.watchBalance(assetId)) {
      // Update staking state when balance changes
      yield await _recalculateStakingState(assetId, balance);
    }
  }

  /// Coordinate with TransactionManager
  Future<void> _trackStakingTransaction(String txHash, AssetId assetId) async {
    // Register transaction for history tracking
    // Update state when transaction confirms
  }
}
```

## Example Usage

### Basic Staking

```dart
// Simple staking with auto-selection
final atomAsset = assetProvider.findByTicker('ATOM'); // Get the Asset instance
final result = await stakingManager.quickStake(
  assetId: atomAsset.id, // Use the AssetId from the Asset
  amount: Amount.fromDecimal('100'),
);
print('Staked with ${result.validators.length} validators');
print('Expected APY: ${result.expectedAPY}%');
```

### Advanced Staking

```dart
// Get recommendations first
final atomAsset = assetProvider.findByTicker('ATOM');
final suggestions = await stakingManager.getStakingSuggestions(atomAsset.id);
print('Recommended amount: ${suggestions.recommendedAmount}');

// Stake with specific strategy
final result = await stakingManager.stake(
  assetId: atomAsset.id,
  amount: suggestions.recommendedAmount,
  strategy: StakingStrategy.balanced,
);
```

### Monitoring

```dart
// Watch staking state
final atomAsset = assetProvider.findByTicker('ATOM');
stakingManager.watchStakingState(atomAsset.id).listen((state) {
  print('Total staked: ${state.totalStaked}');
  print('Pending rewards: ${state.pendingRewards}');
  print('Current APY: ${state.currentAPY}%');

  if (state.hasRewardsToClaim) {
    print('You have rewards to claim!');
  }
});

// Watch rewards specifically
stakingManager.watchRewards(atomAsset.id).listen((reward) {
  print('Current rewards: ${reward.amount}');
  print('Next reward in: ${reward.timeToNext}');
});
```

### Automation

```dart
// Enable auto-claiming with compounding
final atomAsset = assetProvider.findByTicker('ATOM');
await stakingManager.enableAutoClaim(
  assetId: atomAsset.id,
  interval: Duration(days: 7),
  autoCompound: true,
  minAmount: Amount.fromDecimal('1'),
);

// Rebalance existing stakes
final rebalance = await stakingManager.rebalanceStaking(
  assetId: atomAsset.id,
  strategy: StakingStrategy.balanced,
);
print('Rebalanced across ${rebalance.validators.length} validators');
```

## Implementation Notes

1. **Backward Compatibility**: Keep existing methods while adding new abstractions
2. **Progressive Enhancement**: Start with core abstractions, add advanced features iteratively
3. **Testing**: Comprehensive unit tests for validator selection algorithms and state management
4. **Documentation**: Rich inline documentation with examples for each method
5. **Error Recovery**: Graceful handling of partial failures in batch operations

### Mapping Current Implementation

The current `StakingManager` methods map to the improved abstractions as follows:

- `delegate(String coin, StakingDetails details)` → Part of higher-level `stake()` method
- `undelegate(String coin, StakingDetails details)` → Part of higher-level `unstake()` method
- `claimRewards(String coin, ClaimingDetails details)` → Part of `claimAllRewards()` method
- `queryDelegations(AssetId assetId, ...)` → Internal to `getStakingInfo()` and `watchStakingState()`
- `queryValidators(String coin, ...)` → Internal to `getRecommendedValidators()` and validator selection
- `_ensureActivated(String ticker)` → Should use `SharedActivationCoordinator` instead

The key difference is that the improved methods:

- Accept `AssetId` objects instead of string tickers
- Use `SharedActivationCoordinator` for safe, coordinated asset activation
- Provide sensible defaults and auto-selection
- Return richer result types with more context
- Handle common patterns automatically (e.g., claiming before unstaking)
- Prevent race conditions during activation through the coordinator

## Benefits

- **Lower Barrier to Entry**: Developers can stake without understanding validators, delegations, etc.
- **Better UX**: Real-time updates, smart defaults, and automation options
- **Safer Staking**: Built-in validation, warnings, and best practices
- **Flexibility**: Simple methods for basic use cases, advanced options for power users
- **Consistency**: Follows patterns established by other SDK managers
- **Race Condition Prevention**: Using `SharedActivationCoordinator` ensures:
  - Only one activation per asset at a time across all managers
  - Proper waiting for coin availability after activation RPC completes
  - Shared activation results prevent duplicate work
  - Automatic cleanup on wallet changes
