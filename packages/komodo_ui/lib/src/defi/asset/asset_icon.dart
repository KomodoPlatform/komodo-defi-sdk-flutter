import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A widget that displays an icon for a given [AssetId].
///
/// The icon is first looked up in the local assets, then falls back to a CDN,
/// and finally displays a generic icon if neither source has the icon.
class AssetIcon extends StatelessWidget {
  /// Creates an [AssetIcon] widget that displays an icon for the given [AssetId].
  /// This is the preferred constructor as it provides type safety and additional
  /// metadata about the asset.
  const AssetIcon(
    this.assetId, {
    this.size = 20,
    this.suspended = false,
    super.key,
  }) : _legacyTicker = null;

  /// Legacy constructor that accepts a ticker/abbreviation string.
  /// Provided for backwards compatibility with [CoinIcon].
  ///
  /// Consider migrating to the default constructor with [AssetId] for better
  /// type safety and asset metadata support.
  ///
  /// NB! This will likely be deprecated in the future.
  AssetIcon.ofTicker(
    String ticker, {
    this.size = 20,
    this.suspended = false,
    super.key,
  })  : _legacyTicker = ticker.toLowerCase(),
        assetId = null;

  final AssetId? assetId;
  final String? _legacyTicker;
  final double size;
  final bool suspended;

  String get _effectiveId => assetId?.id ?? _legacyTicker!;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: suspended ? 0.4 : 1,
      child: SizedBox.square(
        dimension: size,
        child: _AssetIconResolver(
          key: ValueKey(_effectiveId),
          assetId: _effectiveId,
          size: size,
        ),
      ),
    );
  }

  /// Clears all caches used by [AssetIcon]
  static void clearCaches() {
    _AssetIconResolver.clearCaches();
  }

  /// Pre-loads the asset icon image into the cache.
  ///
  /// This is useful when you know you'll need an icon soon and want to avoid
  /// a loading delay.
  ///
  /// Set [throwExceptions] to true if you want to handle caching errors.
  static Future<void> precacheAssetIcon(
    BuildContext context,
    AssetId asset, {
    bool throwExceptions = false,
  }) {
    return _AssetIconResolver.precacheAssetIcon(
      context,
      asset,
      throwExceptions: throwExceptions,
    );
  }
}

class _AssetIconResolver extends StatelessWidget {
  const _AssetIconResolver({
    required this.assetId,
    required this.size,
    super.key,
  });

  final String assetId;
  final double size;

  static const _coinImagesFolder =
      'packages/komodo_defi_framework/assets/coin_icons/png/';
  static const _mediaCdnUrl = 'https://komodoplatform.github.io/coins/icons/';

  static final Map<String, bool> _assetExistenceCache = {};
  static final Map<String, bool> _cdnExistenceCache = {};

  static void clearCaches() {
    _assetExistenceCache.clear();
    _cdnExistenceCache.clear();
  }

  String get _sanitizedId =>
      AssetSymbol.symbolFromConfigId(assetId).toLowerCase();
  String get _imagePath => '$_coinImagesFolder$_sanitizedId.png';
  String get _cdnUrl => '$_mediaCdnUrl$_sanitizedId.png';

  static Future<void> precacheAssetIcon(
    BuildContext context,
    AssetId asset, {
    bool throwExceptions = false,
  }) async {
    final resolver = _AssetIconResolver(assetId: asset.id, size: 20);
    final sanitizedId = resolver._sanitizedId;

    try {
      bool? assetExists;
      bool? cdnExists;

      final assetImage = AssetImage(resolver._imagePath);
      final cdnImage = NetworkImage(resolver._cdnUrl);

      assetExists = true;
      await precacheImage(
        assetImage,
        context,
        onError: (e, stackTrace) {
          assetExists = false;
          if (throwExceptions) {
            throw Exception(
              'Failed to pre-cache image for asset ${asset.id}: $e',
            );
          }
        },
      );

      if (context.mounted) {
        cdnExists = true;
        await precacheImage(
          cdnImage,
          context,
          onError: (e, stackTrace) {
            cdnExists = false;
            if (throwExceptions) {
              throw Exception(
                'Failed to pre-cache CDN image for asset ${asset.id}: $e',
              );
            }
          },
        );
      }

      _assetExistenceCache[resolver._imagePath] = assetExists ?? false;
      if (cdnExists != null) _cdnExistenceCache[sanitizedId] = cdnExists!;
    } catch (e) {
      debugPrint('Error in precacheAssetIcon for ${asset.id}: $e');
      if (throwExceptions) rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    _assetExistenceCache[_imagePath] = true;
    return Image.asset(
      _imagePath,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        _assetExistenceCache[_imagePath] = false;
        _cdnExistenceCache[_sanitizedId] ??= true;

        return Image.network(
          _cdnUrl,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            _cdnExistenceCache[_sanitizedId] = false;
            return Icon(Icons.monetization_on_outlined, size: size);
          },
        );
      },
    );
  }
}
