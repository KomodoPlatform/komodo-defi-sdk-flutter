import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

void main() {
  group('CoinSubClass Protocol Parsing', () {
    test('CoinSubClass.parse correctly distinguishes UTXO from Smart Chain', () {
      // Test that "UTXO" parses to CoinSubClass.utxo
      final utxoResult = CoinSubClass.parse('UTXO');
      expect(utxoResult, equals(CoinSubClass.utxo));
      
      // Test that "Smart Chain" parses to CoinSubClass.smartChain
      final smartChainResult = CoinSubClass.parse('Smart Chain');
      expect(smartChainResult, equals(CoinSubClass.smartChain));
      
      // Test that "SMART_CHAIN" also parses to CoinSubClass.smartChain
      final smartChainUnderscoreResult = CoinSubClass.parse('SMART_CHAIN');
      expect(smartChainUnderscoreResult, equals(CoinSubClass.smartChain));
    });

    test('UTXO and Smart Chain have different tickers', () {
      expect(CoinSubClass.utxo.ticker, equals('UTXO'));
      expect(CoinSubClass.smartChain.ticker, equals('SMART_CHAIN'));
      expect(CoinSubClass.utxo.ticker, isNot(equals(CoinSubClass.smartChain.ticker)));
    });

    test('UTXO type should preserve utxo subclass', () {
      final json = {
        'type': 'UTXO',
        'coin': 'LTC',
        'name': 'Litecoin',
        'protocol': 'UTXO',
        'pubtype': 48,
        'p2shtype': 50,
        'wiftype': 176,
        'txfee': 100000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum-ltc.bytepower.com:9333', 'ws_url': 'electrum-ltc.bytepower.com:9334'},
        ],
      };

      final protocol = ProtocolClass.fromJson(json);
      expect(protocol.subClass, equals(CoinSubClass.utxo));
    });

    test('Smart Chain type should preserve smartChain subclass', () {
      final json = {
        'type': 'Smart Chain',
        'coin': 'KMD',
        'name': 'Komodo',
        'protocol': 'UTXO',
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'txfee': 10000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum1.cipig.net:10001', 'ws_url': 'electrum1.cipig.net:30001'},
        ],
      };

      final protocol = ProtocolClass.fromJson(json);
      expect(protocol.subClass, equals(CoinSubClass.smartChain));
    });

    test('Both UTXO and Smart Chain use UtxoProtocol but preserve different subclasses', () {
      final utxoJson = {
        'type': 'UTXO',
        'coin': 'LTC',
        'name': 'Litecoin',
        'protocol': 'UTXO',
        'pubtype': 48,
        'p2shtype': 50,
        'wiftype': 176,
        'txfee': 100000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum-ltc.bytepower.com:9333', 'ws_url': 'electrum-ltc.bytepower.com:9334'},
        ],
      };

      final smartChainJson = {
        'type': 'Smart Chain',
        'coin': 'KMD',
        'name': 'Komodo',
        'protocol': 'UTXO',
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'txfee': 10000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum1.cipig.net:10001', 'ws_url': 'electrum1.cipig.net:30001'},
        ],
      };

      final utxoProtocol = ProtocolClass.fromJson(utxoJson);
      final smartChainProtocol = ProtocolClass.fromJson(smartChainJson);

      // Both should use UtxoProtocol but have different subclasses
      expect(utxoProtocol, isA<UtxoProtocol>());
      expect(smartChainProtocol, isA<UtxoProtocol>());
      expect(utxoProtocol.subClass, equals(CoinSubClass.utxo));
      expect(smartChainProtocol.subClass, equals(CoinSubClass.smartChain));
    });

    test('Asset with UTXO protocol preserves utxo subclass in AssetId', () {
      final json = {
        'type': 'UTXO',
        'coin': 'DOGE',
        'name': 'Dogecoin',
        'protocol': 'UTXO',
        'pubtype': 30,
        'p2shtype': 22,
        'wiftype': 158,
        'txfee': 100000000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum1.cipig.net:10060', 'ws_url': 'electrum1.cipig.net:30060'},
        ],
      };

      final asset = Asset.fromJson(json);
      expect(asset.id.subClass, equals(CoinSubClass.utxo));
      expect(asset.protocol, isA<UtxoProtocol>());
      expect(asset.protocol.subClass, equals(CoinSubClass.utxo));
    });

    test('Asset with Smart Chain protocol preserves smartChain subclass in AssetId', () {
      final json = {
        'type': 'Smart Chain',
        'coin': 'KMD',
        'name': 'Komodo',
        'protocol': 'UTXO',
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'txfee': 10000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum1.cipig.net:10001', 'ws_url': 'electrum1.cipig.net:30001'},
        ],
      };

      final asset = Asset.fromJson(json);
      expect(asset.id.subClass, equals(CoinSubClass.smartChain));
      expect(asset.protocol, isA<UtxoProtocol>());
      expect(asset.protocol.subClass, equals(CoinSubClass.smartChain));
    });

    test('Real world examples: LTC, DOGE, ZCASH should be UTXO subclass', () {
      final ltcJson = {
        'type': 'UTXO',
        'coin': 'LTC',
        'name': 'Litecoin',
        'protocol': 'UTXO',
        'pubtype': 48,
        'p2shtype': 50,
        'wiftype': 176,
        'txfee': 100000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum-ltc.bytepower.com:9333'},
        ],
      };

      final dogeJson = {
        'type': 'UTXO',
        'coin': 'DOGE',
        'name': 'Dogecoin',
        'protocol': 'UTXO',
        'pubtype': 30,
        'p2shtype': 22,
        'wiftype': 158,
        'txfee': 100000000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum1.cipig.net:10060'},
        ],
      };

      final zcashJson = {
        'type': 'UTXO',
        'coin': 'ZEC',
        'name': 'Zcash',
        'protocol': 'UTXO',
        'pubtype': 7352,
        'p2shtype': 7357,
        'wiftype': 128,
        'txfee': 10000,
        'mm2': 1,
        'required_confirmations': 2,
        'electrum': [
          {'url': 'electrum1.cipig.net:10065'},
        ],
      };

      final ltcAsset = Asset.fromJson(ltcJson);
      final dogeAsset = Asset.fromJson(dogeJson);
      final zcashAsset = Asset.fromJson(zcashJson);

      expect(ltcAsset.id.subClass, equals(CoinSubClass.utxo));
      expect(dogeAsset.id.subClass, equals(CoinSubClass.utxo));
      expect(zcashAsset.id.subClass, equals(CoinSubClass.utxo));

      // Verify they show as 'UTXO' not 'Komodo Smart Chain'
      expect(ltcAsset.id.subClass.formatted, equals('UTXO'));
      expect(dogeAsset.id.subClass.formatted, equals('UTXO'));
      expect(zcashAsset.id.subClass.formatted, equals('UTXO'));
    });
  });
}