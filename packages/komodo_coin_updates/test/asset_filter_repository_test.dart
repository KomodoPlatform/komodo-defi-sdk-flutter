import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'helpers/asset_test_helpers.dart';

void main() {
  group('Repository-driven asset filtering', () {
    late CoinConfigRepository repo;
    late String hivePath;
    setUp(() async {
      hivePath =
          './.dart_tool/test_hive_${DateTime.now().microsecondsSinceEpoch}';
      Hive
        ..init(hivePath)
        ..registerAdapters();
      repo = CoinConfigRepository.withDefaults(const RuntimeUpdateConfig());
      await repo.upsertRawAssets({'KMD': AssetTestHelpers.utxoJson()}, 'test');
    });

    tearDown(() async {
      try {
        await Hive.close();
      } catch (_) {}
      try {
        final dir = Directory(hivePath);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('UTXO-only filter using repository assets', () async {
      final all = await repo.getAssets();
      final utxoOnly =
          all
              .where(
                (a) =>
                    a.protocol.subClass == CoinSubClass.utxo ||
                    a.protocol.subClass == CoinSubClass.smartChain,
              )
              .toList();
      expect(utxoOnly.any((a) => a.id.id == 'KMD'), isTrue);
      // Ensure no non-UTXO subclasses slipped through
      expect(
        utxoOnly.any(
          (a) =>
              a.protocol.subClass != CoinSubClass.utxo &&
              a.protocol.subClass != CoinSubClass.smartChain,
        ),
        isFalse,
      );
    });
  });
}
