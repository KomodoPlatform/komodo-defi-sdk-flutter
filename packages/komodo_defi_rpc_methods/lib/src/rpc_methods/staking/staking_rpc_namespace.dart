import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class StakingMethodsNamespace extends BaseRpcMethodNamespace {
  StakingMethodsNamespace(super.client);

  Future<DelegationResponse> addDelegation({
    required String coin,
    required String stakingType,
    required String address,
  }) {
    return execute(
      AddDelegationRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        stakingType: stakingType,
        address: address,
      ),
    );
  }

  Future<DelegationResponse> removeDelegation({required String coin}) {
    return execute(RemoveDelegationRequest(rpcPass: rpcPass ?? '', coin: coin));
  }

  Future<StakingInfosResponse> getStakingInfos({required String coin}) {
    return execute(GetStakingInfosRequest(rpcPass: rpcPass ?? '', coin: coin));
  }
}
