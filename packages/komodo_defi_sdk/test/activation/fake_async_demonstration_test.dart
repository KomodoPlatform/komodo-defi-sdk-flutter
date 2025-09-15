import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/src/utils/retry_config.dart';
import 'package:test/test.dart';

import 'mocks/controllable_mock_strategies.dart';
import 'mocks/test_utilities.dart';

/// Demonstration test file showing the power of fake_async for timeout testing
///
/// This file demonstrates how fake_async solves our timeout hierarchy problems
/// and makes timeout tests fast, reliable, and deterministic.
///
/// Key benefits demonstrated:
/// 1. External timeouts work correctly (overriding internal timeouts)
/// 2. Tests run instantly instead of waiting for real timeouts
/// 3. Precise control over when timeouts occur
/// 4. Reliable, deterministic timeout behavior

void main() {
  group('fake_async Timeout Demonstration', () {
    late ActivationManagerTestSetup setup;
    late ControllableMockActivationStrategy controllableStrategy;
    late SharedActivationCoordinator coordinator;

    setUp(() {
      setup = ActivationManagerTestSetup()
        ..setUp(
          activationStrategyFactory: DirectTestActivationStrategyFactory(
            controllableStrategy,
          ),
        );

      controllableStrategy = ControllableMockActivationStrategy(
        MockApiClient(),
      );

      coordinator = SharedActivationCoordinator(
        setup.activationManager,
        setup.mockAuth,
        retryConfig: RetryConfig.testing,
        retryStrategy: const NoRetryStrategy(),
      );
    });

    tearDown(() async {
      controllableStrategy.dispose();
      await coordinator.dispose();
      await setup.tearDown();
    });

    test('fake_async makes 100ms timeout work instantly', () {
      // This test demonstrates that external timeouts now work correctly
      // and run instantly with fake_async, despite the 30-second internal timeout

      fakeAsync((FakeAsync async) {
        controllableStrategy.configureHang(
          progressMessages: ['Starting...', 'About to hang...'],
        );

        var timeoutOccurred = false;
        Object? caughtException;
        final progressEvents = <ActivationProgress>[];

        // Start activation with 100ms external timeout
        // This would normally be overridden by the 30-second internal timeout
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 100))
            .listen(
              progressEvents.add,
              onError: (Object e) {
                if (e is TimeoutException) {
                  timeoutOccurred = true;
                  caughtException = e;
                }
              },
              onDone: () => fail('Should timeout, not complete'),
            );

        // With fake_async, we can instantly trigger the 100ms timeout
        async.elapse(const Duration(milliseconds: 100));

        // Verify external timeout worked (not the internal 30-second timeout)
        expect(
          timeoutOccurred,
          isTrue,
          reason: 'External 100ms timeout should work',
        );
        expect(
          caughtException,
          isA<TimeoutException>(),
          reason: 'Should be a TimeoutException',
        );
        expect(
          progressEvents.isNotEmpty,
          isTrue,
          reason: 'Should have received progress before timeout',
        );
      });
    });

    test('fake_async allows testing different timeout durations', () {
      // This test shows how we can test various timeout scenarios precisely

      fakeAsync((FakeAsync async) {
        controllableStrategy.configureHang(progressMessages: ['Starting...']);

        var shortTimeoutFired = false;
        var mediumTimeoutFired = false;
        var longTimeoutFired = false;

        // Test multiple timeout scenarios

        // 50ms timeout
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 50))
            .listen(
              (_) {},
              onError: (Object e) {
                if (e is TimeoutException) shortTimeoutFired = true;
              },
            );

        // 150ms timeout
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 150))
            .listen(
              (_) {},
              onError: (Object e) {
                if (e is TimeoutException) mediumTimeoutFired = true;
              },
            );

        // 300ms timeout
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 300))
            .listen(
              (_) {},
              onError: (Object e) {
                if (e is TimeoutException) longTimeoutFired = true;
              },
            );

        // Elapse 50ms - only first timeout should fire
        async.elapse(const Duration(milliseconds: 50));
        expect(shortTimeoutFired, isTrue, reason: '50ms timeout should fire');
        expect(
          mediumTimeoutFired,
          isFalse,
          reason: '150ms timeout should not fire yet',
        );
        expect(
          longTimeoutFired,
          isFalse,
          reason: '300ms timeout should not fire yet',
        );

        // Elapse another 100ms (total 150ms) - second timeout should fire
        async.elapse(const Duration(milliseconds: 100));
        expect(
          mediumTimeoutFired,
          isTrue,
          reason: '150ms timeout should now fire',
        );
        expect(
          longTimeoutFired,
          isFalse,
          reason: '300ms timeout should not fire yet',
        );

        // Elapse another 150ms (total 300ms) - third timeout should fire
        async.elapse(const Duration(milliseconds: 150));
        expect(
          longTimeoutFired,
          isTrue,
          reason: '300ms timeout should now fire',
        );
      });
    });

    test('fake_async vs RetryConfig.testing timeout hierarchy', () {
      // This test demonstrates that fake_async makes the timeout hierarchy work correctly
      // External timeout (100ms) should fire before RetryConfig.testing timeout (500ms)

      fakeAsync((FakeAsync async) {
        controllableStrategy.configureHang(
          progressMessages: ['Testing timeout hierarchy...'],
        );

        var externalTimeoutFired = false;
        Object? timeoutException;

        // External 100ms timeout should fire before RetryConfig.testing 500ms timeout
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 100))
            .listen(
              (_) {},
              onError: (Object e) {
                if (e is TimeoutException) {
                  externalTimeoutFired = true;
                  timeoutException = e;
                }
              },
            );

        // Elapse 100ms - external timeout should fire
        async.elapse(const Duration(milliseconds: 100));
        expect(
          externalTimeoutFired,
          isTrue,
          reason: 'External 100ms timeout should fire first',
        );

        // Elapse more time to verify retry config timeout doesn't interfere
        async.elapse(const Duration(milliseconds: 400)); // Total 500ms

        // Should still be the external timeout that fired
        expect(
          timeoutException,
          isA<TimeoutException>(),
          reason: 'Should have timeout exception from external timeout',
        );
      });
    });

    test('fake_async allows precise timing control for edge cases', () {
      // This test demonstrates precise timing control for complex scenarios

      fakeAsync((FakeAsync async) {
        controllableStrategy.configureHang(
          progressMessages: ['Edge case test...'],
        );

        final timeoutTimes = <Duration>[];
        final progressTimes = <Duration>[];

        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(
              const Duration(milliseconds: 123),
            ) // Odd number for precision
            .listen(
              (progress) {
                progressTimes.add(async.elapsed);
              },
              onError: (Object e) {
                if (e is TimeoutException) {
                  timeoutTimes.add(async.elapsed);
                }
              },
            );

        // Elapse exactly to the timeout
        async.elapse(const Duration(milliseconds: 123));

        expect(
          timeoutTimes.length,
          equals(1),
          reason: 'Should have exactly one timeout',
        );
        expect(
          timeoutTimes.first,
          equals(const Duration(milliseconds: 123)),
          reason: 'Timeout should occur at exactly 123ms',
        );
        expect(
          progressTimes.isNotEmpty,
          isTrue,
          reason: 'Should have received progress before timeout',
        );
      });
    });
  });
}
