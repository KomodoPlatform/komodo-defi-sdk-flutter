import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Details about the current staking status returned by the API
class StakingInfoDetails extends Equatable {
  const StakingInfoDetails({
    required this.type,
    required this.amount,
    required this.amIStaking, required this.isStakingSupported, this.staker,
  });

  factory StakingInfoDetails.fromJson(JsonMap json) => StakingInfoDetails(
        type: json.value<String>('type'),
        amount: Decimal.parse(json.value<String>('amount')),
        staker: json.valueOrNull<String>('staker'),
        amIStaking: json.value<bool>('am_i_staking'),
        isStakingSupported: json.value<bool>('is_staking_supported'),
      );

  final String type;
  final Decimal amount;
  final String? staker;
  final bool amIStaking;
  final bool isStakingSupported;

  JsonMap toJson() => {
        'type': type,
        'amount': amount.toString(),
        if (staker != null) 'staker': staker,
        'am_i_staking': amIStaking,
        'is_staking_supported': isStakingSupported,
      };

  @override
  List<Object?> get props =>
      [type, amount, staker, amIStaking, isStakingSupported];
}

/// Wrapper for staking info API response
class StakingInfo extends Equatable {
  const StakingInfo({required this.details});

  factory StakingInfo.fromJson(JsonMap json) => StakingInfo(
        details: StakingInfoDetails.fromJson(
            json.value<JsonMap>('staking_infos_details'),),
      );

  final StakingInfoDetails details;

  JsonMap toJson() => {'staking_infos_details': details.toJson()};

  @override
  List<Object?> get props => [details];
}

/// Parameters for initiating delegation
class DelegationParams implements RpcRequestParams {
  const DelegationParams({required this.type, required this.address});

  final String type;
  final String address;

  @override
  JsonMap toRpcParams() => {'type': type, 'address': address};
}
