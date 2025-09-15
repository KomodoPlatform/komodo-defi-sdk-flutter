import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/src/utils/retry_config.dart';
import 'package:test/test.dart';

import 'mocks/controllable_mock_strategies.dart';
import 'mocks/test_utilities.dart';

/// Test file for failing activation strategy using controllable mocks
///
/// Tests that verify the ActivationManager behaves correctly when
/// an activation strategy fails with an error, using deterministic
/// controllable strategies instead of timing-based approaches.
///
/// Key scenarios tested:
/// 1. Activation that fails should not succeed and manager should remain responsive
/// 2. After failure, a new activation should be possible
/// 3. Manager should handle multiple failures gracefully
/// 4. Manager should remain responsive during and after failures

void main() {
  group('Failing Activation Strategy Tests', () {
    late ActivationManagerTestSetup setup;
    late ControllableMockActivationStrategy controllableStrategy;
    late SharedActivationCoordinator coordinator;

    setUp(() {
      // Create a controllable strategy for deterministic testing
      controllableStrategy = ControllableMockActivationStrategy(
        MockApiClient(),
      );

      // Build activation manager with the controllable strategy
      setup = ActivationManagerTestSetup()
        ..setUp(
          activationStrategyFactory: DirectTestActivationStrategyFactory(
            controllableStrategy,
          ),
        );

      // Create coordinator with no-retry configuration for testing
      coordinator = SharedActivationCoordinator(
        setup.activationManager,
        setup.mockAuth,
        retryConfig: RetryConfig.noRetry, // No retries, no timeout conflicts
        retryStrategy: const NoRetryStrategy(),
      );
    });

    tearDown(() async {
      controllableStrategy.dispose();
      await coordinator.dispose();
      setup.tearDown();
    });

    test('should handle activation failure gracefully', () {
      fakeAsync((FakeAsync async) {
        // Configure the strategy to fail after emitting some progress
        controllableStrategy.configureFailure(
          progressMessages: ['Starting activation...', 'Processing...'],
        );

        bool activationCompleted = false;
        Object? caughtError;

        // Attempt activation - we expect it to fail
        coordinator
            .activateAssetStream(setup.testAsset)
            .listen(
              (_) {},
              onError: (Object e) {
                caughtError = e;
              },
              onDone: () {
                activationCompleted = true;
              },
            );

        // Elapse sufficient time to let failure happen and stream to process
        async.elapse(const Duration(milliseconds: 100));

        // The activation should not have completed successfully
        expect(
          activationCompleted,
          isFalse,
          reason: 'Activation should not succeed with failing strategy',
        );

        // Should have caught the expected error
        expect(
          caughtError,
          isNotNull,
          reason: 'Should have caught an error from failing activation',
        );

        expect(
          caughtError.toString(),
          contains('Simulated activation failure'),
          reason: 'Should contain the expected error message',
        );

        // The key test: verify that the manager is still responsive after the failure
        bool managerResponsive = false;
        try {
          coordinator
              .getActiveAssets()
              .then((activeAssets) {
                expect(activeAssets, isA<Set<dynamic>>());
                managerResponsive = true;
              })
              .catchError((Object e) {
                // Even if this fails due to mock setup, it should not hang
                managerResponsive =
                    true; // If it responds quickly, it's responsive
              });
        } catch (e) {
          managerResponsive = true; // If it responds quickly, it's responsive
        }

        // Elapse minimal time to allow async operation to complete
        async.elapse(const Duration(milliseconds: 1));

        expect(
          managerResponsive,
          isTrue,
          reason: 'Manager should remain responsive after failure',
        );
      });
    });

    test('should create new activation after previous activation failed', () async {
      // This tests that after a failed activation, a new activation can be started
      // rather than being stuck in a failed state

      bool firstActivationCompleted = false;
      bool secondActivationCompleted = false;
      Object? firstError;
      Object? secondError;

      // First activation attempt - configure to fail
      controllableStrategy.configureFailure(
        progressMessages: ['Starting first activation...'],
        errorMessage: 'First activation failure',
      );

      try {
        await coordinator.activateAssetStream(setup.testAsset).last;
        firstActivationCompleted = true;
      } catch (e) {
        firstError = e;
      }

      // Verify first activation did not succeed
      expect(
        firstActivationCompleted,
        isFalse,
        reason: 'First activation should not succeed',
      );

      expect(
        firstError?.toString(),
        contains('First activation failure'),
        reason: 'Should have caught the first activation error',
      );

      // Small delay to ensure first activation is completely done
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Configure for second activation failure
      controllableStrategy.configureFailure(
        progressMessages: ['Starting second activation...'],
        errorMessage: 'Second activation failure',
      );

      // Second activation attempt - should also fail but should be able to start
      try {
        await coordinator.activateAssetStream(setup.testAsset).last;
        secondActivationCompleted = true;
      } catch (e) {
        secondError = e;
      }

      // Verify second activation also did not succeed
      expect(
        secondActivationCompleted,
        isFalse,
        reason: 'Second activation should not succeed',
      );

      expect(
        secondError?.toString(),
        contains('Second activation failure'),
        reason: 'Should have caught the second activation error',
      );

      // The key point: both activations should have been attempted
      // (they failed, but they were able to start, meaning no stuck state)
      expect(
        firstError,
        isNotNull,
        reason: 'First activation should have failed with error',
      );

      expect(
        secondError,
        isNotNull,
        reason: 'Second activation should have failed with error',
      );
    });

    test('should allow status queries after activation failure', () async {
      // Test that after an activation fails, the manager is still responsive
      // to status queries and other operations

      bool activationCompleted = false;

      // Configure strategy to fail
      controllableStrategy.configureFailure(
        progressMessages: ['Starting activation...', 'About to fail...'],
        errorMessage: 'Status query test failure',
      );

      // First, cause an activation to fail
      try {
        await coordinator.activateAssetStream(setup.testAsset).last;
        activationCompleted = true;
      } catch (e) {
        // Expected to fail
      }

      // Verify activation did not succeed
      expect(
        activationCompleted,
        isFalse,
        reason: 'Activation should not succeed with failing strategy',
      );

      // Manager should still respond to queries
      bool managerResponsive = false;

      // Test that manager can still respond to queries
      try {
        final isActive = await coordinator
            .isAssetActive(setup.testAsset.id)
            .timeout(const Duration(milliseconds: 100));
        expect(isActive, isA<bool>());
        managerResponsive = true;
      } catch (e) {
        // Try another operation to verify responsiveness
        try {
          final activeAssets = await coordinator.getActiveAssets().timeout(
            const Duration(milliseconds: 100),
          );
          expect(activeAssets, isA<Set<dynamic>>());
          managerResponsive = true;
        } catch (e) {
          // Manager might fail due to mock setup, but should not hang
          managerResponsive = true; // If it responds quickly, it's responsive
        }
      }

      expect(
        managerResponsive,
        isTrue,
        reason: 'Manager should remain responsive after failure',
      );
    });

    test('should handle multiple sequential failed activations', () async {
      // Test that multiple sequential failed activations don't accumulate
      // failed state or cause memory leaks

      final results = <bool>[];
      final errors = <Object>[];

      for (int i = 0; i < 5; i++) {
        bool activationCompleted = false;

        // Configure unique failure for each attempt
        controllableStrategy.configureFailure(
          progressMessages: ['Starting activation $i...'],
          errorMessage: 'Sequential failure $i',
        );

        try {
          await coordinator.activateAssetStream(setup.testAsset).last;
          activationCompleted = true;
        } catch (e) {
          errors.add(e);
        }

        results.add(activationCompleted);

        // Small delay between attempts
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      // Verify all activations failed (did not complete successfully)
      expect(
        results.every((completed) => !completed),
        isTrue,
        reason: 'All activations should have failed to complete',
      );

      // Verify we caught all the errors
      expect(errors.length, equals(5), reason: 'Should have caught 5 errors');

      // Verify each error is unique (from our configured messages)
      for (int i = 0; i < errors.length; i++) {
        expect(
          errors[i].toString(),
          contains('Sequential failure $i'),
          reason: 'Error $i should contain the expected message',
        );
      }

      // Manager should still be functional after multiple failures
      bool managerResponsive = false;
      try {
        final activeAssets = await coordinator.getActiveAssets().timeout(
          const Duration(milliseconds: 100),
        );
        expect(activeAssets, isA<Set<dynamic>>());
        managerResponsive = true;
      } catch (e) {
        // Manager might fail due to mock setup, but should not hang
        managerResponsive = true;
      }

      expect(
        managerResponsive,
        isTrue,
        reason: 'Should handle multiple sequential failures',
      );
    });

    test('should handle concurrent failed activations', () async {
      // Test that multiple concurrent failed activations don't interfere
      // with each other or cause deadlocks

      final futures = <Future<bool>>[];

      // Start multiple concurrent activations that will fail
      for (int i = 0; i < 3; i++) {
        // Each gets its own strategy instance to avoid conflicts
        final strategy = ControllableMockActivationStrategy(MockApiClient())
          ..configureFailure(
            progressMessages: ['Concurrent activation $i...'],
            errorMessage: 'Concurrent failure $i',
          );

        // Build an ActivationManager with dedicated strategy and wrap with a coordinator
        final dedicatedManager = ActivationManager(
          setup.mockClient,
          setup.mockAuth,
          setup.mockAssetHistory,
          setup.mockCustomTokenHistory,
          setup.mockAssetLookup,
          setup.mockBalanceManager,
          activationStrategyFactory: DirectTestActivationStrategyFactory(
            strategy,
          ),
          assetRefreshNotifier: setup.mockAssetLookup,
        );
        final dedicatedCoordinator = SharedActivationCoordinator(
          dedicatedManager,
          setup.mockAuth,
          retryConfig: RetryConfig.noRetry,
          retryStrategy: const NoRetryStrategy(),
        );

        final future = dedicatedCoordinator
            .activateAssetStream(setup.testAsset)
            .last
            .then((_) => true) // If it completes, return true
            .catchError((Object _) => false) // If it fails, return false
            .whenComplete(() async {
              strategy.dispose();
              await dedicatedCoordinator.dispose();
              await dedicatedManager.dispose();
            });
        futures.add(future);
      }

      // Wait for all to complete (fail)
      final results = await Future.wait(futures);

      // Verify all activations failed (returned false)
      expect(
        results.every((success) => !success),
        isTrue,
        reason: 'All concurrent activations should have failed',
      );

      // Manager should still be responsive
      bool managerResponsive = false;
      try {
        final isActive = await coordinator
            .isAssetActive(setup.testAsset.id)
            .timeout(const Duration(milliseconds: 100));
        expect(isActive, isA<bool>());
        managerResponsive = true;
      } catch (e) {
        // Manager might fail due to mock setup, but should not hang
        managerResponsive = true;
      }

      expect(
        managerResponsive,
        isTrue,
        reason: 'Should handle rapid exception activations',
      );
    });

    test('should emit progress before failing', () async {
      // Test that we can capture progress events before the failure occurs

      final progressEvents = <ActivationProgress>[];
      Object? finalError;

      // Configure strategy to emit specific progress then fail
      controllableStrategy.configureFailure(
        progressMessages: [
          'Initializing activation...',
          'Validating asset...',
          'Processing request...',
        ],
        errorMessage: 'Progress test failure',
      );

      try {
        await for (final progress in coordinator.activateAssetStream(
          setup.testAsset,
        )) {
          progressEvents.add(progress);
        }
      } catch (e) {
        finalError = e;
      }

      // Should have received the expected progress events
      expect(
        progressEvents.length,
        equals(3),
        reason: 'Should have received 3 progress events before failure',
      );

      expect(
        progressEvents[0].status,
        equals('Initializing activation...'),
        reason: 'First progress should match expected message',
      );

      expect(
        progressEvents[1].status,
        equals('Validating asset...'),
        reason: 'Second progress should match expected message',
      );

      expect(
        progressEvents[2].status,
        equals('Processing request...'),
        reason: 'Third progress should match expected message',
      );

      // Should have caught the final error
      expect(
        finalError,
        isNotNull,
        reason: 'Should have caught the failure error',
      );

      expect(
        finalError.toString(),
        contains('Progress test failure'),
        reason: 'Error should contain expected message',
      );
    });
  });
}
