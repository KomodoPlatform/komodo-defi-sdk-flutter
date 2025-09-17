import 'package:collection/collection.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Internal class for grouping related assets by their parent-child relationships.
///
/// This class organizes assets into hierarchical groups where:
/// - Each group has one primary asset (the parent)
/// - Child assets (tokens, derivatives) are grouped under their parent
/// - Assets without parents form their own groups
///
/// For example:
/// - BNB (primary) with USDT-BEP20, CAKE-BEP20 (children)
/// - ETH (primary) with USDT-ERC20, DAI-ERC20 (children)
/// - BTC (primary) with no children
///
/// This grouping is essential for activation coordination, as child assets
/// typically require their parent to be activated first.
class AssetGroup {
  /// Creates an asset group with a primary asset and optional children.
  ///
  /// [primary] - The main asset of this group (parent asset).
  /// [children] - Optional set of child assets that depend on the primary.
  ///
  /// Throws an [AssertionError] if any child asset's parent ID doesn't
  /// match the primary asset's ID.
  AssetGroup({required this.primary, this.children})
    : assert(
        children == null ||
            children.every((asset) => asset.id.parentId == primary.id),
        'All child assets must have the parent asset as their parent '
        'primary  ${primary.id}, child assets: $children',
      );

  /// The primary (parent) asset of this group.
  ///
  /// This asset serves as the foundation for the group and must be activated
  /// before any of its children can be activated.
  final Asset primary;

  /// Optional set of child assets that depend on the primary asset.
  ///
  /// These are typically tokens or derivatives that require the primary
  /// asset to be active. Will be `null` if there are no child assets.
  final Set<Asset>? children;

  /// Gets the parent ID from the first child asset, if any.
  ///
  /// This is primarily used for validation purposes. Returns `null` if
  /// there are no children or no child assets have a parent relationship.
  AssetId? get parentId =>
      children?.firstWhereOrNull((asset) => asset.id.isChildAsset)?.id.parentId;

  static final _logger = Logger('AssetGroup');

  /// Groups a list of assets by their primary (parent) assets.
  ///
  /// This method organizes assets into hierarchical groups where each group
  /// contains a primary asset and its child assets. Assets without parents
  /// form their own groups.
  ///
  /// [assets] - The list of assets to group.
  /// [assetLookup] - Lookup service to find parent assets when needed.
  ///
  /// Returns a list of [AssetGroup] objects, each containing a primary asset
  /// and its associated children.
  ///
  /// The algorithm:
  /// 1. Primary assets (no parent) create new groups
  /// 2. Child assets are added to their parent's group
  /// 3. If a parent isn't in the input list, it's looked up via [assetLookup]
  /// 4. Child assets without findable parents are skipped with a warning
  ///
  /// Example:
  /// ```dart
  /// final assets = [bnb, usdtBep20, eth, usdtErc20];
  /// final groups = AssetGroup.groupByPrimary(assets, lookup);
  /// // Results in 2 groups:
  /// // - BNB group with USDT-BEP20 child
  /// // - ETH group with USDT-ERC20 child
  /// ```
  static List<AssetGroup> groupByPrimary(
    List<Asset> assets,
    IAssetLookup assetLookup,
  ) {
    _logger.info('Grouping ${assets.length} assets by primary');
    final groups = <AssetId, AssetGroup>{};

    for (final asset in assets) {
      if (asset.id.parentId == null) {
        // Primary asset. Preserve any previously added children.
        final existing = groups[asset.id];
        groups[asset.id] = AssetGroup(
          primary: asset,
          children: existing?.children,
        );
      } else {
        // Child asset - look up the parent using asset lookup
        final parentId = asset.id.parentId!;
        final existing = groups[parentId];

        if (existing == null) {
          final parentAsset = assetLookup.fromId(parentId);
          if (parentAsset == null) {
            _logger.warning(
              'Parent asset ${parentId.name} not found in asset lookup, '
              'skipping child ${asset.id.name}',
            );
            continue;
          }

          // Create new group with the looked-up parent as primary
          groups[parentId] = AssetGroup(
            primary: parentAsset,
            children: {asset},
          );
        } else if (existing.children == null) {
          groups[parentId] = AssetGroup(
            primary: existing.primary,
            children: {asset},
          );
        } else {
          existing.children!.add(asset);
        }
      }
    }

    final groupCount = groups.length;
    final totalAssets = groups.values
        .map((g) => 1 + (g.children?.length ?? 0))
        .fold<int>(0, (a, b) => a + b);

    _logger.info(
      'Created $groupCount asset groups containing $totalAssets total assets',
    );

    return groups.values.toList();
  }
}
