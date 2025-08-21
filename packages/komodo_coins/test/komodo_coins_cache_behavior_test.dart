/*
Unit Test Plan: KomodoCoins cache and startup behavior

Objectives:
- Verify that after initialization, the in-memory asset list (assets.all) remains stable even after a background update completes.
- Verify that assets.getCurrentCommitHash returns the cached commit (from initial load) even after background updates complete.
- Verify that calling KomodoCoins.fetchRawCoinsListForKdfStartup() before creating another KomodoCoins instance:
  1) loads asset bundle for both (assuming no storage exists),
  2) performs background updates only for the KomodoCoins instance (not the static fetch),
  3) after background update completes, the instance’s `all` accessor and `getCurrentCommitHash()` return cached (initial) values rather than updated values.

Approach:
- Use mocktail to stub repositories and providers.
- Simulate `storageExists = false` so initial load uses asset bundle.
- Configure the repository/provider to allow background update to execute and alter repository state, but ensure asset manager cache remains unchanged.
- Verify repository.updateCoinConfig() is invoked only for the instance (when auto-update enabled) and not for the static startup fetch (auto-update disabled).
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/komodo_coins.dart'
    show KomodoAssetsUpdateManager, StartupCoinsProvider;
import 'package:komodo_coins/src/asset_filter.dart'
    show NoAssetFilterStrategy, UtxoAssetFilterStrategy;
import 'package:komodo_coins/src/asset_management/_asset_management_index.dart'
    show AssetBundleFirstLoadingStrategy;
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockRuntimeUpdateConfigRepository extends Mock
    implements AssetRuntimeUpdateConfigRepository {}

class MockCoinConfigRepository extends Mock implements CoinConfigRepository {}

class MockCoinConfigTransformer extends Mock implements CoinConfigTransformer {}

class MockCoinConfigDataFactory extends Mock implements CoinConfigDataFactory {}

class MockLocalAssetCoinConfigProvider extends Mock
    implements LocalAssetCoinConfigProvider {}

class MockLocalAssetFallbackProvider extends Mock
    implements LocalAssetCoinConfigProvider {}

class MockGithubCoinConfigProvider extends Mock
    implements GithubCoinConfigProvider {}

// Fakes for mocktail
class FakeRuntimeUpdateConfig extends Fake
    implements AssetRuntimeUpdateConfig {}

class FakeCoinConfigTransformer extends Fake implements CoinConfigTransformer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(FakeRuntimeUpdateConfig());
    registerFallbackValue(FakeCoinConfigTransformer());
  });

  group('KomodoCoins cache behavior', () {
    late MockRuntimeUpdateConfigRepository mockConfigRepository;
    late MockCoinConfigTransformer mockTransformer;
    late MockCoinConfigDataFactory mockDataFactory;
    late MockCoinConfigRepository mockRepo;
    late MockLocalAssetCoinConfigProvider mockLocalProvider;
    late MockLocalAssetFallbackProvider mockFallbackProvider;
    late MockGithubCoinConfigProvider mockRemoteProvider;

    // Minimal coin config and asset
    const bundledCommit = 'bundled-commit-00000000000000000000000000000000';
    const latestCommit = 'latest-commit-11111111111111111111111111111111';

    // Minimal-valid UTXO asset JSON for komodo_defi_types
    final kmdConfig = <String, dynamic>{
      'coin': 'KMD',
      'fname': 'Komodo',
      'type': 'UTXO',
      'chain_id': 777,
      'is_testnet': false,
    };

    late Asset kmdAsset;
    late Asset ltcAsset;

    setUp(() {
      kmdAsset = Asset.fromJson(kmdConfig);
      ltcAsset = Asset.fromJson(const <String, dynamic>{
        'coin': 'LTC',
        'fname': 'Litecoin',
        'type': 'UTXO',
        'chain_id': 2,
        'is_testnet': false,
      });

      mockConfigRepository = MockRuntimeUpdateConfigRepository();
      mockTransformer = MockCoinConfigTransformer();
      mockDataFactory = MockCoinConfigDataFactory();
      mockRepo = MockCoinConfigRepository();
      mockLocalProvider = MockLocalAssetCoinConfigProvider();
      mockFallbackProvider = MockLocalAssetFallbackProvider();
      mockRemoteProvider = MockGithubCoinConfigProvider();

      // runtime config
      when(() => mockConfigRepository.tryLoad()).thenAnswer(
        (_) async => const AssetRuntimeUpdateConfig(
          bundledCoinsRepoCommit: bundledCommit,
        ),
      );

      // transformer: no-op for these tests
      when(() => mockTransformer.apply(any())).thenAnswer((inv) =>
          Map<String, dynamic>.from(inv.positionalArguments.first as Map));

      // factory returns our single repo and separate local providers
      when(() => mockDataFactory.createRepository(any(), any()))
          .thenReturn(mockRepo);
      var localProviderCallCount = 0;
      when(() => mockDataFactory.createLocalProvider(any())).thenAnswer((_) {
        localProviderCallCount++;
        return localProviderCallCount == 1
            ? mockLocalProvider
            : mockFallbackProvider; // for update manager fallback
      });

      // repository wiring
      when(() => mockRepo.coinConfigProvider).thenReturn(mockRemoteProvider);

      // storage does not exist at cold boot; will flip to true after update
      var storageExists = false;
      when(() => mockRepo.updatedAssetStorageExists())
          .thenAnswer((_) async => storageExists);

      // local provider returns bundled asset + commit
      when(() => mockLocalProvider.getAssets())
          .thenAnswer((_) async => [kmdAsset]);
      when(() => mockLocalProvider.getLatestCommit())
          .thenAnswer((_) async => bundledCommit);

      // fallback (for update manager) mirrors bundled
      when(() => mockFallbackProvider.getAssets())
          .thenAnswer((_) async => [kmdAsset]);
      when(() => mockFallbackProvider.getLatestCommit())
          .thenAnswer((_) async => bundledCommit);

      // remote provides a newer commit
      when(() => mockRemoteProvider.getLatestCommit())
          .thenAnswer((_) async => latestCommit);
      // current commit initially unknown; after update we'll return latest
      when(() => mockRepo.getCurrentCommit()).thenAnswer((_) async => null);
      when(() => mockRepo.isLatestCommit()).thenAnswer((_) async => false);
      // update operation succeeds and flips storage state; also provide updated assets
      when(() => mockRepo.updateCoinConfig()).thenAnswer((_) async {
        storageExists = true;
        // After update, repository reads return updated state
        when(() => mockRepo.getCurrentCommit())
            .thenAnswer((_) async => latestCommit);
        when(() => mockRepo.getAssets()).thenAnswer((_) async => [
              kmdAsset,
              ltcAsset,
            ]);
        when(() => mockRepo.isLatestCommit()).thenAnswer((_) async => true);
      });
    });

    test('in-memory assets and commit remain cached after background update',
        () async {
      final coins = KomodoAssetsUpdateManager(
        configRepository: mockConfigRepository,
        transformer: mockTransformer,
        dataFactory: mockDataFactory,
        // Use default strategies; auto-update enabled
      );

      await coins.init();

      // Initial state from asset bundle
      expect(coins.all.length, 1);
      expect(coins.all.values.first.id.id, 'KMD');
      final initialCommit = await coins.getCurrentCommitHash();
      expect(initialCommit, equals(bundledCommit));

      // Allow background update to run once
      await Future<void>.delayed(const Duration(milliseconds: 200));
      verify(() => mockRepo.updateCoinConfig()).called(greaterThanOrEqualTo(1));

      // Even after update, in-memory cache should remain from initial load
      expect(coins.all.length, 1);
      expect(coins.all.values.first.id.id, 'KMD');

      // Commit returned via assets manager should remain cached (bundled)
      final cachedCommit = await coins.getCurrentCommitHash();
      expect(cachedCommit, equals(bundledCommit));

      await coins.dispose();
    });

    test('startup fetch vs instance: background update only for instance',
        () async {
      // 1) Static startup fetch (auto-update disabled)
      await StartupCoinsProvider.fetchRawCoinsForStartup(
        configRepository: mockConfigRepository,
        transformer: mockTransformer,
        dataFactory: mockDataFactory,
        // Force asset-bundle-first to drive through our mocked local provider
        loadingStrategy: AssetBundleFirstLoadingStrategy(),
        appName: 'test_app',
        appStoragePath: '/tmp',
      );
      // No background update should be triggered on the shared repo mock
      verifyNever(() => mockRepo.updateCoinConfig());

      // 2) Instance with auto-update enabled
      final coins = KomodoAssetsUpdateManager(
        configRepository: mockConfigRepository,
        transformer: mockTransformer,
        dataFactory: mockDataFactory,
      );
      await coins.init();

      // Both should have used asset bundle initially (no storage)
      verify(() => mockLocalProvider.getAssets()).called(greaterThan(0));

      // Allow background update to run
      await Future<void>.delayed(const Duration(milliseconds: 200));
      verify(() => mockRepo.updateCoinConfig()).called(greaterThanOrEqualTo(1));

      // After update, instance getters should still return cached values
      expect(coins.all.values.first.id.id, 'KMD');
      final commitAfterUpdate = await coins.getCurrentCommitHash();
      expect(commitAfterUpdate, equals(bundledCommit));

      await coins.dispose();
    });

    test(
      'filteredAssets caching: stable before refresh, updates after refresh',
      () async {
        final coins = KomodoAssetsUpdateManager(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
          // default strategies; auto-update enabled
        );

        await coins.init();

        // Use an explicit strategy (NoAssetFilterStrategy) and confirm initial view
        const noFilter = NoAssetFilterStrategy();
        final initialFiltered = coins.filteredAssets(noFilter);
        expect(initialFiltered.length, 1);
        expect(initialFiltered.values.first.id.id, 'KMD');

        // Re-calling with the same strategy should return the same cached map instance
        final cachedAgain = coins.filteredAssets(noFilter);
        expect(identical(initialFiltered, cachedAgain), isTrue);

        // Allow background update to run (which flips storage state in the repo mock)
        await Future<void>.delayed(const Duration(milliseconds: 200));
        verify(() => mockRepo.updateCoinConfig())
            .called(greaterThanOrEqualTo(1));

        // Before refresh, filtered view remains cached and unchanged
        final stillCached = coins.filteredAssets(noFilter);
        expect(identical(initialFiltered, stillCached), isTrue);
        expect(stillCached.length, 1);
        expect(stillCached.values.first.id.id, 'KMD');

        // Try a different strategy to ensure independent cache entries are also based on current _assets
        const utxoFilter = UtxoAssetFilterStrategy();
        final utxoFiltered = coins.filteredAssets(utxoFilter);
        expect(utxoFiltered.length, 1);

        // Now trigger a manual refresh to pick up updated storage assets
        await coins.assets.refreshAssets();

        // After refresh, filter caches are cleared, so results should be a new instance and reflect updates
        final afterRefresh = coins.filteredAssets(noFilter);
        expect(identical(initialFiltered, afterRefresh), isFalse);
        expect(afterRefresh.length, 2); // KMD + LTC after repo update

        final afterRefreshUtxo = coins.filteredAssets(utxoFilter);
        expect(afterRefreshUtxo.length, 2);

        await coins.dispose();
      },
    );

    test(
      'end-to-end: startup fetch -> init -> cached view -> updateNow -> refreshed view',
      () async {
        // 1) Static startup fetch uses asset bundle, no updates, storage clean
        final startupList = await StartupCoinsProvider.fetchRawCoinsForStartup(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
          loadingStrategy: AssetBundleFirstLoadingStrategy(),
          appName: 'test_app',
          appStoragePath: '/tmp',
        );
        expect(startupList, isNotEmpty);
        expect(startupList.length, equals(1)); // only bundled KMD
        verifyNever(() => mockRepo.updateCoinConfig());
        // Storage check: repository reports no storage initially
        expect(await mockRepo.updatedAssetStorageExists(), isFalse);

        // 2) Instance init triggers background update (which flips storageExists)
        final coins = KomodoAssetsUpdateManager(
          configRepository: mockConfigRepository,
          transformer: mockTransformer,
          dataFactory: mockDataFactory,
        );
        await coins.init();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        verify(() => mockRepo.updateCoinConfig())
            .called(greaterThanOrEqualTo(1));
        // After background update, storage should now exist
        expect(await mockRepo.updatedAssetStorageExists(), isTrue);

        // 3) Cached view still from asset bundle
        expect(coins.all.length, equals(1));

        // 4) Cached commit still bundled
        final cachedCommit = await coins.getCurrentCommitHash();
        expect(cachedCommit, equals(bundledCommit));

        // 5) Force immediate update and then refresh assets to reflect storage
        //    (assets manager intentionally caches until refreshed)
        final updateResult = await coins.updateNow();
        expect(updateResult.success, isTrue);
        await coins.assets.refreshAssets();

        // After refresh, we should see the updated storage assets and commit
        expect(coins.all.length, equals(2)); // KMD + ETH
        final updatedCommit = await coins.getCurrentCommitHash();
        expect(updatedCommit, equals(latestCommit));

        await coins.dispose();
      },
    );
  });
}
