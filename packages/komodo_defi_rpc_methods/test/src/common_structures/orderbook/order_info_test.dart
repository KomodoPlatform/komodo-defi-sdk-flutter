import 'dart:convert';
import 'dart:io';

import 'package:komodo_defi_rpc_methods/src/common_structures/orderbook/order_address.dart';
import 'package:komodo_defi_rpc_methods/src/common_structures/orderbook/order_info.dart';
import 'package:komodo_defi_rpc_methods/src/common_structures/primitive/fraction.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';

Map<String, dynamic> loadFixture(String relativePath) {
  final contents = File('test/fixtures/$relativePath').readAsStringSync();
  return jsonDecode(contents) as Map<String, dynamic>;
}

void main() {
  late Map<String, dynamic> askJson;

  setUpAll(() {
    final fixture = loadFixture('orderbook/orderbook_response.json');
    final result = fixture['result'] as Map<String, dynamic>;
    askJson = Map<String, dynamic>.from(
      (result['asks'] as List<dynamic>).first as Map,
    );
  });

  group('OrderInfo.fromJson', () {
    test('parses ask payload from fixture verbatim', () {
      final info = OrderInfo.fromJson(askJson);

      expect(info.uuid, '1115d7f2-a7b9-4ab1-913f-497db2549a2b');
      expect(info.coin, 'DGB');
      expect(
        info.pubkey,
        '03de96cb66dcfaceaa8b3d4993ce8914cd5fe84e3fd53cefdae45add8032792a12',
      );
      expect(info.isMine, isFalse);

      expect(info.price!.decimal, '0.0002658065');
      expect(info.price!.fraction, isA<Fraction>());
      expect(info.price!.fraction?.numer, '531613');
      expect(info.price!.fraction?.denom, '2000000000');
      expect(
        info.price!.rational,
        Rational(BigInt.from(531613), BigInt.from(2000000000)),
      );

      expect(info.baseMaxVolume!.decimal, '90524.256020352');
      expect(info.baseMaxVolume!.fraction?.numer, '707220750159');
      expect(info.baseMaxVolume!.fraction?.denom, '7812500');
      expect(info.baseMaxVolumeAggregated!.decimal, '133319.023345413');

      expect(
        info.baseMinVolume!.decimal,
        '0.3762135237475381527539770472129161626973004798603495399849138376977237200745655204067620618758382508',
      );

      expect(info.relMaxVolume!.decimal, '24.061935657873693888');
      expect(info.relMaxVolumeAggregated!.decimal, '35.2500366381728643576');
      expect(info.relMinVolume!.decimal, '0.0001');

      expect(info.address!.addressType, OrderAddressType.transparent);
      expect(info.address!.addressData, 'DEsCggcN3WNmaTkF2WpqoMQqx4JGQrLbPS');

      expect(info.confSettings!.baseConfs, 7);
      expect(info.confSettings!.baseNota, isFalse);
      expect(info.confSettings!.relConfs, 2);
      expect(info.confSettings!.relNota, isFalse);
    });
  });

  group('OrderInfo serialization', () {
    test('toJson emits fixture-compliant structure', () {
      final info = OrderInfo.fromJson(askJson);
      final json = info.toJson();

      expect(json, equals(askJson));
    });

    test('supports round-trip serialization', () {
      final info = OrderInfo.fromJson(askJson);
      final serialized = info.toJson();
      final reparsed = OrderInfo.fromJson(
        Map<String, dynamic>.from(serialized),
      );

      expect(reparsed.toJson(), equals(serialized));
      expect(reparsed.toJson(), equals(askJson));
    });
  });
}
