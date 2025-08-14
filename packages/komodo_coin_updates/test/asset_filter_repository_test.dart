import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'helpers/asset_test_helpers.dart';

void main() {
  group('Repository-driven asset filtering', () {
    late CoinConfigRepository repo;
    setUp(() async {
      Hive
        ..init(
          './.dart_tool/test_hive_${DateTime.now().microsecondsSinceEpoch}',
        )
        ..registerAdapters();
      repo = CoinConfigRepository.withDefaults(
        RuntimeUpdateConfig.withDefaults(),
      );
      await repo.upsertRawAssets({'KMD': AssetTestHelpers.utxoJson()}, 'test');
    });

    test('UTXO-only filter using repository assets', () async {
      final all = await repo.getAssets();
      expect(all, isNotNull);
      final utxoOnly =
          all!
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
