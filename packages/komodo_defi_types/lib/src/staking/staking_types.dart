import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';

/// Details for staking/undelegating operations
class StakingDetails extends Equatable implements RpcRequestParams {
  const StakingDetails({
    required this.type,
    this.validatorAddress,
    this.address,
    this.amount,
  }) : assert(
         validatorAddress != null || address != null,
         'Either validatorAddress or address must be provided',
       );

  factory StakingDetails.fromJson(JsonMap json) => StakingDetails(
    type: json.value<String>('type'),
    validatorAddress: json.valueOrNull<String>('validator_address'),
    address: json.valueOrNull<String>('address'),
    amount: json.valueOrNull<String>('amount'),
  );

  final String type;
  final String? validatorAddress;
  final String? address;
  final String? amount;

  @override
  JsonMap toRpcParams() => {
    'type': type,
    if (validatorAddress != null) 'validator_address': validatorAddress,
    if (address != null) 'address': address,
    if (amount != null) 'amount': amount,
  };

  @override
  List<Object?> get props => [type, validatorAddress, address, amount];
}

/// Details for claiming staking rewards
class ClaimingDetails extends Equatable implements RpcRequestParams {
  const ClaimingDetails({
    required this.type,
    required this.validatorAddress,
    this.force = false,
  });

  factory ClaimingDetails.fromJson(JsonMap json) => ClaimingDetails(
    type: json.value<String>('type'),
    validatorAddress: json.value<String>('validator_address'),
    force: json.valueOrNull<bool>('force') ?? false,
  );

  final String type;
  final String validatorAddress;
  final bool force;

  @override
  JsonMap toRpcParams() => {
    'type': type,
    'validator_address': validatorAddress,
    'force': force,
  };

  @override
  List<Object?> get props => [type, validatorAddress, force];
}

/// Pagination and filtering details for staking info queries
class StakingInfoDetails extends Equatable implements RpcRequestParams {
  const StakingInfoDetails({
    required this.type,
    this.filterByStatus,
    this.limit,
    this.pageNumber,
  });

  factory StakingInfoDetails.fromJson(JsonMap json) => StakingInfoDetails(
    type: json.value<String>('type'),
    filterByStatus: json.valueOrNull<String>('filter_by_status'),
    limit: json.valueOrNull<int>('limit'),
    pageNumber: json.valueOrNull<int>('page_number'),
  );

  final String type;
  final String? filterByStatus;
  final int? limit;
  final int? pageNumber;

  @override
  JsonMap toRpcParams() => {
    'type': type,
    if (filterByStatus != null) 'filter_by_status': filterByStatus,
    if (limit != null) 'limit': limit,
    if (pageNumber != null) 'page_number': pageNumber,
  };

  @override
  List<Object?> get props => [type, filterByStatus, limit, pageNumber];
}

/// Delegation information returned from the API
class DelegationInfo extends Equatable {
  const DelegationInfo({
    required this.validatorAddress,
    required this.delegatedAmount,
    required this.rewardAmount,
  });

  factory DelegationInfo.fromJson(JsonMap json) => DelegationInfo(
    validatorAddress: json.value<String>('validator_address'),
    delegatedAmount: json.value<String>('delegated_amount'),
    rewardAmount: json.value<String>('reward_amount'),
  );

  final String validatorAddress;
  final String delegatedAmount;
  final String rewardAmount;

  JsonMap toJson() => {
    'validator_address': validatorAddress,
    'delegated_amount': delegatedAmount,
    'reward_amount': rewardAmount,
  };

  @override
  List<Object?> get props => [validatorAddress, delegatedAmount, rewardAmount];
}

/// Entry for an ongoing undelegation
class OngoingUndelegationEntry extends Equatable {
  const OngoingUndelegationEntry({
    required this.creationHeight,
    required this.completionDatetime,
    required this.balance,
  });

  factory OngoingUndelegationEntry.fromJson(JsonMap json) =>
      OngoingUndelegationEntry(
        creationHeight: json.value<int>('creation_height'),
        completionDatetime: json.value<String>('completion_datetime'),
        balance: json.value<String>('balance'),
      );

  final int creationHeight;
  final String completionDatetime;
  final String balance;

  JsonMap toJson() => {
    'creation_height': creationHeight,
    'completion_datetime': completionDatetime,
    'balance': balance,
  };

  @override
  List<Object?> get props => [creationHeight, completionDatetime, balance];
}

/// Ongoing undelegation info
class OngoingUndelegation extends Equatable {
  const OngoingUndelegation({
    required this.validatorAddress,
    required this.entries,
  });

  factory OngoingUndelegation.fromJson(JsonMap json) => OngoingUndelegation(
    validatorAddress: json.value<String>('validator_address'),
    entries:
        json
            .value<List<dynamic>>('entries')
            .map((e) => OngoingUndelegationEntry.fromJson(e as JsonMap))
            .toList(),
  );

  final String validatorAddress;
  final List<OngoingUndelegationEntry> entries;

