import 'package:collection/collection.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/activation/base_strategies/activation_strategy_factory.dart';
import 'package:komodo_defi_types/types.dart';

/// Manages the activation lifecycle of assets
class ActivationManager {
  const ActivationManager(this._client);

  final ApiClient _client;

  /// Activates an asset and any required dependencies
  Stream<ActivationProgress> activateAsset(Asset asset) =>
      activateAssets([asset]);

  /// Activates multiple assets efficiently by batching where possible
  Stream<ActivationProgress> activateAssets(List<Asset> assets) async* {
    final groups = _AssetGroup._groupByPrimary(assets);

    print('Activating asset groups: $groups');

    for (final group in groups) {
      if (group.parent != null && !await _isAssetActive(group.parent!.id)) {
        yield* _activateWithChildren(
          group.parent!,
          group.children.values.toList(),
        );
      } else {
        for (final asset in group.assets) {
          if (!await _isAssetActive(asset.id)) {
            yield* _activateSingle(asset);
          }
        }
      }
    }
  }

  Future<bool> _isAssetActive(AssetId assetId) async {
    final enabledCoins = await _client.rpc.generalActivation.getEnabledCoins();
    return enabledCoins.result.any((coin) => coin.ticker == assetId.id);
  }

  Stream<ActivationProgress> _activateParentFirst(Asset asset) async* {
    final parentId =
        asset.id.parentId ?? (throw ArgumentError('Asset has no parent'));

    final parent = KomodoDefiSdk.global.assets.fromId(parentId) ??
        (throw ArgumentError('Parent asset not found: ${parentId.id}'));

    yield ActivationProgress(
      status: 'Activating parent asset ${parentId.id} first...',
    );

    yield* _activateWithChildren(parent, [asset]);
  }

  Stream<ActivationProgress> _activateWithChildren(
    Asset parent,
    List<Asset> children,
  ) async* {
    final strategy = ActivationStrategyFactory.createForAsset(
      parent,
      withBatchSupport: true,
    );

    yield* strategy.activate(_client, parent, children);
  }

  Stream<ActivationProgress> _activateSingle(Asset asset) async* {
    final strategy = ActivationStrategyFactory.createForAsset(asset);

    yield* strategy.activate(_client, asset);
  }
}

class _AssetGroup {
  _AssetGroup(this.assets)
      : assert(
          assets.every(
            (asset) =>
                // Asset is either a non-child asset (parent or standalone)
                !asset.id.isChildAsset ||
                // Or its parent is either another asset in the group or matches other children's parent
                asset.id.parentId == _findCommonParentId(assets),
          ),
          'All child assets in a group must have the same parent',
        );

  // Helper method to find the common parent ID
  static AssetId? _findCommonParentId(List<Asset> assets) {
    final childAssets = assets.where((a) => a.id.isChildAsset);
    if (childAssets.isEmpty) return null;

    final parentId = childAssets.first.id.parentId;
    // Verify all children have the same parent
    assert(childAssets.every((a) => a.id.parentId == parentId));
    return parentId;
  }

  final List<Asset> assets;

  AssetId? get _parentId =>
      assets.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

  AssetId get _primaryId => _parentId ?? assets.first.id;

  Map<AssetId, Asset> get children => Map.fromEntries(
        assets
            .where((asset) => asset.id.isChildAsset)
            .map((asset) => MapEntry(asset.id, asset)),
      );

  Asset? get parent => _parentId == null
      ? null
      : assets.firstWhereOrNull((asset) => asset.id == _parentId) ??
          KomodoDefiSdk.global.assets.fromId(_parentId!);

  Asset get primary => parent ?? assets.first;

  static List<_AssetGroup> _groupByPrimary(List<Asset> assets) {
    final groups = <String, List<Asset>>{};

    for (final asset in assets) {
      final primaryId = asset.id.parentId?.id ?? asset.id.id;
      groups.putIfAbsent(primaryId, () => []).add(asset);
    }

    return groups.values.map(_AssetGroup.new).toList();
  }

  @override
  String toString() => 'AssetGroup{primary: $primary, children: $children}';
}
