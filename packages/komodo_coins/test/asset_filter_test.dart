import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  group('Asset filtering', () {
    final btcConfig = {
      'coin': 'BTC',
      'fname': 'Bitcoin',
      'chain_id': 0,
      'type': 'UTXO',
      'protocol': {'type': 'UTXO'},
      'is_testnet': false,
      'trezor_coin': 'Bitcoin',
    };

    final ethConfig = {
      'coin': 'ETH',
      'fname': 'Ethereum',
      'chain_id': 1,
      'type': 'ERC-20',
      'protocol': {
        'type': 'ETH',
        'protocol_data': {'chain_id': 1},
      },
      'nodes': [
        {'url': 'https://rpc'},
      ],
      'swap_contract_address': '0xabc',
      'fallback_swap_contract': '0xdef',
    };

    final btc = Asset.fromJson(btcConfig);
    final eth = Asset.fromJson(ethConfig);

    test('Trezor filter excludes assets missing trezor_coin', () {
      const filter = TrezorAssetFilterStrategy();
      expect(filter.shouldInclude(btc, btc.protocol.config), isTrue);
      expect(filter.shouldInclude(eth, eth.protocol.config), isFalse);

      final assets = {btc.id: btc, eth.id: eth};
      final filtered = <AssetId, Asset>{};
      for (final entry in assets.entries) {
        if (filter.shouldInclude(entry.value, entry.value.protocol.config)) {
          filtered[entry.key] = entry.value;
        }
      }

      expect(filtered.containsKey(btc.id), isTrue);
      expect(filtered.containsKey(eth.id), isFalse);
    });

    test('Trezor filter ignores empty trezor_coin field', () {
      final cfg = Map<String, dynamic>.from(btcConfig)..['trezor_coin'] = '';
      final asset = Asset.fromJson(cfg);
      const filter = TrezorAssetFilterStrategy();
      expect(filter.shouldInclude(asset, asset.protocol.config), isFalse);
    });

    test('UTXO filter only includes utxo assets', () {
      const filter = UtxoAssetFilterStrategy();
      expect(filter.shouldInclude(btc, btc.protocol.config), isTrue);
      expect(filter.shouldInclude(eth, eth.protocol.config), isFalse);
    });

    test('UTXO filter accepts smartChain subclass', () {
      final cfg = Map<String, dynamic>.from(btcConfig)
        ..['type'] = 'SMART_CHAIN'
        ..['protocol'] = {'type': 'UTXO'};
      final asset = Asset.fromJson(cfg);
      const filter = UtxoAssetFilterStrategy();
      expect(asset.protocol.subClass, CoinSubClass.smartChain);
      expect(filter.shouldInclude(asset, asset.protocol.config), isTrue);
    });
  });
}