  JsonMap toJson() => {
    'validator_address': validatorAddress,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [validatorAddress, entries];
}

/// Consensus public key information for a validator.
///
/// Contains the cryptographic public key used by the validator
/// for block signing and consensus participation.
class ConsensusPubkey extends Equatable {
  const ConsensusPubkey({required this.type, required this.key});

  factory ConsensusPubkey.fromJson(JsonMap json) => ConsensusPubkey(
    type: json.valueOrNull<String>('@type') ?? '',
    key: json.valueOrNull<String>('key') ?? '',
  );

  /// The type of public key (e.g., "/cosmos.crypto.ed25519.PubKey").
  final String type;

  /// Base64-encoded public key.
  final String key;

  /// Whether this is an Ed25519 public key.
  bool get isEd25519 => type.contains('ed25519');

  /// Whether this is a secp256k1 public key.
  bool get isSecp256k1 => type.contains('secp256k1');

  JsonMap toJson() => {'@type': type, 'key': key};

  @override
  List<Object?> get props => [type, key];
}

/// Validator description information.
///
/// Contains human-readable information about the validator
/// including name, website, and operational details.
class ValidatorDescription extends Equatable {
  const ValidatorDescription({
    required this.moniker,
    required this.identity,
    required this.website,
    required this.securityContact,
    required this.details,
  });

  factory ValidatorDescription.fromJson(JsonMap json) => ValidatorDescription(
    moniker: json.valueOrNull<String>('moniker') ?? '',
    identity: json.valueOrNull<String>('identity') ?? '',
    website: json.valueOrNull<String>('website') ?? '',
    securityContact: json.valueOrNull<String>('security_contact') ?? '',
    details: json.valueOrNull<String>('details') ?? '',
  );

  /// Validator's display name chosen by the operator.
  final String moniker;

  /// Optional identity verification string.
  final String identity;

  /// Validator's website URL.
  final String website;

  /// Contact information for security issues.
  final String securityContact;

  /// Additional details about the validator's services.
  final String details;

  /// Display name with fallback to "Unknown Validator".
  String get displayName => moniker.isNotEmpty ? moniker : 'Unknown Validator';

  /// Website URL if provided and non-empty.
  String? get websiteUrl => website.isNotEmpty ? website : null;

  /// Security contact if provided and non-empty.
  String? get securityContactInfo =>
      securityContact.isNotEmpty ? securityContact : null;

  /// Details if provided and non-empty.
  String? get detailsInfo => details.isNotEmpty ? details : null;

  JsonMap toJson() => {
    'moniker': moniker,
    'identity': identity,
    'website': website,
    'security_contact': securityContact,
    'details': details,
  };

  @override
  List<Object?> get props => [
    moniker,
    identity,
    website,
    securityContact,
    details,
  ];
}

/// Commission rate structure for a validator.
///
/// Contains the current commission rate and constraints
/// on how the commission can be changed.
class CommissionRates extends Equatable {
  const CommissionRates({
    required this.rate,
    required this.maxRate,
    required this.maxChangeRate,
  });

  factory CommissionRates.fromJson(JsonMap json) => CommissionRates(
    rate: json.valueOrNull<String>('rate') ?? '0',
    maxRate: json.valueOrNull<String>('max_rate') ?? '0',
    maxChangeRate: json.valueOrNull<String>('max_change_rate') ?? '0',
  );

  /// Current commission rate as a string (in 18-decimal precision).
  final String rate;

  /// Maximum commission rate allowed.
  final String maxRate;

  /// Maximum rate of change per day.
  final String maxChangeRate;

  /// Current commission rate as a decimal percentage (0.0 to 1.0).
  Decimal get rateDecimal {
    try {
      final rateValue = Decimal.parse(rate);
      // Convert from 18-decimal precision to percentage
      return (rateValue / Decimal.parse('1000000000000000000')).toDecimal();
    } catch (e) {
      return Decimal.zero;
    }
  }

  /// Maximum commission rate as a decimal percentage.
  Decimal get maxRateDecimal {
    try {
      final maxRateValue = Decimal.parse(maxRate);
      return (maxRateValue / Decimal.parse('1000000000000000000')).toDecimal();
    } catch (e) {
      return Decimal.one; // Default to 100% if parsing fails
    }
  }

  /// Maximum change rate as a decimal percentage.
  Decimal get maxChangeRateDecimal {
    try {
      final maxChangeValue = Decimal.parse(maxChangeRate);
      return (maxChangeValue / Decimal.parse('1000000000000000000'))
          .toDecimal();
    } catch (e) {
      return Decimal.one; // Default to 100% if parsing fails
    }
  }

  JsonMap toJson() => {
    'rate': rate,
    'max_rate': maxRate,
    'max_change_rate': maxChangeRate,
  };

  @override
  List<Object?> get props => [rate, maxRate, maxChangeRate];
}

/// Validator commission information.
///
/// Contains the commission rates and the last time they were updated.
class ValidatorCommission extends Equatable {
  const ValidatorCommission({
    required this.commissionRates,
    required this.updateTime,
  });

  factory ValidatorCommission.fromJson(JsonMap json) => ValidatorCommission(
    commissionRates: CommissionRates.fromJson(
      json.valueOrNull<JsonMap>('commission_rates') ?? {},
    ),
    updateTime: json.valueOrNull<String>('update_time') ?? '',
  );

