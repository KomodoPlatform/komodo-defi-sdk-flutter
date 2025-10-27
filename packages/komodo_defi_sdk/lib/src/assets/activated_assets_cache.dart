import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Cache for the activated assets list with a configurable TTL.
///
/// This cache reduces repeated `get_enabled_coins` RPC calls by memoizing the
/// activated assets for a short duration. It automatically invalidates when
/// the signed-in wallet changes or when explicitly cleared.
class ActivatedAssetsCache {
  /// Creates a new cache instance.
  ActivatedAssetsCache({
    required ApiClient client,
    required KomodoDefiLocalAuth auth,
    required IAssetLookup assetLookup,
    Duration ttl = const Duration(seconds: 2),
    DateTime Function() clock = DateTime.now,
  }) : _client = client,
       _auth = auth,
       _assetLookup = assetLookup,
       _ttl = ttl,
       _clock = clock {
    _authSubscription = _auth.authStateChanges.listen((_) => invalidate());
  }

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final IAssetLookup _assetLookup;
  final Duration _ttl;
  final DateTime Function() _clock;

  List<Asset>? _cache;
  DateTime? _lastFetchAt;
  Future<List<Asset>>? _pendingFetch;
  StreamSubscription<KdfUser?>? _authSubscription;
  bool _isDisposed = false;

  /// Returns the cached activated assets, refreshing when the TTL has expired
  /// or when [forceRefresh] is true.
  Future<List<Asset>> getActivatedAssets({bool forceRefresh = false}) async {
    _assertNotDisposed();

    if (forceRefresh) {
      invalidate();
    }

    if (_hasValidCache) {
      return _cache!;
    }

    final inflight = _pendingFetch;
    if (inflight != null) {
      return inflight;
    }

    final future = _fetchActivatedAssets();
    _pendingFetch = future;
    try {
      final assets = await future;
      _cache = assets;
      _lastFetchAt = _clock();
      return assets;
    } finally {
      if (identical(_pendingFetch, future)) {
        _pendingFetch = null;
      }
    }
  }

  /// Returns the activated [AssetId] set, refreshing as needed.
  Future<Set<AssetId>> getActivatedAssetIds({bool forceRefresh = false}) async {
    final assets = await getActivatedAssets(forceRefresh: forceRefresh);
    return assets.map((asset) => asset.id).toSet();
  }

  /// Clears the current cache forcing the next lookup to hit the network.
  void invalidate() {
    _cache = null;
    _lastFetchAt = null;
    _pendingFetch = null;
  }

  /// Disposes the cache, cancelling auth subscriptions and clearing state.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _authSubscription?.cancel();
    invalidate();
  }

  Future<List<Asset>> _fetchActivatedAssets() async {
    if (!await _auth.isSignedIn()) return const [];

    final response = await _client.rpc.generalActivation.getEnabledCoins();

    final assets = <Asset>[];
    final seen = <AssetId>{};
    for (final coin in response.result) {
      for (final asset in _assetLookup.findAssetsByConfigId(coin.ticker)) {
        if (seen.add(asset.id)) {
          assets.add(asset);
        }
      }
    }

    return assets;
  }

  bool get _hasValidCache {
    if (_ttl == Duration.zero) return false;
    if (_cache == null || _lastFetchAt == null) return false;
    return _clock().difference(_lastFetchAt!) <= _ttl;
  }

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('ActivatedAssetsCache has been disposed');
    }
  }
}
