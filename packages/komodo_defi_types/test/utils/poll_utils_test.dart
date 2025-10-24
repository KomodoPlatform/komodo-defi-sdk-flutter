import 'dart:async';

import 'package:komodo_defi_types/src/utils/backoff_strategy.dart';
import 'package:komodo_defi_types/src/utils/poll_utils.dart';
import 'package:test/test.dart';

class _RecoverableError implements Exception {
  _RecoverableError(this.message);
  final String message;
  @override
  String toString() => 'RecoverableError: $message';
}

class _FatalError implements Exception {
  _FatalError(this.message);
  final String message;
  @override
  String toString() => 'FatalError: $message';
}

void main() {
  group('poll function', () {
    test('returns immediately when isComplete is true on first result', () async {
      var callCount = 0;
      var onPollCalls = 0;

      final result = await poll<int>(
        () async {
          callCount++;
          return 42;
        },
        isComplete: (value) => true,
        maxDuration: const Duration(milliseconds: 200),
        onPoll: (_, __) => onPollCalls++,
      );

      expect(result, equals(42));
      expect(callCount, equals(1));
      expect(onPollCalls, equals(0));
    });

    test('retries until isComplete becomes true (using constant backoff)', () async {
      var callCount = 0;
      final attempts = <int>[];
      final delays = <Duration>[];

      final result = await poll<int>(
        () async => ++callCount,
        isComplete: (value) => value >= 3,
        maxDuration: const Duration(seconds: 2),
        backoffStrategy: const ConstantBackoff(delay: Duration(milliseconds: 10)),
        onPoll: (attempt, delay) {
          attempts.add(attempt);
          delays.add(delay);
        },
      );

      expect(result, equals(3));
      expect(callCount, equals(3));
      // onPoll is called only for iterations that will continue (before the next attempt)
      expect(attempts, equals([0, 1]));
      expect(delays, everyElement(equals(const Duration(milliseconds: 10))));
    });

    test('continues on recoverable errors and eventually completes', () async {
      var callCount = 0;
      final attempts = <int>[];
      final delays = <Duration>[];

      final result = await poll<String>(
        () async {
          callCount++;
          if (callCount <= 2) {
            throw _RecoverableError('temporary');
          }
          return 'ok';
        },
        isComplete: (value) => value == 'ok',
        maxDuration: const Duration(seconds: 2),
        backoffStrategy: const ConstantBackoff(delay: Duration(milliseconds: 10)),
        shouldContinueOnError: (e) => e is _RecoverableError,
        onPoll: (attempt, delay) {
          attempts.add(attempt);
          delays.add(delay);
        },
      );

      expect(result, equals('ok'));
      expect(callCount, equals(3));
      // Two recoverable errors => two onPoll calls for attempts 0 and 1
      expect(attempts, equals([0, 1]));
      expect(delays, everyElement(equals(const Duration(milliseconds: 10))));
    });

    test('propagates non-recoverable error without retry', () async {
      var callCount = 0;
      var onPollCalls = 0;

      expect(
        () => poll<void>(
          () async {
            callCount++;
            throw _FatalError('boom');
          },
          isComplete: (_) => false,
          maxDuration: const Duration(seconds: 1),
          shouldContinueOnError: (e) => e is _RecoverableError,
          onPoll: (_, __) => onPollCalls++,
        ),
        throwsA(isA<_FatalError>()),
      );

      expect(callCount, equals(1));
      expect(onPollCalls, equals(0));
    });

    test('times out when never complete even if calls are quick', () async {
      final stopwatch = Stopwatch()..start();
      const max = Duration(milliseconds: 150);

      await expectLater(
        poll<int>(
          () async => 1,
          isComplete: (_) => false,
          maxDuration: max,
          backoffStrategy: const ConstantBackoff(delay: Duration(milliseconds: 30)),
        ),
        throwsA(isA<TimeoutException>()),
      );

      stopwatch.stop();
      // Ensure overall time budget was respected (allow some overhead)
      expect(stopwatch.elapsed, lessThanOrEqualTo(max + const Duration(milliseconds: 250)));
    });

    test('per-call timeout: hung function throws TimeoutException within maxDuration and does not invoke shouldContinueOnError', () async {
      var continueOnErrorCalls = 0;
      final stopwatch = Stopwatch()..start();
      const max = Duration(milliseconds: 200);

      await expectLater(
        poll<int>(
          () async {
            // Simulate a future that never completes
            return Completer<int>().future;
          },
          isComplete: (_) => false,
          maxDuration: max,
          shouldContinueOnError: (e) {
            continueOnErrorCalls++;
            return true;
          },
        ),
        throwsA(isA<TimeoutException>()),
      );

      stopwatch.stop();
      expect(continueOnErrorCalls, equals(0));
      expect(stopwatch.elapsed, lessThanOrEqualTo(max + const Duration(milliseconds: 250)));
    });

    test('onPoll receives correct attempt indexes and delays for exponential backoff', () async {
      var callCount = 0;
      final attempts = <int>[];
      final delays = <Duration>[];

      final result = await poll<int>(
        () async => ++callCount,
        isComplete: (value) => value >= 3,
        maxDuration: const Duration(seconds: 2),
        backoffStrategy: ExponentialBackoff(
          initialDelay: const Duration(milliseconds: 10),
          maxDelay: const Duration(milliseconds: 100),
          withJitter: false,
        ),
        onPoll: (attempt, delay) {
          attempts.add(attempt);
          delays.add(delay);
        },
      );

      expect(result, equals(3));
      expect(attempts, equals([0, 1]));
      expect(
        delays,
        equals([
          const Duration(milliseconds: 10),
          const Duration(milliseconds: 20),
        ]),
      );
    });

    test('errors thrown by isComplete can be continued via shouldContinueOnError', () async {
      var callCount = 0;
      var checkCount = 0;
      final attempts = <int>[];

      final result = await poll<int>(
        () async => ++callCount,
        isComplete: (value) {
          checkCount++;
          if (checkCount == 1) {
            throw _RecoverableError('from isComplete');
          }
          return value >= 2;
        },
        maxDuration: const Duration(seconds: 2),
        backoffStrategy: const ConstantBackoff(delay: Duration(milliseconds: 10)),
        shouldContinueOnError: (e) => e is _RecoverableError,
        onPoll: (attempt, _) => attempts.add(attempt),
      );

      expect(result, equals(2));
      expect(callCount, equals(2));
      // One continuation due to isComplete error => one onPoll call for attempt 0
      expect(attempts, equals([0]));
    });

    test('delay is effectively capped by remaining time budget', () async {
      // Use a very large backoff delay compared to the budget and ensure
      // overall elapsed time is bounded by the maxDuration (i.e., delay is capped).
      final stopwatch = Stopwatch()..start();
      const budget = Duration(milliseconds: 120);

      await expectLater(
        poll<int>(
          () async => 1,
          isComplete: (_) => false,
          maxDuration: budget,
          backoffStrategy: const LinearBackoff(
            initialDelay: Duration(seconds: 1),
            increment: Duration(seconds: 1),
            maxDelay: Duration(seconds: 5),
          ),
        ),
        throwsA(isA<TimeoutException>()),
      );

      stopwatch.stop();
      // Must be well under the 1 second initial delay and close to the budget.
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 600)));
      expect(stopwatch.elapsed, lessThanOrEqualTo(budget + const Duration(milliseconds: 250)));
    });
  });
}


