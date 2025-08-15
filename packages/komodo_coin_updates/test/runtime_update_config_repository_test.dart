import 'package:flutter/services.dart' show AssetBundle, ByteData;
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config_repository.dart';

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

void main() {
  group('RuntimeUpdateConfigRepository', () {
    test('tryLoad returns null on missing asset', () async {
      final repo = RuntimeUpdateConfigRepository(bundle: _FakeBundle({}));
      final cfg = await repo.tryLoad();
      expect(cfg, isNull);
    });

    test('tryLoad returns null on malformed JSON', () async {
      final repo = RuntimeUpdateConfigRepository(
        bundle: _FakeBundle({
          'packages/komodo_defi_framework/app_build/build_config.json':
              'not json',
        }),
      );
      final cfg = await repo.tryLoad();
      expect(cfg, isNull);
    });

    test('tryLoad returns null when coins node missing or not a map', () async {
      final repoMissing = RuntimeUpdateConfigRepository(
        bundle: _FakeBundle({
          'packages/komodo_defi_framework/app_build/build_config.json': '{}',
        }),
      );
      expect(await repoMissing.tryLoad(), isNull);

      final repoNotMap = RuntimeUpdateConfigRepository(
        bundle: _FakeBundle({
          'packages/komodo_defi_framework/app_build/build_config.json':
              '{"coins": []}',
        }),
      );
      expect(await repoNotMap.tryLoad(), isNull);
    });

    test('load throws on invalid shapes', () async {
      final repo = RuntimeUpdateConfigRepository(
        bundle: _FakeBundle({
          'packages/komodo_defi_framework/app_build/build_config.json': '{}',
        }),
      );
      await expectLater(repo.load(), throwsA(isA<FormatException>()));
    });

    test('load returns config on success', () async {
      // Construct a valid JSON manually to avoid map toString issues
      const valid =
          '{"coins": {"fetch_at_build_enabled": true, "update_commit_on_build": true, "bundled_coins_repo_commit": "master", "coins_repo_api_url": "https://api.github.com/repos/KomodoPlatform/coins", "coins_repo_content_url": "https://raw.githubusercontent.com/KomodoPlatform/coins", "coins_repo_branch": "master", "runtime_updates_enabled": true, "mapped_files": {"assets/config/coins_config.json": "utils/coins_config_unfiltered.json", "assets/config/coins.json": "coins", "assets/config/seed_nodes.json": "seed-nodes.json"}, "mapped_folders": {"assets/coin_icons/png/": "icons"}, "concurrent_downloads_enabled": false, "cdn_branch_mirrors": {"master": "https://komodoplatform.github.io/coins", "main": "https://komodoplatform.github.io/coins"}}}';

      final repo = RuntimeUpdateConfigRepository(
        bundle: _FakeBundle({
          'packages/komodo_defi_framework/app_build/build_config.json': valid,
        }),
      );
      final cfg = await repo.load();
      expect(cfg.coinsRepoBranch, isNotEmpty);
    });
  });
}
