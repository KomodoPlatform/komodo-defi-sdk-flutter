import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager for staking operations such as delegating and removing delegation.
class StakingManager {
  StakingManager(this._client, this._activationManager);

  final ApiClient _client;
  final ActivationManager _activationManager;

  /// Delegate staking of [asset] to [address].
  Future<WithdrawResult> delegate({
    required Asset asset,
    required String address,
  }) async {
    await _activationManager.activateAsset(asset).last;
    final type = _stakingType(asset);
    final response = await _client.rpc.staking.addDelegation(
      coin: asset.id.id,
      stakingType: type,
      address: address,
    );
    return response.result;
  }

  /// Remove staking delegation for [asset].
  Future<WithdrawResult> undelegate(Asset asset) async {
    await _activationManager.activateAsset(asset).last;
    final response = await _client.rpc.staking.removeDelegation(
      coin: asset.id.id,
    );
    return response.result;
  }

  /// Get staking info for [asset].
  Future<StakingInfo> getStakingInfo(Asset asset) async {
    await _activationManager.activateAsset(asset).last;
    final response = await _client.rpc.staking.getStakingInfos(
      coin: asset.id.id,
    );
    return response.result;
  }

  String _stakingType(Asset asset) {
    if (asset.protocol is QtumProtocol) return 'Qtum';
    return asset.protocol.subClass.formatted;
  }
}
