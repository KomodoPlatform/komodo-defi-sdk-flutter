import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Custom exceptions for staking operations in the Komodo DeFi Framework.
///
/// This class provides specific error types for various staking scenarios
/// including validation failures, network issues, and business logic violations.
/// Supports both Cosmos and QTUM staking protocols as defined in the KDF API.
///
/// Example usage:
/// ```dart
/// try {
///   await stakingManager.delegate(amount, validator);
/// } catch (e) {
///   if (e is StakingException) {
///     // Handle specific staking errors
///     print('Staking failed: ${e.message}');
///   }
/// }
/// ```
class StakingException implements Exception {
  final String message;
  final AssetId? assetId;

  const StakingException(this.message, [this.assetId]);

  /// Creates an exception for when the staking amount is below the minimum required.
  ///
  /// The minimum amount varies by coin type:
  /// - Cosmos: Typically defined by the validator's minimum delegation
  /// - QTUM: Stakes the entire balance, so minimum is the wallet balance
  factory StakingException.belowMinimum(Decimal min, Decimal provided) =>
      StakingException('Amount $provided is below minimum $min');

  /// Creates an exception for when attempting to delegate to an inactive validator.
  ///
  /// Validators can be inactive for various reasons:
  /// - Unbonded status (not in the active validator set)
  /// - Technical issues preventing block signing
  /// - Voluntary exit from validation
  factory StakingException.validatorInactive(String address) =>
      StakingException('Validator $address is inactive');

  /// Creates an exception for when attempting to delegate to a jailed validator.
  ///
  /// Validators are jailed when they:
  /// - Miss too many blocks (downtime)
  /// - Double-sign blocks (equivocation)
  /// - Engage in other slashable offenses
  factory StakingException.validatorJailed(String address) =>
      StakingException('Validator $address is jailed');

  /// Creates an exception for insufficient balance to complete the staking operation.
  ///
  /// This considers:
  /// - Available balance for delegation
  /// - Transaction fees
  /// - Minimum balance requirements
  factory StakingException.insufficientBalance() =>
      StakingException('Insufficient balance for staking');

  /// Creates an exception when trying to perform operations during unbonding.
  ///
  /// Unbonding periods vary by network:
  /// - Cosmos chains: Typically 21 days
  /// - QTUM: Immediate but requires confirmation
  factory StakingException.unbondingPeriodActive() =>
      StakingException('Unbonding period is still active');

  /// Creates an exception for asset activation failures.
  ///
  /// Asset activation is required before staking operations can begin.
  /// Common reasons for failure include:
  /// - Network connectivity issues
  /// - Invalid coin configuration
  /// - Insufficient gas/fees for activation
  factory StakingException.activationFailed(AssetId assetId, String reason) =>
      StakingException('Failed to activate asset: $reason', assetId);

  @override
  String toString() => 'StakingException: $message';
}

/// Comprehensive validation result for staking operations.
///
/// Provides detailed feedback about the validity of staking parameters
/// including any issues found and suggestions for improvement.
///
/// Used by the StakingManager to validate operations before execution,
/// helping prevent failed transactions and providing user guidance.
///
/// Example:
/// ```dart
/// final validation = await stakingManager.validateStaking(
///   amount: Decimal.parse('100'),
///   validatorAddress: 'cosmosvaloper1...',
/// );
///
/// if (!validation.isValid) {
///   for (final issue in validation.issues) {
///     print('${issue.severity}: ${issue.message}');
///   }
/// }
/// ```
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.issues,
    this.suggestion,
  });

  /// Whether the staking operation can proceed without errors.
  ///
  /// True if no error-level issues were found. Warnings are allowed
  /// but should be presented to the user for consideration.
  final bool isValid;

  /// List of validation issues found during the check.
  ///
  /// Issues are ordered by severity (errors first, then warnings).
  /// Each issue contains a human-readable message and severity level.
  final List<ValidationIssue> issues;

  /// Optional suggestion for improving the staking configuration.
  ///
  /// Provided when the validator can recommend better parameters
  /// or alternative approaches for optimal staking.
  final StakingSuggestion? suggestion;

  /// Whether any warnings were found during validation.
  ///
  /// Warnings don't prevent execution but indicate suboptimal conditions
  /// such as high validator commission or low uptime.
  bool get hasWarnings =>
      issues.any((i) => i.severity == IssueSeverity.warning);

  /// Whether any errors were found during validation.
  ///
  /// Errors prevent the staking operation from proceeding and must
  /// be resolved before the transaction can be submitted.
  bool get hasErrors => issues.any((i) => i.severity == IssueSeverity.error);
}

/// Individual validation issue found during staking validation.
///
/// Represents a specific problem or concern with the staking parameters.
/// Issues can be either warnings (allowing execution) or errors (blocking execution).
///
/// Common validation issues include:
/// - Validator selection problems (inactive, jailed, high commission)
/// - Amount validation (too low, insufficient balance)
/// - Network-specific requirements
class ValidationIssue {
  const ValidationIssue({required this.message, required this.severity});

  /// Human-readable description of the validation issue.
  ///
  /// Should be clear enough for end users to understand and act upon.
  /// For developer-facing issues, may include technical details.
  final String message;

  /// Severity level indicating whether this issue blocks execution.
  ///
  /// - Error: Prevents the staking operation from proceeding
  /// - Warning: Allows execution but indicates suboptimal conditions
  final IssueSeverity severity;
}

/// Severity levels for validation issues.
///
/// Determines whether a validation issue prevents execution or simply
/// provides advisory information to the user.
enum IssueSeverity {
  /// Advisory information that doesn't prevent execution.
  ///
  /// Examples:
  /// - Validator has higher than average commission
  /// - Amount is large relative to total supply
  /// - Network congestion may cause delays
  warning,

  /// Critical issue that prevents execution.
  ///
  /// Examples:
  /// - Insufficient balance for staking + fees
  /// - Validator is jailed or inactive
  /// - Amount below network minimum
  error,
}

/// Actionable suggestion for improving staking configuration.
///
/// Provided when the validation system can recommend specific improvements
/// to optimize the staking operation for better returns, lower risk,
/// or improved user experience.
///
/// Examples:
/// - Recommending alternative validators with better terms
/// - Suggesting optimal staking amounts
/// - Advising on timing for better network conditions
class StakingSuggestion {
  const StakingSuggestion({
    required this.message,
    required this.recommendedAction,
  });

  /// Description of the potential improvement.
  ///
  /// Explains why the current configuration is suboptimal
  /// and what benefits the suggestion would provide.
  final String message;

  /// Specific action the user can take to implement the suggestion.
  ///
  /// Should be actionable and specific, such as:
  /// - "Stake with validator X instead for 2% higher APY"
  /// - "Reduce amount by 10 tokens to ensure sufficient fees"
  /// - "Wait 2 hours for network congestion to clear"
  final String recommendedAction;
}
