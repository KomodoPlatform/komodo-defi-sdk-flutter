import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_coins/src/update_management/update_strategy.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockCoinConfigRepository extends Mock implements CoinConfigRepository {}

class MockCoinConfigProvider extends Mock implements CoinConfigProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(UpdateRequestType.backgroundUpdate);
  });

  group('UpdateResult', () {
    test('creates valid update result with success', () {
      const result = UpdateResult(
        success: true,
        updatedAssetCount: 5,
        newCommitHash: 'abc123',
        previousCommitHash: 'def456',
      );

      expect(result.success, isTrue);
      expect(result.updatedAssetCount, 5);
      expect(result.newCommitHash, 'abc123');
      expect(result.previousCommitHash, 'def456');
      expect(result.hasNewCommit, isTrue);
      expect(result.error, isNull);
    });

    test('creates valid update result with failure', () {
      final error = Exception('Update failed');
      final result = UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: error,
      );

      expect(result.success, isFalse);
      expect(result.updatedAssetCount, 0);
      expect(result.newCommitHash, isNull);
      expect(result.previousCommitHash, isNull);
      expect(result.hasNewCommit, isFalse);
      expect(result.error, equals(error));
    });

    test('hasNewCommit returns false when hashes are same', () {
      const result = UpdateResult(
        success: true,
        updatedAssetCount: 0,
        newCommitHash: 'abc123',
        previousCommitHash: 'abc123',
      );

      expect(result.hasNewCommit, isFalse);
    });

    test('hasNewCommit returns false when newCommitHash is null', () {
      const result = UpdateResult(
        success: true,
        updatedAssetCount: 0,
        previousCommitHash: 'abc123',
      );

      expect(result.hasNewCommit, isFalse);
    });
  });

  group('UpdateStrategy', () {
    late MockCoinConfigRepository mockRepository;
    late MockCoinConfigProvider mockProvider;

    setUp(() {
      mockRepository = MockCoinConfigRepository();
      mockProvider = MockCoinConfigProvider();
      when(() => mockRepository.coinConfigProvider).thenReturn(mockProvider);
    });

    group('BackgroundUpdateStrategy', () {
      late BackgroundUpdateStrategy strategy;

      setUp(() {
        strategy = const BackgroundUpdateStrategy();
      });

      test('has correct update interval', () {
        expect(strategy.updateInterval, const Duration(hours: 6));
      });

      test('should update when no last update time', () async {
        when(() => mockRepository.isLatestCommit())
            .thenAnswer((_) async => false);

        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
        );

        expect(result, isTrue);
      });

      test('should update when enough time has passed', () async {
        when(() => mockRepository.isLatestCommit())
            .thenAnswer((_) async => false);
        final oldTime = DateTime.now().subtract(const Duration(hours: 7));

        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
          lastUpdateTime: oldTime,
        );

        expect(result, isTrue);
      });

      test('should not update when not enough time has passed', () async {
        when(() => mockRepository.isLatestCommit())
            .thenAnswer((_) async => true);
        final recentTime = DateTime.now().subtract(const Duration(hours: 1));

        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
          lastUpdateTime: recentTime,
        );

        expect(result, isFalse);
      });

      test('should update for immediate request regardless of time', () async {
        when(() => mockRepository.isLatestCommit())
            .thenAnswer((_) async => false);
        final recentTime = DateTime.now().subtract(const Duration(minutes: 1));

        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.immediateUpdate,
          repository: mockRepository,
          lastUpdateTime: recentTime,
        );

        expect(result, isTrue);
      });

      test('should not update when already at latest commit', () async {
        when(() => mockRepository.isLatestCommit())
            .thenAnswer((_) async => true);

        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
        );

        expect(result, isFalse);
      });

      test('executes update successfully', () async {
        when(() => mockRepository.updateCoinConfig()).thenAnswer((_) async {});
        when(() => mockRepository.getCurrentCommit())
            .thenAnswer((_) async => 'old123');
        when(() => mockRepository.getAssets())
            .thenAnswer((_) async => []); // Empty list for simplicity
        when(() => mockProvider.getLatestCommit())
            .thenAnswer((_) async => 'new456');

        final result = await strategy.executeUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
        );

        expect(result.success, isTrue);
        expect(result.updatedAssetCount, 0); // Empty asset list
        expect(result.error, isNull);
        verify(() => mockRepository.updateCoinConfig()).called(1);
      });

      test('handles update failure', () async {
        when(() => mockRepository.updateCoinConfig())
            .thenThrow(Exception('Update failed'));

        final result = await strategy.executeUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
        );

        expect(result.success, isFalse);
        expect(result.updatedAssetCount, 0);
        expect(result.error, isA<Exception>());
      });
    });

    group('ImmediateUpdateStrategy', () {
      late ImmediateUpdateStrategy strategy;

      setUp(() {
        strategy = const ImmediateUpdateStrategy();
      });

      test('has short update interval', () {
        expect(strategy.updateInterval, const Duration(minutes: 30));
      });

      test('always should update', () async {
        when(() => mockRepository.isLatestCommit())
            .thenAnswer((_) async => true);
        final recentTime = DateTime.now().subtract(const Duration(minutes: 1));

        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.immediateUpdate,
          repository: mockRepository,
          lastUpdateTime: recentTime,
        );

        expect(result, isTrue);
      });

      test('executes update with standard call', () async {
        when(() => mockRepository.updateCoinConfig()).thenAnswer((_) async {});
        when(() => mockRepository.getCurrentCommit())
            .thenAnswer((_) async => 'old123');
        when(() => mockRepository.getAssets())
            .thenAnswer((_) async => []); // Empty list for simplicity
        when(() => mockProvider.getLatestCommit())
            .thenAnswer((_) async => 'new456');

        final result = await strategy.executeUpdate(
          requestType: UpdateRequestType.immediateUpdate,
          repository: mockRepository,
        );

        expect(result.success, isTrue);
        verify(() => mockRepository.updateCoinConfig()).called(1);
      });
    });

    group('NoUpdateStrategy', () {
      late NoUpdateStrategy strategy;

      setUp(() {
        strategy = NoUpdateStrategy();
      });

      test('has long update interval', () {
        expect(strategy.updateInterval, const Duration(days: 365));
      });

      test('never should update for background requests', () async {
        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
        );

        expect(result, isFalse);
      });

      test('never should update for immediate requests', () async {
        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.immediateUpdate,
          repository: mockRepository,
        );

        expect(result, isFalse);
      });

      test('allows force updates', () async {
        final result = await strategy.shouldUpdate(
          requestType: UpdateRequestType.forceUpdate,
          repository: mockRepository,
        );

        expect(result, isTrue);
      });

      test('returns failure for non-force updates', () async {
        final result = await strategy.executeUpdate(
          requestType: UpdateRequestType.backgroundUpdate,
          repository: mockRepository,
        );

        expect(result.success, isFalse);
        expect(result.updatedAssetCount, 0);
        expect(result.error, isA<Exception>());

        // Should not call any update methods
        verifyNever(() => mockRepository.updateCoinConfig());
      });

      test('executes force updates', () async {
        when(() => mockRepository.getCurrentCommit())
            .thenAnswer((_) async => 'current123');
        when(() => mockRepository.getAssets())
            .thenAnswer((_) async => []); // Empty list for simplicity

        final result = await strategy.executeUpdate(
          requestType: UpdateRequestType.forceUpdate,
          repository: mockRepository,
        );

        expect(result.success, isTrue);
        expect(result.updatedAssetCount, 0);
        expect(result.error, isNull);

        // Should call repository methods but not updateCoinConfig
        verify(() => mockRepository.getCurrentCommit()).called(1);
        verify(() => mockRepository.getAssets()).called(1);
        verifyNever(() => mockRepository.updateCoinConfig());
      });
    });
  });

  group('UpdateRequestType', () {
    test('has all expected values', () {
      expect(
        UpdateRequestType.values,
        contains(UpdateRequestType.backgroundUpdate),
      );
      expect(
        UpdateRequestType.values,
        contains(UpdateRequestType.immediateUpdate),
      );
      expect(
        UpdateRequestType.values,
        contains(UpdateRequestType.scheduledUpdate),
      );
      expect(UpdateRequestType.values, contains(UpdateRequestType.forceUpdate));
    });
  });
}
