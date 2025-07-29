import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:komodo_defi_sdk/src/activation/retryable_activation_manager.dart';
import 'package:komodo_defi_types/src/utils/retry_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import 'mocks/controllable_mock_strategies.dart';
import 'mocks/test_utilities.dart';

/// Timeout verification test to confirm our hanging strategy and timeout mechanisms work correctly
void main() {
  group('Timeout Verification', () {
    late ActivationManagerTestSetup setup;
    late ControllableMockActivationStrategy controllableStrategy;
    late RetryableActivationManager retryableManager;

    setUp(() {
      setup = ActivationManagerTestSetup()..setUp();

      controllableStrategy = ControllableMockActivationStrategy(
        MockApiClient(),
      );

      retryableManager = RetryableActivationManager(
        setup.mockClient,
        setup.mockAuth,
        setup.mockAssetHistory,
        setup.mockCustomTokenHistory,
        setup.mockAssetLookup,
        setup.mockBalanceManager,
        activationStrategyFactory: DirectTestActivationStrategyFactory(
          controllableStrategy,
        ),
        retryConfig: RetryConfig.testing,
        retryStrategy: const NoRetryStrategy(),
        operationTimeout: const Duration(seconds: 60), // Long internal timeout
      );
    });

    tearDown(() async {
      controllableStrategy.dispose();
      await retryableManager.dispose();
      await setup.tearDown();
    });

    test('timeout should work correctly on hanging activation', () {
      fakeAsync((FakeAsync async) {
        // Configure strategy to hang after emitting progress
        controllableStrategy.configureHang(
          progressMessages: ['Starting...', 'Processing...'],
        );

        final progressEvents = <ActivationProgress>[];
        Object? caughtException;
        bool timeoutOccurred = false;

        retryableManager
            .activateAsset(setup.testAsset)
            .timeout(const Duration(milliseconds: 100)) // Short timeout
            .listen(
              (progress) {
                progressEvents.add(progress);
              },
              onError: (Object e) {
                if (e is TimeoutException) {
                  timeoutOccurred = true;
                  caughtException = e;
                }
              },
              onDone: () {
                fail('Expected timeout, but activation completed');
              },
            );

        // Elapse time to trigger timeout
        async.elapse(const Duration(milliseconds: 100));

        // Verify timeout occurred
        expect(timeoutOccurred, isTrue, reason: 'Should have timed out');
        expect(caughtException, isA<TimeoutException>());

        // Verify we got some progress before timeout
        expect(
          progressEvents.length,
          greaterThan(0),
          reason: 'Should have received progress before timeout',
        );
      });
    });

    test('quick completion should not timeout', () {
      fakeAsync((FakeAsync async) {
        // Configure strategy to complete quickly
        controllableStrategy.configureSuccess(
          progressMessages: ['Quick start', 'Quick finish'],
        );

        bool completed = false;
        Object? caughtException;

        retryableManager
            .activateAsset(setup.testAsset)
            .timeout(const Duration(milliseconds: 500)) // Generous timeout
            .listen(
              (_) {},
              onError: (Object e) {
                caughtException = e;
              },
              onDone: () {
                completed = true;
              },
            );

        // Elapse minimal time to let completion happen
        async.elapse(const Duration(milliseconds: 50));

        // Verify completion without timeout
        expect(completed, isTrue, reason: 'Should have completed successfully');
        expect(
          caughtException,
          isNull,
          reason: 'Should not have any exception',
        );
      });
    });

    test('failure should not timeout', () {
      fakeAsync((FakeAsync async) {
        // Configure strategy to fail quickly
        controllableStrategy.configureFailure(
          progressMessages: ['Start', 'About to fail'],
          errorMessage: 'Test failure',
        );

        bool completed = false;
        Object? caughtException;

        retryableManager
            .activateAsset(setup.testAsset)
            .timeout(const Duration(milliseconds: 500)) // Generous timeout
            .listen(
              (_) {},
              onError: (Object e) {
                caughtException = e;
              },
              onDone: () {
                completed = true;
              },
            );

        // Elapse minimal time to let failure happen
        async.elapse(const Duration(milliseconds: 50));

        // Verify failure without timeout
        expect(
          completed,
          isFalse,
          reason: 'Should not have completed successfully',
        );
        expect(
          caughtException,
          isNotNull,
          reason: 'Should have caught an exception',
        );
        expect(
          caughtException,
          isNot(isA<TimeoutException>()),
          reason: 'Should not be a timeout exception',
        );
      });
    });
  });
}
