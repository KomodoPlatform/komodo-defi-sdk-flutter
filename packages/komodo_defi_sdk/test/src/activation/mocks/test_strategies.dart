import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    show PrivateKeyPolicy;
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Factory that creates test strategies for different test scenarios
class TestActivationStrategyFactory implements IActivationStrategyFactory {
  const TestActivationStrategyFactory(this.testStrategy);

  final ProtocolActivationStrategy testStrategy;

  @override
  SmartAssetActivator createStrategy(
    ApiClient client,
    PrivateKeyPolicy privKeyPolicy,
  ) {
    return SmartAssetActivator(
      client,
      CompositeAssetActivator(client, [testStrategy]),
    );
  }
}

/// Direct test strategy factory that bypasses SmartAssetActivator extra progress messages
/// This factory creates a minimal wrapper that directly delegates to the test strategy
/// without adding the extra progress messages that SmartAssetActivator and CompositeAssetActivator add
class DirectTestActivationStrategyFactory
    implements IActivationStrategyFactory {
  const DirectTestActivationStrategyFactory(this.testStrategy);

  final ProtocolActivationStrategy testStrategy;

  @override
  SmartAssetActivator createStrategy(
    ApiClient client,
    PrivateKeyPolicy privKeyPolicy,
  ) {
    return _DirectTestAssetActivator(client, testStrategy);
  }
}

/// Minimal asset activator that directly delegates to the test strategy
/// without adding extra progress messages
class _DirectTestAssetActivator extends SmartAssetActivator {
  _DirectTestAssetActivator(ApiClient client, this._testStrategy)
    : super(client, CompositeAssetActivator(client, []));

  final ProtocolActivationStrategy _testStrategy;

  @override
  bool canHandle(Asset asset) => _testStrategy.canHandle(asset);

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    // Directly delegate to the test strategy without adding extra progress messages
    yield* _testStrategy.activate(asset, children);
  }
}

/// Test strategy that hangs indefinitely by emitting initial progress
/// then triggers a timeout. This strategy:
/// 1. Emits initial progress to show activation started
/// 2. Emits a second progress update to show "work" is happening
/// 3. Creates a future that hangs for a very long time
/// 4. Relies on external timeout mechanisms to stop the stream
///
/// This simulates real-world scenarios where an activation process
/// starts successfully but then hangs due to network issues,
/// unresponsive servers, or other blocking operations.
class HangingMockActivationStrategy extends ProtocolActivationStrategy {
  const HangingMockActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.utxo};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    // Emit initial progress to show activation started
    yield const ActivationProgress(
      status: 'Starting activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 3,
      ),
    );

    // Small delay to simulate initial work
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Emit a second progress to show we're "working"
    yield const ActivationProgress(
      status: 'Processing activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'processing',
        stepCount: 3,
      ),
    );

    // Create a future that will hang for a very long time
    // This allows timeout mechanisms to kick in properly
    await Future<void>.delayed(const Duration(hours: 1));

    // This line should never be reached due to timeouts
    yield ActivationProgress.success();
  }
}

/// Test strategy that emits progress then throws an exception
class FailingMockActivationStrategy extends ProtocolActivationStrategy {
  const FailingMockActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.utxo};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    // Emit some progress
    yield const ActivationProgress(
      status: 'Starting activation...',
      progressPercentage: 10,
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 3,
      ),
    );

    // Simulate some processing time
    await Future<void>.delayed(const Duration(milliseconds: 10));

    yield const ActivationProgress(
      status: 'Processing...',
      progressPercentage: 50,
      progressDetails: ActivationProgressDetails(
        currentStep: 'processing',
        stepCount: 3,
      ),
    );

    // Simulate more processing time
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Throw an exception instead of emitting error progress
    throw Exception('Simulated activation failure');
  }
}

/// Test strategy that throws an exception immediately
class ExceptionThrowingMockActivationStrategy
    extends ProtocolActivationStrategy {
  const ExceptionThrowingMockActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.utxo};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    // Emit initial progress
    yield const ActivationProgress(
      status: 'Starting activation...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 1,
      ),
    );

    // Throw an exception immediately for predictable behavior
    throw StateError('Simulated exception during activation');
  }
}

/// Test strategy that succeeds normally
class SuccessfulMockActivationStrategy extends ProtocolActivationStrategy {
  const SuccessfulMockActivationStrategy(super.client);

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.utxo};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    yield const ActivationProgress(
      status: 'Starting activation...',
      progressPercentage: 25,
      progressDetails: ActivationProgressDetails(
        currentStep: 'initialization',
        stepCount: 4,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    yield const ActivationProgress(
      status: 'Configuring...',
      progressPercentage: 50,
      progressDetails: ActivationProgressDetails(
        currentStep: 'configuration',
        stepCount: 4,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    yield const ActivationProgress(
      status: 'Finalizing...',
      progressPercentage: 75,
      progressDetails: ActivationProgressDetails(
        currentStep: 'finalization',
        stepCount: 4,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    yield ActivationProgress.success(
      details: ActivationProgressDetails(
        currentStep: 'complete',
        stepCount: 4,
        additionalInfo: {
          'activatedChain': asset.id.name,
          'activationTime': DateTime.now().toIso8601String(),
        },
      ),
    );
  }
}

/// Test strategy that succeeds after a delay
class DelayedSuccessfulMockActivationStrategy
    extends ProtocolActivationStrategy {
  final Duration delay;

  const DelayedSuccessfulMockActivationStrategy(
    super.client, {
    this.delay = const Duration(milliseconds: 200),
  });

  @override
  Set<CoinSubClass> get supportedProtocols => {CoinSubClass.utxo};

  @override
  bool get supportsBatchActivation => false;

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    yield const ActivationProgress(
      status: 'Starting delayed activation...',
      progressPercentage: 0,
      progressDetails: ActivationProgressDetails(
        currentStep: 'waiting',
        stepCount: 2,
      ),
    );

    // Wait for the specified delay
    await Future<void>.delayed(delay);

    yield ActivationProgress.success(
      details: ActivationProgressDetails(
        currentStep: 'complete',
        stepCount: 2,
        additionalInfo: {
          'activatedChain': asset.id.name,
          'delayDuration': delay.inMilliseconds.toString(),
        },
      ),
    );
  }
}
