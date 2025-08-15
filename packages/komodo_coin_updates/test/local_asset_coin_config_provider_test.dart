import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, ByteData;
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/src/coins_config/config_transform.dart';
import 'package:komodo_coin_updates/src/coins_config/local_asset_coin_config_provider.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class _FakeBundle extends AssetBundle {
  _FakeBundle(this.map);
  final Map<String, String> map;
  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      map[key] ?? (throw StateError('Asset not found: $key'));
  @override
  void evict(String key) {}
}

class _ForceWalletOnlyTransform implements CoinConfigTransform {
  const _ForceWalletOnlyTransform();
  @override
  JsonMap transform(JsonMap config) {
    final out = JsonMap.of(config);
    out['wallet_only'] = true;
    return out;
  }

  @override
  bool needsTransform(JsonMap config) => true;
}

void main() {
  group('LocalAssetCoinConfigProvider', () {
    test('throws when asset is missing', () async {
      final provider = LocalAssetCoinConfigProvider.fromConfig(
        const RuntimeUpdateConfig(),
        bundle: _FakeBundle({}),
      );
      expect(provider.getAssets(), throwsA(isA<StateError>()));
    });

    test('applies transform and filters excluded coins', () async {
      const jsonMap = {
        'KMD': {
          'coin': 'KMD',
          'decimals': 8,
          'type': 'UTXO',
          'protocol': {'type': 'UTXO'},
          'fname': 'Komodo',
          'chain_id': 0,
          'is_testnet': false,
        },
        'SLP': {
          'coin': 'SLP',
          'decimals': 8,
          'type': 'SLP',
          'protocol': {'type': 'SLP'},
          'fname': 'SLP Token',
          'chain_id': 0,
          'is_testnet': false,
        },
      };
      final bundle = _FakeBundle({
        'packages/komodo_defi_framework/assets/config/coins_config.json':
            jsonEncode(jsonMap),
      });

      final provider = LocalAssetCoinConfigProvider.fromConfig(
        const RuntimeUpdateConfig(),
        transformer: const CoinConfigTransformer(
          transforms: [_ForceWalletOnlyTransform()],
        ),
        bundle: bundle,
      );

      final assets = await provider.getAssets();
      expect(assets.any((a) => a.id.id == 'KMD'), isTrue);
      expect(assets.any((a) => a.id.id == 'SLP'), isFalse);
      final kmd = assets.firstWhere((a) => a.id.id == 'KMD');
      expect(kmd.isWalletOnly, isTrue);
    });
  });
}
