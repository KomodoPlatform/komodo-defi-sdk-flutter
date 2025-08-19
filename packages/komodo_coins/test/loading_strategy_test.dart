import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/asset_management/loading_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils/asset_config_builders.dart';

// Mock classes
class MockCoinConfigRepository extends Mock implements CoinConfigRepository {}

class MockLocalAssetCoinConfigProvider extends Mock
    implements LocalAssetCoinConfigProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(LoadingRequestType.initialLoad);
    registerFakeAssetTypes();
  });

  group('LoadingStrategy', () {
    late MockCoinConfigRepository mockRepository;
    late MockLocalAssetCoinConfigProvider mockLocalProvider;

    // Test data
    final testAssetConfig = StandardAssetConfigs.komodo();
    final testAsset = Asset.fromJson(testAssetConfig);

    setUp(() {
      mockRepository = MockCoinConfigRepository();
      mockLocalProvider = MockLocalAssetCoinConfigProvider();
    });

    group('StorageFirstLoadingStrategy', () {
      late StorageFirstLoadingStrategy strategy;

      setUp(() {
        strategy = StorageFirstLoadingStrategy();
      });

      test('returns storage first when storage exists and auto-update disabled',
          () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.initialLoad,
          availableSources: availableSources,
          storageExists: true,
          enableAutoUpdate: false,
        );

        expect(result.length, 2);
        expect(result[0], isA<StorageCoinConfigSource>());
        expect(result[1], isA<AssetBundleCoinConfigSource>());
      });

      test('returns storage first when storage exists and auto-update enabled',
          () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.initialLoad,
          availableSources: availableSources,
          storageExists: true,
          enableAutoUpdate: true,
        );

        expect(result.length, 2);
        expect(result[0], isA<StorageCoinConfigSource>());
        expect(result[1], isA<AssetBundleCoinConfigSource>());
      });

      test('returns local assets first when storage does not exist', () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.initialLoad,
          availableSources: availableSources,
          storageExists: false,
          enableAutoUpdate: true,
        );

        // When storage doesn't exist, only asset bundle should be returned
        expect(result.length, 1);
        expect(result[0], isA<AssetBundleCoinConfigSource>());
      });

      test('handles refresh load request', () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.refreshLoad,
          availableSources: availableSources,
          storageExists: true,
          enableAutoUpdate: true,
        );

        expect(result.length, 2);
        expect(result[0], isA<StorageCoinConfigSource>());
      });

      test('handles fallback load request', () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.fallbackLoad,
          availableSources: availableSources,
          storageExists: true,
          enableAutoUpdate: true,
        );

        expect(result.length, 2);
        expect(result[0], isA<AssetBundleCoinConfigSource>());
        expect(result[1], isA<StorageCoinConfigSource>());
      });
    });

    group('AssetBundleFirstLoadingStrategy', () {
      late AssetBundleFirstLoadingStrategy strategy;

      setUp(() {
        strategy = AssetBundleFirstLoadingStrategy();
      });

      test('always returns local assets first', () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.initialLoad,
          availableSources: availableSources,
          storageExists: true,
          enableAutoUpdate: true,
        );

        expect(result.length, 2);
        expect(result[0], isA<AssetBundleCoinConfigSource>());
        expect(result[1], isA<StorageCoinConfigSource>());
      });

      test('works when storage does not exist', () async {
        final storageSource =
            StorageCoinConfigSource(repository: mockRepository);
        final localSource =
            AssetBundleCoinConfigSource(provider: mockLocalProvider);
        final availableSources = [storageSource, localSource];

        final result = await strategy.selectSources(
          requestType: LoadingRequestType.initialLoad,
          availableSources: availableSources,
          storageExists: false,
          enableAutoUpdate: false,
        );

        expect(result.length, 2);
        expect(result[0], isA<AssetBundleCoinConfigSource>());
        expect(result[1], isA<StorageCoinConfigSource>());
      });
    });
  });

  group('CoinConfigSource', () {
    late MockCoinConfigRepository mockRepository;
    late MockLocalAssetCoinConfigProvider mockLocalProvider;

    // Test data
    final testAssetConfig = StandardAssetConfigs.komodo();
    final testAsset = Asset.fromJson(testAssetConfig);

    setUp(() {
      mockRepository = MockCoinConfigRepository();
      mockLocalProvider = MockLocalAssetCoinConfigProvider();
    });

    group('StorageCoinConfigSource', () {
      late StorageCoinConfigSource source;

      setUp(() {
        source = StorageCoinConfigSource(repository: mockRepository);
      });

      test('has correct source properties', () {
        expect(source.sourceId, 'storage');
        expect(source.displayName, 'Local Storage');
      });

      test('supports all loading request types', () {
        expect(source.supports(LoadingRequestType.initialLoad), isTrue);
        expect(source.supports(LoadingRequestType.refreshLoad), isTrue);
        expect(source.supports(LoadingRequestType.fallbackLoad), isTrue);
      });

      test('loads assets from repository', () async {
        when(() => mockRepository.getAssets())
            .thenAnswer((_) async => [testAsset]);

        final result = await source.loadAssets();

        expect(result.length, 1);
        expect(result[0], equals(testAsset));
        verify(() => mockRepository.getAssets()).called(1);
      });

      test('checks availability from repository', () async {
        when(() => mockRepository.updatedAssetStorageExists())
            .thenAnswer((_) async => true);

        final result = await source.isAvailable();

        expect(result, isTrue);
        verify(() => mockRepository.updatedAssetStorageExists()).called(1);
      });

      test('handles repository errors gracefully', () async {
        when(() => mockRepository.getAssets())
            .thenThrow(Exception('Storage error'));

        expect(() => source.loadAssets(), throwsException);
      });

      test('returns false when storage is not available', () async {
        when(() => mockRepository.updatedAssetStorageExists())
            .thenAnswer((_) async => false);

        final result = await source.isAvailable();

        expect(result, isFalse);
      });
    });

    group('AssetBundleCoinConfigSource', () {
      late AssetBundleCoinConfigSource source;

      setUp(() {
        source = AssetBundleCoinConfigSource(provider: mockLocalProvider);
      });

      test('has correct source properties', () {
        expect(source.sourceId, 'asset_bundle');
        expect(source.displayName, 'Asset Bundle');
      });

      test('supports all loading request types', () {
        expect(source.supports(LoadingRequestType.initialLoad), isTrue);
        expect(source.supports(LoadingRequestType.refreshLoad), isTrue);
        expect(source.supports(LoadingRequestType.fallbackLoad), isTrue);
      });

      test('loads assets from local provider', () async {
        when(() => mockLocalProvider.getAssets())
            .thenAnswer((_) async => [testAsset]);

        final result = await source.loadAssets();

        expect(result.length, 1);
        expect(result[0], equals(testAsset));
        verify(() => mockLocalProvider.getAssets()).called(1);
      });

      test('is always available', () async {
        // Mock the provider to return assets successfully
        when(() => mockLocalProvider.getAssets())
            .thenAnswer((_) async => [testAsset]);

        final result = await source.isAvailable();

        expect(result, isTrue);
        verify(() => mockLocalProvider.getAssets()).called(1);
      });

      test('handles provider errors gracefully', () async {
        when(() => mockLocalProvider.getAssets())
            .thenThrow(Exception('Asset bundle error'));

        expect(() => source.loadAssets(), throwsException);
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
