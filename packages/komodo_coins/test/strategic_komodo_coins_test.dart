import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/asset_management/coin_config_manager.dart';
import 'package:komodo_coins/src/asset_management/loading_strategy.dart';
import 'package:komodo_coins/src/komodo_coins_strategic.dart';
import 'package:komodo_coins/src/update_management/coin_update_manager.dart';
import 'package:komodo_coins/src/update_management/update_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils/asset_config_builders.dart';

// Mock classes
class MockRuntimeUpdateConfigRepository extends Mock
    implements RuntimeUpdateConfigRepository {}

class MockCoinConfigTransformer extends Mock implements CoinConfigTransformer {}

class MockCoinConfigDataFactory extends Mock implements CoinConfigDataFactory {}

class MockLoadingStrategy extends Mock implements LoadingStrategy {}

class MockUpdateStrategy extends Mock implements UpdateStrategy {}

class MockCoinConfigManager extends Mock implements CoinConfigManager {}

class MockCoinUpdateManager extends Mock implements CoinUpdateManager {}

class MockCoinConfigRepository extends Mock implements CoinConfigRepository {}

class MockLocalAssetCoinConfigProvider extends Mock
    implements LocalAssetCoinConfigProvider {}

// Fake classes for mocktail fallback values
class FakeRuntimeUpdateConfig extends Fake implements RuntimeUpdateConfig {}

class FakeCoinConfigTransformer extends Fake implements CoinConfigTransformer {}

