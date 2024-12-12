// This file contains a set of extensions used while transitioning KW to the
// KDF SDK.
// NB: These likely will be removed in the future.

import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mutex/mutex.dart';

/// Message used for deprecation warnings
const _deprecatedMessage =
    'This extension/class/method is intended for use while transitioning KW to the KDF SDK. \n'
    'NB: These likely will be removed in the future.';

/// Extension providing deprecated ticker-based asset lookup functionality
/// while transitioning from KW to KDF SDK.
///
/// Example usage:
/// ```dart
/// // Initialize the index
/// await assetManager.initTickerIndex();
///
/// // Look up assets by ticker
/// final btcAssets = assetManager.assetsFromTicker('BTC');
/// print('Found ${btcAssets.length} BTC assets');
///
/// // Access assets across chains
/// for (final asset in btcAssets) {
///   print('${asset.id.name} on ${asset.protocol.subClass.formatted}');
/// }
/// ```
@Deprecated(_deprecatedMessage)
extension AssetTickerIndexExtension on AssetManager {
  static final Map<String, Set<Asset>> _tickerIndex = {};
  static bool _isInitialized = false;
  static final _lock = Mutex();

  /// Initializes the ticker index. Must be called before
  /// using [assetsFromTicker].
  ///
  /// Thread-safe and idempotent - can be called multiple times safely.
  ///
  /// Called as part of KomodoDefiSdk initialization.
  ///
  /// Example:
  /// ```dart
  /// final sdk = KomodoDefiSdk();
  /// await sdk.init();
  /// ```
  Future<void> initTickerIndex() async {
    await _lock.protect(() async {
      if (_isInitialized) return;
      _tickerIndex
        ..clear()
        ..addAll(_buildTickerIndex(availableOrdered.values));
      _isInitialized = true;
    });
  }

  /// Internal method to build the ticker-to-assets index
  Map<String, Set<Asset>> _buildTickerIndex(Iterable<Asset> assets) {
    final index = <String, Set<Asset>>{};
    for (final asset in assets) {
      (index[asset.id.id] ??= {}).add(asset);
    }
    return Map.unmodifiable(index);
  }

  /// Returns all assets matching the given ticker symbol.
  ///
  /// Must call [initTickerIndex] before using this method.
  /// Returns an unmodifiable set to prevent accidental modifications.
  ///
  /// Example:
  /// ```dart
  /// final ethAssets = assetManager.assetsFromTicker('ETH');
  /// final mainnetEth = ethAssets.firstWhere((a) => !a.protocol.isTestnet);
  /// ```
  @Deprecated(_deprecatedMessage)
  Set<Asset> assetsFromTicker(String ticker) {
    assert(
      _isInitialized,
      'Ticker index not initialized. Call initTickerIndex() first.',
    );
    return Set<Asset>.unmodifiable(_tickerIndex[ticker] ?? {});
  }

  /// Cleans up the ticker index. Call when the manager is no longer needed.
  void dispose() {
    _tickerIndex.clear();
    _isInitialized = false;
  }

  // Internal methods for maintaining the index
  // ignore: unused_element
  Future<void> _updateIndex(Asset asset, {bool remove = false}) async {
    if (!_isInitialized) return;
    await _lock.protect(() async {
      _updateTickerIndex(asset, remove: remove);
    });
  }

  void _updateTickerIndex(Asset asset, {bool remove = false}) {
    if (remove) {
      _tickerIndex[asset.id.id]?.remove(asset);
      if (_tickerIndex[asset.id.id]?.isEmpty == true) {
        _tickerIndex.remove(asset.id.id);
      }
    } else {
      (_tickerIndex[asset.id.id] ??= {}).add(asset);
    }
  }
}

/// Shorthand extension for accessing assets by ticker directly from Asset class
@Deprecated(_deprecatedMessage)
extension AssetTickerShortExtension on Asset {
  /// Static helper to find assets by ticker. Optionally accepts a specific
  /// SDK instance. Passing the SDK is recommended if available.
  ///
  /// NB: Currently there are no instances where we have multiple asset IDs with
  /// the same ticker, however this has been the case in the past and may be
  /// in the future again.
  ///
  /// Example:
  /// ```dart
  /// final btcAssets = Asset.byTicker('BTC', _sdk /* sdk is optional, but recommended if available */);
  /// print('Found ${btcAssets.length} BTC assets');
  /// ```
  @Deprecated(_deprecatedMessage)
  static Set<Asset> byTicker(String ticker, [KomodoDefiSdk? sdk]) {
    return (sdk ?? KomodoDefiSdk.global).assets.assetsFromTicker(ticker);
  }
}

/// Extension for backwards compatibility with pubkey operations
@Deprecated(_deprecatedMessage)
extension AssetPubkeysExtension on Asset {
  /// Fetches pubkeys for this asset. Optionally accepts a
  /// specific SDK instance. Passing the SDK is recommended if available.
  ///
  /// Example:
  /// ```dart
  /// final btcAsset = Asset.byTicker('BTC').first;
  /// final pubkeys = await btcAsset.getPubkeys();
  /// print('BTC addresses: ${pubkeys.keys.map((k) => k.address).join(", ")}');
  /// ```
  @Deprecated(_deprecatedMessage)
  Future<AssetPubkeys> getPubkeys([KomodoDefiSdk? sdk]) {
    return (sdk ?? KomodoDefiSdk.global).pubkeys.getPubkeys(this);
  }
}
