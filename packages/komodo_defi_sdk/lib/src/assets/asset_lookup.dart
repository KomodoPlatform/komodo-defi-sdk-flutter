// lib/src/assets/asset_lookup.dart

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Interface for looking up assets in the system
abstract class IAssetLookup {
  /// Get all available assets
  Map<AssetId, Asset> get available;

  /// Find assets by ticker symbol
  Set<Asset> findAssetsByConfigId(String ticker);

  /// Get an asset by its ID
  Asset? fromId(AssetId id);

  /// Get child assets for a given parent asset
  Set<Asset> childAssetsOf(AssetId parentId);
}

/// Defines asset lookup capabilities with additional async methods
abstract class IAssetProvider extends IAssetLookup {
  /// Get list of currently activated assets
  Future<List<Asset>> getActivatedAssets();

  /// Get list of enabled coin tickers
  Future<Set<String>> getEnabledCoins();
}
