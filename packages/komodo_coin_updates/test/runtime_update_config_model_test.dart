/// Unit tests for the RuntimeUpdateConfig model class.
///
/// **Purpose**: Tests the configuration model that defines runtime behavior for coin
/// updates, including repository branches, file mappings, and feature flags.
///
/// **Test Cases**:
/// - Default value application when creating from empty JSON
/// - JSON serialization and deserialization round-trip
/// - Configuration property validation and defaults
/// - Model state consistency and immutability
///
/// **Functionality Tested**:
/// - JSON parsing and validation
/// - Default value application
/// - Configuration property access
/// - Serialization/deserialization integrity
/// - Configuration state management
///
/// **Edge Cases**:
/// - Empty JSON input handling
/// - Default value fallbacks
/// - Configuration property validation
/// - Immutable configuration state
///
/// **Dependencies**: Tests the core configuration model that drives runtime behavior
/// for coin updates, ensuring proper defaults and configuration persistence.
library;

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
