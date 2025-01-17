import 'dart:async';

import 'package:collection/collection.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manages the activation lifecycle of assets

/// Manages the activation lifecycle of assets
class ActivationManager {
  ActivationManager(ApiClient client)
      : _activator = ActivationStrategyFactory.createStrategy(client);

  final SmartAssetActivator _activator;
  final Map<AssetId, Completer<void>> _activationCompleters = {};
  final Set<AssetId> _activeAssetIds = {};

  Stream<ActivationProgress> activateAsset(Asset asset) =>
      activateAssets([asset]);

  Stream<ActivationProgress> activateAssets(List<Asset> assets) async* {
    final groups = _AssetGroup._groupByPrimary(assets);

    for (final group in groups) {
      final primaryCompleter = _activationCompleters.putIfAbsent(
        group.primary.id,
        Completer<void>.new,
      );

      final parentAsset = group.parentId != null
          ? KomodoDefiSdk.global.assets.fromId(group.parentId!)
          : null;

      yield ActivationProgress(
        status: 'Starting activation for ${group.primary.id.name}...',
        progressDetails: ActivationProgressDetails(
          currentStep: 'group_start',
          stepCount: 1,
          additionalInfo: {
            'primaryAsset': group.primary.id.name,
            'childCount': group.children?.length ?? 0,
          },
        ),
      );

      try {
        await for (final progress in _activator.activate(
          parentAsset ?? group.primary,
          group.children?.toList(),
        )) {
          yield progress;

          if (progress.isComplete) {
            if (progress.isSuccess) {
              _activeAssetIds.add(group.primary.id);
              if (group.children != null) {
                _activeAssetIds.addAll(group.children!.map((c) => c.id));
              }

              if (!primaryCompleter.isCompleted) {
                primaryCompleter.complete();
              }
            } else {
              if (!primaryCompleter.isCompleted) {
                primaryCompleter.completeError(
                  progress.errorMessage ?? 'Unknown error',
                );
              }
            }
          }
        }
      } catch (e) {
        if (!primaryCompleter.isCompleted) {
          primaryCompleter.completeError(e);
        }
        rethrow;
      } finally {
        _activationCompleters.remove(group.primary.id);
      }
    }
  }

  // bool isAssetActive(AssetId assetId) => _activeAssetIds.contains(assetId);

  void dispose() {
    _activationCompleters.clear();
  }
}

/// Helper class for grouping assets by their primary/parent
class _AssetGroup {
  _AssetGroup({
    required this.primary,
    this.children,
  }) : assert(
          children == null || children.every((asset) => asset.id == primary.id),
          'All child assets in a group must have the same parent',
        );

  final Asset primary;
  final Set<Asset>? children;

  AssetId? get parentId =>
      children?.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

  static List<_AssetGroup> _groupByPrimary(List<Asset> assets) {
    final groups = <AssetId, _AssetGroup>{};

    for (final asset in assets) {
      if (asset.id.parentId != null) {
        // Child asset
        final group = groups.putIfAbsent(
          asset.id.parentId!,
          () => _AssetGroup(
            primary: asset,
            children: {},
          ),
        );
        group.children?.add(asset);
      } else {
        // Primary asset
        groups.putIfAbsent(
          asset.id,
          () => _AssetGroup(primary: asset),
        );
      }
    }

    return groups.values.toList();
  }
}

// class _AssetGroup {
//   _AssetGroup(this.assets)
//       : assert(
//           assets.every(
//             (asset) =>
//                 // Asset is either a non-child asset (parent or standalone)
//                 !asset.id.isChildAsset ||
//                 // Or its parent is either another asset in the group or matches other children's parent
//                 asset.id.parentId == _findCommonParentId(assets),
//           ),
//           'All child assets in a group must have the same parent',
//         );

//   // Helper method to find the common parent ID
//   static AssetId? _findCommonParentId(List<Asset> assets) {
//     final childAssets = assets.where((a) => a.id.isChildAsset);
//     if (childAssets.isEmpty) return null;

//     final parentId = childAssets.first.id.parentId;
//     // Verify all children have the same parent
//     assert(childAssets.every((a) => a.id.parentId == parentId));
//     return parentId;
//   }

//   final List<Asset> assets;

//   AssetId? get _parentId =>
//       assets.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

//   AssetId get _primaryId => _parentId ?? assets.first.id;

//   Map<AssetId, Asset> get children => Map.fromEntries(
//         assets
//             .where((asset) => asset.id.isChildAsset)
//             .map((asset) => MapEntry(asset.id, asset)),
//       );

//   Asset? get parent => _parentId == null
//       ? null
//       : assets.firstWhereOrNull((asset) => asset.id == _parentId) ??
//           KomodoDefiSdk.global.assets.fromId(_parentId!);

//   Asset get primary => parent ?? assets.first;

//   static List<_AssetGroup> _groupByPrimary(List<Asset> assets) {
//     final groups = <AssetId, List<Asset>>{};

//     for (final asset in assets) {
//       final primaryId = asset.id.parentId ?? asset.id;
//       groups.putIfAbsent(primaryId, () => []).add(asset);
//     }

//     return groups.values.map(_AssetGroup.new).toList();
//   }

//   @override
//   String toString() => 'AssetGroup{primary: $primary, children: $children}';
// }
