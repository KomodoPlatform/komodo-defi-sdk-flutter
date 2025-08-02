import 'package:decimal/decimal.dart';

/// Result types for staking operations in the Komodo DeFi Framework.
///
/// These classes represent the outcomes of various staking operations
/// and provide structured data for transaction tracking, UI updates,
/// and portfolio management.
///
/// All result types include transaction hashes for blockchain verification
/// and relevant metadata for the specific operation performed.

/// Result from a successful staking/delegation operation.
///
/// Returned when funds are successfully delegated to one or more validators.
/// Contains transaction details and expected returns information.
///
/// Corresponds to the response from the KDF API's delegate method.
///
/// Example usage:
/// ```dart
/// final result = await stakingManager.delegate(
///   amount: Decimal.parse('100'),
///   validatorAddress: 'cosmosvaloper1...',
/// );
///
/// print('Transaction: ${result.transactionHash}');
/// print('Expected APY: ${result.expectedAPY}%');
/// ```
class StakingResult {
  const StakingResult({
    required this.transactionHash,
    required this.validators,
    required this.amount,
    required this.expectedAPY,
  });

  /// Blockchain transaction hash for the delegation.
  ///
  /// Can be used to track the transaction on block explorers
  /// and verify successful execution on-chain.
  final String transactionHash;

  /// List of validator addresses that received delegations.
  ///
  /// For single-validator delegations, contains one address.
  /// For diversified staking, may contain multiple validators.
  final List<String> validators;

  /// Total amount staked in the transaction.
  ///
  /// This is the amount that will start earning rewards
  /// based on validator performance.
  final Decimal amount;

  /// Expected Annual Percentage Yield from this delegation.
  ///
  /// Calculated based on current validator performance
  /// and network conditions at the time of staking.
  final Decimal expectedAPY;
}

/// Result from a successful unstaking/undelegation operation.
///
/// Returned when funds are successfully undelegated from validators.
/// Includes unbonding period information since funds are not immediately available.
///
/// Corresponds to the response from the KDF API's undelegate method.
///
/// Important: Undelegated funds enter an unbonding period during which
/// they don't earn rewards but also can't be withdrawn.
///
/// Example:
/// ```dart
/// final result = await stakingManager.undelegate(
///   amount: Decimal.parse('50'),
///   validatorAddress: 'cosmosvaloper1...',
/// );
///
/// print('Funds available: ${result.completionTime}');
/// ```
class UnstakingResult {
  const UnstakingResult({
    required this.transactionHash,
    required this.amount,
    required this.completionTime,
    required this.validators,
  });

  /// Blockchain transaction hash for the undelegation.
  ///
  /// Can be used to verify the transaction on block explorers.
  final String transactionHash;

  /// Amount that was undelegated and entered unbonding.
  ///
  /// This amount will become available for withdrawal
  /// after the completion time.
  final Decimal amount;

  /// When the unbonding period completes.
  ///
  /// After this time, funds can be withdrawn to the wallet.
  /// Varies by network (e.g., 21 days for most Cosmos chains).
  final DateTime completionTime;

  /// List of validators from which funds were undelegated.
  ///
  /// Typically contains one validator but may have multiple
  /// for batch undelegation operations.
  final List<String> validators;
}

/// Result from a quick stake operation with auto-selected validators.
///
/// Extends StakingResult with the same data structure but indicates
/// that the staking was performed using automatic validator selection
/// based on the system's optimization algorithms.
///
/// Quick stake chooses validators based on:
/// - Performance metrics (uptime, commission)
/// - Risk diversification
/// - Network decentralization goals
///
/// Example:
/// ```dart
/// final result = await stakingManager.quickStake(
///   amount: Decimal.parse('100'),
/// );
///
/// // Same interface as StakingResult
/// print('Auto-selected validators: ${result.validators}');
/// ```
class QuickStakeResult extends StakingResult {
  const QuickStakeResult({
    required super.transactionHash,
    required super.validators,
    required super.amount,
    required super.expectedAPY,
  });
}

/// Result from a successful reward claiming operation.
///
/// Returned when accumulated staking rewards are claimed from validators.
/// Includes information about auto-restaking if that option was selected.
///
/// Corresponds to the response from the KDF API's claim_rewards method.
///
/// Rewards can either be:
/// - Claimed to the wallet for immediate use
/// - Auto-restaked to compound returns
///
/// Example:
/// ```dart
/// final result = await stakingManager.claimRewards(
///   validators: ['cosmosvaloper1...'],
///   autoRestake: true,
/// );
///
/// print('Claimed: ${result.claimedAmount}');
/// print('Auto-restaked: ${result.autoRestaked}');
/// ```
class ClaimResult {
  const ClaimResult({
    required this.transactionHash,
    required this.claimedAmount,
    required this.validators,
    required this.autoRestaked,
  });

  /// Blockchain transaction hash for the reward claim.
  ///
  /// Can be used to verify the transaction on block explorers.
  final String transactionHash;

  /// Total amount of rewards that were claimed.
  ///
  /// If auto-restaked, this amount was immediately delegated back.
  /// If not auto-restaked, this amount was sent to the wallet.
  final Decimal claimedAmount;

  /// List of validators from which rewards were claimed.
  ///
  /// Can claim from multiple validators in a single transaction
  /// for gas efficiency.
  final List<String> validators;

  /// Whether the claimed rewards were automatically restaked.
  ///
  /// When true, rewards were immediately delegated back to validators
  /// for compound growth. When false, rewards were sent to the wallet.
  final bool autoRestaked;
}

/// Result from rebalancing staking distribution across validators.
///
/// Returned when the staking portfolio is rebalanced to optimize
/// returns, reduce risk, or improve diversification.
///
/// Rebalancing involves:
/// - Undelegating from over-weighted validators
/// - Delegating to under-weighted or better-performing validators
/// - Multiple transactions to achieve the target distribution
///
/// Example:
/// ```dart
/// final result = await stakingManager.rebalance(
///   targetDistribution: {
///     'validator1': Decimal.parse('40'),
///     'validator2': Decimal.parse('35'),
///     'validator3': Decimal.parse('25'),
///   },
/// );
///
/// print('Rebalance transactions: ${result.transactions.length}');
/// ```
class RebalanceResult {
  const RebalanceResult({
    required this.transactions,
    required this.validators,
    required this.oldDistribution,
    required this.newDistribution,
  });

  /// List of transaction hashes for all rebalancing operations.
  ///
  /// Rebalancing typically requires multiple transactions:
  /// - Undelegation transactions (with unbonding periods)
  /// - New delegation transactions
  /// - Possible redelegation transactions (if supported)
  final List<String> transactions;

  /// List of all validators involved in the rebalancing.
  ///
  /// Includes both validators that had funds removed
  /// and validators that received new delegations.
  final List<String> validators;

  /// Distribution of funds before rebalancing.
  ///
  /// Maps validator addresses to the amounts that were
  /// previously delegated to each validator.
  final Map<String, Decimal> oldDistribution;

  /// Distribution of funds after rebalancing.
  ///
  /// Maps validator addresses to the target amounts
  /// that will be delegated to each validator.
  /// Note: Some changes may be pending due to unbonding periods.
  final Map<String, Decimal> newDistribution;
}
