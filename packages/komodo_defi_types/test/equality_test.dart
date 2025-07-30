import 'package:komodo_defi_rpc_methods/src/common_structures/general/balance_info.dart';
import 'package:komodo_defi_rpc_methods/src/common_structures/general/new_address_info.dart';
import 'package:komodo_defi_types/src/public_key/asset_pubkeys.dart';
import 'package:test/test.dart';

void main() {
  group('Equality operators test', () {
    test('NewAddressInfo equality', () {
      final balance = BalanceInfo.zero();

      final addressInfo1 = NewAddressInfo(
        address: 'test_address',
        derivationPath: "m/44'/0'/0'/0/0",
        chain: 'test_chain',
        balances: {'TEST': balance},
      );

      final addressInfo2 = NewAddressInfo(
        address: 'test_address',
        derivationPath: "m/44'/0'/0'/0/0",
        chain: 'test_chain',
        balances: {'TEST': balance},
      );

      final addressInfo3 = NewAddressInfo(
        address: 'different_address',
        derivationPath: "m/44'/0'/0'/0/0",
        chain: 'test_chain',
        balances: {'TEST': balance},
      );

      expect(addressInfo1, equals(addressInfo2));
      expect(addressInfo1, isNot(equals(addressInfo3)));
      expect(addressInfo1.hashCode, equals(addressInfo2.hashCode));
    });

    test('PubkeyInfo equality', () {
      final balance = BalanceInfo.zero();

      final pubkeyInfo1 = PubkeyInfo(
        address: 'test_address',
        derivationPath: "m/44'/0'/0'/0/0",
        chain: 'test_chain',
        balance: balance,
        coinTicker: 'TEST',
        name: 'Test Name',
      );

      final pubkeyInfo2 = PubkeyInfo(
        address: 'test_address',
        derivationPath: "m/44'/0'/0'/0/0",
        chain: 'test_chain',
        balance: balance,
        coinTicker: 'TEST',
        name: 'Test Name',
      );

      final pubkeyInfo3 = PubkeyInfo(
        address: 'test_address',
        derivationPath: "m/44'/0'/0'/0/0",
        chain: 'test_chain',
        balance: balance,
        coinTicker: 'TEST',
        name: 'Different Name',
      );

      expect(pubkeyInfo1, equals(pubkeyInfo2));
      expect(pubkeyInfo1, isNot(equals(pubkeyInfo3)));
      expect(pubkeyInfo1.hashCode, equals(pubkeyInfo2.hashCode));
    });
  });
}
