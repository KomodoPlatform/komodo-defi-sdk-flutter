import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/rpc/rpc_task_buddy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class PubkeyManager {
  //

  PubkeyManager(this._client);

  final ApiClient _client;
  // final KomodoDefiLocalAuth _auth;

  // TODO:Refactor to make array of AssetId
  Future<List<String>> _activeAssets() async {
    final assets = await _client.rpc.generalActivation.getEnabledCoins();

    return assets.result.map((e) => e.ticker).toList();
  }

  Future<List<String>> _activePubkeys(AssetId assetId) async {
    final balances = await _client.rpc.hdWallet
        .accountBalanceInit(coin: assetId.id, accountIndex: 0)
        .watch(
          getTaskStatus: (id) =>
              _client.rpc.hdWallet.accountBalanceStatus(taskId: id),
          isTaskComplete: (status) => status.status.isComplete,
          pollingInterval: const Duration(milliseconds: 500),
        )
        .last
        .then((status) => status.details.data!);

    return balances.addresses.map((e) => e.address).toList();
  }

  Future<void> _ensureAssetActive(Asset asset) async {
    final isAssetActive = (await _activeAssets()).contains(asset.id.id);

    if (!isAssetActive) {
      // TODO! Exception handling
      // final result = await asset.preActivate().firstWhere((e) => e.isComplete);
      final result = await asset.preActivate().last;

      if (!result.isSuccess) {
        // TODO: Exception type
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<AssetPubkeys> getPubkeys(Asset asset) async {
    await _ensureAssetActive(asset);

    return asset.pubkeyStrategy.getPubkeys(asset.id, _client);
  }

  Future<PubkeyInfo> createNewPubkey(Asset asset) async {
    await _ensureAssetActive(asset);

    final newAddress =
        await asset.pubkeyStrategy.getNewAddress(asset.id, _client);

    return newAddress;
  }
}
