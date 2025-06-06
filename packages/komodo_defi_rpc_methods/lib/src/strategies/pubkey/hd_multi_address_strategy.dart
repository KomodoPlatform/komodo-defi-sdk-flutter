import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Mixin containing shared HD wallet logic
mixin HDWalletMixin on PubkeyStrategy {
  KdfUser get kdfUser;
  
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
    final balanceInfo = await getAccountBalance(assetId, client);
    return convertBalanceInfoToAssetPubkeys(assetId, balanceInfo);
  }

  @override
  Future<void> scanForNewAddresses(AssetId assetId, ApiClient client) async {
    await getAccountBalance(assetId, client);
  }

  Future<AccountBalanceInfo> getAccountBalance(
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

  Future<AssetPubkeys> convertBalanceInfoToAssetPubkeys(
    AssetId assetId,
    AccountBalanceInfo balanceInfo,
  ) async {
    final addresses =
        balanceInfo.addresses
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
      availableAddressesCount: await availableNewAddressesCount(
        addresses,
      ).then((value) => value),
      syncStatus: SyncStatusEnum.success,
    );
  }

  Future<int> availableNewAddressesCount(List<PubkeyInfo> addresses) {
    final gapFromLastUsed =
        addresses.lastIndexWhere((addr) => addr.balance.hasValue) + 1;

    return Future.value((_gapLimit - gapFromLastUsed).clamp(0, _gapLimit));
  }
}

/// HD wallet strategy for context private key wallets
class ContextPrivKeyHDWalletStrategy extends PubkeyStrategy with HDWalletMixin {
  ContextPrivKeyHDWalletStrategy({required this.kdfUser});

  @override
  final KdfUser kdfUser;

  @override
  Future<PubkeyInfo> getNewAddress(AssetId assetId, ApiClient client) async {
    final newAddress =
        (await client.rpc.hdWallet.getNewAddress(
          assetId.id,
          accountId: 0,
          chain: 'External',
          gapLimit: _gapLimit,
        )).newAddress;

    return PubkeyInfo(
      address: newAddress.address,
      derivationPath: newAddress.derivationPath,
      chain: newAddress.chain,
      balance: newAddress.balance,
    );
  }
}

/// HD wallet strategy for Trezor wallets
class TrezorHDWalletStrategy extends PubkeyStrategy with HDWalletMixin {
  TrezorHDWalletStrategy({required this.kdfUser});

  @override
  final KdfUser kdfUser;

  @override
  Future<PubkeyInfo> getNewAddress(AssetId assetId, ApiClient client) async {
    final newAddress = await _getNewAddressTask(assetId, client);

    return PubkeyInfo(
      address: newAddress.address,
      derivationPath: newAddress.derivationPath,
      chain: newAddress.chain,
      balance: newAddress.balance,
    );
  }

  Future<NewAddressInfo> _getNewAddressTask(
    AssetId assetId,
    ApiClient client,
  ) async {
    final initResponse = await client.rpc.hdWallet.getNewAddressTaskInit(
      coin: assetId.id,
      accountId: 0,
      chain: 'External',
      gapLimit: _gapLimit,
    );

    NewAddressInfo? result;
    while (result == null) {
      final status = await client.rpc.hdWallet.getNewAddressTaskStatus(
        taskId: initResponse.taskId,
        forgetIfFinished: false,
      );
      result = (status.details..throwIfError).data;

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return result;
  }
}