  /// Current commission rate structure.
  final CommissionRates commissionRates;

  /// ISO timestamp of the last commission update.
  final String updateTime;

  /// Current commission rate as a decimal percentage.
  Decimal get currentRate => commissionRates.rateDecimal;

  /// When the commission was last updated.
  DateTime? get lastUpdateTime {
    if (updateTime.isEmpty) return null;
    try {
      return DateTime.parse(updateTime);
    } catch (e) {
      return null;
    }
  }

  JsonMap toJson() => {
    'commission_rates': commissionRates.toJson(),
    'update_time': updateTime,
  };

  @override
  List<Object?> get props => [commissionRates, updateTime];
}

/// Validator information with typed fields for better type safety.
///
/// Represents a validator as returned by the KDF API's get_validators method.
/// Provides strongly-typed access to validator data while maintaining
/// backward compatibility through the raw data field.
class ValidatorInfo extends Equatable {
  const ValidatorInfo({
    required this.operatorAddress,
    required this.consensusPubkey,
    required this.jailed,
    required this.status,
    required this.tokens,
    required this.delegatorShares,
    required this.description,
    required this.commission,
    required this.unbondingHeight,
    required this.unbondingTime,
    required this.minSelfDelegation,
    required this.data,
  });

  factory ValidatorInfo.fromJson(JsonMap json) {
    return ValidatorInfo(
      operatorAddress: json.valueOrNull<String>('operator_address') ?? '',
      consensusPubkey: ConsensusPubkey.fromJson(
        json.valueOrNull<JsonMap>('consensus_pubkey') ?? {},
      ),
      jailed: json.valueOrNull<bool>('jailed') ?? false,
      status: json.valueOrNull<int>('status') ?? 0,
      tokens: json.valueOrNull<String>('tokens') ?? '0',
      delegatorShares: json.valueOrNull<String>('delegator_shares') ?? '0',
      description: ValidatorDescription.fromJson(
        json.valueOrNull<JsonMap>('description') ?? {},
      ),
      commission: ValidatorCommission.fromJson(
        json.valueOrNull<JsonMap>('commission') ?? {},
      ),
      unbondingHeight: json.valueOrNull<int>('unbonding_height') ?? 0,
      unbondingTime: json.valueOrNull<String>('unbonding_time') ?? '',
      minSelfDelegation: json.valueOrNull<String>('min_self_delegation') ?? '0',
      data: json,
    );
  }

  /// The validator's unique operator address (e.g., "iva1qq93sapmdcx36uz64vvw5gzuevtxsc7lcfxsat").
  final String operatorAddress;

  /// Consensus public key information for block signing.
  final ConsensusPubkey consensusPubkey;

  /// Whether the validator is currently jailed due to misbehavior.
  final bool jailed;

  /// Validator status (3 = BOND_STATUS_BONDED/active).
  final int status;

  /// Total tokens delegated to this validator.
  final String tokens;

  /// Total delegator shares for this validator.
  final String delegatorShares;

  /// Validator description including moniker, website, details.
  final ValidatorDescription description;

  /// Commission rates and settings.
  final ValidatorCommission commission;

  /// Block height when validator started unbonding (0 if never unbonded).
  final int unbondingHeight;

  /// Time when validator unbonding completed (1970-01-01 if never unbonded).
  final String unbondingTime;

  /// Minimum self-delegation required by this validator.
  final String minSelfDelegation;

  /// Raw JSON data for backward compatibility and additional fields.
  final JsonMap data;

  /// Whether the validator is currently active (status == 3).
  bool get isActive => status == 3;

  /// Whether the validator has ever been unbonded.
  bool get hasBeenUnbonded => unbondingHeight > 0;

  /// Validator moniker (display name).
  String get moniker => description.displayName;

  /// Validator website URL if provided.
  String? get website => description.websiteUrl;

  /// Validator details/description if provided.
  String? get details => description.detailsInfo;

  /// Current commission rate as a decimal.
  Decimal get commissionRate => commission.currentRate;

  /// Public key type for consensus.
  String get pubkeyType => consensusPubkey.type;

  /// Whether this validator uses Ed25519 keys.
  bool get usesEd25519 => consensusPubkey.isEd25519;

  JsonMap toJson() => data;

  @override
  List<Object?> get props => [
    operatorAddress,
    consensusPubkey,
    jailed,
    status,
    tokens,
    delegatorShares,
    description,
    commission,
    unbondingHeight,
    unbondingTime,
    minSelfDelegation,
    data,
  ];
}

/// Summary of staking information for QTUM coins
class StakingInfosDetails extends Equatable {
  const StakingInfosDetails({
    required this.type,
    required this.amount,
    required this.amIStaking,
    required this.isStakingSupported,
    this.staker,
  });

  factory StakingInfosDetails.fromJson(JsonMap json) => StakingInfosDetails(
    type: json.value<String>('type'),
    amount: json.value<String>('amount'),
    staker: json.valueOrNull<String>('staker'),
    amIStaking: json.value<bool>('am_i_staking'),
    isStakingSupported: json.value<bool>('is_staking_supported'),
  );

