import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

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
        entries: (json.value<List>('entries') as List)
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

/// Validator information
class ValidatorInfo extends Equatable {
  const ValidatorInfo({required this.data});

  factory ValidatorInfo.fromJson(JsonMap json) => ValidatorInfo(data: json);

  final JsonMap data;

  JsonMap toJson() => data;

  @override
  List<Object?> get props => [data];
}

/// Summary of staking information for QTUM coins
class StakingInfosDetails extends Equatable {
  const StakingInfosDetails({
    required this.type,
    required this.amount,
    this.staker,
    required this.amIStaking,
    required this.isStakingSupported,
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