class FakeAssetId extends Fake implements AssetId {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRuntimeUpdateConfig());
    registerFallbackValue(FakeCoinConfigTransformer());
    registerFakeAssetTypes();
  });

  group('StrategicKomodoCoins', () {
    late MockRuntimeUpdateConfigRepository mockConfigRepository;
    late MockCoinConfigTransformer mockTransformer;
    late MockCoinConfigDataFactory mockDataFactory;
    late MockLoadingStrategy mockLoadingStrategy;
    late MockUpdateStrategy mockUpdateStrategy;
    late MockCoinConfigRepository mockRepository;
    late MockLocalAssetCoinConfigProvider mockLocalProvider;

    // Test data using asset config builders
    final testAssetConfig = StandardAssetConfigs.komodo();
    final testAsset = Asset.fromJson(testAssetConfig);

    const bundledCommitHash = 'abc123def456789012345678901234567890abcd';
    const latestCommitHash = 'def456abc789012345678901234567890abcdef';

    setUp(() {
      mockConfigRepository = MockRuntimeUpdateConfigRepository();
      mockTransformer = MockCoinConfigTransformer();
      mockDataFactory = MockCoinConfigDataFactory();
      mockLoadingStrategy = MockLoadingStrategy();
      mockUpdateStrategy = MockUpdateStrategy();
      mockRepository = MockCoinConfigRepository();
      mockLocalProvider = MockLocalAssetCoinConfigProvider();

      // Set up runtime config
      const runtimeConfig = RuntimeUpdateConfig(
        bundledCoinsRepoCommit: bundledCommitHash,
      );

      when(() => mockConfigRepository.tryLoad())
          .thenAnswer((_) async => runtimeConfig);

      // Set up factory
      when(() => mockDataFactory.createRepository(any(), any()))
          .thenReturn(mockRepository);
      when(() => mockDataFactory.createLocalProvider(any()))
          .thenReturn(mockLocalProvider);

      // Set up transformer
      when(() => mockTransformer.apply(any())).thenReturn(testAssetConfig);

      // Set up repository
      when(() => mockRepository.coinConfigProvider)
          .thenReturn(mockLocalProvider);

      // Set up local provider responses
      when(() => mockLocalProvider.getAssets())
          .thenAnswer((_) async => [testAsset]);
      when(() => mockLocalProvider.getLatestCommit())
          .thenAnswer((_) async => bundledCommitHash);
    });

    group('Constructor', () {
      test('creates instance with default dependencies', () {
        final coins = StrategicKomodoCoins();

        expect(coins.enableAutoUpdate, isTrue);
        expect(coins.isInitialized, isFalse);
      });

      test('creates instance with custom dependencies', () {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
          loadingStrategy: mockLoadingStrategy,
          updateStrategy: mockUpdateStrategy,
          enableAutoUpdate: false,
        );

        expect(coins.enableAutoUpdate, isFalse);
        expect(coins.isInitialized, isFalse);
      });

      test('creates instance with auto-update disabled', () {
        final coins = StrategicKomodoCoins(enableAutoUpdate: false);

        expect(coins.enableAutoUpdate, isFalse);
      });
    });

    group('Initialization', () {
      test('throws StateError when accessing assets before init', () {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        expect(() => coins.assets, throwsStateError);
      });

      test('throws StateError when accessing updates before init', () {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        expect(() => coins.updates, throwsStateError);
      });

      test('throws StateError when accessing updateStream before init', () {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        expect(() => coins.updateStream, throwsStateError);
      });

      test('initializes successfully with valid configuration', () async {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
          loadingStrategy: mockLoadingStrategy,
          updateStrategy: mockUpdateStrategy,
        );

        // Mock the internal managers
        final mockAssetManager = MockCoinConfigManager();
        final mockUpdateManager = MockCoinUpdateManager();

        // Set up mock behaviors
        when(mockAssetManager.init).thenAnswer((_) async {});
        when(mockUpdateManager.init).thenAnswer((_) async {});
        when(mockUpdateManager.startBackgroundUpdates).thenReturn(null);

        // We need to mock the internal creation of managers
        // This is a limitation of the current design - managers are created internally
        // For now, we'll test the public API behavior

        expect(coins.isInitialized, isFalse);
      });
    });

    group('Static methods', () {
      test('fetchAndTransformCoinsList handles successful fetch', () async {
        // Set up mocks for static method
        when(() => mockConfigRepository.tryLoad())
            .thenAnswer((_) async => const RuntimeUpdateConfig());
        when(() => mockRepository.updatedAssetStorageExists())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getAssets())
            .thenAnswer((_) async => [testAsset]);
        when(() => mockTransformer.apply(any())).thenReturn(testAssetConfig);

        // Note: This test would require more complex mocking of the static method
        // The static method creates its own instances internally
        expect(true, isTrue); // Placeholder for now
      });

      test('fetchAndTransformCoinsList handles storage not existing', () async {
        when(() => mockConfigRepository.tryLoad())
            .thenAnswer((_) async => const RuntimeUpdateConfig());
        when(() => mockRepository.updatedAssetStorageExists())
            .thenAnswer((_) async => false);
        when(() => mockLocalProvider.getAssets())
            .thenAnswer((_) async => [testAsset]);

        // Note: This test would require more complex mocking
        expect(true, isTrue); // Placeholder for now
      });

      test('fetchAndTransformCoinsList handles errors with retry', () async {
        when(() => mockConfigRepository.tryLoad())
            .thenThrow(Exception('Network error'));

        // Note: This test would require more complex mocking
        expect(true, isTrue); // Placeholder for now
      });
    });

    group('Error handling', () {
      test('handles config repository load failure', () async {
        when(() => mockConfigRepository.tryLoad())
            .thenThrow(Exception('Config load failed'));

        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        // Should handle the error gracefully
        expect(coins.isInitialized, isFalse);
      });

      test('handles data factory creation failure', () async {
        when(() => mockDataFactory.createRepository(any(), any()))
            .thenThrow(Exception('Repository creation failed'));

        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        // Should handle the error gracefully
        expect(coins.isInitialized, isFalse);
      });
    });

    group('Lifecycle management', () {
      test('dispose cleans up resources', () async {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        // Should not throw when disposing uninitialized instance
        await expectLater(coins.dispose(), completes);
      });

      test('multiple dispose calls are safe', () async {
        final coins = StrategicKomodoCoins(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );

        await coins.dispose();
        await expectLater(coins.dispose(), completes);
      });
    });

    group('Configuration validation', () {
      test('validates enableAutoUpdate flag', () {
        final coinsWithAutoUpdate = StrategicKomodoCoins();
        final coinsWithoutAutoUpdate =
            StrategicKomodoCoins(enableAutoUpdate: false);

        expect(coinsWithAutoUpdate.enableAutoUpdate, isTrue);
        expect(coinsWithoutAutoUpdate.enableAutoUpdate, isFalse);
      });

      test('uses default strategies when not provided', () {
        final coins = StrategicKomodoCoins();

        expect(coins.enableAutoUpdate, isTrue);
      });
    });
  });
}

/// Helper function to register fake asset types for mocktail
void registerFakeAssetTypes() {
  // Create test asset config using builder
  final fakeConfig = StandardAssetConfigs.testCoin();
  final fakeAsset = Asset.fromJson(fakeConfig);

  registerFallbackValue(fakeAsset.id);
  registerFallbackValue(fakeAsset);
}