  final String type;
  final String amount;
  final String? staker;
  final bool amIStaking;
  final bool isStakingSupported;

  JsonMap toJson() => {
    'type': type,
    'amount': amount,
    if (staker != null) 'staker': staker,
    'am_i_staking': amIStaking,
    'is_staking_supported': isStakingSupported,
  };

  @override
  List<Object?> get props => [
    type,
    amount,
    staker,
    amIStaking,
    isStakingSupported,
  ];
}

/// Comprehensive staking state for a specific asset.
///
/// Represents the complete staking situation including active positions,
/// pending rewards, unbonding positions, and overall health metrics.
/// Supports both Cosmos and QTUM staking as defined in the KDF API.
///
/// This is the primary data structure returned by staking info queries
/// and provides all necessary information for staking UI and operations.
///
/// Example usage:
/// ```dart
/// final stakingState = await stakingManager.getStakingState(assetId);
/// print('Total staked: ${stakingState.totalStaked}');
/// print('APY: ${stakingState.currentAPY}%');
/// print('Health: ${stakingState.health}');
/// ```
class StakingState extends Equatable {
  const StakingState({
    required this.positions,
    required this.totalStaked,
    required this.pendingRewards,
    required this.unbonding,
    required this.currentAPY,
    required this.lastUpdated,
    required this.health,
  });

  /// Active staking positions across all validators.
  ///
  /// Each position represents a delegation to a specific validator
  /// with details about amount, rewards, and validator information.
  final List<StakingPosition> positions;

  /// Total amount currently staked across all validators.
  ///
  /// This is the sum of all active position amounts.
  /// Does not include unbonding amounts or pending rewards.
  final Decimal totalStaked;

  /// Total rewards available for claiming.
  ///
  /// Accumulated rewards from all validators that can be claimed
  /// immediately. In Cosmos, these are auto-compounded unless claimed.
  final Decimal pendingRewards;

  /// Positions currently in the unbonding process.
  ///
  /// These funds are no longer earning rewards but are not yet
  /// available for withdrawal due to unbonding periods.
  final List<UnbondingPosition> unbonding;

  /// Current estimated Annual Percentage Yield.
  ///
  /// Weighted average APY across all active positions.
  /// Calculated based on validator performance and commission rates.
  final Decimal currentAPY;

  /// Timestamp of the last state update.
  ///
  /// Used for cache management and determining data freshness.
  /// Staking data should be refreshed periodically.
  final DateTime lastUpdated;

  /// Overall health assessment of the staking portfolio.
  ///
  /// Considers factors like validator diversity, risk distribution,
  /// and potential issues requiring attention.
  final StakingHealth health;

  /// Whether there are any rewards available for claiming.
  ///
  /// Convenience getter for UI to show claim buttons and notifications.
  bool get hasRewardsToClaim => pendingRewards > Decimal.zero;

  /// Total value including staked amount and pending rewards.
  ///
  /// Represents the complete value of the staking portfolio
  /// including unrealized gains from rewards.
  Decimal get totalValue => totalStaked + pendingRewards;

  /// Whether all positions are in the process of unbonding.
  ///
  /// Indicates the user is fully exiting staking but waiting
  /// for unbonding periods to complete.
  bool get isFullyUnbonding => positions.isEmpty && unbonding.isNotEmpty;

  @override
  List<Object?> get props => [
    positions,
    totalStaked,
    pendingRewards,
    unbonding,
    currentAPY,
    lastUpdated,
    health,
  ];
}

/// Individual staking position with a specific validator.
///
/// Represents a delegation to a single validator including the staked amount,
/// accumulated rewards, and validator-specific information.
///
/// Corresponds to the delegation data returned by the KDF API's staking_info
/// method when filtered by validator address.
///
/// Example:
/// ```dart
/// final position = stakingState.positions.first;
/// print('Validator: ${position.validator.name}');
/// print('Staked: ${position.stakedAmount}');
/// print('Rewards: ${position.rewards}');
/// print('APY: ${position.validatorAPY}%');
/// ```
class StakingPosition extends Equatable {
  const StakingPosition({
    required this.validatorAddress,
    required this.validator,
    required this.stakedAmount,
    required this.rewards,
    required this.stakedAt,
    required this.validatorAPY,
  });

  /// The validator's operator address.
  ///
  /// Unique identifier for the validator in the network.
  /// Format varies by network (e.g., cosmosvaloper1... for Cosmos).
  final String validatorAddress;

  /// Detailed validator information.
  ///
  /// Enhanced data about the validator including performance metrics,
  /// commission rates, and operational status.
  final EnhancedValidatorInfo validator;

  /// Amount currently staked with this validator.
  ///
  /// The principal amount delegated, excluding any accumulated rewards.
  /// This amount earns rewards based on the validator's performance.
  final Decimal stakedAmount;

  /// Rewards accumulated from this delegation.
  ///
  /// Available for claiming or auto-compounding.
  /// Updated periodically based on validator block signing.
  final Decimal rewards;

  /// Timestamp when the delegation was created.
  ///
  /// Used for calculating staking duration and reward projections.
  /// In some networks, delegation time affects reward calculations.
  final DateTime stakedAt;

