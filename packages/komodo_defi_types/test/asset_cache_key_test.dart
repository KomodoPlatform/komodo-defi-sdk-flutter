import 'dart:math';

import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

void main() {
  group('AssetCacheKey', () {
    // Build a minimal AssetId for tests
    final asset = AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'btc'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );

    test('equality and hashCode are consistent for identical keys', () {
      final k1 = AssetCacheKey(
        assetConfigId: asset.id,
        chainId: asset.chainId.formattedChainId,
        subClass: asset.subClass.formatted,
        protocolKey: asset.parentId?.id ?? 'base',
        customFields: const {
          'quote': 'USDT',
          'kind': 'price',
          'ts': 1620000000000,
        },
      );
      final k2 = AssetCacheKey(
        assetConfigId: asset.id,
        chainId: asset.chainId.formattedChainId,
        subClass: asset.subClass.formatted,
        protocolKey: asset.parentId?.id ?? 'base',
        customFields: const {
          'quote': 'USDT',
          'kind': 'price',
          'ts': 1620000000000,
        },
      );

      expect(k1, equals(k2));
      expect(k1.hashCode, equals(k2.hashCode));
    });

    test('different optional fields produce distinct keys', () {
      final base = AssetCacheKey(
        assetConfigId: asset.id,
        chainId: asset.chainId.formattedChainId,
        subClass: asset.subClass.formatted,
        protocolKey: asset.parentId?.id ?? 'base',
      );
      final withQuote = base.copyWith(customFields: const {'quote': 'USDT'});
      final withKind = base.copyWith(customFields: const {'kind': 'price'});
      final withDate = base.copyWith(customFields: const {'ts': 123});

      expect(base, isNot(equals(withQuote)));
      expect(base, isNot(equals(withKind)));
      expect(base, isNot(equals(withDate)));
    });

    test('customFields participate in equality and hashing', () {
      final base = AssetCacheKey(
        assetConfigId: asset.id,
        chainId: asset.chainId.formattedChainId,
        subClass: asset.subClass.formatted,
        protocolKey: asset.parentId?.id ?? 'base',
      );
      final k1 = base.copyWith(
        customFields: const {'window': 24, 'smoothing': 'ema'},
      );
      final k2 = base.copyWith(
        customFields: const {
          'smoothing': 'ema',
          'window': 24,
        }, // different order
      );
      final k3 = base.copyWith(customFields: const {'window': 24});

      expect(k1, equals(k2));
      expect(k1.hashCode, equals(k2.hashCode));
      expect(k1, isNot(equals(k3)));
    });

    test('works as Map key without conflicts', () {
      final k1 = AssetCacheKey(
        assetConfigId: asset.id,
        chainId: asset.chainId.formattedChainId,
        subClass: asset.subClass.formatted,
        protocolKey: asset.parentId?.id ?? 'base',
        customFields: const {'quote': 'USDT', 'kind': 'price', 'ts': 42},
      );
      final map = <AssetCacheKey, String>{};
      map[k1] = 'value';

      // Create a logically equal key
      final k2 = AssetCacheKey(
        assetConfigId: asset.id,
        chainId: asset.chainId.formattedChainId,
        subClass: asset.subClass.formatted,
        protocolKey: asset.parentId?.id ?? 'base',
        customFields: const {'quote': 'USDT', 'kind': 'price', 'ts': 42},
      );

      expect(map[k2], equals('value'));
    });
  });

  // Fuzzy tests
  group('AssetCacheKey fuzzy', () {
    String stringKeyFrom(AssetCacheKey k) {
      final custom = (k.customFields.keys.toList()..sort())
          .map((key) => '$key=${k.customFields[key]}')
          .join('|');
      return '${k.assetConfigId}_${k.chainId}_${k.subClass}_${k.protocolKey}_{$custom}';
    }

    AssetCacheKey randomKey(Random rng) {
      String rndStr(int len) {
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        return String.fromCharCodes(
          List.generate(
            len,
            (_) => chars.codeUnitAt(rng.nextInt(chars.length)),
          ),
        );
      }

      final cf = <String, Object?>{};
      // Randomly include 0-3 custom fields
      final cfCount = rng.nextInt(4);
      for (var i = 0; i < cfCount; i++) {
        final key = 'k${rng.nextInt(5)}';
        final choice = rng.nextInt(3);
        switch (choice) {
          case 0:
            cf[key] = rndStr(3);
          case 1:
            cf[key] = rng.nextInt(1000);
          default:
            cf[key] = rng.nextBool();
        }
      }

      return AssetCacheKey(
        assetConfigId: rndStr(3),
        chainId: '${rng.nextInt(3)}',
        subClass: ['UTXO', 'ERC20', 'COSMOS'][rng.nextInt(3)],
        protocolKey: rng.nextBool() ? rndStr(2) : 'base',
        customFields: cf,
      );
    }

    test('random equal pairs; single-field mutations not equal', () {
      final rng = Random(1337);
      const iterations = 2000;

      for (var i = 0; i < iterations; i++) {
        final a = randomKey(rng);
        final b = a.copyWith(customFields: Map.of(a.customFields));

        // Equal pairs
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));

        // Mutate one dimension randomly and ensure inequality
        final which = rng.nextInt(5);
        AssetCacheKey c;
        switch (which) {
          case 0:
            c = a.copyWith(assetConfigId: '${a.assetConfigId}x');
          case 1:
            c = a.copyWith(chainId: '${a.chainId}x');
          case 2:
            c = a.copyWith(subClass: a.subClass == 'UTXO' ? 'ERC20' : 'UTXO');
          case 3:
            c = a.copyWith(protocolKey: a.protocolKey == 'base' ? 'p' : 'base');
          default:
            final mutated = Map<String, Object?>.of(a.customFields);
            mutated['mut'] = rng.nextInt(999);
            c = a.copyWith(customFields: mutated);
        }
        expect(a, isNot(equals(c)));
      }
    });

    test('set cardinality matches between AssetCacheKey and String keys', () {
      final rng = Random(4242);
      const n = 3000;
      final keys = List.generate(n, (_) => randomKey(rng));

      final setA = keys.toSet();
      final setS = keys.map(stringKeyFrom).toSet();

      expect(setA.length, equals(setS.length));
    });
  });

  // Micro-benchmarks
  group('AssetCacheKey benchmark', () {
    // Run only when explicitly enabled to avoid flakiness in CI
    const runBench = bool.fromEnvironment('RUN_BENCH');

    void benchInsertLookupDelete(int n, void Function(String) log) {
      final rng = Random(2025);
      final keys = List.generate(n, (_) {
        final k = AssetCacheKey(
          assetConfigId: 'a${rng.nextInt(1 << 20)}',
          chainId: 'c${rng.nextInt(256)}',
          subClass: ['UTXO', 'ERC20', 'COSMOS'][rng.nextInt(3)],
          protocolKey: rng.nextBool() ? 'base' : 'p${rng.nextInt(100)}',
          customFields: {
            'q': 'USDT',
            if (rng.nextBool()) 'ts': rng.nextInt(1 << 31),
          },
        );
        return k;
      });
      String sKey(AssetCacheKey k) {
        final custom = (k.customFields.keys.toList()..sort())
            .map((key) => '$key=${k.customFields[key]}')
            .join('|');
        return '${k.assetConfigId}_${k.chainId}_${k.subClass}_${k.protocolKey}_{$custom}';
      }

      final stringKeys = keys.map(sKey).toList(growable: false);

      // Warmup
      {
        final m = <AssetCacheKey, int>{};
        for (var i = 0; i < n; i++) {
          m[keys[i]] = i;
        }
        for (var i = 0; i < n; i++) {
          expect(m[keys[i]], equals(i));
        }
        for (var i = 0; i < n; i++) {
          m.remove(keys[i]);
        }
      }
      {
        final m = <String, int>{};
        for (var i = 0; i < n; i++) {
          m[stringKeys[i]] = i;
        }
        for (var i = 0; i < n; i++) {
          expect(m[stringKeys[i]], equals(i));
        }
        for (var i = 0; i < n; i++) {
          m.remove(stringKeys[i]);
        }
      }

      // Timed - AssetCacheKey
      final insertA = Stopwatch()..start();
      final mapA = <AssetCacheKey, int>{};
      for (var i = 0; i < n; i++) {
        mapA[keys[i]] = i;
      }
      insertA.stop();

      final lookupA = Stopwatch()..start();
      var sumA = 0;
      for (var i = 0; i < n; i++) {
        sumA += mapA[keys[i]]!;
      }
      lookupA.stop();

      final deleteA = Stopwatch()..start();
      for (var i = 0; i < n; i++) {
        mapA.remove(keys[i]);
      }
      deleteA.stop();

      // Timed - String
      final insertS = Stopwatch()..start();
      final mapS = <String, int>{};
      for (var i = 0; i < n; i++) {
        mapS[stringKeys[i]] = i;
      }
      insertS.stop();

      final lookupS = Stopwatch()..start();
      var sumS = 0;
      for (var i = 0; i < n; i++) {
        sumS += mapS[stringKeys[i]]!;
      }
      lookupS.stop();

      final deleteS = Stopwatch()..start();
      for (var i = 0; i < n; i++) {
        mapS.remove(stringKeys[i]);
      }
      deleteS.stop();

      // Prevent DCE of sums
      expect(sumA, equals(sumS));

      log(
        'AssetCacheKey insert: ${insertA.elapsedMilliseconds}ms, '
        'lookup: ${lookupA.elapsedMilliseconds}ms, '
        'delete: ${deleteA.elapsedMilliseconds}ms',
      );
      log(
        'String        insert: ${insertS.elapsedMilliseconds}ms, '
        'lookup: ${lookupS.elapsedMilliseconds}ms, '
        'delete: ${deleteS.elapsedMilliseconds}ms',
      );
    }

    test('micro-benchmark insert/lookup/delete (prints timings)', () {
      if (!runBench) {
        // Skip in normal runs; enable with: --dart-define=RUN_BENCH=true
        return;
      }
      benchInsertLookupDelete(5000, print);
    }, skip: !runBench);

    test(
      'canonical base-prefix string key benchmark (prints timings)',
      () {
        if (!runBench) {
          return;
        }
        void bench(int n) {
          final rng = Random(3030);
          final assets = List.generate(n, (_) {
            final a = AssetId(
              id: 'A${rng.nextInt(1 << 20)}',
              name: 'N',
              symbol: AssetSymbol(assetConfigId: 'a'),
              chainId: AssetChainId(chainId: rng.nextInt(256)),
              derivationPath: null,
              subClass:
                  [
                    CoinSubClass.utxo,
                    CoinSubClass.erc20,
                    CoinSubClass.tendermint,
                  ][rng.nextInt(3)],
            );
            return a;
          });
          final basePrefixes = assets.map((a) => a.baseCacheKeyPrefix).toList();
          final customList = List.generate(
            n,
            (_) => <String, Object?>{
              'quote': 'USDT',
              if (rng.nextBool()) 'ts': rng.nextInt(1 << 31),
              'kind': 'price',
            },
          );

          // Build canonical keys once
          final canonicalKeys = List.generate(
            n,
            (i) =>
                canonicalCacheKeyFromBasePrefix(basePrefixes[i], customList[i]),
            growable: false,
          );

          // Compare against object keys
          final objectKeys = List.generate(
            n,
            (i) => AssetCacheKey(
              assetConfigId: assets[i].id,
              chainId: assets[i].chainId.formattedChainId,
              subClass: assets[i].subClass.formatted,
              protocolKey: assets[i].parentId?.id ?? 'base',
              customFields: customList[i],
            ),
            growable: false,
          );

          // Timed - Map<String, int>
          final insertStr = Stopwatch()..start();
          final mapStr = <String, int>{};
          for (var i = 0; i < n; i++) {
            mapStr[canonicalKeys[i]] = i;
          }
          insertStr.stop();

          final lookupStr = Stopwatch()..start();
          var sumStr = 0;
          for (var i = 0; i < n; i++) {
            sumStr += mapStr[canonicalKeys[i]]!;
          }
          lookupStr.stop();

          final deleteStr = Stopwatch()..start();
          for (var i = 0; i < n; i++) {
            mapStr.remove(canonicalKeys[i]);
          }
          deleteStr.stop();

          // Timed - Map<AssetCacheKey, int>
          final insertObj = Stopwatch()..start();
          final mapObj = <AssetCacheKey, int>{};
          for (var i = 0; i < n; i++) {
            mapObj[objectKeys[i]] = i;
          }
          insertObj.stop();

          final lookupObj = Stopwatch()..start();
          var sumObj = 0;
          for (var i = 0; i < n; i++) {
            sumObj += mapObj[objectKeys[i]]!;
          }
          lookupObj.stop();

          final deleteObj = Stopwatch()..start();
          for (var i = 0; i < n; i++) {
            mapObj.remove(objectKeys[i]);
          }
          deleteObj.stop();

          // Prevent DCE
          expect(sumStr, equals(sumObj));

          print(
            'Canonical<String> insert: ${insertStr.elapsedMilliseconds}ms, '
            'lookup: ${lookupStr.elapsedMilliseconds}ms, '
            'delete: ${deleteStr.elapsedMilliseconds}ms',
          );
          print(
            'Object<AssetCacheKey> insert: ${insertObj.elapsedMilliseconds}ms, '
            'lookup: ${lookupObj.elapsedMilliseconds}ms, '
            'delete: ${deleteObj.elapsedMilliseconds}ms',
          );
        }

        bench(6000);
      },
      skip: !runBench,
    );

    test('scaling with number of custom fields (prints timings)', () {
      if (!runBench) {
        return;
      }

      Map<String, Object?> buildCustomFields(int count, int seed) {
        final map = <String, Object?>{};
        for (var i = 0; i < count; i++) {
          map['f$i'] = (seed + i) % 997;
        }
        return map;
      }

      void benchCount(int customCount, int n) {
        final rng = Random(2026 + customCount);
        final keys = List.generate(n, (_) {
          return AssetCacheKey(
            assetConfigId: 'a${rng.nextInt(1 << 20)}',
            chainId: 'c${rng.nextInt(256)}',
            subClass: ['UTXO', 'ERC20', 'COSMOS'][rng.nextInt(3)],
            protocolKey: rng.nextBool() ? 'base' : 'p${rng.nextInt(100)}',
            customFields: buildCustomFields(customCount, rng.nextInt(1 << 20)),
          );
        });

        String sKey(AssetCacheKey k) {
          final custom = (k.customFields.keys.toList()..sort())
              .map((key) => '$key=${k.customFields[key]}')
              .join('|');
          return '${k.assetConfigId}_${k.chainId}_${k.subClass}_${k.protocolKey}_{$custom}';
        }

        final stringKeys = keys.map(sKey).toList(growable: false);

        // Warmup
        {
          final m = <AssetCacheKey, int>{};
          for (var i = 0; i < n; i++) {
            m[keys[i]] = i;
          }
          for (var i = 0; i < n; i++) {
            expect(m[keys[i]], equals(i));
          }
          for (var i = 0; i < n; i++) {
            m.remove(keys[i]);
          }
        }
        {
          final m = <String, int>{};
          for (var i = 0; i < n; i++) {
            m[stringKeys[i]] = i;
          }
          for (var i = 0; i < n; i++) {
            expect(m[stringKeys[i]], equals(i));
          }
          for (var i = 0; i < n; i++) {
            m.remove(stringKeys[i]);
          }
        }

        // Timed - AssetCacheKey
        final insertA = Stopwatch()..start();
        final mapA = <AssetCacheKey, int>{};
        for (var i = 0; i < n; i++) {
          mapA[keys[i]] = i;
        }
        insertA.stop();

        final lookupA = Stopwatch()..start();
        var sumA = 0;
        for (var i = 0; i < n; i++) {
          sumA += mapA[keys[i]]!;
        }
        lookupA.stop();

        final deleteA = Stopwatch()..start();
        for (var i = 0; i < n; i++) {
          mapA.remove(keys[i]);
        }
        deleteA.stop();

        // Timed - String
        final insertS = Stopwatch()..start();
        final mapS = <String, int>{};
        for (var i = 0; i < n; i++) {
          mapS[stringKeys[i]] = i;
        }
        insertS.stop();

        final lookupS = Stopwatch()..start();
        var sumS = 0;
        for (var i = 0; i < n; i++) {
          sumS += mapS[stringKeys[i]]!;
        }
        lookupS.stop();

        final deleteS = Stopwatch()..start();
        for (var i = 0; i < n; i++) {
          mapS.remove(stringKeys[i]);
        }
        deleteS.stop();

        expect(sumA, equals(sumS));

        print(
          'customFields=$customCount  AssetCacheKey insert: ${insertA.elapsedMilliseconds}ms, lookup: ${lookupA.elapsedMilliseconds}ms, delete: ${deleteA.elapsedMilliseconds}ms',
        );
        print(
          'customFields=$customCount  String        insert: ${insertS.elapsedMilliseconds}ms, lookup: ${lookupS.elapsedMilliseconds}ms, delete: ${deleteS.elapsedMilliseconds}ms',
        );
      }

      // Try a range of custom field counts; keep n moderate
      const counts = [0, 1, 2, 4, 8, 16, 32];
      for (final c in counts) {
        // Use fewer keys for larger custom field counts to keep runtime sensible
        final n =
            c <= 4
                ? 4000
                : c <= 16
                ? 2500
                : 1500;
        benchCount(c, n);
      }
    }, skip: !runBench);
  });
}
