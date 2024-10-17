import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SingleAddressStrategy implements PubkeyStrategy {
  SingleAddressStrategy();

  @override
  bool get supportsMultipleAddresses => false;

  // @override
  // bool protocolSupported(ProtocolClass protocol) => true;

  @override
  Future<AssetPubkeys> getPubkeys(AssetId assetId, ApiClient client) async {
    final address = (await client.rpc.generalActivation.getEnabledCoins())
        .result
        .firstWhere(
          (coin) => coin.ticker == assetId.id,
          orElse: () => throw Exception('Coin not found'),
        );

    final balance =
        // TODO! Remove balance methods from address strategy
        // await _client.rpc.generalActivation.getBalance(ticker: assetId.id);
        Decimal.zero;

    return AssetPubkeys(
      assetId: assetId,
      addresses: [
        PubkeyInfo(
          // TODO! Switch to same method as multi address strategy or replace
          // this strategy with the multi address strategy with necessary
          // minor changes
          address: 'address.address',
          chain: 'External',
          spendableBalance: balance, //balance.result.spendable,
          unspendableBalance: balance, // balance.result.unspendable,
        )
      ],
      usedAddressesCount: 1,
      availableAddressesCount: 0,
      syncStatus: SyncStatus.success,
    );
  }

  @override
  Future<String> getNewAddress(AssetId _, ApiClient __) async {
    throw UnsupportedError(
        'Single address coins do not support generating new addresses');
  }

  @override
  Future<void> scanForNewAddresses(AssetId _, ApiClient __) async {
    // No-op for single address coins
  }
}