  /// Current APY specific to this validator.
  ///
  /// May differ from network average due to validator-specific
  /// factors like commission rate and performance.
  final Decimal validatorAPY;

  /// Whether the validator is currently active and earning rewards.
  ///
  /// Inactive validators don't earn rewards and may indicate
  /// the need to redelegate to an active validator.
  bool get isActive => validator.isActive;

  /// How long the delegation has been active.
  ///
  /// Useful for calculating total returns and assessing
  /// the investment timeline.
  Duration get stakingDuration => DateTime.now().difference(stakedAt);

  @override
  List<Object?> get props => [
    validatorAddress,
    validator,
    stakedAmount,
    rewards,
    stakedAt,
    validatorAPY,
  ];
}

/// Position currently in the unbonding process.
///
/// Represents funds that have been undelegated but are still locked
/// during the network's unbonding period. These funds don't earn rewards
/// but also can't be immediately withdrawn.
///
/// Unbonding periods vary by network:
/// - Cosmos chains: Typically 21 days
/// - QTUM: Immediate but requires confirmation
///
/// Corresponds to unbonding delegation entries in the KDF API response.
class UnbondingPosition extends Equatable {
  const UnbondingPosition({
    required this.validatorAddress,
    required this.amount,
    required this.completionTime,
    required this.transactionId,
  });

  /// The validator from which funds are being undelegated.
  ///
  /// Identifies the source of the unbonding position.
  final String validatorAddress;

  /// Amount of funds in the unbonding process.
  ///
  /// This amount is no longer earning rewards and will become
  /// available for withdrawal after the completion time.
  final Decimal amount;

  /// When the unbonding process will complete.
  ///
  /// After this time, funds can be withdrawn to the wallet.
  /// Set based on network unbonding period parameters.
  final DateTime completionTime;

  /// Transaction hash that initiated the unbonding.
  ///
  /// Can be used to track the undelegation transaction
  /// on block explorers.
  final String transactionId;

  /// Time remaining until funds are available for withdrawal.
  ///
  /// Returns negative duration if unbonding is already complete.
  Duration get timeRemaining => completionTime.difference(DateTime.now());

  /// Whether the unbonding period has completed.
  ///
  /// When true, funds can be withdrawn from the unbonding position.
  bool get isComplete => DateTime.now().isAfter(completionTime);

  @override
  List<Object?> get props => [
    validatorAddress,
    amount,
    completionTime,
    transactionId,
  ];
}

/// Enhanced validator information with comprehensive metrics.
///
/// Provides structured data about a validator including performance metrics,
/// commission rates, and operational status. Created from raw validator data
/// returned by the KDF API's get_validators method.
///
/// Includes both basic validator information and calculated metrics
/// to help users make informed delegation decisions.
///
/// Example validator selection logic:
/// ```dart
/// final goodValidators = validators.where((v) =>
///   v.isActive &&
///   !v.isJailed &&
///   v.commission < 0.05 &&
///   v.uptime > 0.95
/// ).toList();
/// ```
class EnhancedValidatorInfo extends Equatable {
  const EnhancedValidatorInfo({
    required this.address,
    required this.name,
    required this.commission,
    required this.uptime,
    required this.isActive,
    required this.isJailed,
    required this.totalDelegated,
    required this.votingPower,
    required this.description,
  });

  /// Creates enhanced validator info from typed ValidatorInfo data.
  ///
  /// Parses the validator information returned by the get_validators
  /// method and extracts relevant fields into a structured format.
  ///
  /// Uses the typed fields from ValidatorInfo for better type safety
  /// and handles missing or malformed data gracefully with sensible defaults.
  factory EnhancedValidatorInfo.fromValidatorInfo(ValidatorInfo info) {
    return EnhancedValidatorInfo(
      address: info.operatorAddress,
      name: info.moniker,
      commission: info.commissionRate,
      uptime: _parseUptime(info.data),
      isActive: info.isActive,
      isJailed: info.jailed,
      totalDelegated: Decimal.parse(info.tokens),
      votingPower: _parseVotingPower(info.data),
      description: _parseDescription(info.description),
    );
  }

  /// The validator's unique operator address.
  ///
  /// Used for delegation transactions and identifying the validator
  /// across all staking operations.
  final String address;

  /// Human-readable validator name or moniker.
  ///
  /// Display name chosen by the validator operator.
  /// Defaults to 'Unknown Validator' if not provided.
  final String name;

  /// Commission rate charged by the validator (0.0 to 1.0).
  ///
  /// Percentage of rewards kept by the validator as compensation.
  /// Lower commission means higher delegator rewards.
  final Decimal commission;

  /// Validator uptime percentage (0.0 to 1.0).
  ///
  /// Measure of reliability based on block signing performance.
  /// Higher uptime indicates more consistent rewards.
  final Decimal uptime;

  /// Whether the validator is currently active in the consensus.
  ///
  /// Only active validators earn rewards for their delegators.
  /// Inactive validators should generally be avoided.
  final bool isActive;

