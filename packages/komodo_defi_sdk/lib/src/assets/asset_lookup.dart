// lib/src/assets/asset_lookup.dart

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Interface defining asset lookup capabilities
abstract class IAssetLookup {
  /// Find an asset by its ID
  Asset? fromId(AssetId id);

  /// Find assets by ticker symbol
  Set<Asset> findAssetsByTicker(String ticker);

  /// Get child assets for a parent asset ID
  Set<Asset> childAssetsOf(AssetId parentId);

  /// Get all available assets
  Map<AssetId, Asset> get available;
}

/// Defines asset lookup capabilities with additional async methods
abstract class IAssetProvider extends IAssetLookup {
  /// Get list of currently activated assets
  Future<List<Asset>> getActivatedAssets();

  /// Get list of enabled coin tickers
  Future<Set<String>> getEnabledCoins();
}
