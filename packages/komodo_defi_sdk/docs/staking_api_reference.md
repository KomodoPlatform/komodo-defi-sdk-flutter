# Staking API Reference - Komodo DeFi Framework

## Quick Reference

This document provides a concise API reference for the KDF staking system. For comprehensive guides and examples, see [staking_comprehensive_guide.md](staking_comprehensive_guide.md).

## Core Classes

### StakingManager

Main interface for all staking operations.

```dart
class StakingManager {
  // State Management
  Future<StakingState> getStakingState();
  Future<List<EnhancedValidatorInfo>> getValidators();
  Future<StakingInfo> getStakingInfo();

  // Staking Operations
  Future<StakingResult> delegate(Decimal amount, String validatorAddress);
  Future<QuickStakeResult> quickStake(Decimal amount);
  Future<UnstakingResult> undelegate(Decimal amount, String validatorAddress);
  Future<ClaimResult> claimRewards(List<String> validators, {bool autoRestake = false});

  // Validation
  Future<ValidationResult> validateStaking(Decimal amount, String validatorAddress);

  // Optimization
  Future<StakingSuggestions> getStakingSuggestions(Decimal availableBalance, StakingRisk riskTolerance);
  Future<RebalanceResult> rebalance(Map<String, Decimal> targetDistribution);

  // Streaming Updates
  Stream<StakingState> get stateChanges;
  Stream<RewardUpdate> get rewardUpdates;
}
```

### StakingState

Complete staking portfolio state.

```dart
class StakingState {
  final List<StakingPosition> positions;           // Active delegations
  final Decimal totalStaked;                       // Total staked amount
  final Decimal pendingRewards;                    // Claimable rewards
  final List<UnbondingPosition> unbonding;         // Unbonding positions
  final double currentAPY;                         // Weighted average APY
  final DateTime lastUpdated;                      // Last refresh time
  final StakingHealth health;                      // Portfolio health

  // Convenience getters
  bool get hasRewardsToClaim;                      // Has claimable rewards
  Decimal get totalValue;                          // Staked + rewards
  bool get isFullyUnbonding;                       // All positions unbonding
}
```

### StakingPosition

Individual validator delegation.

```dart
class StakingPosition {
  final String validatorAddress;                   // Validator ID
  final EnhancedValidatorInfo validator;           // Validator details
  final Decimal stakedAmount;                      // Principal amount
  final Decimal rewards;                           // Accumulated rewards
  final DateTime stakedAt;                         // Delegation time
  final double validatorAPY;                       // Validator APY

  // Convenience getters
  bool get isActive;                               // Validator is active
  Duration get stakingDuration;                    // Time staked
}
```

### EnhancedValidatorInfo

Comprehensive validator information.

```dart
class EnhancedValidatorInfo {
  final String address;                            // Validator address
  final String name;                               // Display name
  final double commission;                         // Fee rate (0.0-1.0)
  final double uptime;                             // Reliability (0.0-1.0)
  final bool isActive;                             // Currently validating
  final bool isJailed;                             // Temporarily excluded
  final Decimal totalDelegated;                    // Total validator stake
  final double votingPower;                        // Network influence
  final String? description;                       // Validator description

  factory EnhancedValidatorInfo.fromValidatorInfo(ValidatorInfo info);
}
```

### UnbondingPosition

Funds in unbonding period.

```dart
class UnbondingPosition {
  final String validatorAddress;                   // Source validator
  final Decimal amount;                            // Unbonding amount
  final DateTime completionTime;                   // When available
  final String transactionId;                      // Unbonding tx hash

  // Convenience getters
  Duration get timeRemaining;                      // Time until completion
  bool get isComplete;                             // Unbonding complete
}
```

## Result Types

### StakingResult

Standard delegation result.

```dart
class StakingResult {
  final String transactionHash;                    // Blockchain tx hash
  final List<String> validators;                   // Delegated validators
  final Decimal amount;                            // Delegated amount
  final double expectedAPY;                        // Expected returns
}
```

### QuickStakeResult

Auto-optimized delegation result (extends StakingResult).

```dart
class QuickStakeResult extends StakingResult {
  // Same properties as StakingResult
  // Indicates auto-validator selection was used
}
```

