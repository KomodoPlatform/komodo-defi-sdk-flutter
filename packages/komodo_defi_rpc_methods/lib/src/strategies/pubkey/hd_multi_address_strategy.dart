import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/types.dart';

class HDWalletStrategy extends PubkeyStrategy {
  HDWalletStrategy();

  @override
  bool get supportsMultipleAddresses => true;

  static bool protocolSupported(ProtocolClass protocol) {
    return protocol is UtxoProtocol;
  }

  @override
  Future<AssetPubkeys> getPubkeys(AssetId assetId, ApiClient client) async {
    final balanceInfo = await _getAccountBalance(assetId, client);
    return _convertBalanceInfoToAssetPubkeys(assetId, balanceInfo);
  }

  @override
  Future<String> getNewAddress(AssetId assetId, ApiClient client) async {
    final response = await client.rpc.hdWallet.getNewAddress(
      assetId.id,
      accountId: 0,
      chain: 'External',
    );
    return response.newAddress.address;
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

      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return result;
  }

  AssetPubkeys _convertBalanceInfoToAssetPubkeys(
    AssetId assetId,
    AccountBalanceInfo balanceInfo,
  ) {
    final addresses = balanceInfo.addresses
        .map(
          (addr) => PubkeyInfo(
            address: addr.address,
            derivationPath: addr.derivationPath,
            chain: addr.chain,
            spendableBalance: addr.balance.spendable,
            unspendableBalance: addr.balance.unspendable,
          ),
        )
        .toList();

    return AssetPubkeys(
      assetId: assetId,
      addresses: addresses,
      usedAddressesCount: addresses
          .where(
            (addr) =>
                addr.spendableBalance > Decimal.zero ||
                addr.unspendableBalance > Decimal.zero,
          )
          .length,
      availableAddressesCount: addresses.length -
          addresses
              .where(
                (addr) =>
                    addr.spendableBalance > Decimal.zero ||
                    addr.unspendableBalance > Decimal.zero,
              )
              .length,
      syncStatus: SyncStatus.success,
    );
  }
}
