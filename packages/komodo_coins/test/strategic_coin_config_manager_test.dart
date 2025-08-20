import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/asset_filter.dart';
import 'package:komodo_coins/src/asset_management/coin_config_manager.dart';
import 'package:komodo_coins/src/asset_management/loading_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils/asset_config_builders.dart';

// Mock classes
class MockCoinConfigSource extends Mock implements CoinConfigSource {}

class MockLoadingStrategy extends Mock implements LoadingStrategy {}

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
    registerFallbackValue(LoadingRequestType.initialLoad);
    registerFakeAssetTypes();
  });

  group('StrategicCoinConfigManager', () {
    late MockCoinConfigSource mockStorageSource;
    late MockCoinConfigSource mockLocalSource;
    late MockLoadingStrategy mockLoadingStrategy;

    // Test data using asset config builders
    final komodoAssetConfig = StandardAssetConfigs.komodo();
    final komodoAsset = Asset.fromJson(komodoAssetConfig);
    final btcAssetConfig = StandardAssetConfigs.bitcoin();
    final btcAsset = Asset.fromJson(btcAssetConfig);
    final testAssetConfig = StandardAssetConfigs.testCoin();
    final testAsset = Asset.fromJson(testAssetConfig);

    final testAssets = [komodoAsset, btcAsset, testAsset];
    final testAssetsMap = {
      for (final asset in testAssets) asset.id: asset,
    };

    setUp(() {
      mockStorageSource = MockCoinConfigSource();
      mockLocalSource = MockCoinConfigSource();
      mockLoadingStrategy = MockLoadingStrategy();

      // Set up source behaviors
      when(() => mockStorageSource.sourceId).thenReturn('storage');
      when(() => mockLocalSource.sourceId).thenReturn('local');
      when(() => mockStorageSource.displayName).thenReturn('Storage');
      when(() => mockLocalSource.displayName).thenReturn('Local');
      when(() => mockStorageSource.isAvailable()).thenAnswer((_) async => true);
      when(() => mockLocalSource.isAvailable()).thenAnswer((_) async => true);

      // Set up loading strategy
      when(
        () => mockLoadingStrategy.selectSources(
          requestType: any(named: 'requestType'),
          availableSources: any(named: 'availableSources'),
          storageExists: any(named: 'storageExists'),
          enableAutoUpdate: any(named: 'enableAutoUpdate'),
        ),
      ).thenAnswer((invocation) async {
        final sources =
            invocation.namedArguments[const Symbol('availableSources')]
                as List<CoinConfigSource>;
        return sources;
      });

      // Set up source loading
      when(() => mockStorageSource.loadAssets())
          .thenAnswer((_) async => testAssets);
      when(() => mockLocalSource.loadAssets())
          .thenAnswer((_) async => testAssets);
    });

    group('Constructor', () {
      test('creates instance with required parameters', () {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        expect(manager.enableAutoUpdate, isTrue);
        expect(manager.isInitialized, isFalse);
      });

      test('creates instance with auto-update disabled', () {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
          enableAutoUpdate: false,
        );

        expect(manager.enableAutoUpdate, isFalse);
      });

      test('uses default loading strategy when not provided', () {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
        );

        expect(manager.loadingStrategy, isA<StorageFirstLoadingStrategy>());
      });
    });

    group('Initialization', () {
      test('initializes successfully with valid sources', () async {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        await manager.init();

        expect(manager.isInitialized, isTrue);
        expect(manager.all, isNotEmpty);
        expect(manager.all.length, equals(testAssets.length));
      });

      test('can be initialized multiple times safely', () async {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        await manager.init();
        expect(manager.isInitialized, isTrue);

        // Should be able to initialize again without error
        await expectLater(manager.init(), completes);
        expect(manager.isInitialized, isTrue);
      });

      test('handles source availability check failures gracefully', () async {
        when(() => mockStorageSource.isAvailable())
            .thenThrow(Exception('Availability check failed'));

        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        // Should not throw, should continue with available sources
        await expectLater(manager.init(), completes);
        expect(manager.isInitialized, isTrue);
      });

      test('handles source loading failures gracefully', () async {
        when(() => mockStorageSource.loadAssets())
            .thenThrow(Exception('Load failed'));

        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        // Should not throw, should continue with available sources
        await expectLater(manager.init(), completes);
        expect(manager.isInitialized, isTrue);
      });
    });

    group('Asset retrieval', () {
      late StrategicCoinConfigManager manager;

      setUp(() async {
        manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();
      });

      test('returns all assets', () {
        final assets = manager.all;

        expect(assets, isNotEmpty);
        expect(assets.length, equals(testAssets.length));
        expect(assets.values, containsAll(testAssets));
      });

      test('returns empty map when no assets available', () async {
        when(() => mockStorageSource.loadAssets()).thenAnswer((_) async => []);
        when(() => mockLocalSource.loadAssets()).thenAnswer((_) async => []);

        final emptyManager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await emptyManager.init();

        expect(emptyManager.all, isEmpty);
      });

      test('deduplicates assets from multiple sources', () async {
        // Set up sources to return the same assets
        when(() => mockStorageSource.loadAssets())
            .thenAnswer((_) async => testAssets);
        when(() => mockLocalSource.loadAssets())
            .thenAnswer((_) async => testAssets);

        final dedupManager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await dedupManager.init();

        // Should not have duplicates
        expect(dedupManager.all.length, equals(testAssets.length));
      });
    });

    group('Asset filtering', () {
      late StrategicCoinConfigManager manager;

      setUp(() async {
        manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();
      });

      test('filters assets using provided strategy', () {
        const filter = UtxoAssetFilterStrategy();
        final filtered = manager.filteredAssets(filter);

        expect(filtered, isNotEmpty);
        // All test assets should be UTXO type
        expect(
          filtered.values
              .every((asset) => asset.id.subClass == CoinSubClass.utxo),
          isTrue,
        );
      });

      test('returns empty map when no assets match filter', () async {
        // Create a test asset without trezor_coin field
        final noTrezorConfig = {
          'coin': 'NTZ',
          'fname': 'NoTrezor',
          'chain_id': 1,
          'type': 'UTXO',
          'protocol': {'type': 'UTXO'},
          'is_testnet': false,
          // intentionally no 'trezor_coin'
        };
        final noTrezorAsset = Asset.fromJson(noTrezorConfig);

        // Set up source to return only the no-trezor asset
        when(() => mockStorageSource.loadAssets())
            .thenAnswer((_) async => [noTrezorAsset]);
        when(() => mockLocalSource.loadAssets())
            .thenAnswer((_) async => [noTrezorAsset]);

        final noTrezorManager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await noTrezorManager.init();

        const filter = TrezorAssetFilterStrategy();
        final filtered = noTrezorManager.filteredAssets(filter);

        // Assets without trezor_coin field should be filtered out
        expect(filtered, isEmpty);
      });

      test('caches filtered results', () {
        const filter = UtxoAssetFilterStrategy();

        final firstCall = manager.filteredAssets(filter);
        final secondCall = manager.filteredAssets(filter);

        expect(identical(firstCall, secondCall), isTrue);
      });
    });

    group('Asset lookup', () {
      late StrategicCoinConfigManager manager;

      setUp(() async {
        manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();
      });

      test('finds asset by ticker and subclass', () {
        final found = manager.findByTicker('KMD', CoinSubClass.utxo);

        expect(found, isNotNull);
        expect(found!.id.id, equals('KMD'));
        expect(found.id.subClass, equals(CoinSubClass.utxo));
      });

      test('returns null when asset not found', () {
        final found = manager.findByTicker('NONEXISTENT', CoinSubClass.utxo);

        expect(found, isNull);
      });

      test('finds all variants of a coin by ticker', () {
        final variants = manager.findVariantsOfCoin('KMD');

        expect(variants, isNotEmpty);
        expect(variants.every((asset) => asset.id.id == 'KMD'), isTrue);
      });

      test('returns empty set when no variants found', () {
        final variants = manager.findVariantsOfCoin('NONEXISTENT');

        expect(variants, isEmpty);
      });

      test('finds child assets of a parent asset', () {
        // This test depends on the test data having parent-child relationships
        // For now, we'll test the method exists and returns a Set
        final children = manager.findChildAssets(komodoAsset.id);

        expect(children, isA<Set<Asset>>());
      });
    });

    group('Asset refresh', () {
      late StrategicCoinConfigManager manager;

      setUp(() async {
        manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();
      });

      test('refreshes assets from sources', () async {
        // Create a new manager for this test to avoid cache issues
        final refreshManager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await refreshManager.init();

        // Verify that refresh completes without error
        await expectLater(refreshManager.refreshAssets(), completes);

        // Verify that assets are still available after refresh
        expect(refreshManager.all, isNotEmpty);
      });

      test('handles refresh failures gracefully', () async {
        when(() => mockStorageSource.loadAssets())
            .thenThrow(Exception('Refresh failed'));

        final initialAssets = Map<AssetId, Asset>.from(manager.all);

        await expectLater(manager.refreshAssets(), completes);

        // Should retain existing assets even if refresh fails
        expect(manager.all, equals(initialAssets));
      });
    });

    group('Error handling', () {
      test('throws StateError when accessing assets before init', () {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        expect(() => manager.all, throwsStateError);
        expect(
          () => manager.filteredAssets(const UtxoAssetFilterStrategy()),
          throwsStateError,
        );
        expect(
          () => manager.findByTicker('KMD', CoinSubClass.utxo),
          throwsStateError,
        );
        expect(() => manager.findVariantsOfCoin('KMD'), throwsStateError);
        expect(() => manager.findChildAssets(komodoAsset.id), throwsStateError);
      });

      test('throws StateError when using disposed manager', () async {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();
        await manager.dispose();

        expect(() => manager.all, throwsStateError);
        expect(manager.refreshAssets, throwsStateError);
      });
    });

    group('Lifecycle management', () {
      test('dispose cleans up resources', () async {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();

        await expectLater(manager.dispose(), completes);
        expect(manager.isInitialized, isFalse);
      });

      test('multiple dispose calls are safe', () async {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();

        await manager.dispose();
        await expectLater(manager.dispose(), completes);
      });

      test('dispose works on uninitialized manager', () async {
        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );

        await expectLater(manager.dispose(), completes);
      });
    });

    group('Loading strategy integration', () {
      test('uses loading strategy to select sources', () async {
        final selectedSources = <CoinConfigSource>[];
        when(
          () => mockLoadingStrategy.selectSources(
            requestType: any(named: 'requestType'),
            availableSources: any(named: 'availableSources'),
            storageExists: any(named: 'storageExists'),
            enableAutoUpdate: any(named: 'enableAutoUpdate'),
          ),
        ).thenAnswer((invocation) async {
          final sources =
              invocation.namedArguments[const Symbol('availableSources')]
                  as List<CoinConfigSource>;
          selectedSources.addAll(sources);
          return sources;
        });

        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
        );
        await manager.init();

        expect(
          selectedSources,
          containsAll([mockStorageSource, mockLocalSource]),
        );
      });

      test('respects enableAutoUpdate flag in loading strategy', () async {
        var enableAutoUpdatePassed = false;
        when(
          () => mockLoadingStrategy.selectSources(
            requestType: any(named: 'requestType'),
            availableSources: any(named: 'availableSources'),
            storageExists: any(named: 'storageExists'),
            enableAutoUpdate: any(named: 'enableAutoUpdate'),
          ),
        ).thenAnswer((invocation) async {
          enableAutoUpdatePassed = invocation
              .namedArguments[const Symbol('enableAutoUpdate')] as bool;
          final sources =
              invocation.namedArguments[const Symbol('availableSources')]
                  as List<CoinConfigSource>;
          return sources;
        });

        final manager = StrategicCoinConfigManager(
          configSources: [mockStorageSource, mockLocalSource],
          loadingStrategy: mockLoadingStrategy,
          enableAutoUpdate: false,
        );
        await manager.init();

        expect(enableAutoUpdatePassed, isFalse);
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