### UnstakingResult

Undelegation result.

```dart
class UnstakingResult {
  final String transactionHash;                    // Undelegation tx hash
  final Decimal amount;                            // Undelegated amount
  final DateTime completionTime;                   // When funds available
  final List<String> validators;                   // Source validators
}
```

### ClaimResult

Reward claiming result.

```dart
class ClaimResult {
  final String transactionHash;                    // Claim tx hash
  final Decimal claimedAmount;                     // Claimed rewards
  final List<String> validators;                   // Source validators
  final bool autoRestaked;                         // Auto-compounded?
}
```

### RebalanceResult

Portfolio rebalancing result.

```dart
class RebalanceResult {
  final List<String> transactions;                 // All tx hashes
  final List<String> validators;                   // Affected validators
  final Map<String, Decimal> oldDistribution;      // Previous allocation
  final Map<String, Decimal> newDistribution;      // Target allocation
}
```

## Validation Types

### ValidationResult

Staking operation validation.

```dart
class ValidationResult {
  final bool isValid;                              // Can proceed?
  final List<ValidationIssue> issues;              // Found issues
  final StakingSuggestion? suggestion;             // Improvement suggestion

  // Convenience getters
  bool get hasWarnings;                            // Has warnings
  bool get hasErrors;                              // Has errors
}
```

### ValidationIssue

Individual validation problem.

```dart
class ValidationIssue {
  final String message;                            // Issue description
  final IssueSeverity severity;                    // warning | error
}
```

### StakingSuggestion

Improvement recommendation.

```dart
class StakingSuggestion {
  final String message;                            // What to improve
  final String recommendedAction;                  // How to improve
}
```

## Exception Types

### StakingException

Comprehensive staking errors.

```dart
class StakingException implements Exception {
  final String message;                            // Error description
  final AssetId? assetId;                          // Related asset

  // Factory constructors for common errors
  factory StakingException.belowMinimum(Decimal min, Decimal provided);
  factory StakingException.validatorInactive(String address);
  factory StakingException.validatorJailed(String address);
  factory StakingException.insufficientBalance();
  factory StakingException.unbondingPeriodActive();
  factory StakingException.activationFailed(AssetId assetId, String reason);
}
```

## Enums

### StakingHealth

Portfolio health assessment.

```dart
enum StakingHealth {
  good,                                            // Well optimized
  warning,                                         // Needs attention
  critical,                                        // Immediate action needed
}
```

### StakingRisk

Risk tolerance levels.

```dart
enum StakingRisk {
  low,                                             // Conservative
  medium,                                          // Balanced
  high,                                            // Aggressive
}
```

### IssueSeverity

Validation issue severity.

```dart
enum IssueSeverity {
  warning,                                         // Advisory only
  error,                                           // Blocks execution
}
```

## Optimization Types

### StakingSuggestions

AI-driven optimization recommendations.

```dart
class StakingSuggestions {
  final Decimal recommendedAmount;                 // Suggested stake amount
  final Decimal expectedReturns;                   // Projected returns
  final StakingRisk riskLevel;                     // Risk assessment
  final List<ValidatorRecommendation> suggestedValidators; // Validator recommendations
  final List<String> warnings;                     // Important notices
}
```

### ValidatorRecommendation

Scored validator suggestion.

```dart
class ValidatorRecommendation {
  final EnhancedValidatorInfo validator;           // Recommended validator
  final double score;                              // Recommendation strength (0.0-1.0)
  final List<String> reasons;                      // Why recommended
}
```

## Utility Types

### RewardUpdate

Real-time reward information.

```dart
class RewardUpdate {
  final Decimal amount;                            // Current rewards
  final Duration timeToNext;                       // Next distribution
  final double estimatedAPY;                       // Current APY
}
```

### StakingInfo

Portfolio analysis data.

```dart
class StakingInfo {
  final Decimal totalStaked;                       // Total staked
  final Decimal availableBalance;                  // Available for staking
  final Decimal pendingRewards;                    // Claimable rewards
  final List<EnhancedValidatorInfo> validators;    // Available validators
  final Decimal unbondingAmount;                   // Total unbonding
  final double estimatedAPY;                       // Network APY
  final DateTime? nextRewardTime;                  // Next reward time
}
```

