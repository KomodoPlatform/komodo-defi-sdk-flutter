import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SingleAddressStrategy extends HDWalletStrategy {
  SingleAddressStrategy();

  @override
  bool get supportsMultipleAddresses => false;

  @override
  Future<int> availableNewAddressesCount(
    List<PubkeyInfo> addresses,
  ) {
    return Future.value(addresses.isEmpty ? 1 : 0);
  }

  @override
  Future<PubkeyInfo> getNewAddress(AssetId _, ApiClient __) async {
    throw UnsupportedError(
      'Single address coins do not support generating new addresses',
    );
  }

  @override
  Future<void> scanForNewAddresses(AssetId _, ApiClient __) async {
    // No-op for single address coins
  }
}
