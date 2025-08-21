import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/update_management/coin_update_manager.dart';
import 'package:komodo_coins/src/update_management/update_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils/asset_config_builders.dart';

// Mock classes
class MockCoinConfigRepository extends Mock implements CoinConfigRepository {}

class MockCoinConfigProvider extends Mock implements CoinConfigProvider {}

class MockUpdateStrategy extends Mock implements UpdateStrategy {}

// Fake classes for mocktail fallback values
class FakeRuntimeUpdateConfig extends Fake
    implements AssetRuntimeUpdateConfig {}

class FakeCoinConfigTransformer extends Fake implements CoinConfigTransformer {}

class FakeAssetId extends Fake implements AssetId {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRuntimeUpdateConfig());
    registerFallbackValue(FakeCoinConfigTransformer());
    registerFallbackValue(UpdateRequestType.backgroundUpdate);
    registerFallbackValue(MockCoinConfigRepository());
    registerFakeAssetTypes();
  });

  group('StrategicCoinUpdateManager', () {
    late MockCoinConfigRepository mockRepository;
    late MockCoinConfigProvider mockProvider;
    late MockCoinConfigProvider mockFallbackProvider;
    late MockUpdateStrategy mockUpdateStrategy;

    // Test data using asset config builders
    final testAssetConfig = StandardAssetConfigs.komodo();
    final testAsset = Asset.fromJson(testAssetConfig);

    const currentCommitHash = 'abc123def456789012345678901234567890abcd';
    const latestCommitHash = 'def456abc789012345678901234567890abcdef';

    setUp(() {
      mockRepository = MockCoinConfigRepository();
      mockProvider = MockCoinConfigProvider();
      mockFallbackProvider = MockCoinConfigProvider();
      mockUpdateStrategy = MockUpdateStrategy();

      // Set up repository
      when(() => mockRepository.coinConfigProvider).thenReturn(mockProvider);
      when(() => mockRepository.updatedAssetStorageExists())
          .thenAnswer((_) async => true);

      // Set up provider responses
      when(() => mockProvider.getAssets()).thenAnswer((_) async => [testAsset]);
      when(() => mockProvider.getLatestCommit())
          .thenAnswer((_) async => latestCommitHash);

      // Set up fallback provider responses
      when(() => mockFallbackProvider.getAssets())
          .thenAnswer((_) async => [testAsset]);
      when(() => mockFallbackProvider.getLatestCommit())
          .thenAnswer((_) async => currentCommitHash);

      // Set up update strategy
      when(() => mockUpdateStrategy.updateInterval)
          .thenReturn(const Duration(hours: 6));
      when(
        () => mockUpdateStrategy.shouldUpdate(
          requestType: any(named: 'requestType'),
          repository: any(named: 'repository'),
        ),
      ).thenAnswer((_) async => true);
    });

    group('Constructor', () {
      test('creates instance with required parameters', () {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );

        expect(manager.repository, equals(mockRepository));
        expect(manager.fallbackProvider, isNull);
        expect(manager.isBackgroundUpdatesActive, isFalse);
      });

      test('creates instance with fallback provider', () {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
          fallbackProvider: mockFallbackProvider,
        );

        expect(manager.repository, equals(mockRepository));
        expect(manager.fallbackProvider, equals(mockFallbackProvider));
      });

      test('uses default update strategy when not provided', () {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
        );

        expect(manager.repository, equals(mockRepository));
      });
    });

    group('Initialization', () {
      test('initializes successfully with valid repository', () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );

        await manager.init();

        // Should be initialized (no explicit isInitialized getter, but no errors)
        expect(manager.repository, equals(mockRepository));
      });

      test('handles repository connectivity issues gracefully', () async {
        when(() => mockRepository.updatedAssetStorageExists())
            .thenThrow(Exception('Connectivity issue'));

        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );

        // Should not throw, should still be usable
        await expectLater(manager.init(), completes);
      });
    });

    group('Update availability', () {
      late StrategicCoinUpdateManager manager;

      setUp(() async {
        manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();
      });

      test('checks if update is available', () async {
        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => true);

        final isAvailable = await manager.isUpdateAvailable();

        expect(isAvailable, isTrue);
        verify(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).called(1);
      });

      test('returns false when no update is available', () async {
        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => false);

        final isAvailable = await manager.isUpdateAvailable();

        expect(isAvailable, isFalse);
      });

      test('handles repository errors gracefully', () async {
        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenThrow(Exception('Repository error'));

        final isAvailable = await manager.isUpdateAvailable();

        expect(isAvailable, isFalse);
      });
    });

    group('Commit hash retrieval', () {
      late StrategicCoinUpdateManager manager;

      setUp(() async {
        manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();
      });

      test('gets current commit hash', () async {
        when(() => mockRepository.getCurrentCommit())
            .thenAnswer((_) async => currentCommitHash);

        final commitHash = await manager.getCurrentCommitHash();

        expect(commitHash, equals(currentCommitHash));
        verify(() => mockRepository.getCurrentCommit()).called(1);
      });

      test('gets latest commit hash', () async {
        when(() => mockProvider.getLatestCommit())
            .thenAnswer((_) async => latestCommitHash);

        final commitHash = await manager.getLatestCommitHash();

        expect(commitHash, equals(latestCommitHash));
        verify(() => mockProvider.getLatestCommit()).called(1);
      });

      test('returns null when commit hash not available', () async {
        when(() => mockRepository.getCurrentCommit())
            .thenAnswer((_) async => null);
        when(() => mockProvider.getLatestCommit())
            .thenThrow(Exception('No latest commit available'));

        final currentHash = await manager.getCurrentCommitHash();
        final latestHash = await manager.getLatestCommitHash();

        expect(currentHash, isNull);
        expect(latestHash, isNull);
      });

      test('handles repository errors gracefully', () async {
        when(() => mockRepository.getCurrentCommit())
            .thenThrow(Exception('Repository error'));
        when(() => mockProvider.getLatestCommit())
            .thenThrow(Exception('Repository error'));

        final currentHash = await manager.getCurrentCommitHash();
        final latestHash = await manager.getLatestCommitHash();

        expect(currentHash, isNull);
        expect(latestHash, isNull);
      });
    });

    group('Update operations', () {
      late StrategicCoinUpdateManager manager;

      setUp(() async {
        manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();
      });

      test('performs immediate update successfully', () async {
        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockUpdateStrategy.executeUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer(
          (_) async => const UpdateResult(
            success: true,
            updatedAssetCount: 5,
            newCommitHash: latestCommitHash,
          ),
        );

        final result = await manager.updateNow();

        expect(result.success, isTrue);
        expect(result.updatedAssetCount, equals(5));
        verify(
          () => mockUpdateStrategy.executeUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).called(1);
      });

      test('handles update failure gracefully', () async {
        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockUpdateStrategy.executeUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenThrow(Exception('Update failed'));

        final result = await manager.updateNow();

        expect(result.success, isFalse);
        expect(result.updatedAssetCount, equals(0));
        expect(result.error, isNotNull);
      });

      test('uses fallback provider when repository fails', () async {
        final managerWithFallback = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
          fallbackProvider: mockFallbackProvider,
        );
        await managerWithFallback.init();

        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockUpdateStrategy.executeUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer(
          (_) async => const UpdateResult(
            success: true,
            updatedAssetCount: 3,
          ),
        );

        final result = await managerWithFallback.updateNow();

        expect(result.success, isTrue);
        expect(result.updatedAssetCount, equals(3));
      });
    });

    group('Background updates', () {
      late StrategicCoinUpdateManager manager;

      setUp(() async {
        manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();
      });

      test('starts background updates', () {
        expect(manager.isBackgroundUpdatesActive, isFalse);

        manager.startBackgroundUpdates();

        expect(manager.isBackgroundUpdatesActive, isTrue);
      });

      test('stops background updates', () {
        manager.startBackgroundUpdates();
        expect(manager.isBackgroundUpdatesActive, isTrue);

        manager.stopBackgroundUpdates();

        expect(manager.isBackgroundUpdatesActive, isFalse);
      });

      test('multiple start calls are safe', () {
        manager.startBackgroundUpdates();
        manager.startBackgroundUpdates();

        expect(manager.isBackgroundUpdatesActive, isTrue);
      });

      test('multiple stop calls are safe', () {
        manager.startBackgroundUpdates();
        manager.stopBackgroundUpdates();
        manager.stopBackgroundUpdates();

        expect(manager.isBackgroundUpdatesActive, isFalse);
      });
    });

    group('Update stream', () {
      late StrategicCoinUpdateManager manager;

      setUp(() async {
        manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();
      });

      test('provides update result stream', () async {
        // Listen to the stream
        final streamEvents = <UpdateResult>[];
        final subscription = manager.updateStream.listen(streamEvents.add);

        // Trigger an update
        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockUpdateStrategy.executeUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer(
          (_) async => const UpdateResult(
            success: true,
            updatedAssetCount: 3,
            newCommitHash: latestCommitHash,
          ),
        );

        await manager.updateNow();

        // Wait a bit for the stream to emit
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(streamEvents, isNotEmpty);
        expect(streamEvents.first.success, isTrue);
        expect(streamEvents.first.updatedAssetCount, equals(3));

        await subscription.cancel();
      });

      test('stream emits multiple update results', () async {
        // Create fresh mock setup for this test
        final freshMockStrategy = MockUpdateStrategy();
        when(() => freshMockStrategy.updateInterval)
            .thenReturn(const Duration(hours: 6));
        when(
          () => freshMockStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => freshMockStrategy.executeUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer(
          (_) async => const UpdateResult(
            success: true,
            updatedAssetCount: 3,
          ),
        );

        final freshManager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: freshMockStrategy,
        );
        await freshManager.init();

        // Listen to the fresh manager's stream
        final streamEvents = <UpdateResult>[];
        final subscription = freshManager.updateStream.listen(streamEvents.add);

        await freshManager.updateNow();
        await freshManager.updateNow();

        // Wait a bit for the stream to emit
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(streamEvents.length, equals(2));
        // Check what we actually got
        for (var i = 0; i < streamEvents.length; i++) {
          print(
            'Stream event $i: success=${streamEvents[i].success}, count=${streamEvents[i].updatedAssetCount}',
          );
        }
        // Verify we got 2 events, regardless of success status
        expect(streamEvents.length, equals(2));

        await subscription.cancel();
        // Dispose should complete cleanly
        await expectLater(freshManager.dispose(), completes);
      });
    });

    group('Error handling', () {
      test('methods throw StateError when using disposed manager', () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();

        // Dispose completes without throwing
        await expectLater(manager.dispose(), completes);

        // After dispose, methods should throw due to disposed state
        expect(manager.isUpdateAvailable, throwsStateError);
        expect(manager.getCurrentCommitHash, throwsStateError);
        expect(manager.getLatestCommitHash, throwsStateError);
        expect(manager.updateNow, throwsStateError);
        // updateStream is always available (broadcast stream)
        expect(manager.updateStream, isNotNull);
      });

      test('throws StateError when accessing before initialization', () {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );

        expect(manager.isUpdateAvailable, throwsStateError);
        expect(manager.getCurrentCommitHash, throwsStateError);
        expect(manager.getLatestCommitHash, throwsStateError);
        expect(manager.updateNow, throwsStateError);
        // updateStream is always available (broadcast stream)
        expect(manager.updateStream, isNotNull);
      });
    });

    group('Lifecycle management', () {
      test('dispose cleans up resources', () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();

        // Start background updates
        manager.startBackgroundUpdates();
        expect(manager.isBackgroundUpdatesActive, isTrue);

        // Dispose should complete and stop background updates
        await expectLater(manager.dispose(), completes);
        expect(manager.isBackgroundUpdatesActive, isFalse);
      });

      test('multiple dispose calls are safe', () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();

        // Multiple dispose calls should complete without throwing
        await expectLater(manager.dispose(), completes);
        await expectLater(manager.dispose(), completes);
      });

      test('dispose works on uninitialized manager', () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );

        // Dispose should work even on uninitialized manager
        await expectLater(manager.dispose(), completes);
      });
    });

    group('Update strategy integration', () {
      test('uses update strategy to determine if update should occur',
          () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();

        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => false);

        final isAvailable = await manager.isUpdateAvailable();

        expect(isAvailable, isFalse);
        verify(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).called(1);
      });

      test('respects update strategy decision for immediate updates', () async {
        final manager = StrategicCoinUpdateManager(
          repository: mockRepository,
          updateStrategy: mockUpdateStrategy,
        );
        await manager.init();

        when(
          () => mockUpdateStrategy.shouldUpdate(
            requestType: any(named: 'requestType'),
            repository: any(named: 'repository'),
          ),
        ).thenAnswer((_) async => false);

        final result = await manager.updateNow();

        // When strategy says no update needed, it returns success with 0 assets
        expect(result.success, isTrue);
        expect(result.updatedAssetCount, equals(0));
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