### CachedData<T>

Generic cache wrapper.

```dart
class CachedData<T> {
  final T data;                                    // Cached data
  final DateTime timestamp;                       // Cache time

  bool isExpired(Duration ttl);                    // Check if expired
}
```

## Usage Patterns

### Basic Staking Flow

```dart
// 1. Get staking manager
final manager = sdk.getStakingManager('ATOM');

// 2. Check current state
final state = await manager.getStakingState();

// 3. Validate operation
final validation = await manager.validateStaking(amount, validator);
if (!validation.isValid) return;

// 4. Execute staking
final result = await manager.delegate(amount, validator);

// 5. Monitor results
print('Staked ${result.amount} with ${result.expectedAPY}% APY');
```

### Error Handling Pattern

```dart
try {
  final result = await stakingManager.delegate(amount, validator);
  // Handle success
} on StakingException catch (e) {
  // Handle specific staking errors
  switch (e.message) {
    case 'insufficient balance':
      showInsufficientBalanceDialog();
      break;
    case 'validator inactive':
      suggestAlternativeValidators();
      break;
    default:
      showGenericStakingError(e.message);
  }
} catch (e) {
  // Handle other errors (network, etc.)
  showNetworkErrorDialog();
}
```

### Validation Pattern

```dart
final validation = await stakingManager.validateStaking(amount, validator);

if (validation.hasErrors) {
  // Show errors and prevent execution
  showValidationErrors(validation.issues.where((i) => i.severity == IssueSeverity.error));
  return;
}

if (validation.hasWarnings) {
  // Show warnings but allow execution
  final proceed = await showWarningsDialog(validation.issues.where((i) => i.severity == IssueSeverity.warning));
  if (!proceed) return;
}

// Execute staking operation
await stakingManager.delegate(amount, validator);
```

### Stream Usage Pattern

```dart
// Listen for state changes
stakingManager.stateChanges.listen((newState) {
  updateUI(newState);
});

// Listen for reward updates
stakingManager.rewardUpdates.listen((update) {
  updateRewardDisplay(update.amount, update.estimatedAPY);
});
```

## Constants and Defaults

### Network-Specific Values

```dart
// Typical unbonding periods
const cosmosUnbondingPeriod = Duration(days: 21);
const qtumUnbondingPeriod = Duration.zero;

// Typical minimum amounts (vary by validator)
const cosmosMinimumDelegation = Decimal.parse('0.000001'); // 1 µATOM
const qtumMinimumStake = Decimal.parse('1'); // 1 QTUM

// Cache TTL values
const validatorCacheTTL = Duration(hours: 1);
const stakingStateCacheTTL = Duration(seconds: 30);
const rewardEstimateCacheTTL = Duration(minutes: 5);
```

### Commission Rate Guidelines

```dart
// Recommended commission rate ranges
const lowCommission = 0.05;     // < 5% (excellent)
const moderateCommission = 0.10; // 5-10% (good)
const highCommission = 0.20;    // 10-20% (acceptable)
// > 20% generally not recommended
```

## KDF API Mappings

### Staking Operations → KDF Methods

| SDK Method          | KDF API Method   | Description                  |
| ------------------- | ---------------- | ---------------------------- |
| `delegate()`        | `delegate`       | Stake funds with validator   |
| `undelegate()`      | `undelegate`     | Unstake funds from validator |
| `claimRewards()`    | `claim_rewards`  | Claim accumulated rewards    |
| `getValidators()`   | `get_validators` | List available validators    |
| `getStakingState()` | `staking_info`   | Get staking portfolio state  |

### Staking Details Object

```dart
// Maps to KDF API StakingDetails
{
  "type": "Cosmos" | "Qtum",
  "validator_address": "cosmosvaloper1...",
  "amount": "100.0"
}
```

### Staking Info Details Object

```dart
// Maps to KDF API StakingInfoDetails
{
  "filter_by_status": "Active" | "Inactive" | "All",
  "limit": 100,
  "page_number": 1
}
```

This API reference provides quick access to all staking system components. For detailed usage examples and integration guides, refer to the comprehensive staking guide.
