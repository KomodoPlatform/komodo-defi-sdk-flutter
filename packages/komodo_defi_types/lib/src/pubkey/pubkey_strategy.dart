import 'package:komodo_defi_types/types.dart';

// TODO: Refactor strategy consumption so that API client does not need to be
// passed in. See the activation strategy for an example of how this can
// be done.
abstract class PubkeyStrategy {
  Future<AssetPubkeys> getPubkeys(AssetId assetId, ApiClient client);
  Future<String> getNewAddress(AssetId assetId, ApiClient client);
  Future<void> scanForNewAddresses(AssetId assetId, ApiClient client);
  // bool protocolSupported(ProtocolClass protocol, ApiClient client);

  // TODO: Add interfaces for getting number of addresses used and
  // available addresses.
  bool get supportsMultipleAddresses;
}
