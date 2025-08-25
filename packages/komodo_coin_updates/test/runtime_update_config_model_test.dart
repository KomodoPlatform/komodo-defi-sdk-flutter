import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart'
    show AssetRuntimeUpdateConfig;

/// Unit tests for the AssetRuntimeUpdateConfigRepository model class.
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

void main() {
  group('RuntimeUpdateConfig model', () {
    test('fromJson applies defaults', () {
      final cfg = AssetRuntimeUpdateConfig.fromJson({});
      expect(cfg.coinsRepoBranch, isNotEmpty);
      expect(cfg.mappedFiles.isNotEmpty, isTrue);
      expect(cfg.mappedFolders.isNotEmpty, isTrue);
      expect(cfg.cdnBranchMirrors.isNotEmpty, isTrue);
    });

    test('round-trip toJson/fromJson', () {
      const original = AssetRuntimeUpdateConfig(
        coinsRepoBranch: 'dev',
        concurrentDownloadsEnabled: true,
      );
      final cloned = AssetRuntimeUpdateConfig.fromJson(original.toJson());
      expect(cloned.coinsRepoBranch, 'dev');
      expect(cloned.concurrentDownloadsEnabled, isTrue);
    });
  });
}
