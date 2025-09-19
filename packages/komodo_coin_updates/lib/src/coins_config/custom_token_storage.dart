import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Storage for custom tokens that are not part of the official coin configuration.
/// These tokens are persisted independently from the main coin configuration
/// and are not affected by coin config updates.
class CustomTokenStorage implements ICustomTokenStorage {
  /// Creates a custom token storage instance.
  /// [customTokensBoxName] is the name of the Hive box for storing custom tokens.
  /// [customTokensBox] is an optional pre-opened LazyBox for testing/mocking.
  CustomTokenStorage({
    this.customTokensBoxName = 'custom_tokens',
    LazyBox<Asset>? customTokensBox,
    AssetParser assetParser = const AssetParser(),
  }) : _customTokensBox = customTokensBox,
       _assetParser = assetParser;

  static final Logger _log = Logger('CustomTokenStorage');

  /// The name of the Hive box for custom tokens.
  final String customTokensBoxName;

  /// Not final to allow for reopening if closed or in a corrupted state.
  LazyBox<Asset>? _customTokensBox;

  /// The asset parser used to rebuild parent-child relationships.
  final AssetParser _assetParser;

  @override
  Future<void> storeCustomToken(Asset asset) async {
    _log.fine('Storing custom token ${asset.id.id}');
    final box = await _openCustomTokensBox();
    await box.put(asset.id.id, asset);
  }

  @override
  Future<void> storeCustomTokens(List<Asset> assets) async {
    _log.fine('Storing ${assets.length} custom tokens');
    final box = await _openCustomTokensBox();
    final putMap = <String, Asset>{for (final a in assets) a.id.id: a};
    await box.putAll(putMap);
  }

  @override
  Future<List<Asset>> getAllCustomTokens() async {
    _log.fine('Retrieving all custom tokens');
    final box = await _openCustomTokensBox();
    final keys = box.keys;
    final values = await Future.wait(
      keys.map((dynamic key) => box.get(key as String)),
    );

    return _assetParser
        .rebuildParentChildRelationships(
          values.whereType<Asset>(),
          logContext: 'for custom tokens',
        )
        .map(
          (asset) => asset.copyWith(
            // IMPORTANT: This cast to Erc20Protocol is by design for now,
            // as custom tokens are currently only supported for ERC20.
            // This may change in future versions to support other protocols.
            protocol: (asset.protocol as Erc20Protocol).copyWith(
              isCustomToken: true,
            ),
          ),
        )
        .toList();
  }

  @override
  Future<Asset?> getCustomToken(AssetId assetId) async {
    _log.fine('Retrieving custom token ${assetId.id}');
    final box = await _openCustomTokensBox();
    final asset = await box.get(assetId.id);
    return asset?.copyWith(
      // IMPORTANT: This cast to Erc20Protocol is by design for now,
      // as custom tokens are currently only supported for ERC20.
      // This may change in future versions to support other protocols.
      protocol: (asset.protocol as Erc20Protocol).copyWith(isCustomToken: true),
    );
  }

  @override
  Future<bool> hasCustomToken(AssetId assetId) async {
    final box = await _openCustomTokensBox();
    return box.containsKey(assetId.id);
  }

  @override
  Future<void> deleteCustomToken(AssetId assetId) async {
    _log.fine('Deleting custom token ${assetId.id}');
    final box = await _openCustomTokensBox();
    await box.delete(assetId.id);
  }

  @override
  Future<void> deleteCustomTokens(List<AssetId> assetIds) async {
    _log.fine('Deleting ${assetIds.length} custom tokens');
    final box = await _openCustomTokensBox();
    await box.deleteAll(assetIds.map((id) => id.id));
  }

  @override
  Future<void> deleteAllCustomTokens() async {
    _log.fine('Deleting all custom tokens');
    final box = await _openCustomTokensBox();
    await box.clear();
  }

  @override
  Future<bool> hasCustomTokens() async {
    final boxExists = await Hive.boxExists(customTokensBoxName);
    if (!boxExists) {
      return false;
    }

    final box = await _openCustomTokensBox();
    return box.isNotEmpty;
  }

  @override
  Future<bool> updateCustomToken(Asset asset) async {
    final box = await _openCustomTokensBox();
    final existed = box.containsKey(asset.id.id);
    await box.put(asset.id.id, asset);

    if (existed) {
      _log.fine('Updated existing custom token ${asset.id.id}');
    } else {
      _log.fine('Stored new custom token ${asset.id.id}');
    }

    return existed;
  }

  @override
  Future<bool> addCustomTokenIfNotExists(Asset asset) async {
    final box = await _openCustomTokensBox();
    if (box.containsKey(asset.id.id)) {
      _log.fine('Custom token ${asset.id.id} already exists, skipping');
      return false;
    }

    await box.put(asset.id.id, asset);
    _log.fine('Added new custom token ${asset.id.id}');
    return true;
  }

  @override
  Future<int> getCustomTokenCount() async {
    final box = await _openCustomTokensBox();
    return box.length;
  }

  @override
  Future<void> dispose() async {
    if (_customTokensBox != null) {
      _log.fine('Closing custom tokens box');
      await _customTokensBox!.close();
      _customTokensBox = null;
    }
  }

  Future<LazyBox<Asset>> _openCustomTokensBox() async {
    if (_customTokensBox == null || !_customTokensBox!.isOpen) {
      _log.fine('Opening custom tokens box "$customTokensBoxName"');
      try {
        _customTokensBox = await Hive.openLazyBox<Asset>(customTokensBoxName);
      } catch (e) {
        _log.warning('Failed to open custom tokens box, retrying: $e');
        // If the box is in a corrupted state, try to delete and recreate
        if (await Hive.boxExists(customTokensBoxName)) {
          await _customTokensBox?.close();
        }
        _customTokensBox = await Hive.openLazyBox<Asset>(customTokensBoxName);
      }
    }

    return _customTokensBox!;
  }
}