  /// Whether the validator is currently jailed.
  ///
  /// Jailed validators are temporarily excluded from consensus
  /// due to misbehavior and don't earn rewards.
  final bool isJailed;

  /// Total amount delegated to this validator.
  ///
  /// Indicates the validator's size and trustworthiness.
  /// Very large validators may pose centralization risks.
  final Decimal totalDelegated;

  /// Validator's voting power as a percentage of total network power.
  ///
  /// Higher voting power indicates more influence in governance.
  /// Extremely high values may indicate centralization concerns.
  final Decimal votingPower;

  /// Optional validator description or website.
  ///
  /// Additional information provided by the validator operator
  /// about their services and philosophy.
  final String? description;

  /// Parses a meaningful description from the validator description object.
  ///
  /// Combines available description fields into a useful string.
  static String? _parseDescription(ValidatorDescription description) {
    final parts = <String>[];

    if (description.detailsInfo != null) {
      parts.add(description.detailsInfo!);
    }
    if (description.websiteUrl != null) {
      parts.add('Website: ${description.websiteUrl!}');
    }

    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }
    return null;
  }

  /// Calculates validator uptime from available status information.
  ///
  /// Since detailed signing information isn't available in the validator
  /// response, this method provides a reasonable heuristic based on
  /// validator status and jailed state:
  /// - Jailed validators: 0.0 (no uptime while jailed)
  /// - Active validators (status 3): 0.95 (high uptime assumption)
  /// - Inactive validators: 0.8 (moderate uptime assumption)
  ///
  /// For precise uptime calculations, additional signing info would be needed.
  static Decimal _parseUptime(JsonMap data) {
    final isJailed = data.valueOrNull<bool>('jailed') ?? false;
    final status = data.valueOrNull<int>('status') ?? 0;

    if (isJailed) {
      // Jailed validators have effectively 0% uptime
      return Decimal.zero;
    }

    if (status == 3) {
      // Active validators (BOND_STATUS_BONDED) - assume high uptime
      return Decimal.parse('0.95');
    }

    // Inactive validators - assume moderate uptime
    return Decimal.parse('0.80');
  }

  /// Calculates voting power as a percentage of total network power.
  ///
  /// Compares the validator's token amount to total network supply
  /// to determine their influence in consensus and governance.
  ///
  /// Note: Individual validator responses don't include total_supply,
  /// so this calculation can only be performed when total supply data
  /// is available from a separate network query. Returns 0.0 when
  /// total supply is not provided.
  ///
  /// For accurate voting power calculation, pass total_supply in the
  /// validator data or calculate at a higher level with network totals.
  static Decimal _parseVotingPower(JsonMap data) {
    final tokens = data.valueOrNull<String>('tokens');
    final totalSupply = data.valueOrNull<String>('total_supply');

    // Return 0.0 if total supply isn't available (common for individual validator queries)
    if (tokens == null || totalSupply == null) {
      return Decimal.zero;
    }

    try {
      final tokensDecimal = Decimal.parse(tokens);
      final totalDecimal = Decimal.parse(totalSupply);

      if (totalDecimal > Decimal.zero) {
        return (tokensDecimal / totalDecimal).toDecimal();
      }
    } catch (e) {
      // Return 0.0 if parsing fails
      return Decimal.zero;
    }

    return Decimal.zero;
  }

  @override
  List<Object?> get props => [
    address,
    name,
    commission,
    uptime,
    isActive,
    isJailed,
    totalDelegated,
    votingPower,
    description,
  ];
}

/// Comprehensive staking information for portfolio analysis.
///
/// Aggregated view of staking data including balances, validators,
/// and projected returns. Used for making staking decisions and
/// displaying portfolio overviews.
///
/// Typically refreshed periodically to maintain accuracy of
/// reward estimates and validator rankings.
class StakingInfo extends Equatable {
  const StakingInfo({
    required this.totalStaked,
    required this.availableBalance,
    required this.pendingRewards,
    required this.validators,
    required this.unbondingAmount,
    required this.estimatedAPY,
    required this.nextRewardTime,
  });

  /// Total amount currently staked across all validators.
  final Decimal totalStaked;

  /// Available balance that can be used for additional staking.
  ///
  /// Considers transaction fees and minimum balance requirements.
  final Decimal availableBalance;

  /// Total rewards pending across all delegations.
  final Decimal pendingRewards;

  /// List of all available validators with enhanced information.
  ///
  /// Sorted by recommendation score or user preference.
  /// Used for validator selection during delegation.
  final List<EnhancedValidatorInfo> validators;

  /// Total amount currently in unbonding across all validators.
  final Decimal unbondingAmount;

  /// Estimated APY based on current network conditions.
  ///
  /// Weighted average considering validator performance and fees.
  final Decimal estimatedAPY;

  /// Estimated time until next reward distribution.
  ///
  /// May be null for networks with continuous reward accrual.
  final DateTime? nextRewardTime;

  @override
  List<Object?> get props => [
    totalStaked,
    availableBalance,
    pendingRewards,
    validators,
    unbondingAmount,
    estimatedAPY,
    nextRewardTime,
  ];
}

