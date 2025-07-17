import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class StakingMethodsNamespace extends BaseRpcMethodNamespace {
  StakingMethodsNamespace(super.client);

  Future<StakingTxResponse> delegate({
    required String coin,
    required StakingDetails details,
  }) {
    return execute(
      DelegateRequest(rpcPass: rpcPass ?? '', coin: coin, details: details),
    );
  }

  Future<StakingTxResponse> undelegate({
    required String coin,
    required StakingDetails details,
  }) {
    return execute(
      UndelegateRequest(rpcPass: rpcPass ?? '', coin: coin, details: details),
    );
  }

  Future<StakingTxResponse> claimRewards({
    required String coin,
    required ClaimingDetails details,
  }) {
    return execute(
      ClaimRewardsRequest(rpcPass: rpcPass ?? '', coin: coin, details: details),
    );
  }

  Future<QueryDelegationsResponse> queryDelegations({
    required String coin,
    StakingInfoDetails? infoDetails,
  }) {
    return execute(
      QueryDelegationsRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        infoDetails: infoDetails,
      ),
    );
  }

  Future<QueryOngoingUndelegationsResponse> queryOngoingUndelegations({
    required String coin,
    required StakingInfoDetails infoDetails,
  }) {
    return execute(
      QueryOngoingUndelegationsRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        infoDetails: infoDetails,
      ),
    );
  }

  Future<QueryValidatorsResponse> queryValidators({
    required String coin,
    required StakingInfoDetails infoDetails,
  }) {
    return execute(
      QueryValidatorsRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        infoDetails: infoDetails,
      ),
    );
  }
}

class DelegateRequest
    extends BaseRequest<StakingTxResponse, GeneralErrorResponse> {
  DelegateRequest({
    required super.rpcPass,
    required this.coin,
    required this.details,
  }) : super(method: 'experimental::staking::delegate', mmrpc: '2.0');

  final String coin;
  final StakingDetails details;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'staking_details': details.toRpcParams()},
  };

  @override
  StakingTxResponse parse(Map<String, dynamic> json) =>
      StakingTxResponse.parse(json);
}

class UndelegateRequest
    extends BaseRequest<StakingTxResponse, GeneralErrorResponse> {
  UndelegateRequest({
    required super.rpcPass,
    required this.coin,
    required this.details,
  }) : super(method: 'experimental::staking::undelegate', mmrpc: '2.0');

  final String coin;
  final StakingDetails details;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'staking_details': details.toRpcParams()},
  };

  @override
  StakingTxResponse parse(Map<String, dynamic> json) =>
      StakingTxResponse.parse(json);
}

class ClaimRewardsRequest
    extends BaseRequest<StakingTxResponse, GeneralErrorResponse> {
  ClaimRewardsRequest({
    required super.rpcPass,
    required this.coin,
    required this.details,
  }) : super(method: 'experimental::staking::claim_rewards', mmrpc: '2.0');

  final String coin;
  final ClaimingDetails details;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'claiming_details': details.toRpcParams()},
  };

  @override
  StakingTxResponse parse(Map<String, dynamic> json) =>
      StakingTxResponse.parse(json);
}

class QueryDelegationsRequest
    extends BaseRequest<QueryDelegationsResponse, GeneralErrorResponse> {
  QueryDelegationsRequest({
    required super.rpcPass,
    required this.coin,
    this.infoDetails,
  }) : super(method: 'experimental::staking::query::delegations', mmrpc: '2.0');

  final String coin;
  final StakingInfoDetails? infoDetails;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'coin': coin,
      if (infoDetails != null) 'info_details': infoDetails!.toRpcParams(),
    },
  };

  @override
  QueryDelegationsResponse parse(Map<String, dynamic> json) =>
      QueryDelegationsResponse.parse(json);
}

