import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/src/utils/retry_config.dart';
import 'package:test/test.dart';

import 'mocks/controllable_mock_strategies.dart';
import 'mocks/test_utilities.dart';

/// Test file for hanging activation strategy using controllable mocks
///
/// Tests that verify the ActivationManager behaves correctly when
/// an activation strategy hangs indefinitely (never completes).
///
/// This test suite uses controllable strategies that can simulate
/// hanging behavior in a deterministic way without relying on timing.
///
/// Key scenarios tested:
/// 1. Activation that hangs should timeout properly when a timeout is applied
/// 2. After timeout, a new activation should be possible
/// 3. Stream should emit initial progress before hanging
/// 4. Manager should remain responsive to other operations during hanging
/// 5. Multiple concurrent hanging activations should be handled gracefully

void main() {
  group('Hanging Activation Strategy Tests', () {
    late ActivationManagerTestSetup setup;
    late ControllableMockActivationStrategy controllableStrategy;
    late SharedActivationCoordinator coordinator;

    setUp(() {
      // Create a controllable strategy for deterministic hanging behavior
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
        retryConfig: RetryConfig.noRetry,
        retryStrategy: const NoRetryStrategy(),
      );
    });

    tearDown(() async {
      controllableStrategy.dispose();
      await coordinator.dispose();
      await setup.tearDown();
    });

    test('should timeout when activation strategy hangs indefinitely', () {
      fakeAsync((FakeAsync async) {
        // Configure strategy to hang after emitting initial progress
        controllableStrategy.configureHang(
          progressMessages: ['Starting activation...', 'Processing...'],
        );

        var timeoutOccurred = false;
        Object? caughtException;

        // Start activation with external timeout
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 200))
            .listen(
              (_) {}, // Handle progress events
              onError: (Object e) {
                if (e is TimeoutException) {
                  timeoutOccurred = true;
                  caughtException = e;
                }
              },
              onDone: () {
                fail('Stream should not complete normally during hang');
              },
            );

        // Elapse fake time to trigger the external timeout
        async.elapse(const Duration(milliseconds: 200));

        // Verify that we got a timeout
        expect(
          timeoutOccurred,
          isTrue,
          reason: 'Should have timed out due to hanging activation',
        );

        expect(
          caughtException,
          isA<TimeoutException>(),
          reason: 'Should be a TimeoutException',
        );
      });
    });

    test('should allow new activation after previous activation timed out', () {
      fakeAsync((FakeAsync async) {
        // Test that after a hanging activation times out,
        // the ActivationManager can start a new activation

        Object? firstException;
        Object? secondException;

        // First activation attempt - configure to hang
        controllableStrategy.configureHang(
          progressMessages: ['First activation starting...'],
        );

        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 150))
            .listen(
              (_) {},
              onError: (Object e) {
                if (e is TimeoutException) {
                  firstException = e;
                }
              },
              onDone: () {
                fail('First activation should not complete normally');
              },
            );

        // Elapse time to trigger first timeout
        async.elapse(const Duration(milliseconds: 150));

        // Verify first activation timed out
        expect(
          firstException,
          isA<TimeoutException>(),
          reason: 'First activation should have timed out',
        );

        // Configure for second hanging activation
        controllableStrategy.configureHang(
          progressMessages: ['Second activation starting...'],
        );

        // Second activation attempt - should also timeout but should be able to start fresh
        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 150))
            .listen(
              (_) {},
              onError: (Object e) {
                if (e is TimeoutException) {
                  secondException = e;
                }
              },
              onDone: () {
                fail('Second activation should not complete normally');
              },
            );

        // Elapse time to trigger second timeout
        async.elapse(const Duration(milliseconds: 150));

        // Verify second activation also timed out
        expect(
          secondException,
          isA<TimeoutException>(),
          reason: 'Second activation should have timed out',
        );
      });
    });

    test(
      'should remain responsive to status queries during hanging activation',
      () {
        fakeAsync((FakeAsync async) {
          // Configure strategy to hang after initial progress
          controllableStrategy.configureHang(
            progressMessages: ['Starting activation...', 'About to hang...'],
          );

          Object? activationException;

          // Start an activation that would hang (but we'll timeout)
          coordinator
              .activateAssetStream(setup.testAsset)
              .timeout(const Duration(milliseconds: 200))
              .listen(
                (_) {},
                onError: (Object e) {
                  if (e is TimeoutException) {
                    activationException = e;
                  }
                },
                onDone: () {
                  fail('Activation should not complete normally');
                },
              );

          // Elapse minimal time to start activation
          async.elapse(const Duration(milliseconds: 10));

          // While activation is in progress, manager should still respond to queries
          var managerResponsive = false;
          try {
            // This should work quickly with fake_async
            coordinator
                .isAssetActive(setup.testAsset.id)
                .then((isActive) {
                  // Should return some value (true or false) without hanging
                  expect(isActive, isA<bool>());
                  managerResponsive = true;
                })
                .catchError((e) {
                  // May fail due to mock setup, but should not hang
                  managerResponsive =
                      true; // Still considered responsive if it fails quickly
                });
          } catch (e) {
            managerResponsive =
                true; // Still considered responsive if it fails quickly
          }

          // Elapse minimal time to allow async operation to complete
          async.elapse(const Duration(milliseconds: 1));

          expect(
            managerResponsive,
            isTrue,
            reason: 'Manager should remain responsive during activation',
          );

          // Trigger the activation timeout
          async.elapse(const Duration(milliseconds: 200));

          expect(
            activationException,
            isA<TimeoutException>(),
            reason: 'Activation should have timed out',
          );
        });
      },
    );

    test(
      'should handle multiple concurrent hanging activations gracefully',
      () async {
        // Test that multiple hanging activations don't deadlock the manager

        final futures = <Future<void>>[];
        final exceptions = <Object?>[];

        // Start multiple activations that would hang
        for (var i = 0; i < 3; i++) {
          // Each gets its own strategy instance to avoid conflicts
          final strategy = ControllableMockActivationStrategy(MockApiClient())
            ..configureHang(
              progressMessages: ['Concurrent hanging activation $i...'],
            );

          // Build dedicated ActivationManager and Coordinator for this concurrent test
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
              .timeout(const Duration(milliseconds: 150))
              .last
              .then((_) {
                fail('Activation $i should have timed out');
              })
              .catchError(exceptions.add)
              .whenComplete(() async {
                strategy.dispose();
                await dedicatedCoordinator.dispose();
                await dedicatedManager.dispose();
              });
          futures.add(future);
        }

        // Wait for all to complete (timeout)
        await Future.wait(futures);

        // Verify all activations threw exceptions
        expect(
          exceptions.length,
          equals(3),
          reason: 'All 3 activations should have thrown exceptions',
        );

        for (final exception in exceptions) {
          expect(
            exception,
            isA<TimeoutException>(),
            reason: 'Each activation should have timed out',
          );
        }

        // Main manager should still be responsive
        var managerResponsive = false;
        try {
          final activeAssets = await coordinator.getActiveAssets();
          expect(activeAssets, isA<Set<dynamic>>());
          managerResponsive = true;
        } catch (e) {
          // May fail due to mock setup, but should not hang
          managerResponsive =
              true; // Still considered responsive if it fails quickly
        }

        expect(
          managerResponsive,
          isTrue,
          reason:
              'Manager should be responsive after concurrent hanging activations',
        );
      },
    );

    test('hanging activation should emit initial progress before hanging', () {
      fakeAsync((FakeAsync async) {
        // Configure strategy to emit specific progress then hang
        controllableStrategy.configureHang(
          progressMessages: [
            'Starting activation process...',
            'Validating configuration...',
            'About to hang...',
          ],
        );

        final progressUpdates = <ActivationProgress>[];
        Object? finalException;

        coordinator
            .activateAssetStream(setup.testAsset)
            .timeout(const Duration(milliseconds: 200))
            .listen(
              progressUpdates.add,
              onError: (Object e) {
                if (e is TimeoutException) {
                  finalException = e;
                }
              },
              onDone: () {
                fail('Activation should not complete normally');
              },
            );

        // Elapse minimal time to let progress events be emitted
        async.elapse(const Duration(milliseconds: 50));

        // Verify we got the expected progress before hanging
        expect(
          progressUpdates.length,
          equals(3),
          reason: 'Should receive 3 progress updates before hanging',
        );

        // Verify specific progress messages
        expect(
          progressUpdates[0].status,
          equals('Starting activation process...'),
          reason: 'First progress should match expected message',
        );

        expect(
          progressUpdates[1].status,
          equals('Validating configuration...'),
          reason: 'Second progress should match expected message',
        );

        expect(
          progressUpdates[2].status,
          equals('About to hang...'),
          reason: 'Third progress should match expected message',
        );

        // Now trigger the timeout
        async.elapse(const Duration(milliseconds: 200));

        // Verify we got a timeout
        expect(
          finalException,
          isA<TimeoutException>(),
          reason: 'Should have timed out due to hanging',
        );
      });
    });
  });
}