/// AI-driven suggestions for optimal staking configuration.
///
/// Provides recommendations based on user's risk tolerance,
/// available balance, and current market conditions.
///
/// Helps users optimize their staking strategy for better
/// returns while managing risk through validator diversification.
class StakingSuggestions extends Equatable {
  const StakingSuggestions({
    required this.recommendedAmount,
    required this.expectedReturns,
    required this.riskLevel,
    required this.suggestedValidators,
    required this.warnings,
  });

  /// Recommended amount to stake based on available balance.
  ///
  /// Considers transaction fees, minimum balances, and risk management.
  final Decimal recommendedAmount;

  /// Expected annual returns from the recommended configuration.
  ///
  /// Calculated based on suggested validators and current rates.
  final Decimal expectedReturns;

  /// Risk level of the recommended staking strategy.
  ///
  /// Based on validator diversification and individual validator risk profiles.
  final StakingRisk riskLevel;

  /// List of recommended validators with scoring rationale.
  ///
  /// Ordered by recommendation strength with explanations
  /// for why each validator is suggested.
  final List<ValidatorRecommendation> suggestedValidators;

  /// Important warnings about the current staking environment.
  ///
  /// May include network risks, validator concerns, or market conditions.
  final List<String> warnings;

  @override
  List<Object?> get props => [
    recommendedAmount,
    expectedReturns,
    riskLevel,
    suggestedValidators,
    warnings,
  ];
}

/// Scored recommendation for a specific validator.
///
/// Combines validator information with a recommendation score
/// and human-readable explanations for why the validator
/// is being suggested.
///
/// Scoring considers factors like:
/// - Commission rates
/// - Uptime and reliability
/// - Voting power (avoiding over-concentration)
/// - Historical performance
class ValidatorRecommendation extends Equatable {
  const ValidatorRecommendation({
    required this.validator,
    required this.score,
    required this.reasons,
  });

  /// The validator being recommended.
  final EnhancedValidatorInfo validator;

  /// Recommendation score from 0.0 to 1.0.
  ///
  /// Higher scores indicate stronger recommendations.
  /// Based on multiple weighted factors.
  final double score;

  /// Human-readable reasons for the recommendation.
  ///
  /// Explains why this validator received its score,
  /// highlighting strengths and any concerns.
  final List<String> reasons;

  @override
  List<Object?> get props => [validator, score, reasons];
}

/// Generic wrapper for cached data with TTL management.
///
/// Used internally by the staking system to manage cached
/// validator lists, staking states, and other frequently
/// accessed data with defined expiration times.
///
/// Helps reduce API calls while ensuring data freshness
/// for time-sensitive staking operations.
class CachedData<T> extends Equatable {
  const CachedData(this.data, this.timestamp);

  /// The cached data of any type.
  final T data;

  /// When the data was cached.
  final DateTime timestamp;

  /// Whether the cached data has exceeded its time-to-live.
  ///
  /// Returns true if the data should be refreshed.
  bool isExpired(Duration ttl) => DateTime.now().difference(timestamp) > ttl;

  @override
  List<Object?> get props => [data, timestamp];
}

/// Overall health assessment of a staking portfolio.
///
/// Evaluates the portfolio across multiple dimensions including
/// validator diversification, risk concentration, and potential issues.
enum StakingHealth {
  /// Portfolio is well-diversified with reliable validators.
  ///
  /// All validators are active, commissions are reasonable,
  /// and risk is well-distributed.
  good,

  /// Some concerns that should be addressed.
  ///
  /// May include high concentration in few validators,
  /// some validators with higher risk profiles, or
  /// approaching network governance thresholds.
  warning,

  /// Immediate attention required.
  ///
  /// Critical issues like jailed validators, excessive
  /// concentration, or significant risk exposure that
  /// could impact returns or principal.
  critical,
}

/// Risk levels for staking strategies and validators.
///
/// Used to categorize investment approaches and help users
/// make informed decisions based on their risk tolerance.
enum StakingRisk {
  /// Conservative approach with established validators.
  ///
  /// Focus on stability and consistent returns over
  /// maximum yield. Suitable for risk-averse users.
  low,

  /// Balanced approach mixing stability and opportunity.
  ///
  /// Combination of established and emerging validators
  /// for reasonable returns with managed risk.
  medium,

  /// Aggressive approach prioritizing maximum returns.
  ///
  /// May include newer validators or those with higher
  /// commission but potentially higher rewards.
  high,
}

/// Real-time update about reward accumulation progress.
///
/// Provides information about currently accumulated rewards
/// and projections for future reward distributions.
///
/// Used for live updates in staking UIs to show:
/// - Current unclaimed reward amounts
/// - Time until next reward distribution
/// - Updated APY calculations
///
/// Example in a periodic update:
/// ```dart
/// stakingManager.rewardUpdates.listen((update) {
///   print('Current rewards: ${update.amount}');
///   print('Next reward in: ${update.timeToNext}');
///   print('Current APY: ${update.estimatedAPY}%');
/// });
/// ```
class RewardUpdate extends Equatable {
  const RewardUpdate({
    required this.amount,
    required this.timeToNext,
    required this.estimatedAPY,
  });

