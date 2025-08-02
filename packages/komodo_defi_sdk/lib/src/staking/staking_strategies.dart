import 'package:decimal/decimal.dart';

/// Defines specific criteria for validator selection when staking.
///
/// This class allows fine-grained control over which validators are considered
/// suitable for staking. It's used internally by staking strategies and can be
/// customized for the `StakingStrategy.custom` approach.
///
/// ## Default Values:
///
/// The default configuration represents a balanced approach suitable for most users:
/// - Maximum 10% commission rate
/// - Minimum 95% uptime requirement
/// - Maximum 20% voting power concentration
/// - Excludes jailed validators
/// - Prefers decentralized validator selection
///
/// ## Usage Examples:
///
/// ```dart
/// // Default balanced criteria
/// const criteria = ValidatorSelectionCriteria();
///
/// // Conservative criteria for maximum safety
/// const conservative = ValidatorSelectionCriteria(
///   maxCommission: 0.05,     // Max 5% commission
///   minUptime: 0.99,         // 99% uptime required
///   maxConcentration: 0.1,   // Max 10% voting power
///   preferDecentralization: true,
/// );
///
/// // Aggressive criteria for maximum returns
/// const aggressive = ValidatorSelectionCriteria(
///   maxCommission: 0.2,      // Allow up to 20% commission
///   minUptime: 0.9,          // 90% uptime acceptable
///   maxConcentration: 0.5,   // Allow higher concentration
///   preferDecentralization: false,
/// );
///
/// // Custom staking with specific criteria
/// final recommendations = await stakingManager.getRecommendedValidators(
///   assetId: AssetId('ATOM'),
///   criteria: conservative,
/// );
/// ```
///
/// ## Field Descriptions:
///
/// ### Commission Rate (maxCommission)
/// Validators charge a commission on staking rewards. Lower commissions mean
/// higher net returns for stakers, but may indicate different validator
/// business models or operational approaches.
///
/// ### Uptime (minUptime)
/// Measures validator reliability in block production and network participation.
/// Higher uptime validators are more reliable but may be slightly more competitive.
///
/// ### Voting Power Concentration (maxConcentration)
/// Limits stake concentration with high-power validators to support network
/// decentralization. Lower limits promote decentralization but may reduce
/// individual validator reliability.
///
/// ### Jailed Status (excludeJailed)
/// Jailed validators cannot receive new delegations and may have missed blocks
/// or violated network rules. Generally recommended to exclude them.
///
/// ### Decentralization Preference (preferDecentralization)
/// When enabled, favors validators with lower voting power to distribute stake
/// more evenly across the network, supporting network security and censorship
/// resistance.
///
/// ## Network Security Considerations:
///
/// - **Decentralization**: Helps prevent any single entity from controlling too much stake
/// - **Reliability**: Uptime requirements ensure validator performance
/// - **Economic Efficiency**: Commission limits balance returns with validator sustainability
/// - **Risk Management**: Jailed validator exclusion prevents delegation to problematic nodes
class ValidatorSelectionCriteria {
  /// Creates validator selection criteria with specified parameters.
  ///
  /// All parameters have sensible defaults for balanced staking.
  ///
  /// **Parameters:**
  /// - [maxCommission]: Maximum acceptable commission rate (0.0 to 1.0)
  /// - [minUptime]: Minimum required uptime percentage (0.0 to 1.0)
  /// - [maxConcentration]: Maximum voting power concentration (0.0 to 1.0)
  /// - [excludeJailed]: Whether to exclude jailed validators
  /// - [preferDecentralization]: Whether to favor smaller validators
  ValidatorSelectionCriteria({
    Decimal? maxCommission,
    Decimal? minUptime,
    Decimal? maxConcentration,
    this.excludeJailed = true,
    this.preferDecentralization = true,
  })  : maxCommission = maxCommission ?? Decimal.parse('0.1'),
        minUptime = minUptime ?? Decimal.parse('0.95'),
        maxConcentration = maxConcentration ?? Decimal.parse('0.2');

  /// Maximum acceptable commission rate (0.0 to 1.0).
  ///
  /// Validators with commission rates above this threshold will be excluded
  /// from selection. Commission rates represent the percentage of staking
  /// rewards that validators keep for their services.
  ///
  /// **Examples:**
  /// - `0.05` = 5% commission (conservative)
  /// - `0.1` = 10% commission (balanced, default)
  /// - `0.2` = 20% commission (aggressive)
  ///
  /// **Considerations:**
  /// - Lower commissions mean higher net returns for stakers
  /// - Very low commissions might indicate unsustainable validator economics
  /// - Commission rates can change, so monitor validator policies
  final Decimal maxCommission;

  /// Minimum required uptime percentage (0.0 to 1.0).
  ///
  /// Validators must maintain at least this level of network participation
  /// to be considered for staking. Uptime measures how consistently a
  /// validator participates in block production and network consensus.
  ///
  /// **Examples:**
  /// - `0.9` = 90% uptime (aggressive)
  /// - `0.95` = 95% uptime (balanced, default)
  /// - `0.99` = 99% uptime (conservative)
  ///
  /// **Impact:**
  /// - Higher uptime validators are more reliable
  /// - Low uptime can result in slashing penalties
  /// - Affects network security and your staking rewards
  final Decimal minUptime;

  /// Maximum acceptable voting power concentration (0.0 to 1.0).
  ///
  /// Limits stake delegation to validators with voting power below this
  /// threshold to promote network decentralization. Voting power represents
  /// a validator's influence in network governance and consensus.
  ///
  /// **Examples:**
  /// - `0.1` = 10% max voting power (highly decentralized)
  /// - `0.2` = 20% max voting power (balanced, default)
  /// - `0.33` = 33% max voting power (allows larger validators)
  ///
  /// **Decentralization Benefits:**
  /// - Prevents excessive concentration of network control
  /// - Supports censorship resistance
  /// - Reduces systemic risk from validator failures
  final Decimal maxConcentration;

  /// Whether to exclude jailed validators from selection.
  ///
  /// Jailed validators have been penalized for misbehavior such as:
  /// - Missing too many blocks (downtime)
  /// - Double-signing blocks (equivocation)
  /// - Other protocol violations
  ///
  /// **Default: `true`** (recommended)
  ///
  /// **When to consider `false`:**
  /// - Advanced users who want to manually evaluate jailed validators
  /// - Specific validators you trust despite jailed status
  /// - Testing or development scenarios
  ///
  /// **Note:** Jailed validators cannot receive new delegations until unjailed.
  final bool excludeJailed;

  /// Whether to prefer validators with lower voting power for decentralization.
  ///
  /// When enabled, the selection algorithm favors validators with smaller
  /// voting power stakes to promote network decentralization. This helps
  /// distribute stake more evenly across the validator set.
  ///
  /// **Default: `true`** (recommended)
  ///
  /// **Benefits:**
  /// - Supports network health and decentralization
  /// - Reduces systemic risks
  /// - Helps smaller validators grow
  ///
  /// **Trade-offs:**
  /// - May select slightly less established validators
  /// - Could reduce individual validator track record
  /// - Balances network good vs. individual optimization
  final bool preferDecentralization;
}
