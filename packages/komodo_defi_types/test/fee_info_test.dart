import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  group('FeeInfo EthGas serialization', () {
    test('should serialize EthGas with correct type', () {
      final feeInfo = FeeInfo.ethGas(
        coin: 'ETH',
        gasPrice: Decimal.parse('0.000000003'),
        gas: 21000,
      );

      final json = feeInfo.toJson();
      
      expect(json['type'], equals('EthGas'));
      expect(json['coin'], equals('ETH'));
      expect(json['gas_price'], equals('0.000000003'));
      expect(json['gas'], equals(21000));
    });

    test('should deserialize EthGas from JSON', () {
      final json = {
        'type': 'EthGas',
        'coin': 'ETH',
        'gas_price': '0.000000003',
        'gas': 21000,
      };

      final feeInfo = FeeInfo.fromJson(json);
      
      expect(feeInfo, isA<FeeInfoEthGas>());
      final ethGas = feeInfo as FeeInfoEthGas;
      expect(ethGas.coin, equals('ETH'));
      expect(ethGas.gasPrice, equals(Decimal.parse('0.000000003')));
      expect(ethGas.gas, equals(21000));
    });

    test('should handle backward compatibility with Eth type', () {
      final json = {
        'type': 'Eth', // Old format
        'coin': 'ETH',
        'gas_price': '0.000000003',
        'gas': 21000,
      };

      final feeInfo = FeeInfo.fromJson(json);
      
      expect(feeInfo, isA<FeeInfoEthGas>());
      final ethGas = feeInfo as FeeInfoEthGas;
      expect(ethGas.coin, equals('ETH'));
      expect(ethGas.gasPrice, equals(Decimal.parse('0.000000003')));
      expect(ethGas.gas, equals(21000));
    });
  });
} 