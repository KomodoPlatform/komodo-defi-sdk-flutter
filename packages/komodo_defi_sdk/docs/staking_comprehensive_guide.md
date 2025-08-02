# Comprehensive Staking Guide - Komodo DeFi Framework

## Overview

The Komodo DeFi Framework (KDF) provides comprehensive staking support for Cosmos and QTUM networks through a unified API. This guide covers all aspects of the staking system, from basic operations to advanced portfolio management.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Supported Networks](#supported-networks)
3. [Core Components](#core-components)
4. [Basic Usage](#basic-usage)
5. [Advanced Features](#advanced-features)
6. [Error Handling](#error-handling)
7. [Best Practices](#best-practices)
8. [API Reference](#api-reference)

## Architecture Overview

The staking system is built around several key components:

- **StakingManager**: Main interface for all staking operations
- **StakingTypes**: Data structures representing staking state and validator information
- **StakingResults**: Result types for operation outcomes
- **StakingExceptions**: Comprehensive error handling
- **StakingStrategies**: Optimization algorithms for validator selection

```dart
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  StakingManager │────│ KDF RPC Client  │────│ Blockchain Node │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ├── StakingState
         ├── ValidatorInfo
         ├── StakingResults
         └── StakingExceptions
```

## Supported Networks

### Cosmos Ecosystem

- **Supported Coins**: Any Cosmos-based chain activated in KDF
- **Features**:
  - Multi-validator delegation
  - Reward claiming and auto-compounding
  - Redelegation (where supported)
  - Governance participation

### QTUM

- **Features**:
  - Full balance staking
  - Immediate unstaking
  - Network-wide staking pool

## Core Components

### StakingState

The central data structure representing your complete staking portfolio:

```dart
class StakingState {
  final List<StakingPosition> positions;      // Active delegations
  final Decimal totalStaked;                  // Total amount earning rewards
  final Decimal pendingRewards;               // Claimable rewards
  final List<UnbondingPosition> unbonding;    // Funds in unbonding
  final double currentAPY;                    // Weighted average returns
  final DateTime lastUpdated;                 // Data freshness
  final StakingHealth health;                 // Portfolio assessment
}
```

### StakingPosition

Individual delegation to a specific validator:

```dart
class StakingPosition {
  final String validatorAddress;              // Validator identifier
  final EnhancedValidatorInfo validator;      // Validator details
  final Decimal stakedAmount;                 // Principal amount
  final Decimal rewards;                      // Accumulated rewards
  final DateTime stakedAt;                    // Delegation timestamp
  final double validatorAPY;                  // Validator-specific returns
}
```

### EnhancedValidatorInfo

Comprehensive validator metrics for informed selection:

```dart
class EnhancedValidatorInfo {
  final String address;                       // Unique validator ID
  final String name;                          // Display name
  final double commission;                    // Fee percentage (0.0-1.0)
  final double uptime;                        // Reliability metric
  final bool isActive;                        // Currently validating
  final bool isJailed;                        // Temporarily excluded
  final Decimal totalDelegated;               // Total validator size
  final double votingPower;                   // Network influence
}
```

## Basic Usage

### 1. Initialize Staking

```dart
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

// Initialize the SDK
final sdk = KomodoDefiSDK();

// Get staking manager for a specific coin
final stakingManager = sdk.getStakingManager('ATOM');
```

### 2. Check Staking Information

```dart
// Get current staking state
final stakingState = await stakingManager.getStakingState();

print('Total Staked: ${stakingState.totalStaked}');
print('Pending Rewards: ${stakingState.pendingRewards}');
print('Current APY: ${stakingState.currentAPY}%');
print('Health: ${stakingState.health}');

// Get available validators
final validators = await stakingManager.getValidators();
for (final validator in validators) {
  print('${validator.name}: ${validator.commission * 100}% commission');
}
```

### 3. Stake Funds

```dart
// Manual validator selection
try {
  final result = await stakingManager.delegate(
    amount: Decimal.parse('100'),
    validatorAddress: 'cosmosvaloper1...',
  );

  print('Staked successfully!');
  print('Transaction: ${result.transactionHash}');
  print('Expected APY: ${result.expectedAPY}%');
} catch (e) {
  if (e is StakingException) {
    print('Staking failed: ${e.message}');
  }
}

// Or use quick stake for automatic optimization
try {
  final result = await stakingManager.quickStake(
    amount: Decimal.parse('100'),
  );

  print('Quick stake successful!');
  print('Selected validators: ${result.validators}');
} catch (e) {
  print('Quick stake failed: $e');
}
```

### 4. Claim Rewards

```dart
// Claim rewards to wallet
final claimResult = await stakingManager.claimRewards(
  validators: ['cosmosvaloper1...'],
  autoRestake: false,
);

print('Claimed: ${claimResult.claimedAmount}');

// Or auto-compound for better returns
final compoundResult = await stakingManager.claimRewards(
  validators: ['cosmosvaloper1...'],
  autoRestake: true,
);

print('Auto-restaked: ${compoundResult.claimedAmount}');
```

### 5. Unstake Funds

```dart
final unstakeResult = await stakingManager.undelegate(
  amount: Decimal.parse('50'),
  validatorAddress: 'cosmosvaloper1...',
);

print('Unstaking initiated!');
print('Available: ${unstakeResult.completionTime}');
print('Transaction: ${unstakeResult.transactionHash}');
```

## Advanced Features

### Validation and Pre-flight Checks

```dart
// Validate staking parameters before execution
final validation = await stakingManager.validateStaking(
  amount: Decimal.parse('100'),
  validatorAddress: 'cosmosvaloper1...',
);

if (!validation.isValid) {
  print('Validation failed:');
  for (final issue in validation.issues) {
    print('${issue.severity}: ${issue.message}');
  }

  // Check for suggestions
  if (validation.suggestion != null) {
    final suggestion = validation.suggestion!;
    print('Suggestion: ${suggestion.message}');
    print('Action: ${suggestion.recommendedAction}');
  }
} else {
  // Proceed with staking
  await stakingManager.delegate(amount, validatorAddress);
}
```

### Portfolio Optimization

```dart
// Get AI-driven staking suggestions
final suggestions = await stakingManager.getStakingSuggestions(
  availableBalance: Decimal.parse('1000'),
  riskTolerance: StakingRisk.medium,
);

print('Recommended amount: ${suggestions.recommendedAmount}');
print('Expected returns: ${suggestions.expectedReturns}');
print('Risk level: ${suggestions.riskLevel}');

// Review suggested validators
for (final recommendation in suggestions.suggestedValidators) {
  print('${recommendation.validator.name}: ${recommendation.score}');
  print('Reasons: ${recommendation.reasons.join(', ')}');
}
```

### Portfolio Rebalancing

```dart
// Rebalance for optimal distribution
final rebalanceResult = await stakingManager.rebalance(
  targetDistribution: {
    'validator1': Decimal.parse('400'),  // 40%
    'validator2': Decimal.parse('350'),  // 35%
    'validator3': Decimal.parse('250'),  // 25%
  },
);

print('Rebalancing completed with ${rebalanceResult.transactions.length} transactions');
print('Old distribution: ${rebalanceResult.oldDistribution}');
print('New distribution: ${rebalanceResult.newDistribution}');
```

### Real-time Updates

```dart
// Listen for reward updates
stakingManager.rewardUpdates.listen((update) {
  print('Current rewards: ${update.amount}');
  print('Next reward in: ${update.timeToNext}');
  print('Updated APY: ${update.estimatedAPY}%');
});

// Listen for state changes
stakingManager.stateChanges.listen((newState) {
  // Update UI with new staking state
  updateStakingUI(newState);
});
```

## Error Handling

The staking system provides comprehensive error handling through `StakingException`:

```dart
try {
  await stakingManager.delegate(amount, validatorAddress);
} catch (e) {
  if (e is StakingException) {
    switch (e.runtimeType) {
      case StakingException:
        if (e.message.contains('below minimum')) {
          // Handle minimum amount error
          showMinimumAmountDialog();
        } else if (e.message.contains('inactive')) {
          // Handle inactive validator
          suggestAlternativeValidators();
        }
        break;
    }
  } else {
    // Handle other errors (network, etc.)
    showGenericErrorDialog(e.toString());
  }
}
```

### Common Error Types

- **Insufficient Balance**: Not enough funds for staking + fees
- **Below Minimum**: Amount below validator or network minimum
- **Validator Issues**: Inactive, jailed, or overloaded validators
- **Network Issues**: RPC failures, connectivity problems
- **Activation Required**: Asset not activated for staking

## Best Practices

### 1. Validator Selection

```dart
// Good validator selection criteria
final goodValidators = validators.where((v) =>
  v.isActive &&                    // Currently validating
  !v.isJailed &&                   // Not penalized
  v.commission < 0.05 &&           // Low fees (< 5%)
  v.uptime > 0.95 &&              // High reliability (> 95%)
  v.votingPower < 0.10             // Avoid over-centralization (< 10%)
).toList();
```

### 2. Risk Management

```dart
// Diversify across multiple validators
final maxPerValidator = totalAmount * Decimal.parse('0.20'); // Max 20% per validator
final validatorCount = min(5, goodValidators.length); // 3-5 validators ideal

for (int i = 0; i < validatorCount; i++) {
  final amount = totalAmount / Decimal.fromInt(validatorCount);
  await stakingManager.delegate(amount, goodValidators[i].address);
}
```

### 3. Reward Optimization

```dart
// Auto-compound for better returns
await stakingManager.claimRewards(
  validators: activeValidators,
  autoRestake: true, // Compound for exponential growth
);

// Or claim periodically for liquidity
if (needsLiquidity) {
  await stakingManager.claimRewards(
    validators: activeValidators,
    autoRestake: false,
  );
}
```

### 4. Monitoring and Maintenance

```dart
// Regular health checks
final state = await stakingManager.getStakingState();
if (state.health == StakingHealth.warning ||
    state.health == StakingHealth.critical) {

  // Get recommendations for improvement
  final suggestions = await stakingManager.getStakingSuggestions(
    availableBalance: state.totalValue,
    riskTolerance: StakingRisk.low,
  );

  // Implement suggestions
  await implementSuggestions(suggestions);
}
```

## API Reference

### StakingManager Methods

| Method                                  | Description                         | Returns                               |
| --------------------------------------- | ----------------------------------- | ------------------------------------- |
| `getStakingState()`                     | Get current staking portfolio       | `Future<StakingState>`                |
| `getValidators()`                       | List available validators           | `Future<List<EnhancedValidatorInfo>>` |
| `delegate(amount, validator)`           | Stake funds with specific validator | `Future<StakingResult>`               |
| `quickStake(amount)`                    | Auto-optimized staking              | `Future<QuickStakeResult>`            |
| `undelegate(amount, validator)`         | Unstake funds                       | `Future<UnstakingResult>`             |
| `claimRewards(validators, autoRestake)` | Claim accumulated rewards           | `Future<ClaimResult>`                 |
| `validateStaking(amount, validator)`    | Pre-validate staking operation      | `Future<ValidationResult>`            |
| `getStakingSuggestions(balance, risk)`  | Get optimization suggestions        | `Future<StakingSuggestions>`          |
| `rebalance(distribution)`               | Rebalance portfolio                 | `Future<RebalanceResult>`             |

### Key Enums

- **StakingHealth**: `good`, `warning`, `critical`
- **StakingRisk**: `low`, `medium`, `high`
- **IssueSeverity**: `warning`, `error`

### Result Types

- **StakingResult**: Standard delegation result
- **QuickStakeResult**: Auto-optimized delegation result
- **UnstakingResult**: Undelegation result with unbonding info
- **ClaimResult**: Reward claiming result
- **RebalanceResult**: Portfolio rebalancing result

## Integration Examples

### Flutter UI Integration

```dart
class StakingScreen extends StatefulWidget {
  @override
  _StakingScreenState createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  StakingManager? stakingManager;
  StakingState? stakingState;

  @override
  void initState() {
    super.initState();
    _initializeStaking();
  }

  Future<void> _initializeStaking() async {
    stakingManager = await KomodoDefiSDK().getStakingManager('ATOM');
    await _refreshStakingState();
  }

  Future<void> _refreshStakingState() async {
    final state = await stakingManager!.getStakingState();
    setState(() {
      stakingState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stakingState == null) {
      return CircularProgressIndicator();
    }

    return Column(
      children: [
        // Portfolio overview
        StakingOverviewCard(state: stakingState!),

        // Active positions
        ...stakingState!.positions.map((position) =>
          StakingPositionCard(position: position)
        ),

        // Action buttons
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _showStakeDialog(),
              child: Text('Stake More'),
            ),
            ElevatedButton(
              onPressed: stakingState!.hasRewardsToClaim
                ? () => _claimRewards()
                : null,
              child: Text('Claim Rewards'),
            ),
          ],
        ),
      ],
    );
  }
}
```

## Performance Considerations

### Caching Strategy

The staking system implements intelligent caching:

- **Validator lists**: Cached for 1 hour
- **Staking state**: Cached for 30 seconds
- **Reward estimates**: Cached for 5 minutes

### Batch Operations

For better performance and lower fees:

```dart
// Batch multiple delegations
await stakingManager.batchDelegate([
  DelegationRequest(amount1, validator1),
  DelegationRequest(amount2, validator2),
  DelegationRequest(amount3, validator3),
]);

// Batch reward claims
await stakingManager.claimRewards(
  validators: [validator1, validator2, validator3],
  autoRestake: true,
);
```

## Security Considerations

1. **Validator Verification**: Always verify validator addresses
2. **Amount Validation**: Use built-in validation before transactions
3. **Network Security**: Only use trusted RPC endpoints
4. **Private Key Safety**: Never log or expose private keys
5. **Transaction Verification**: Always verify transaction hashes

## Troubleshooting

### Common Issues

1. **"Insufficient Balance"**

   - Check available balance minus transaction fees
   - Ensure account has enough for both staking and fees

2. **"Validator Inactive"**

   - Choose active validators from the validator list
   - Check validator status before delegating

3. **"Below Minimum Amount"**

   - Check network minimum delegation amounts
   - Combine smaller amounts into larger delegations

4. **"Unbonding Period Active"**
   - Wait for existing unbonding to complete
   - Use redelegation if supported by the network

## Conclusion

The Komodo DeFi Framework staking system provides a comprehensive, type-safe, and user-friendly interface for staking operations across multiple networks. With built-in optimization, comprehensive error handling, and real-time updates, it enables developers to build sophisticated staking applications with confidence.

For additional support and examples, refer to the individual component documentation and the KDF API reference.