  /// Current accumulated reward amount available for claiming.
  ///
  /// This amount continues to grow until rewards are claimed
  /// or auto-compounded by the network.
  final Decimal amount;

  /// Time remaining until the next reward distribution.
  ///
  /// May be null for networks with continuous reward accrual.
  /// Used to inform users when to expect reward updates.
  final Duration timeToNext;

  /// Current estimated APY based on recent performance.
  ///
  /// Recalculated based on actual validator performance
  /// and may differ from initial estimates.
  final Decimal estimatedAPY;

  @override
  List<Object?> get props => [amount, timeToNext, estimatedAPY];
}

/// Defines different strategies for validator selection when staking assets.
///
/// Each strategy represents a different risk/reward profile and determines
/// how validators are automatically selected when staking. The strategies
/// influence validator selection criteria such as commission rates, uptime,
/// voting power distribution, and decentralization preferences.
///
/// ## Strategy Details:
///
/// ### Aggressive Strategy
/// - **Goal**: Maximize staking returns
/// - **Risk**: Higher risk tolerance
/// - **Validator Selection**: Focuses on validators with lowest commission rates
/// - **Validator Count**: Typically selects 1 validator (concentrated)
/// - **Commission Tolerance**: Up to 20%
/// - **Uptime Requirement**: Minimum 90%
/// - **Use Case**: When maximizing yield is the primary concern
///
/// ### Balanced Strategy (Default)
/// - **Goal**: Balance between returns and safety
/// - **Risk**: Moderate risk tolerance
/// - **Validator Selection**: Considers commission, uptime, and decentralization
/// - **Validator Count**: Typically selects 3 validators (diversified)
/// - **Commission Tolerance**: Up to 10%
/// - **Uptime Requirement**: Minimum 95%
/// - **Use Case**: General purpose staking for most users
///
/// ### Conservative Strategy
/// - **Goal**: Prioritize safety and network decentralization
/// - **Risk**: Lower risk tolerance
/// - **Validator Selection**: Emphasizes high uptime and network security
/// - **Validator Count**: Multiple validators (highly diversified)
/// - **Commission Tolerance**: Up to 5%
/// - **Uptime Requirement**: Minimum 99%
/// - **Use Case**: When preserving capital is more important than maximizing returns
///
/// ### Custom Strategy
/// - **Goal**: User-defined criteria
/// - **Risk**: Varies based on configuration
/// - **Validator Selection**: Uses custom ValidatorSelectionCriteria
/// - **Use Case**: Advanced users with specific requirements
///
/// ## Example Usage:
///
/// ```dart
/// // Aggressive staking for maximum returns
/// final result = await stakingManager.stake(
///   assetId: AssetId('ATOM'),
///   amount: Decimal.parse('100'),
///   strategy: StakingStrategy.aggressive,
/// );
///
/// // Conservative staking for safety
/// final result = await stakingManager.stake(
///   assetId: AssetId('IRIS'),
///   amount: Decimal.parse('50'),
///   strategy: StakingStrategy.conservative,
/// );
///
/// // Balanced approach (default)
/// final result = await stakingManager.quickStake(
///   assetId: AssetId('OSMO'),
///   amount: Decimal.parse('75'),
/// );
/// ```
///
/// ## Risk Considerations:
///
/// - **Aggressive**: Higher potential returns but increased risk of validator issues
/// - **Balanced**: Good compromise between yield and safety
/// - **Conservative**: Lower returns but higher safety and network support
/// - **Custom**: Risk depends on user-defined criteria
///
/// ## Supported Networks:
///
/// These strategies work with all supported staking networks including:
/// - Cosmos ecosystem (ATOM, IRIS, OSMO, etc.)
/// - Qtum and tQTUM (testnet)
/// - Other Tendermint-based chains
enum StakingStrategy {
  /// **Aggressive Strategy**: Maximize staking returns with higher risk tolerance.
  ///
  /// - Selects validators with lowest commission rates (up to 20%)
  /// - Typically uses 1 validator for concentrated staking
  /// - Minimum 90% uptime requirement
  /// - Best for users prioritizing maximum yield over safety
  /// - Higher risk of validator-specific issues affecting returns
  aggressive,

  /// **Balanced Strategy**: Default strategy balancing returns with safety.
  ///
  /// - Considers commission, uptime, and decentralization factors
  /// - Typically distributes stake across 3 validators
  /// - Maximum 10% commission tolerance
  /// - Minimum 95% uptime requirement
  /// - Recommended for most users as a good all-around choice
  balanced,

  /// **Conservative Strategy**: Prioritize safety and network decentralization.
  ///
  /// - Emphasizes high uptime and network security
  /// - Distributes stake across multiple validators
  /// - Maximum 5% commission tolerance
  /// - Minimum 99% uptime requirement
  /// - Supports network decentralization by avoiding large validators
  /// - Best for users prioritizing capital preservation
  conservative,

  /// **Custom Strategy**: Use user-defined validator selection criteria.
  ///
  /// - Allows complete customization of selection parameters
  /// - Requires providing custom ValidatorSelectionCriteria
  /// - Risk and return characteristics depend on user configuration
  /// - Advanced feature for users with specific requirements
  custom,
}
