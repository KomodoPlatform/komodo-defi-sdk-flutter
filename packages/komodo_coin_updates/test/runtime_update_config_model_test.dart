import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';

void main() {
  group('RuntimeUpdateConfig model', () {
    test('fromJson applies defaults', () {
      final cfg = RuntimeUpdateConfig.fromJson({});
      expect(cfg.coinsRepoBranch, isNotEmpty);
      expect(cfg.mappedFiles.isNotEmpty, isTrue);
      expect(cfg.mappedFolders.isNotEmpty, isTrue);
      expect(cfg.cdnBranchMirrors.isNotEmpty, isTrue);
    });

    test('round-trip toJson/fromJson', () {
      const original = RuntimeUpdateConfig(
        coinsRepoBranch: 'dev',
        concurrentDownloadsEnabled: true,
      );
      final cloned = RuntimeUpdateConfig.fromJson(original.toJson());
      expect(cloned.coinsRepoBranch, 'dev');
      expect(cloned.concurrentDownloadsEnabled, isTrue);
    });
  });
}
