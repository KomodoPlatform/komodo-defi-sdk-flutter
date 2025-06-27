import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  print('Testing SIA protocol parsing...');

  // Test SIA coin configuration based on the example provided
  final siaConfig = {
    "coin": "SC",
    "type": "SIA",
    "name": "Siacoin",
    "coinpaprika_id": "sc-siacoin",
    "coingecko_id": "siacoin",
    "livecoinwatch_id": "SC",
    "explorer_url": "https://siascan.com/",
    "explorer_tx_url": "tx/",
    "explorer_address_url": "address/",
    "supported": <String>[],
    "active": false,
    "is_testnet": false,
    "currently_enabled": false,
    "wallet_only": false,
    "fname": "Siacoin",
    "mm2": 1,
    "required_confirmations": 1,
    "protocol": {"type": "SIA"},
    "nodes": [
      {"url": "https://api.siascan.com/wallet/api"}
    ],
    "explorer_block_url": "block/"
  };

  try {
    // Test that SiaProtocol can be created
    print('Creating SiaProtocol...');
    final protocol = SiaProtocol.fromJson(siaConfig);
    assert(protocol.subClass == CoinSubClass.sia,
        'Protocol subClass should be SIA');
    assert(protocol.rpcUrlsMap.isNotEmpty, 'RPC URLs should not be empty');
    assert(protocol.serverUrl == null,
        'Server URL should be null since not in config');
    print('✅ SiaProtocol created successfully!');

    // Test that Asset can be created with SIA protocol
    print('Creating Asset with SIA protocol...');
    final asset = Asset.fromJson(siaConfig);
    assert(asset.id.id == 'SC', 'Asset ID should be SC');
    assert(
        asset.id.subClass == CoinSubClass.sia, 'Asset subClass should be SIA');
    assert(
        asset.protocol is SiaProtocol, 'Asset protocol should be SiaProtocol');
    print('✅ Asset with SIA protocol created successfully!');

    print('✅ All SIA protocol parsing tests passed!');
  } catch (e, stackTrace) {
    print('❌ Test failed: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}