class QueryOngoingUndelegationsRequest
    extends
        BaseRequest<QueryOngoingUndelegationsResponse, GeneralErrorResponse> {
  QueryOngoingUndelegationsRequest({
    required super.rpcPass,
    required this.coin,
    required this.infoDetails,
  }) : super(
         method: 'experimental::staking::query::ongoing_undelegations',
         mmrpc: '2.0',
       );

  final String coin;
  final StakingInfoDetails infoDetails;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'info_details': infoDetails.toRpcParams()},
  };

  @override
  QueryOngoingUndelegationsResponse parse(Map<String, dynamic> json) =>
      QueryOngoingUndelegationsResponse.parse(json);
}

class QueryValidatorsRequest
    extends BaseRequest<QueryValidatorsResponse, GeneralErrorResponse> {
  QueryValidatorsRequest({
    required super.rpcPass,
    required this.coin,
    required this.infoDetails,
  }) : super(method: 'experimental::staking::query::validators', mmrpc: '2.0');

  final String coin;
  final StakingInfoDetails infoDetails;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'info_details': infoDetails.toRpcParams()},
  };

  @override
  QueryValidatorsResponse parse(Map<String, dynamic> json) =>
      QueryValidatorsResponse.parse(json);
}

class StakingTxResponse extends BaseResponse {
  StakingTxResponse({required super.mmrpc, required this.result});

  factory StakingTxResponse.parse(Map<String, dynamic> json) =>
      StakingTxResponse(
        mmrpc: json.value<String>('mmrpc'),
        result: WithdrawResult.fromJson(json.value<JsonMap>('result')),
      );

  final WithdrawResult result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}

class QueryDelegationsResponse extends BaseResponse {
  QueryDelegationsResponse({
    required super.mmrpc,
    this.delegations,
    this.stakingInfosDetails,
  });

  factory QueryDelegationsResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    return QueryDelegationsResponse(
      mmrpc: json.value<String>('mmrpc'),
      delegations:
          result.containsKey('delegations')
              ? (result['delegations'] as List)
                  .map((e) => DelegationInfo.fromJson(e as JsonMap))
                  .toList()
              : null,
      stakingInfosDetails:
          result.containsKey('staking_infos_details')
              ? StakingInfosDetails.fromJson(
                result.value<JsonMap>('staking_infos_details'),
              )
              : null,
    );
  }

  final List<DelegationInfo>? delegations;
  final StakingInfosDetails? stakingInfosDetails;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      if (delegations != null)
        'delegations': delegations!.map((e) => e.toJson()).toList(),
      if (stakingInfosDetails != null)
        'staking_infos_details': stakingInfosDetails!.toJson(),
    },
  };
}

class QueryOngoingUndelegationsResponse extends BaseResponse {
  QueryOngoingUndelegationsResponse({
    required super.mmrpc,
    required this.undelegations,
  });

  factory QueryOngoingUndelegationsResponse.parse(Map<String, dynamic> json) =>
      QueryOngoingUndelegationsResponse(
        mmrpc: json.value<String>('mmrpc'),
        undelegations:
            (json.value<JsonMap>('result')['ongoing_undelegations'] as List)
                .map((e) => OngoingUndelegation.fromJson(e as JsonMap))
                .toList(),
      );

  final List<OngoingUndelegation> undelegations;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'ongoing_undelegations':
          undelegations
              .map(
                (e) => {
                  'validator_address': e.validatorAddress,
                  'entries':
                      e.entries
                          .map(
                            (entry) => {
                              'creation_height': entry.creationHeight,
                              'completion_datetime': entry.completionDatetime,
                              'balance': entry.balance,
                            },
                          )
                          .toList(),
                },
              )
              .toList(),
    },
  };
}

class QueryValidatorsResponse extends BaseResponse {
  QueryValidatorsResponse({required super.mmrpc, required this.validators});

  factory QueryValidatorsResponse.parse(Map<String, dynamic> json) =>
      QueryValidatorsResponse(
        mmrpc: json.value<String>('mmrpc'),
        validators:
            (json.value<JsonMap>('result')['validators'] as List)
                .map((e) => ValidatorInfo.fromJson(e as JsonMap))
                .toList(),
      );

  final List<ValidatorInfo> validators;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'validators': validators.map((v) => v.data).toList()},
  };
}
