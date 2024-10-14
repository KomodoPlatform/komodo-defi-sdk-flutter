import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class PubkeyManager {
  //

  PubkeyManager(this._client);

  final ApiClient _client;
  // final KomodoDefiLocalAuth _auth;

  Future<List<String>> _activePubkeys(AssetId assetId) async {
    final pubkeys = await _client.rpc.generalActivation.getEnabledCoins().then(
          (r) => r.result
              .where((e) => e.ticker == assetId.id)
              .map((e) => e.address)
              .toList(),
        );

    return pubkeys;
  }

  Future<Pubkey> getPubkey(Asset asset) async {
    final pubkeys = await _activePubkeys(asset.id);

    // If there are no pubkeys, activate the asset
    if (pubkeys.isEmpty) {
      final result = await asset.preActivate().firstWhere((e) => e.isComplete);

      if (!result.isSuccess) {
        // TODO: Exception type
        throw Exception(result.errorMessage);
      }

      pubkeys.addAll(await _activePubkeys(asset.id));
    }

    return Pubkey(
      assetId: asset.id,
      pubkey: pubkeys.first,

      // TODO! HD multi-addresses. We can't assume the addresses appear in
      // the order of their indexes.
      keys: pubkeys.map((e) => (pubkeys.indexOf(e), e)).toList(),
    );
  }
}
