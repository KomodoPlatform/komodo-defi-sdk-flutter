import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Command types for controlling mock activation strategies.
abstract class _MockCommand {}

class _EmitProgressCommand extends _MockCommand {
  final ActivationProgress progress;
  _EmitProgressCommand(this.progress);
}

class _CompleteSuccessCommand extends _MockCommand {
  final ActivationProgress? finalProgress;
  _CompleteSuccessCommand([this.finalProgress]);
}

class _CompleteErrorCommand extends _MockCommand {
  final Object error;
  final StackTrace? stackTrace;
  _CompleteErrorCommand(this.error, [this.stackTrace]);
}

class _DelayCommand extends _MockCommand {
  final Duration duration;
  _DelayCommand(this.duration);
}

class _HangCommand extends _MockCommand {
  final Duration? hangDuration;
  _HangCommand([this.hangDuration]);
}

/// A controllable mock activation strategy that allows tests to precisely control
/// when progress is emitted, when completion occurs, and when errors are thrown.
///
/// This strategy eliminates timing-based issues in tests by providing
/// deterministic control over the activation process.
///
/// Example usage:
/// ```dart
/// final strategy = ControllableMockActivationStrategy();
///
/// // Queue up the activation sequence
/// strategy.emitProgress(ActivationProgress(status: 'Starting...'));
/// strategy.emitProgress(ActivationProgress(status: 'Processing...'));
/// strategy.completeSuccess();
///
/// // Now run the activation - it will follow the queued sequence
/// final results = await strategy.activate(testAsset).toList();
/// ```
class ControllableMockActivationStrategy extends ProtocolActivationStrategy {
  ControllableMockActivationStrategy(super.client);

  final _commandQueue = <_MockCommand>[];
  final _commandController = StreamController<_MockCommand>();
  bool _isProcessing = false;

  @override
  Set<CoinSubClass> get supportedProtocols => CoinSubClass.values.toSet();

  @override
  bool get supportsBatchActivation => true;

  /// Queue a progress emission.
  void emitProgress(ActivationProgress progress) {
    _commandQueue.add(_EmitProgressCommand(progress));
    // Don't auto-process during configuration - let activate() handle processing
  }

  /// Queue a successful completion.
  void completeSuccess([ActivationProgress? finalProgress]) {
    final progress = finalProgress ?? ActivationProgress.success();
    _commandQueue.add(_CompleteSuccessCommand(progress));
    // Don't auto-process during configuration - let activate() handle processing
  }

  /// Queue an error completion.
  void completeError(Object error, [StackTrace? stackTrace]) {
    _commandQueue.add(_CompleteErrorCommand(error, stackTrace));
    // Don't auto-process during configuration - let activate() handle processing
  }

  /// Queue a delay (useful for testing timing scenarios).
  void addDelay(Duration duration) {
    _commandQueue.add(_DelayCommand(duration));
    // Don't auto-process during configuration - let activate() handle processing
  }

  /// Queue a hang operation (will hang until timeout or manual completion).
  void hang([Duration? hangDuration]) {
    _commandQueue.add(_HangCommand(hangDuration));
    // Don't auto-process during configuration - let activate() handle processing
  }

  /// Clear all queued commands.
  void clearQueue() {
    _commandQueue.clear();
  }

  /// Get the number of queued commands.
  int get queueLength => _commandQueue.length;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    _isProcessing = true;

