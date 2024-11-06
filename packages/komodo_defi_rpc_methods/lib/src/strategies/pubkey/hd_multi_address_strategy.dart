import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/types.dart';

class HDWalletStrategy extends PubkeyStrategy {
  HDWalletStrategy();

  int get _gapLimit => 20;

  @override
  bool get supportsMultipleAddresses => true;

  @override
  bool protocolSupported(ProtocolClass protocol) {
    //TODO! (ETH?) return protocol is UtxoProtocol || protocol is SlpProtocol;
    // return protocol is UtxoProtocol || protocol is SlpProtocol;
    return true;
  }

  @override
  Future<AssetPubkeys> getPubkeys(AssetId assetId, ApiClient client) async {
    final balanceInfo = await _getAccountBalance(assetId, client);
    return _convertBalanceInfoToAssetPubkeys(assetId, balanceInfo);
  }

  @override
  Future<PubkeyInfo> getNewAddress(AssetId assetId, ApiClient client) async {
    final newAddress = (await client.rpc.hdWallet.getNewAddress(
      assetId.id,
      accountId: 0,
      chain: 'External',
      gapLimit: _gapLimit,
    ))
        .newAddress;

    return PubkeyInfo(
      address: newAddress.address,
      derivationPath: newAddress.derivationPath,
      chain: newAddress.chain,
      balance: newAddress.balance,
    );
  }

  @override
  Future<void> scanForNewAddresses(AssetId assetId, ApiClient client) async {
    await _getAccountBalance(assetId, client);
  }

  Future<AccountBalanceInfo> _getAccountBalance(
    AssetId assetId,
    ApiClient client,
  ) async {
    final initResponse = await client.rpc.hdWallet.accountBalanceInit(
      coin: assetId.id,
      accountIndex: 0,
    );

    AccountBalanceInfo? result;
    while (result == null) {
      final status = await client.rpc.hdWallet.accountBalanceStatus(
        taskId: initResponse.taskId,
        forgetIfFinished: false,
      );
      result = (status.details..throwIfError).data;

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return result;
  }

  Future<AssetPubkeys> _convertBalanceInfoToAssetPubkeys(
    AssetId assetId,
    AccountBalanceInfo balanceInfo,
  ) async {
    final addresses = balanceInfo.addresses
        .map(
          (addr) => PubkeyInfo(
            address: addr.address,
            derivationPath: addr.derivationPath,
            chain: addr.chain,
            balance: addr.balance.balanceOf(assetId.id),
          ),
        )
        .toList();

    return AssetPubkeys(
      assetId: assetId,
      keys: addresses,
      availableAddressesCount:
          await availableNewAddressesCount(addresses).then((value) => value),
      syncStatus: SyncStatus.success,
    );
  }

  Future<int> availableNewAddressesCount(
    List<PubkeyInfo> addresses,
  ) {
    final gapFromLastUsed = addresses.lastIndexWhere(
          (addr) => addr.balance.hasBalance,
        ) +
        1;

    return Future.value((_gapLimit - gapFromLastUsed).clamp(0, _gapLimit));
  }
}
