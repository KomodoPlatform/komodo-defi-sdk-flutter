import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager for staking operations using the KDF RPC API.
class StakingManager {
  StakingManager(this._client, this._assetProvider, this._activationManager);

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final ActivationManager _activationManager;

  Future<WithdrawResult> delegate(String coin, StakingDetails details) async {
    await _ensureActivated(coin);
    final response = await _client.rpc.staking.delegate(
      coin: coin,
      details: details,
    );
    final broadcast = await _client.rpc.withdraw.sendRawTransaction(
      coin: coin,
      txHex: response.result.txHex,
    );
    return response.result.copyWith(txHash: broadcast.txHash);
  }

  Future<WithdrawResult> undelegate(String coin, StakingDetails details) async {
    await _ensureActivated(coin);
    final response = await _client.rpc.staking.undelegate(
      coin: coin,
      details: details,
    );
    final broadcast = await _client.rpc.withdraw.sendRawTransaction(
      coin: coin,
      txHex: response.result.txHex,
    );
    return response.result.copyWith(txHash: broadcast.txHash);
  }

  Future<WithdrawResult> claimRewards(
    String coin,
    ClaimingDetails details,
  ) async {
    await _ensureActivated(coin);
    final response = await _client.rpc.staking.claimRewards(
      coin: coin,
      details: details,
    );
    final broadcast = await _client.rpc.withdraw.sendRawTransaction(
      coin: coin,
      txHex: response.result.txHex,
    );
    return response.result.copyWith(txHash: broadcast.txHash);
  }

  Future<List<DelegationInfo>> queryDelegations(
    String coin, {
    StakingInfoDetails? infoDetails,
  }) async {
    await _ensureActivated(coin);
    final response = await _client.rpc.staking.queryDelegations(
      coin: coin,
      infoDetails: infoDetails,
    );
    return response.delegations;
  }

  Future<List<OngoingUndelegation>> queryOngoingUndelegations(
    String coin,
    StakingInfoDetails infoDetails,
  ) async {
    await _ensureActivated(coin);
    final response = await _client.rpc.staking.queryOngoingUndelegations(
      coin: coin,
      infoDetails: infoDetails,
    );
    return response.undelegations;
  }

  Future<List<ValidatorInfo>> queryValidators(
    String coin,
    StakingInfoDetails infoDetails,
  ) async {
    await _ensureActivated(coin);
    final response = await _client.rpc.staking.queryValidators(
      coin: coin,
      infoDetails: infoDetails,
    );
    return response.validators;
  }

  Future<void> _ensureActivated(String ticker) async {
    final asset = _assetProvider.findAssetsByTicker(ticker).firstOrNull;
    if (asset != null) {
      final progress = await _activationManager.activateAsset(asset).last;
      if (progress.isComplete && !progress.isSuccess) {
        throw Exception('Failed to activate $ticker');
      }
    }
  }

  Future<void> dispose() async {}
}

extension on WithdrawResult {
  WithdrawResult copyWith({required String txHash}) {
    return WithdrawResult(
      txHash: txHash,
      balanceChanges: balanceChanges,
      coin: coin,
      toAddress: to.first,
      fee: fee,
      kmdRewardsEligible: kmdRewardsEligible,
    );
  }
}