    try {
      // Process all queued commands in sequence
      while (_commandQueue.isNotEmpty) {
        final command = _commandQueue.removeAt(0);

        if (command is _EmitProgressCommand) {
          yield command.progress;
        } else if (command is _CompleteSuccessCommand) {
          if (command.finalProgress != null) {
            yield command.finalProgress!;
          }
          return; // End the stream
        } else if (command is _CompleteErrorCommand) {
          throw command.error;
        } else if (command is _DelayCommand) {
          await Future<void>.delayed(command.duration);
        } else if (command is _HangCommand) {
          if (command.hangDuration != null) {
            // Hang for specified duration then timeout
            await Future<void>.delayed(command.hangDuration!);
            throw TimeoutException(
              'Activation timed out after ${command.hangDuration}',
              command.hangDuration,
            );
          } else {
            // Hang using multiple short delays to allow timeout interruption
            // This approach is more easily cancelled by external timeouts
            for (int i = 0; i < 100000; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            }
            // This should never be reached due to external timeouts
            throw TimeoutException(
              'Activation timed out after hanging',
              const Duration(seconds: 10000),
            );
          }
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Dispose of resources.
  void dispose() {
    _commandController.close();
    _commandQueue.clear();
  }
}

/// A predictable failing strategy that fails in a deterministic way
/// without relying on timing.
class PredictableFailingStrategy extends ProtocolActivationStrategy {
  PredictableFailingStrategy(
    super.client, {
    this.progressSteps = const [],
    this.errorMessage = 'Simulated activation failure',
    this.failAfterProgress = true,
  });

  /// Progress steps to emit before failing.
  final List<ActivationProgress> progressSteps;

  /// Error message to use when failing.
  final String errorMessage;

  /// Whether to fail after emitting progress or immediately.
  final bool failAfterProgress;

  @override
  Set<CoinSubClass> get supportedProtocols => CoinSubClass.values.toSet();

  @override
  bool get supportsBatchActivation => true;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    if (!failAfterProgress) {
      throw Exception(errorMessage);
    }

    // Emit configured progress steps
    for (final progress in progressSteps) {
      yield progress;
    }

    // Then fail
    throw Exception(errorMessage);
  }
}

/// A configurable hanging strategy that hangs for a specific duration
/// or until manually completed.
class ConfigurableHangingStrategy extends ProtocolActivationStrategy {
  ConfigurableHangingStrategy(
    super.client, {
    this.progressSteps = const [],
    this.hangDuration,
    this.timeoutAfterHang = true,
  });

  /// Progress steps to emit before hanging.
  final List<ActivationProgress> progressSteps;

  /// Duration to hang before timing out (null = hang indefinitely).
  final Duration? hangDuration;

  /// Whether to throw TimeoutException after hang duration.
  final bool timeoutAfterHang;

  @override
  Set<CoinSubClass> get supportedProtocols => CoinSubClass.values.toSet();

  @override
  bool get supportsBatchActivation => true;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    // Emit configured progress steps
    for (final progress in progressSteps) {
      yield progress;
    }

    // Now hang
    if (hangDuration != null) {
      if (timeoutAfterHang) {
        // Wait for hang duration then throw timeout
        await Future<void>.delayed(hangDuration!);
        throw TimeoutException(
          'Activation timed out after ${hangDuration}',
          hangDuration,
        );
      } else {
        // Wait for hang duration then complete successfully
        await Future<void>.delayed(hangDuration!);
        yield ActivationProgress.success();
      }
    } else {
      // Hang indefinitely
      final completer = Completer<void>();
      await completer.future; // Never completes
    }
  }
}

/// A step-by-step strategy that emits progress in a controlled sequence.
class StepByStepStrategy extends ProtocolActivationStrategy {
  StepByStepStrategy(
    super.client, {
    required this.steps,
    this.stepDelay = Duration.zero,
  });

  /// Steps to execute in sequence.
  final List<ActivationProgress> steps;

  /// Delay between steps (useful for testing timing).
  final Duration stepDelay;

  @override
  Set<CoinSubClass> get supportedProtocols => CoinSubClass.values.toSet();

  @override
  bool get supportsBatchActivation => true;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    for (final step in steps) {
      if (stepDelay > Duration.zero) {
        await Future<void>.delayed(stepDelay);
      }
      yield step;
    }
  }
}

/// Convenience methods for creating common test scenarios.
extension TestScenarios on ControllableMockActivationStrategy {
  /// Configure a simple success scenario.
  void configureSuccess({
    List<String> progressMessages = const ['Starting...', 'Processing...'],
  }) {
    clearQueue();
    for (final message in progressMessages) {
      emitProgress(ActivationProgress(status: message));
    }
    completeSuccess();
  }

  /// Configure a simple failure scenario.
  void configureFailure({
    List<String> progressMessages = const ['Starting...', 'Processing...'],
    String errorMessage = 'Simulated activation failure',
  }) {
    clearQueue();
    for (final message in progressMessages) {
      emitProgress(ActivationProgress(status: message));
    }
    completeError(Exception(errorMessage));
  }

  /// Configure a hanging scenario.
  void configureHang({
    List<String> progressMessages = const ['Starting...', 'Processing...'],
    Duration? hangDuration,
  }) {
    clearQueue();
    for (final message in progressMessages) {
      emitProgress(ActivationProgress(status: message));
    }
    hang(hangDuration);
  }

  /// Configure a timeout scenario.
  void configureTimeout({
    List<String> progressMessages = const ['Starting...', 'Processing...'],
    Duration timeoutAfter = const Duration(milliseconds: 100),
  }) {
    clearQueue();
    for (final message in progressMessages) {
      emitProgress(ActivationProgress(status: message));
    }
    addDelay(timeoutAfter);
    completeError(TimeoutException('Activation timed out', timeoutAfter));
  }
}
