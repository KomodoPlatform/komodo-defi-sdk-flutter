import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class AssetActivator {
  const AssetActivator(this.client);

  final ApiClient client;

  Stream<ActivationProgress> activate(Asset asset, [List<Asset>? children]);
  bool canHandle(Asset asset);
}

/// Base for strategies that support batch operations
abstract class BatchCapableActivator extends AssetActivator {
  const BatchCapableActivator(super.client);

  bool get supportsBatchActivation;

  /// Whether the activator supports activation of custom EVM-chain
  /// tokens that are not part of the live coins configuration.
  /// Defaults to false.
  bool get supportsCustomTokenActivation => false;
}

/// Smart activator that chooses between batch/single methods
class SmartAssetActivator extends BatchCapableActivator {
  SmartAssetActivator(super.client, this._activator);

  final CompositeAssetActivator _activator;

  @override
  bool get supportsBatchActivation => true;

  @override
  bool canHandle(Asset asset) => _activator.canHandle(asset);

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    // Check if parent is already activated
    final parentActivated = await _isAssetActive(asset);
    final hasChildren = children?.isNotEmpty ?? false;

    yield ActivationProgress(
      status: 'Planning activation strategy...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'planning',
        stepCount: 1,
        additionalInfo: {
          'parentActivated': parentActivated,
          'hasChildren': hasChildren,
          'supportsBatch': _supportsBatchActivation(asset),
        },
      ),
    );

    if (!parentActivated && hasChildren && _supportsBatchActivation(asset)) {
      // Parent not active + has children = use batch activation
      yield* _activator.activate(asset, children);
    } else if (!parentActivated) {
      // Parent not active, no children = activate parent only
      yield* _activator.activate(asset);
    } else if (hasChildren) {
      // Parent active + has children = activate children individually
      for (final child in children!) {
        if (!await _isAssetActive(child)) {
          yield* _activator.activate(child);
        }
      }
    } else {
      // Single asset activation
      yield* _activator.activate(asset);
    }
  }

  Future<bool> _isAssetActive(Asset asset) async {
    final enabledCoins = await client.rpc.generalActivation.getEnabledCoins();
    return enabledCoins.result.any((coin) => coin.ticker == asset.id.id);
  }

  bool _supportsBatchActivation(Asset asset) {
    return asset.protocol.supportedProtocols.isNotEmpty;
  }
}

/// Composite activator that chains multiple activation strategies
class CompositeAssetActivator extends BatchCapableActivator {
  CompositeAssetActivator(
    super.client,
    List<ProtocolActivationStrategy> strategies,
  ) : _strategies = strategies;

  final List<ProtocolActivationStrategy> _strategies;

  @override
  bool get supportsBatchActivation => true;

  ProtocolActivationStrategy _findStrategy(Asset asset) {
    final strategy = _strategies.firstWhere(
      (s) => s.canHandle(asset),
      orElse: () => throw UnsupportedError(
        'No activation strategy found for ${asset.id}',
      ),
    );
    return strategy;
  }

  @override
  bool canHandle(Asset asset) => _strategies.any((s) => s.canHandle(asset));

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    yield ActivationProgress(
      status: 'Finding appropriate activation strategy...',
      progressDetails: ActivationProgressDetails(
        currentStep: 'strategy_selection',
        stepCount: 1,
        additionalInfo: {'assetId': asset.id.id},
      ),
    );

    final strategy = _findStrategy(asset);
    yield* strategy.activate(asset, children);
  }
}

/// Base class for protocol-specific activation implementations
abstract class ProtocolActivationStrategy extends BatchCapableActivator {
  const ProtocolActivationStrategy(super.client);

  @override
  bool canHandle(Asset asset) =>
      // | isCustomToken | supportsCustomTokenActivation | result |
      // |---------------|------------------------------|--------|
      // | true          | true                         | true   |
      // | true          | false                        | false  |
      // | false         | true                         | true   |
      // | false         | false                        | false  |
      (!asset.protocol.isCustomToken || supportsCustomTokenActivation) &&
      supportedProtocols.contains(asset.protocol.subClass);

  Set<CoinSubClass> get supportedProtocols;
}
